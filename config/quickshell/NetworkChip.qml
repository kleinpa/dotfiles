import QtQuick
import QtQuick.Layouts

// The network readout, shared by the bar and the lock screen. Which device it
// describes is Net.qml's decision; this is only the visual. Wired wins when
// both are up -- NetworkManager routes over it in preference to wifi -- so
// the ssid does not stay up after a cable is plugged in. Red when there is
// no connection at all.
Chip {
  id: netChip

  // Status only -- the icon, without the ssid and signal strength. The lock
  // screen wants to know whether it is online, not which network it is on.
  property bool brief: false
  interactive: false

  accent: (Net.activeNet || Net.wiredDevice) ? "transparent" : Theme.critTint

  // "ssid 00%", wifi only: a wired connection has neither.
  MonoText {
    Layout.maximumWidth: 160
    elide: Text.ElideRight
    visible: !netChip.brief && !Net.wiredDevice && Net.activeNet !== null
    text: Net.activeNet
        ? Net.activeNet.name + " " + Math.round(Net.activeNet.signalStrength * 100) + "%"
        : ""
  }

  // The same bands nm-applet uses for its bars.
  Icon {
    name: {
      if (Net.wiredDevice) return "network-wired-symbolic";
      if (!Net.activeNet) return "network-wireless-offline-symbolic";
      const s = Net.activeNet.signalStrength;
      const level = s > 0.8 ? "excellent"
                  : s > 0.55 ? "good"
                  : s > 0.3 ? "ok"
                  : s > 0.05 ? "weak"
                  : "none";
      return "network-wireless-signal-" + level + "-symbolic";
    }
  }

  // The homelab tunnel, while a wireguard link exists: dimmed until it is
  // routable. Which links, and their addresses, is the panel's business.
  Icon {
    visible: Vpn.present
    name: Vpn.up ? "network-vpn-symbolic" : "network-vpn-disconnected-symbolic"
    color: Vpn.up ? Theme.text : Theme.muted
  }
}
