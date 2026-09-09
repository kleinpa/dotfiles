pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// CPU and memory from /proc: cpu as a jiffy delta between ticks, memory from
// MemAvailable. A singleton so the polling happens once rather than once per
// output's bar.
Singleton {
  id: sys

  property real cpuPercent: 0
  property real memPercent: 0
  property real memUsedGb: 0
  property real memTotalGb: 0

  property real lastCpuBusy: 0
  property real lastCpuTotal: 0

  FileView { id: statFile; path: "/proc/stat" }
  FileView { id: memFile; path: "/proc/meminfo" }

  Timer {
    interval: 3000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      statFile.reload();
      memFile.reload();

      const statLine = statFile.text().split("\n")[0];
      if (statLine && statLine.startsWith("cpu ")) {
        const f = statLine.split(/\s+/).slice(1).map(Number);
        const idle = f[3] + f[4];
        const total = f.reduce((a, b) => a + b, 0);
        const dTotal = total - sys.lastCpuTotal;
        const dBusy = (total - idle) - sys.lastCpuBusy;
        if (sys.lastCpuTotal > 0 && dTotal > 0)
          sys.cpuPercent = Math.max(0, Math.min(100, (dBusy / dTotal) * 100));
        sys.lastCpuTotal = total;
        sys.lastCpuBusy = total - idle;
      }

      const mem = memFile.text();
      const totalM = mem.match(/MemTotal:\s+(\d+)/);
      const availM = mem.match(/MemAvailable:\s+(\d+)/);
      if (totalM && availM) {
        const t = Number(totalM[1]);
        const used = t - Number(availM[1]);
        sys.memPercent = (used / t) * 100;
        sys.memUsedGb = used / 1048576;
        sys.memTotalGb = t / 1048576;
      }
    }
  }
}
