// A small Quickshell desktop shell for sway: bar, launcher, power menu, audio
// and network panels, and the session lock. Ported from the hyprland
// experiment in kleinpa/home-network, with the rice turned down -- no blur, no
// shadows, no wallpaper effects.
//
// Wants, beyond quickshell itself: NetworkManager (network panel), pipewire
// (audio), a StatusNotifier tray, /etc/pam.d/swaylock (lock), and the Adwaita
// icon theme for the symbolic icons. The media chip reads MPRIS, so mpd needs
// mpDris2 to appear there.
//
// The sway config drives it over IPC: `qs ipc call launcher toggle` and
// friends. See config/sway/config.

pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

ShellRoot {
  id: root

  // Volume and mute are only valid on tracked nodes. Every device, not just
  // the sinks: the audio panel lists them all, and the mic-mute key acts on
  // the default source.
  PwObjectTracker {
    objects: Pipewire.nodes.values.filter(n => !n.isStream)
  }

  Variants {
    model: Quickshell.screens

    Background {}
  }

  Variants {
    model: Quickshell.screens

    Bar {}
  }

  Lock { id: lock }

  // IPC lives here rather than inside the per-screen bars: an IpcHandler
  // registers a target globally, so one nested in Variants would be registered
  // once per monitor.

  // `qs ipc call lock lock` -- the power menu, and swayidle. sleep/wake are
  // swayidle's too: they stop and restart the fingerprint reader around the
  // display going off and the machine suspending. Both are no-ops unlocked.
  IpcHandler {
    target: "lock"
    function lock(): void { Session.locked = true; }
    function unlock(): void { Session.locked = false; }
    function isLocked(): bool { return Session.locked; }
    function sleep(): void { lock.sleep(); }
    function wake(): void { lock.wake(); }
  }

  IpcHandler {
    target: "launcher"
    function toggle(): void { Session.toggleMenu("launcher"); }
    function show(): void { Session.openMenu = "launcher"; }
    function hide(): void { Session.openMenu = ""; }
  }

  IpcHandler {
    target: "power"
    function toggle(): void { Session.toggleMenu("power"); }
    function show(): void { Session.openMenu = "power"; }
    function hide(): void { Session.openMenu = ""; }
  }

  // Volume acts on the default sink, mic mute on the default source. Raising
  // the volume deliberately does not unmute, matching what the pactl bindings
  // these replaced did.
  function addVolume(delta: real): void {
    const sink = Pipewire.defaultAudioSink;
    if (!sink || !sink.audio) return;
    sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + delta));
  }

  IpcHandler {
    target: "audio"
    function toggle(): void { Session.toggleMenu("audio"); }
    function show(): void { Session.openMenu = "audio"; }
    function hide(): void { Session.openMenu = ""; }

    function volumeUp(): void { root.addVolume(0.05); }
    function volumeDown(): void { root.addVolume(-0.05); }

    function mute(): void {
      const sink = Pipewire.defaultAudioSink;
      if (sink && sink.audio) sink.audio.muted = !sink.audio.muted;
    }

    function micMute(): void {
      const src = Pipewire.defaultAudioSource;
      if (src && src.audio) src.audio.muted = !src.audio.muted;
    }
  }

  // The media keys. Which player they act on is Player.qml's decision, the
  // same one the bar chip shows.
  IpcHandler {
    target: "media"
    function playPause(): void { Player.togglePlaying(); }
    function next(): void { Player.next(); }
    function prev(): void { Player.previous(); }
  }

  IpcHandler {
    target: "brightness"
    function up(): void { Brightness.step(true); }
    function down(): void { Brightness.step(false); }
  }

  IpcHandler {
    target: "music"
    function toggle(): void { Session.toggleMenu("music"); }
    function show(): void { Session.openMenu = "music"; }
    function hide(): void { Session.openMenu = ""; }
  }

  IpcHandler {
    target: "keymap"
    function toggle(): void { Session.toggleMenu("keymap"); }
    function show(): void { Session.openMenu = "keymap"; }
    function hide(): void { Session.openMenu = ""; }
  }

  IpcHandler {
    target: "network"
    function toggle(): void { Session.toggleMenu("network"); }
    function show(): void { Session.openMenu = "network"; }
    function hide(): void { Session.openMenu = ""; }
  }

  // `qs ipc call menus closeAll` -- the escape hatch. If a menu ever holds an
  // exclusive keyboard grab, this releases it without killing the session.
  IpcHandler {
    target: "menus"
    function closeAll(): void { Session.openMenu = ""; }
  }

  IpcHandler {
    target: "shell"
    function reload(): void {
      Session.openMenu = "";
      Quickshell.reload(false);
    }
    function reloadHard(): void {
      Session.openMenu = "";
      Quickshell.reload(true);
    }
  }
}
