pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Battery state, straight from sysfs. `uevent` carries every field in one file,
// so this is a single read rather than one per value, and it works on machines
// where UPower reports a stale state and 0 W.
Singleton {
  id: battery

  // Device names are vendor-specific: BAT0/BAT1/ACAD on most laptops, but e.g.
  // C1F4/C1F2 on an HP 8510w. Probe the sysfs class directory once and keep
  // whichever paths report the right POWER_SUPPLY_TYPE.
  property string batPath: ""
  property string acPath: ""

  Process {
    id: findSupplies
    running: true
    command: [
      "sh", "-c",
      "for d in /sys/class/power_supply/*/; do " +
      "t=$(cat \"$d/type\" 2>/dev/null); " +
      "case \"$t\" in Battery) echo \"BAT=$d\";; Mains) echo \"AC=$d\";; esac; " +
      "done"
    ]
    stdout: StdioCollector {
      onStreamFinished: {
        for (const line of this.text.split("\n")) {
          if (line.startsWith("BAT=") && battery.batPath === "")
            battery.batPath = line.slice(4) + "uevent";
          else if (line.startsWith("AC=") && battery.acPath === "")
            battery.acPath = line.slice(3) + "online";
        }
      }
    }
  }

  property bool present: false
  property bool online: false
  property real percent: 0
  property real watts: 0
  property real hours: 0

  readonly property bool charging: battery.online && battery.watts > 0.1

  // Adwaita draws the level in steps of ten, each with a charging and a
  // plugged-in variant -- except full, which is "charged" rather than
  // "100-charging".
  readonly property string icon: {
    if (!battery.present) return "battery-missing-symbolic";
    const level = Math.round(battery.percent * 10) * 10;
    const state = battery.charging ? (level === 100 ? "-charged" : "-charging")
                : battery.online ? "-plugged-in"
                : "";
    return "battery-level-" + level + state + "-symbolic";
  }

  // "2h" / "59m" / "5m". Blank when plugged in or the rate is unknown.
  readonly property string time: {
    if (battery.online || battery.hours <= 0) return "";
    const mins = Math.round(battery.hours * 60);
    if (mins >= 60) return Math.floor(mins / 60) + "h";
    return mins + "m";
  }

  // blockLoading: these are a few hundred bytes of sysfs, and an async first
  // read returns empty, leaving the chip blank until the next tick.
  FileView {
    id: uevent
    path: battery.batPath
    blockLoading: true
  }

  FileView {
    id: ac
    path: battery.acPath
    blockLoading: true
  }

  Timer {
    interval: 3000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      // Desktops have no battery at all, and the probe may not have finished.
      if (battery.batPath === "") {
        battery.present = false;
        return;
      }

      uevent.reload();
      if (battery.acPath !== "") ac.reload();

      const ue = uevent.text();
      const field = k => {
        const m = ue.match(new RegExp("POWER_SUPPLY_" + k + "=(-?\\d+)"));
        return m ? Number(m[1]) : 0;
      };

      battery.present = field("PRESENT") === 1;
      battery.online = ac.text().trim() === "1";
      if (!battery.present) return;

      // Some batteries report charge/current (Ah, A), others energy/power
      // (Wh, W). Handle both.
      const volt = field("VOLTAGE_NOW") / 1e6;
      let now = field("CHARGE_NOW"), full = field("CHARGE_FULL");
      let rate = field("CURRENT_NOW");
      if (full > 0) {
        now /= 1e6; full /= 1e6; rate /= 1e6;
        battery.watts = rate * volt;
      } else {
        now = field("ENERGY_NOW") / 1e6;
        full = field("ENERGY_FULL") / 1e6;
        rate = field("POWER_NOW") / 1e6;
        battery.watts = rate;
      }
      battery.percent = full > 0 ? now / full : 0;
      battery.hours = rate > 0 ? now / rate : 0;
    }
  }
}
