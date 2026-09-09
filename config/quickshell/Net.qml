pragma Singleton

import Quickshell
import Quickshell.Networking

// The bar chip and the network panel both need to pick a device out of
// NetworkManager's list; doing it here keeps the two in agreement.
Singleton {
  id: net

  readonly property var wiredDevice: {
    for (const d of Networking.devices.values) {
      if (d.type === DeviceType.Wired && d.connected) return d;
    }
    return null;
  }

  readonly property var wifiDevice: {
    for (const d of Networking.devices.values) {
      if (d.type === DeviceType.Wifi) return d;
    }
    return null;
  }

  // Wifi only: a wired connection has no ssid or signal strength, so it gets
  // the bare ethernet icon rather than a name and a meaningless percentage.
  readonly property var activeNet: {
    for (const d of Networking.devices.values) {
      if (!d.connected || d.type !== DeviceType.Wifi) continue;
      for (const n of d.networks.values) {
        if (n.connected) return n;
      }
    }
    return null;
  }
}
