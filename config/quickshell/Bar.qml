pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.I3
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

// One layer surface per output, carrying the bar strip and every dropdown that
// hangs off it. A single window rather than one per panel: two overlapping
// translucent surfaces composite to a visible seam where they meet. The window
// itself paints nothing -- the strip and each panel draw their own ground, so
// there is only ever one translucent layer over any pixel.
PanelWindow {
  id: bar

  required property var modelData
  screen: bar.modelData

  // The bar belongs on every output, but the dropdowns are nested inside it and
  // share one Session.openMenu, so without this each monitor would show its own
  // copy of whichever menu is open.
  readonly property bool focused:
    I3.focusedMonitor !== null && I3.focusedMonitor.name === bar.modelData.name

  readonly property var sink: Pipewire.defaultAudioSink

  // The window is tall enough for the tallest panel whether or not one is
  // open, and only ever grows. Resizing it as menus open and close -- and on
  // every keystroke in a picker, as its list shrinks -- shows a frame of the
  // old buffer at the new geometry. The window is transparent and the mask
  // below keeps input off the empty part, so the extra height costs nothing.
  readonly property int menuExtent: Math.max(
    launcher.panelHeight, powerMenu.panelHeight, keymapPanel.panelHeight,
    musicPicker.panelHeight, audioPanel.panelHeight, netPanel.panelHeight)
  property int windowExtent: bar.menuExtent
  onMenuExtentChanged: if (bar.menuExtent > bar.windowExtent) bar.windowExtent = bar.menuExtent

  anchors { top: true; left: true; right: true }
  WlrLayershell.namespace: "quickshell-bar"
  // Top normally, so the bar stays under fullscreen windows. While a menu is
  // open it rises to Overlay, so the launcher and its panel are usable over a
  // fullscreen client -- and drops straight back.
  WlrLayershell.layer: Session.openMenu !== "" ? WlrLayer.Overlay : WlrLayer.Top
  // The merged window is the only surface, so keyboard focus lives here. Taken
  // only while a menu is open on this output, and released the moment it is
  // dismissed -- holding an exclusive grab open locks the desktop.
  WlrLayershell.keyboardFocus: Session.openMenu !== "" && bar.focused
                               ? WlrKeyboardFocus.Exclusive
                               : WlrKeyboardFocus.None
  exclusionMode: ExclusionMode.Normal
  // Only the bar strip reserves space; the dropdown overhangs the windows.
  exclusiveZone: Theme.barHeight
  implicitHeight: Theme.barHeight + bar.windowExtent
  color: "transparent"

  // A menu that loses keyboard focus closes. Sway bindings still fire under the
  // exclusive grab -- $mod+j moves focus to a window and the menu is left
  // standing, dead, with its own key now needing two presses to bring it
  // back. Qt marks a Wayland window active for exactly as long as it holds the
  // wl_keyboard, so that going false is the menu losing focus, whatever took
  // it. Also fires when the focused output changes, so a menu closes instead
  // of hopping to the other monitor's bar.
  Item {
    id: focusWatch
    readonly property bool hasKeyboard: Window.active
    onHasKeyboardChanged: {
      if (!focusWatch.hasKeyboard && Session.openMenu !== "") Session.openMenu = "";
    }
  }

  // Click-away. The bar window is only as tall as its dropdowns and masked to
  // them, so a click anywhere else would land on the desktop and leave the
  // menu up. While one is open this covers the output a layer below the bar
  // (which is on Overlay for the duration), paints nothing, and closes the
  // menu on any press. The press is swallowed rather than passed through, the
  // way a popover's is. One per output, so a click on any monitor closes it.
  LazyLoader {
    active: Session.openMenu !== ""

    PanelWindow {
      screen: bar.modelData
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.namespace: "quickshell-backdrop"
      WlrLayershell.layer: WlrLayer.Top
      color: "transparent"

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onPressed: Session.openMenu = ""
      }
    }
  }

  // Input lands on the bar strip plus whichever panel is open, so clicks
  // elsewhere in the tall window reach the desktop underneath. Each nested
  // region is zero-sized unless its panel is on screen.
  mask: Region {
    width: bar.width
    height: Theme.barHeight

    Region {
      x: launcher.x; y: launcher.y
      width: launcher.dropWidth; height: launcher.dropHeight
    }
    Region {
      x: powerMenu.x; y: powerMenu.y
      width: powerMenu.dropWidth; height: powerMenu.dropHeight
    }
    Region {
      x: keymapPanel.x; y: keymapPanel.y
      width: keymapPanel.dropWidth; height: keymapPanel.dropHeight
    }
    Region {
      x: musicPicker.x; y: musicPicker.y
      width: musicPicker.dropWidth; height: musicPicker.dropHeight
    }
    Region {
      x: audioPanel.x; y: audioPanel.y
      width: audioPanel.dropWidth; height: audioPanel.dropHeight
    }
    Region {
      x: netPanel.x; y: netPanel.y
      width: netPanel.dropWidth; height: netPanel.dropHeight
    }
  }

  // The bar strip itself. Bar content anchors to this rather than to the
  // window, which is as tall as the open dropdown.
  Rectangle {
    id: barStrip
    anchors { top: parent.top; left: parent.left; right: parent.right }
    height: Theme.barHeight
    color: Theme.ground
  }

  // Three independently anchored rows, so the sections cannot fight over slack
  // the way a single RowLayout with spacers does. The clock owns the centre:
  // each side row is capped at the room between its edge and the clock, and
  // when that is short only its elidable text gives way -- every chip keeps
  // its natural width, so the squeeze lands on the window title on the left
  // and the track title on the right.
  readonly property int edgeMargin: 7
  readonly property int sideWidth:
    (barStrip.width - clockText.width) / 2 - bar.edgeMargin - 10

  // left ---------------------------------------------------------------
  RowLayout {
    anchors.left: barStrip.left
    anchors.leftMargin: bar.edgeMargin
    anchors.verticalCenter: barStrip.verticalCenter
    width: Math.min(implicitWidth, bar.sideWidth)
    spacing: 6

    RowLayout {
      spacing: 5

      Repeater {
        model: I3.workspaces

        Rectangle {
          id: wsChip
          required property var modelData

          // Per-output, as swaybar does it. Filtering the model instead would
          // not re-evaluate when a workspace moves between outputs; a binding
          // on each chip does. i3 and sway keep their internal workspaces
          // (the scratchpad) in the same list, hence the name check.
          visible: !wsChip.modelData.name.startsWith("__")
                   && (!wsChip.modelData.monitor
                       || wsChip.modelData.monitor.name === bar.modelData.name)

          implicitWidth: Math.max(20, wsLabel.implicitWidth + 8)
          implicitHeight: 20
          Layout.preferredWidth: implicitWidth
          Layout.preferredHeight: implicitHeight
          radius: Theme.radius
          color: wsChip.modelData.urgent ? Theme.crit
               : wsChip.modelData.focused ? Theme.chipActive
               : wsChipArea.containsMouse ? Theme.chipHover
               : Theme.chip

          Behavior on color { ColorAnimation { duration: 150 } }

          MonoText {
            id: wsLabel
            anchors.centerIn: parent
            text: wsChip.modelData.name
            opacity: wsChip.modelData.focused ? 1.0 : 0.65

            Behavior on opacity { NumberAnimation { duration: 150 } }
          }

          MouseArea {
            id: wsChipArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: wsChip.modelData.activate()
          }
        }
      }
    }

    // wlr-foreign-toplevel rather than an i3 tree query: sway implements it,
    // and it updates on its own instead of needing a poll.
    MonoText {
      // fillWidth so the row may shrink it; the row is never wider than its
      // content, so it cannot grow past the cap.
      Layout.fillWidth: true
      Layout.maximumWidth: 260
      elide: Text.ElideRight
      text: ToplevelManager.activeToplevel ? ToplevelManager.activeToplevel.title : ""
      color: Theme.subtle
    }
  }

  // centre -------------------------------------------------------------
  MonoText {
    id: clockText
    anchors.horizontalCenter: barStrip.horizontalCenter
    anchors.verticalCenter: barStrip.verticalCenter
    text: Qt.formatDateTime(clock.date, "dddd yyyy-MM-dd HH:mm")
    color: Theme.muted
  }

  // right --------------------------------------------------------------
  RowLayout {
    anchors.right: barStrip.right
    anchors.rightMargin: bar.edgeMargin
    anchors.verticalCenter: barStrip.verticalCenter
    width: Math.min(implicitWidth, bar.sideWidth)
    // Two adjacent chips each contribute their own pixel of surrounding pad,
    // so neighbours sit 2px further apart than a chip does from the edge.
    spacing: 5

    // media: green while playing, plain when paused. Left toggles, right
    // skips, middle goes back.
    MediaChip {
      interactive: true
      buttons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
      onClicked: button => {
        if (button === Qt.LeftButton) Player.togglePlaying();
        else if (button === Qt.RightButton) Player.next();
        else Player.previous();
      }
    }

    // audio: "00% (speaker)"; grey when muted. Left opens the picker, right
    // toggles mute, wheel adjusts volume.
    Chip {
      buttons: Qt.LeftButton | Qt.RightButton
      onWheel: delta => {
        if (!bar.sink || !bar.sink.audio) return;
        const step = delta > 0 ? 0.01 : -0.01;
        bar.sink.audio.volume = Math.max(0, Math.min(1, bar.sink.audio.volume + step));
      }
      onClicked: button => {
        if (button === Qt.RightButton) {
          if (bar.sink && bar.sink.audio) bar.sink.audio.muted = !bar.sink.audio.muted;
        } else {
          Session.toggleMenu("audio");
        }
      }
      accent: bar.sink && bar.sink.audio && bar.sink.audio.muted
              ? Theme.mutedTint : "transparent"

      MonoText {
        text: {
          if (!bar.sink || !bar.sink.audio) return "--%";
          if (bar.sink.audio.muted) return "";
          return Math.round(bar.sink.audio.volume * 100) + "%";
        }
      }

      // The same thresholds GNOME's volume indicator uses, with the extra
      // step above 100% for a sink pushed past its nominal maximum.
      Icon {
        name: {
          if (!bar.sink || !bar.sink.audio || bar.sink.audio.muted) return "audio-volume-muted-symbolic";
          const v = bar.sink.audio.volume;
          return v > 1 ? "audio-volume-overamplified-symbolic"
               : v > 0.66 ? "audio-volume-high-symbolic"
               : v > 0.33 ? "audio-volume-medium-symbolic"
               : v > 0 ? "audio-volume-low-symbolic"
               : "audio-volume-muted-symbolic";
        }
        color: bar.sink && bar.sink.audio && bar.sink.audio.muted ? Theme.muted : Theme.text
      }
    }

    // network: "ssid 00% (bars) (vpn)"; red when disconnected
    NetworkChip {
      interactive: true
      onClicked: Session.toggleMenu("network")
    }

    // perf: "00% (cpu) 1/8 (mem)". Not interactive, so no hover.
    Chip {
      interactive: false

      MonoText {
        text: Math.round(SysInfo.cpuPercent) + "%"
        color: SysInfo.cpuPercent > 85 ? Theme.crit : Theme.text
      }

      // Adwaita has no cpu icon as such; the performance gauge is the nearest
      // it comes, and it stands for the whole chip -- "x/y" beside it is
      // recognisably memory without a second icon.
      Icon { name: "power-profile-performance-symbolic" }

      MonoText {
        text: SysInfo.memUsedGb.toFixed(0) + "/" + SysInfo.memTotalGb.toFixed(0)
        color: SysInfo.memPercent > 85 ? Theme.crit : Theme.text
      }
    }

    // power: "50% 2h 5w" on battery, green while charging, red when low.
    BatteryChip {
      interactive: true
      onClicked: Session.toggleMenu("power")
    }

    // tray last, matching the waybar config. An empty RowLayout still takes a
    // slot and its share of the parent's spacing, so hide it outright when
    // nothing is in the tray.
    RowLayout {
      spacing: 8
      visible: SystemTray.items.values.length > 0

      Repeater {
        model: SystemTray.items

        Image {
          id: trayIcon
          required property var modelData

          source: trayIcon.modelData.icon
          width: 16
          height: 16
          sourceSize.width: 16
          sourceSize.height: 16
          smooth: true

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
              if (mouse.button === Qt.LeftButton) trayIcon.modelData.activate();
              else trayIcon.modelData.secondaryActivate();
            }
          }
        }
      }
    }
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  // panels -------------------------------------------------------------

  Picker {
    id: launcher
    active: bar.focused
    menu: "launcher"
    placeholder: "search"
    // $mod+Return opens a terminal directly; this just keeps the most-used
    // entry under the cursor rather than whatever sorts first.
    pinned: ["alacritty"]
    entries: {
      const out = [];
      for (const app of DesktopEntries.applications.values) {
        out.push({
          id: app.id,
          name: app.name,
          sub: app.genericName || app.comment || "",
          icon: app.icon,
          // execute() ignores Terminal=true, so a console app (btop, ncmpcpp)
          // would run headless and exit. Wrap those in the same terminal
          // $mod+Return opens.
          run: () => {
            if (app.runInTerminal) {
              Quickshell.execDetached(["alacritty", "-e", ...app.command]);
            } else {
              app.execute();
            }
          }
        });
      }
      return out;
    }
  }

  Picker {
    id: powerMenu
    active: bar.focused
    menu: "power"
    placeholder: "power"
    // Alphabetical order otherwise puts "bios" under the cursor, so opening
    // the menu and pressing Enter would reboot to firmware setup. Lock is
    // both the safest default and the one actually wanted most often.
    pinned: ["lock"]
    // Same list scripts/power-menu.sh offered.
    entries: [
      // The lock lives in this same shell, so set it directly rather than
      // shelling out. loginctl lock-session only emits a logind signal, which
      // nothing listens for now that swaylock is gone.
      { name: "lock", sub: "lock the session", icon: "",
        run: () => { Session.locked = true; } },
      { name: "logout", sub: "exit sway", icon: "",
        run: () => I3.dispatch("exit") },
      { name: "suspend", sub: "sleep", icon: "",
        run: () => I3.dispatch("exec systemctl suspend") },
      { name: "reboot", sub: "restart", icon: "",
        run: () => I3.dispatch("exec systemctl reboot") },
      { name: "bios", sub: "reboot to firmware setup", icon: "",
        run: () => I3.dispatch("exec systemctl reboot --firmware-setup") },
      { name: "shutdown", sub: "power off", icon: "",
        run: () => I3.dispatch("exec systemctl poweroff") },
      { name: "reload", sub: "reload sway and the bar", icon: "",
        run: () => {
          I3.dispatch("reload");
          Quickshell.reload(false);
        } },
      { name: "help", sub: "show the keymap", icon: "",
        run: () => I3.dispatch("exec ~/.config/sway/scripts/keymap.sh") }
    ]
  }

  MusicPicker {
    id: musicPicker
    active: bar.focused
  }

  Keymap {
    id: keymapPanel
    active: bar.focused
  }

  AudioPanel {
    id: audioPanel
    active: bar.focused
  }

  NetworkPanel {
    id: netPanel
    active: bar.focused
  }
}
