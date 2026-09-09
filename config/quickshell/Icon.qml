import QtQuick
import QtQuick.Controls.impl as Impl

// A symbolic icon from the system icon theme, the way GNOME and KDE draw
// theirs: a named monochrome SVG (network-wireless-signal-good-symbolic,
// say) resolved through the freedesktop icon theme, recoloured to match the
// text beside it. Adwaita ships the whole set; the sway config names it
// through QS_ICON_THEME, since nothing else on a bare sway session tells Qt
// which theme is current.
//
// QtQuick.Controls.impl is Qt's own back end for `icon.color` on buttons,
// and is what does the recolouring here. It is an implementation module, but
// IconImage has been exported unchanged since Qt 5.10.
Impl.IconImage {
  id: icon

  property int size: Theme.iconSize

  color: Theme.text
  // Image derives its implicit size from sourceSize, so this is what sizes the
  // icon in a layout as well as what the SVG is rasterised at.
  sourceSize.width: icon.size
  sourceSize.height: icon.size
  fillMode: Image.PreserveAspectFit
}
