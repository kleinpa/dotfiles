pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Backlight control. The device is probed out of /sys/class/backlight the same
// way Battery.qml probes /sys/class/power_supply, because the name is
// vendor-specific (amdgpu_bl1, intel_backlight, acpi_video0).
//
// Reads come from sysfs, but writes go through brightnessctl rather than
// straight to the file: the brightness node is root-owned, and brightnessctl
// ships a setuid helper for exactly this.
Singleton {
  id: brightness

  property string device: ""
  property int max: 0
  property int current: 0

  readonly property bool available: brightness.device !== "" && brightness.max > 0
  readonly property real percent:
    brightness.max > 0 ? brightness.current / brightness.max : 0

  // Percent per keypress, matching what `light -A 5` did before.
  readonly property int stepPercent: 5

  Process {
    id: findBacklight
    running: true
    command: [
      "sh", "-c",
      "for d in /sys/class/backlight/*/; do " +
      "[ -r \"$d/max_brightness\" ] || continue; " +
      "echo \"$(basename $d)|$(cat $d/max_brightness)\"; break; done"
    ]
    stdout: StdioCollector {
      onStreamFinished: {
        const f = this.text.trim().split("|");
        if (f.length < 2 || f[0] === "") return;
        brightness.device = f[0];
        brightness.max = Number(f[1]);
        brightness.refresh();
      }
    }
  }

  // blockLoading, as in Battery.qml: reload() is then synchronous, so text()
  // is fresh by the time it is read on the next line.
  FileView {
    id: level
    path: brightness.device === ""
          ? "" : "/sys/class/backlight/" + brightness.device + "/brightness"
    blockLoading: true
  }

  function refresh(): void {
    if (brightness.device === "") return;
    level.reload();
    brightness.current = Number(level.text().trim()) || 0;
  }

  function step(up: bool): void {
    const arg = brightness.stepPercent + "%" + (up ? "+" : "-");
    // Deliberately not gated on `available`: the probe is async, so a key
    // pressed in the first moment after the shell starts would otherwise be
    // swallowed. Without a device name brightnessctl picks the first backlight
    // itself, which is the one the probe would have found; on a machine with
    // none it exits non-zero and nothing happens, which is correct anyway.
    setter.command = brightness.device === ""
        ? ["brightnessctl", "set", arg]
        : ["brightnessctl", "--device", brightness.device, "set", arg];
    setter.running = false;
    setter.running = true;
  }

  Process {
    id: setter
    onExited: brightness.refresh()
  }
}
