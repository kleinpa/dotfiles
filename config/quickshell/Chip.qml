import QtQuick
import QtQuick.Layouts

// A waybar-style module chip: translucent white by default, tinted only when a
// widget passes an accent for an active state.
Rectangle {
  id: chip

  // Content goes into the row; the MouseArea below is part of the chip itself,
  // since an anchored child inside a Layout breaks sizing.
  default property alias content: chipRow.data
  property color accent: "transparent"
  property bool interactive: true
  property int buttons: Qt.LeftButton
  readonly property bool hovered: chip.interactive && chipArea.containsMouse

  signal clicked(int button)
  signal wheel(int delta)

  // Slightly wider than tall: text needs more room beside it than above it
  // before it stops looking cramped against the chip's edge.
  property int paddingH: 4
  property int paddingV: 3
  // Height comes from the text line box, not the content: an icon-only chip
  // (ethernet, say) has a shorter glyph line box than a chip with mono text,
  // and would otherwise render visibly shorter than its neighbours.
  property int contentHeight: 16
  property int spacing: 5
  implicitWidth: chipRow.implicitWidth + chip.paddingH * 2
  implicitHeight: chip.contentHeight + chip.paddingV * 2
  // A Rectangle in a RowLayout is sized from Layout.preferredWidth; without
  // these it can be stretched and swallow the row's slack. fillWidth false
  // makes it fixed: a crowded row cannot squeeze it either, so a chip that
  // can elide its text opts back in with fillWidth and a minimum of its own.
  Layout.preferredWidth: chip.implicitWidth
  Layout.preferredHeight: chip.implicitHeight
  Layout.fillWidth: false
  radius: Theme.radius

  color: chip.accent.a > 0 ? chip.accent
       : chip.hovered ? Theme.chipHover
       : Theme.chip

  Behavior on color { ColorAnimation { duration: 120 } }

  // Sized from the chip rather than from its content, so a chip given less
  // than its natural width passes the squeeze down to its text.
  RowLayout {
    id: chipRow
    anchors.centerIn: parent
    width: chip.width - chip.paddingH * 2
    spacing: chip.spacing
  }

  MouseArea {
    id: chipArea
    anchors.fill: parent
    enabled: chip.interactive
    hoverEnabled: chip.interactive
    acceptedButtons: chip.buttons
    onClicked: mouse => chip.clicked(mouse.button)
    onWheel: wheelEvent => chip.wheel(wheelEvent.angleDelta.y)
  }
}
