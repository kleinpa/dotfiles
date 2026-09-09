import QtQuick
import QtQuick.Layouts

// The IPv4 and primary globally routable IPv6 addresses for one interface,
// indented under the connection they belong to. Collapses entirely when the
// interface has neither, so a link that is up but unaddressed adds no blank
// rows. `addr` is one entry of NetworkPanel's address map.
ColumnLayout {
  id: lines

  property var addr: null

  readonly property string v4: lines.addr && lines.addr.v4 ? lines.addr.v4 : ""
  readonly property string v6: lines.addr && lines.addr.v6 ? lines.addr.v6 : ""

  Layout.fillWidth: true
  Layout.leftMargin: 12
  spacing: 0
  visible: lines.v4 !== "" || lines.v6 !== ""

  MonoText {
    visible: text !== ""
    Layout.fillWidth: true
    elide: Text.ElideRight
    text: lines.v4
    color: Theme.muted
    font.pixelSize: 10
  }

  MonoText {
    visible: text !== ""
    Layout.fillWidth: true
    elide: Text.ElideRight
    text: lines.v6
    color: Theme.muted
    font.pixelSize: 10
  }
}
