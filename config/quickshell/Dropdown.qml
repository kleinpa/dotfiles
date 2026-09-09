import QtQuick

// A panel that rolls down out of the bar: an outer clipper pinned to the bar's
// bottom edge, with the panel sliding within it. The panel is cropped at the
// top rather than sliding over the bar, so no compositor layer tricks are
// needed -- and it lives inside the bar's window, so the shell only ever puts
// one translucent surface over any pixel.
Item {
  id: dd

  default property alias content: body.data

  // The name this panel answers to in Session.openMenu.
  property string menu: ""
  // Set false on unfocused outputs: the bar is per-screen, so without this
  // every monitor would show its own copy of the open menu.
  property bool active: true
  property int panelHeight: 0

  readonly property bool wanted:
    dd.active && dd.menu !== "" && Session.openMenu === dd.menu

  // Stays laid out while rolling up, so the slide is actually visible. Cleared
  // when the animation settles, or by the guard below if it never ran.
  property bool rolling: false
  visible: dd.wanted || dd.rolling

  // Geometry the bar reads to size its window and build its input mask. Zero
  // unless this panel is the one on screen.
  readonly property int dropHeight: dd.visible ? dd.panelHeight : 0
  readonly property int dropWidth: dd.visible ? dd.width : 0

  signal opened
  signal closed

  onWantedChanged: {
    if (dd.wanted) {
      rollGuard.stop();
      dd.rolling = false;
      dd.opened();
    } else {
      dd.rolling = true;
      rollGuard.restart();
    }
  }

  function hide(): void {
    if (Session.openMenu === dd.menu) Session.openMenu = "";
  }

  function finishClose(): void {
    if (dd.wanted || !dd.rolling) return;
    rollGuard.stop();
    dd.rolling = false;
    dd.closed();
  }

  // Failsafe: if the slide never runs, do not stay laid out forever.
  Timer {
    id: rollGuard
    interval: 400
    onTriggered: dd.finishClose()
  }

  y: Theme.barHeight
  height: dd.panelHeight
  clip: true

  Rectangle {
    id: panel
    width: dd.width
    // Extended upward by the corner radius so the rounded top is parked above
    // the clip boundary and only square edges ever meet the bar.
    height: dd.panelHeight + Theme.menuRadius
    color: Theme.ground
    radius: Theme.menuRadius

    y: dd.wanted ? -Theme.menuRadius : -panel.height

    Behavior on y {
      NumberAnimation {
        duration: 140
        easing.type: Easing.OutCubic
        onFinished: dd.finishClose()
      }
    }

    Item {
      id: body
      anchors.fill: parent
      anchors.topMargin: Theme.menuRadius
    }
  }
}
