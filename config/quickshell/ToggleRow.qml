import QtQuick
import QtQuick.Layouts

// One switchable network in NetworkPanel: a wireguard profile or an ethernet
// port. `row` is one entry of the panel's wgRows/ethRows; clicking emits
// toggled() and the panel decides what that means. Read-only rows (links some
// other manager owns) highlight nothing and emit nothing.
ColumnLayout {
  id: tRow

  property var row: ({})
  property bool pending: false
  property var addr: null

  signal toggled

  readonly property bool busy: tRow.pending || tRow.row.busy === true

  Layout.fillWidth: true
  spacing: 0

  Rectangle {
    Layout.fillWidth: true
    implicitHeight: 20
    radius: Theme.radius
    color: tArea.containsMouse && !tRow.row.readOnly ? Theme.chipHover : "transparent"

    Behavior on color { ColorAnimation { duration: 100 } }

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 6
      anchors.rightMargin: 6
      spacing: 6

      MonoText {
        Layout.fillWidth: true
        elide: Text.ElideRight
        text: (tRow.row.on ? "> " : "  ") + tRow.row.name
        color: tRow.row.on ? Theme.good : Theme.text
        font.pixelSize: 11
      }

      MonoText {
        text: tRow.busy ? "..." : tRow.row.on ? "on" : "off"
        color: tRow.row.on ? Theme.good : Theme.muted
        font.pixelSize: 11
      }
    }

    MouseArea {
      id: tArea
      anchors.fill: parent
      hoverEnabled: !tRow.row.readOnly
      onClicked: if (!tRow.row.readOnly) tRow.toggled()
    }
  }

  AddressLines {
    visible: tRow.row.on === true && (v4 !== "" || v6 !== "")
    addr: tRow.addr
  }
}
