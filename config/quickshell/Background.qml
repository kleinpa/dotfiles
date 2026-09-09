import Quickshell
import Quickshell.Wayland
import QtQuick

// The wallpaper, as a layer-shell surface -- the same mechanism Lock.qml uses,
// further down the stack. sway's `output bg` did this before; having the shell
// own it means one mechanism instead of two, and the image path resolves
// exactly the way the lock screen's does.
PanelWindow {
  id: wall

  required property var modelData
  screen: wall.modelData

  WlrLayershell.namespace: "quickshell-wallpaper"
  // Bottom, not Background, which is the layer a wallpaper would normally
  // want: sway paints its own configured `output bg` over anything on the
  // Background layer, so a surface there is simply never seen. Bottom is still
  // beneath every window and every other shell surface, and it sits above
  // sway's solid colour rather than under it.
  WlrLayershell.layer: WlrLayer.Bottom
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  // Covers the output without reserving any of it.
  exclusionMode: ExclusionMode.Ignore
  anchors { top: true; bottom: true; left: true; right: true }
  // Shows through wherever the image does not reach, and while it loads.
  color: Theme.base

  // An empty mask: the wallpaper takes no input, so clicks and drags land on
  // the desktop as if it were not there.
  mask: Region {}

  Image {
    anchors.fill: parent
    source: "file://" + Theme.wallpaper
    fillMode: Image.PreserveAspectCrop
    // Decode at output size rather than the image's full 5k.
    sourceSize.width: wall.width
    sourceSize.height: wall.height
    asynchronous: true
  }
}
