pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Networking
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Wifi toggle and network list, replacing networkmanager_dmenu.
Dropdown {
  id: netMenu

  menu: "network"
  width: 300
  panelHeight: netBody.implicitHeight + 20
  anchors.horizontalCenter: parent.horizontalCenter

  // Scan only while the panel is up.
  onVisibleChanged: {
    if (Net.wifiDevice) Net.wifiDevice.scannerEnabled = netMenu.visible;
    if (!netMenu.visible) pskPrompt.target = null;
  }

  // This panel has no search field to carry the key handlers, and the bar holds
  // an exclusive keyboard grab while it is open, so Escape needs somewhere to
  // land or there is no way out but the mouse.
  onOpened: netKeys.forceActiveFocus()

  Item {
    id: netKeys
    anchors.fill: parent
    Keys.onEscapePressed: netMenu.hide()
  }

  ColumnLayout {
    id: netBody
    anchors.fill: parent
    anchors.margins: 10
    spacing: 6

    // WireGuard links, read-only. These are systemd-networkd interfaces, not
    // NetworkManager profiles: `nmcli connection down` on one deletes the
    // adopted profile and drops the route this machine is administered over,
    // so there is deliberately no toggle here.
    property var vpns: []

    Process {
      id: vpnList
      running: netMenu.wanted
      command: [
        "sh", "-c",
        "for d in /sys/class/net/*/; do n=$(basename $d); " +
        "grep -q DEVTYPE=wireguard \"$d/uevent\" 2>/dev/null || continue; " +
        "st=$(networkctl list --no-legend 2>/dev/null | awk -v n=\"$n\" '$2==n {print $4}'); " +
        "a=$(ip -o -6 addr show dev \"$n\" scope global 2>/dev/null | awk '{print $4}' | head -1); " +
        "echo \"$n|$st|$a\"; done"
      ]
      stdout: StdioCollector {
        onStreamFinished: {
          const out = [];
          for (const line of this.text.split("\n")) {
            const f = line.split("|");
            if (f.length < 3 || f[0] === "") continue;
            out.push({ name: f[0], state: f[1], address: f[2] });
          }
          netBody.vpns = out;
        }
      }
    }

    // Interface addresses, keyed by interface name. NetworkDevice carries a
    // single `address`, but this needs both families, and "primary globally
    // routable" is a v6 notion NetworkManager does not express -- so ask `ip`,
    // the same way the wireguard section above does. -deprecated and
    // -tentative drop addresses that are still global but not usable as a
    // source; of what remains, the first is the one the kernel prefers.
    property var addrs: ({})

    Process {
      id: addrList
      running: netMenu.wanted
      command: [
        "sh", "-c",
        "for d in /sys/class/net/*/; do n=$(basename $d); " +
        "[ \"$n\" = lo ] && continue; " +
        "v4=$(ip -o -4 addr show dev \"$n\" scope global 2>/dev/null " +
        "| awk '{print $4}' | head -1); " +
        "v6=$(ip -o -6 addr show dev \"$n\" scope global -deprecated -tentative 2>/dev/null " +
        "| awk '{print $4}' | head -1); " +
        "echo \"$n|$v4|$v6\"; done"
      ]
      stdout: StdioCollector {
        onStreamFinished: {
          const m = {};
          for (const line of this.text.split("\n")) {
            const f = line.split("|");
            if (f.length < 3 || f[0] === "") continue;
            m[f[0]] = { v4: f[1], v6: f[2] };
          }
          netBody.addrs = m;
        }
      }
    }

    // Refresh while the panel is open so state does not go stale.
    Timer {
      interval: 3000
      running: netMenu.wanted
      repeat: true
      onTriggered: {
        vpnList.running = false;
        vpnList.running = true;
        addrList.running = false;
        addrList.running = true;
      }
    }

    // Wrapped so the whole section, including its spacing, collapses on
    // machines with no wireguard link.
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 6
      visible: netBody.vpns.length > 0

      MonoText {
        text: "wireguard"
        color: Theme.muted
        font.pixelSize: 11
      }

      Repeater {
        model: netBody.vpns

        ColumnLayout {
          id: vpnRow
          required property var modelData

          Layout.fillWidth: true
          spacing: 0

          // "routable" means the link is up and carrying an address;
          // "carrier" means the interface exists but has no usable address.
          readonly property bool up: vpnRow.modelData.state === "routable"

          RowLayout {
            Layout.fillWidth: true
            spacing: 6

            MonoText {
              Layout.fillWidth: true
              elide: Text.ElideRight
              text: vpnRow.modelData.name
              color: vpnRow.up ? Theme.good : Theme.text
              font.pixelSize: 11
            }

            MonoText {
              text: vpnRow.modelData.state
              color: vpnRow.up ? Theme.good : Theme.muted
              font.pixelSize: 11
            }
          }

          MonoText {
            visible: vpnRow.modelData.address !== ""
            Layout.fillWidth: true
            elide: Text.ElideRight
            text: vpnRow.modelData.address
            color: Theme.muted
            font.pixelSize: 10
          }
        }
      }

      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Theme.overlay
      }
    }

    // Wired. Net.wiredDevice is already filtered to a connected wired device,
    // so this whole section is absent unless a cable is actually up.
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 6
      visible: Net.wiredDevice !== null

      MonoText {
        text: "ethernet"
        color: Theme.muted
        font.pixelSize: 11
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        MonoText {
          Layout.fillWidth: true
          elide: Text.ElideRight
          text: "> " + (Net.wiredDevice ? Net.wiredDevice.name : "")
          color: Theme.good
          font.pixelSize: 11
        }

        AddressLines {
          addr: Net.wiredDevice ? netBody.addrs[Net.wiredDevice.name] : null
        }
      }

      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Theme.overlay
      }
    }

    RowLayout {
      Layout.fillWidth: true

      MonoText {
        Layout.fillWidth: true
        text: "wifi"
        color: Theme.muted
        font.pixelSize: 11
      }

      MonoText {
        text: Networking.wifiEnabled ? "on" : "off"
        color: Networking.wifiEnabled ? Theme.good : Theme.muted
        font.pixelSize: 11

        MouseArea {
          anchors.fill: parent
          onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
        }
      }
    }

    Repeater {
      model: Net.wifiDevice ? Net.wifiDevice.networks : null

      // Wrapper so the connected network can carry its addresses on lines
      // beneath it without the click target growing to cover them.
      ColumnLayout {
        id: netEntry
        required property var modelData

        Layout.fillWidth: true
        spacing: 0

        // A plain Item, not the RowLayout itself: the click target has to fill the
        // row, and anchoring a child of a layout is undefined behaviour.
        Rectangle {
          id: netRow
          readonly property var modelData: netEntry.modelData

          Layout.fillWidth: true
          implicitHeight: 20
          radius: Theme.radius
          color: netRowArea.containsMouse ? Theme.chipHover : "transparent"

          Behavior on color { ColorAnimation { duration: 100 } }

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            spacing: 6

            MonoText {
              Layout.fillWidth: true
              elide: Text.ElideRight
              text: (netRow.modelData.connected ? "> " : "  ") + netRow.modelData.name
              color: netRow.modelData.connected ? Theme.good
                   : netRow.modelData.known ? Theme.text
                   : Theme.subtle
              font.pixelSize: 11
            }

            MonoText {
              text: netRow.modelData.state === ConnectionState.Connecting
                    ? "..."
                    : Math.round(netRow.modelData.signalStrength * 100) + "%"
              color: Theme.muted
              font.pixelSize: 11
            }
          }

          MouseArea {
            id: netRowArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              if (netRow.modelData.connected) {
                netRow.modelData.disconnect();
              } else {
                // Try saved credentials first; prompt only on NoSecrets.
                pskPrompt.target = null;
                netRow.modelData.connect();
              }
            }
          }

          Connections {
            target: netRow.modelData
            function onConnectionFailed(reason): void {
              if (reason === ConnectionFailReason.NoSecrets)
                pskPrompt.target = netRow.modelData;
            }
          }
        }

        AddressLines {
          visible: netEntry.modelData.connected
          addr: Net.wifiDevice ? netBody.addrs[Net.wifiDevice.name] : null
        }
      }
    }

    // PSK prompt, shown only when a network asks for secrets.
    ColumnLayout {
      id: pskPrompt
      property var target: null

      visible: pskPrompt.target !== null
      Layout.fillWidth: true
      spacing: 4

      onVisibleChanged: if (visible) pskField.forceActiveFocus()

      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Theme.overlay
      }

      MonoText {
        text: pskPrompt.target ? "password for " + pskPrompt.target.name : ""
        color: Theme.muted
        font.pixelSize: 11
      }

      TextField {
        id: pskField
        Layout.fillWidth: true
        echoMode: TextInput.Password
        color: Theme.text
        font.family: Theme.mono
        font.pixelSize: 11
        background: Rectangle {
          color: Theme.base
          radius: 3
        }
        onAccepted: {
          if (pskPrompt.target) pskPrompt.target.connectWithPsk(pskField.text);
          pskField.text = "";
          pskPrompt.target = null;
        }

        // The prompt steals focus from netKeys while it is up.
        Keys.onEscapePressed: netMenu.hide()
      }
    }
  }
}
