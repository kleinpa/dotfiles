pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Networking
import QtQuick

// WireGuard links, whoever configured them. NetworkManager and systemd-networkd
// both hand the kernel a wireguard netdev, and the kernel is the one place
// the two meet: `ip` lists them by type on any machine, so there is one probe
// here rather than one per manager. No `wg show` -- it wants CAP_NET_ADMIN
// even to read, so the handshake is out of reach, and "up with a routable
// address" is the most that can be said without it.
Singleton {
  id: vpn

  // [{ name, up }], one per wireguard interface.
  property var links: []
  readonly property bool present: vpn.links.length > 0
  readonly property bool up: vpn.links.some(l => l.up)

  function refresh(): void {
    probe.running = false;
    probe.running = true;
  }

  Process {
    id: probe
    running: true
    command: ["ip", "-j", "addr", "show", "type", "wireguard"]
    stdout: StdioCollector {
      onStreamFinished: {
        let parsed = [];
        try { parsed = JSON.parse(this.text || "[]"); } catch (e) {}
        vpn.links = parsed.map(l => ({
          name: l.ifname,
          up: l.flags.includes("UP") && l.addr_info.some(a => a.scope === "global")
        }));
      }
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: vpn.refresh()
  }

  // NetworkManager creates and deletes the netdev with its profile; catch
  // that as it happens rather than on the next tick.
  Connections {
    target: Networking.devices
    function onValuesChanged(): void { vpn.refresh(); }
  }
}
