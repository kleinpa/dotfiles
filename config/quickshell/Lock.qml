import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick
import QtQuick.Layouts

// Session lock, replacing swaylock. ext-session-lock-v1 keeps the compositor
// locked even if this client dies, so a crash leaves a blank locked screen
// rather than an unlocked desktop.
//
// Authentication is two PAM conversations raced against each other, the way
// GDM does it: pam_unix waiting on the password field, and pam_fprintd
// waiting on the reader. One stack cannot do both -- whichever module comes
// first blocks the other -- so each gets its own service file in pam/, which
// PamContext loads through pam_start_confdir rather than /etc/pam.d.
//
// All of that state lives here rather than on the surface: the surface is
// instantiated once per output, and two monitors must not mean two
// fingerprint conversations fighting over the reader. A Scope rather than the
// lock itself, because WlSessionLock's only child slot is `surface` -- a
// PamContext nested in it is silently dropped, and the lock screen just
// never authenticates.
Scope {
  id: sessionLock

  readonly property bool locked: Session.locked

  // Under the field: a password result, or what the reader wants.
  property string status: ""
  property bool statusIsError: false

  // The reader is the exception, not the rule: most machines running this
  // config have none, and on those the fingerprint half must be invisible --
  // no glyph, no message, no pam_fprintd erroring on a loop. `available` is
  // therefore false until a probe finds enrolled prints, every time the
  // screen locks, so enrolling later is picked up.
  property bool fingerprintAvailable: false
  // False while the display is off or the machine is asleep, from swayidle
  // through the lock IPC target. A verify does not survive suspend, and there
  // is no point holding the reader open in an empty room.
  property bool awake: true
  // A round is one pam_fprintd conversation: max-tries misses. Bounded, so a
  // bag brushing the sensor all night cannot keep the reader live forever;
  // any keypress or wake resets it.
  property int rounds: 0
  readonly property int maxRounds: 5
  readonly property bool listening: fingerprintPam.active
  // The last thing the reader said was a miss. Separate from statusIsError so
  // a wrong password does not paint the glyph red.
  property bool missed: false

  property string pending: ""

  onLockedChanged: {
    if (sessionLock.locked) {
      sessionLock.status = "";
      sessionLock.statusIsError = false;
      sessionLock.rounds = 0;
      sessionLock.fingerprintAvailable = false;
      fingerprintProbe.running = true;
    } else {
      if (fingerprintPam.active) fingerprintPam.abort();
      if (passwordPam.active) passwordPam.abort();
    }
  }

  function unlock(): void {
    // Abort the loser first so fprintd releases the device before the screen
    // goes; otherwise the next lock's probe can find it still claimed.
    if (fingerprintPam.active) fingerprintPam.abort();
    if (passwordPam.active) passwordPam.abort();
    sessionLock.status = "";
    Session.locked = false;
  }

  function authenticate(password: string): void {
    if (passwordPam.active || password === "") return;
    sessionLock.pending = password;
    sessionLock.status = "";
    sessionLock.statusIsError = false;
    passwordPam.start();
  }

  function sleep(): void {
    sessionLock.awake = false;
    if (fingerprintPam.active) fingerprintPam.abort();
  }

  function wake(): void {
    sessionLock.awake = true;
    sessionLock.rounds = 0;
    sessionLock.listen();
  }

  function listen(): void {
    if (!sessionLock.locked || !sessionLock.fingerprintAvailable
        || !sessionLock.awake || fingerprintPam.active) return;
    if (sessionLock.rounds >= sessionLock.maxRounds) {
      sessionLock.status = "fingerprint paused, press any key";
      sessionLock.statusIsError = false;
      return;
    }
    sessionLock.rounds += 1;
    sessionLock.missed = false;
    fingerprintPam.start();
  }

  // `fprintd-list` prints one " - #n: finger" line per enrolled print, and
  // errors (or does not exist) everywhere else. Wrapped in sh so a machine
  // without fprintd still runs *something* and the collector finishes.
  Process {
    id: fingerprintProbe
    command: [
      "sh", "-c",
      "command -v fprintd-list >/dev/null 2>&1 && fprintd-list \"$USER\" 2>/dev/null"
    ]
    stdout: StdioCollector {
      onStreamFinished: {
        sessionLock.fingerprintAvailable = /^ - #/m.test(this.text);
        sessionLock.listen();
      }
    }
  }

  PamContext {
    id: passwordPam
    configDirectory: "pam"
    config: "password"

    onPamMessage: {
      if (passwordPam.responseRequired) passwordPam.respond(sessionLock.pending);
    }

    onCompleted: result => {
      sessionLock.pending = "";
      if (result === PamResult.Success) {
        sessionLock.unlock();
      } else {
        sessionLock.status = "wrong password";
        sessionLock.statusIsError = true;
      }
    }

    onError: {
      sessionLock.pending = "";
      sessionLock.status = "authentication error";
      sessionLock.statusIsError = true;
    }
  }

  PamContext {
    id: fingerprintPam
    configDirectory: "pam"
    config: "fingerprint"

    // pam_fprintd talks in prompts -- "Place your finger on the reader",
    // "Failed to match fingerprint" -- none of which want an answer. Only the
    // errors are worth words; the glyph in the field says the reader is
    // listening, and it says so without a sentence under the clock.
    onPamMessage: {
      if (fingerprintPam.responseRequired) {
        fingerprintPam.respond("");
        return;
      }
      sessionLock.missed = fingerprintPam.messageIsError;
      if (fingerprintPam.messageIsError) {
        sessionLock.status = fingerprintPam.message;
        sessionLock.statusIsError = true;
      }
    }

    onCompleted: result => {
      if (result === PamResult.Success) {
        sessionLock.unlock();
        return;
      }
      // Three misses. Go again, after a beat so a wedged reader cannot spin.
      relisten.restart();
    }

    // The reader went away, or fprintd would not give it up: stop asking, and
    // stop showing a glyph for something that does not work.
    onError: {
      sessionLock.fingerprintAvailable = false;
      if (!sessionLock.statusIsError) sessionLock.status = "";
    }
  }

  Timer {
    id: relisten
    interval: 300
    onTriggered: sessionLock.listen()
  }

  WlSessionLock {
    locked: Session.locked

    surface: WlSessionLockSurface {
      id: lockSurface

      color: Theme.base

      // The desktop wallpaper behind the form. sourceSize keeps Qt from decoding
      // the full 5k image into memory for a surface this size.
      Image {
        anchors.fill: parent
        source: "file://" + Theme.wallpaper
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: lockSurface.width
        sourceSize.height: lockSurface.height
        asynchronous: true
      }

      Rectangle {
        anchors.fill: parent
        color: Theme.scrim
      }

      // The corner of the bar that still matters while locked: what is playing,
      // whether the machine is online, and how much battery is left. Readouts
      // only -- the media keys keep working through sway's --locked bindings, so
      // nothing here needs to be a button.
      Rectangle {
        id: lockStub
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        implicitWidth: lockChips.implicitWidth + 6
        implicitHeight: Theme.barHeight
        color: Theme.ground
        topLeftRadius: Theme.menuRadius

        RowLayout {
          id: lockChips
          anchors.centerIn: parent
          spacing: 5

          MediaChip {}

          NetworkChip { brief: true }

          BatteryChip {}
        }
      }

      ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.28
        spacing: 4

        MonoText {
          Layout.alignment: Qt.AlignHCenter
          text: Qt.formatDateTime(lockClock.date, "HH:mm")
          font.pixelSize: 56
        }

        MonoText {
          Layout.alignment: Qt.AlignHCenter
          text: Qt.formatDateTime(lockClock.date, "dddd yyyy-MM-dd")
          color: Theme.muted
          font.pixelSize: 16
        }
      }

      Rectangle {
        id: lockField
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.52
        width: 320
        height: 44
        radius: Theme.menuRadius
        // The same translucent dark the bar's dropdowns use.
        color: Theme.ground

        TextInput {
          id: lockInput
          anchors.fill: parent
          anchors.leftMargin: 14
          // Room for the fingerprint glyph, whether or not it is showing, so the
          // field does not reflow when the probe comes back.
          anchors.rightMargin: 36
          verticalAlignment: TextInput.AlignVCenter
          echoMode: TextInput.Password
          passwordCharacter: "•"
          enabled: !passwordPam.active
          color: Theme.text
          font.family: Theme.mono
          font.pixelSize: 16
          focus: true

          // Any key counts as someone being here: re-arm a paused reader.
          Keys.onPressed: sessionLock.wake()
          Keys.onReturnPressed: sessionLock.authenticate(lockInput.text)
          Keys.onEnterPressed: sessionLock.authenticate(lockInput.text)
        }

        // Only ever on screen once a probe has found enrolled prints. White
        // while the reader listens, red after a miss, dim while paused.
        Icon {
          anchors.right: parent.right
          anchors.rightMargin: 14
          anchors.verticalCenter: parent.verticalCenter
          visible: sessionLock.fingerprintAvailable
          name: "auth-fingerprint-symbolic"
          size: 18
          color: !sessionLock.listening ? Theme.muted
               : sessionLock.missed ? Theme.crit
               : Theme.text
          opacity: sessionLock.listening ? 1 : 0.35
        }

        // Both fields belong to the one conversation that won; clear every
        // output's copy of the field whichever way the lock ends.
        Connections {
          target: sessionLock
          function onLockedChanged(): void { lockInput.text = ""; }
        }
        Connections {
          target: passwordPam
          function onCompleted(): void { lockInput.text = ""; }
        }
      }

      MonoText {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: lockField.bottom
        anchors.topMargin: 14
        text: passwordPam.active ? "checking" : sessionLock.status
        color: sessionLock.statusIsError ? Theme.crit : Theme.muted
        font.pixelSize: 13
      }

      SystemClock {
        id: lockClock
        precision: SystemClock.Seconds
      }
    }
  }
}
