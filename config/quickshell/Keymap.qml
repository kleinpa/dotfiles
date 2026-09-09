import QtQuick
import QtQuick.Layouts

// The keymap, as static text in a dropdown. Previously scripts/keymap.sh,
// which piped the same art through `fuzzel --dmenu` sized to 131 columns --
// a picker pretending to be a document. The layout is a corne: two halves,
// home cluster on the left, directions one key right of hjkl on the right.
Dropdown {
  id: keymap

  menu: "keymap"
  anchors.horizontalCenter: parent.horizontalCenter
  width: art.implicitWidth + 32
  panelHeight: art.implicitHeight + 24

  // No search field to hold the handlers, and the bar takes an exclusive
  // keyboard grab while a menu is up, so Escape needs somewhere to land.
  onOpened: keymapKeys.forceActiveFocus()

  Item {
    id: keymapKeys
    anchors.fill: parent
    Keys.onEscapePressed: keymap.hide()
  }

  MonoText {
    id: art
    anchors.centerIn: parent
    horizontalAlignment: Text.AlignHCenter
    font.pixelSize: 11
    color: Theme.text
    text: "/--------|--------|--------|--------|--------|--------\\                    /--------|--------|--------|--------|--------|--------\\\n"
        + "|        | ws 1   | ws 2   | ws 3   | ws 4   | ws 5   |                    | parent | menu   | split  | tabs   |        | power  |\n"
        + "|--------|--------|--------|--------|--------|--------|                    |--------|--------|--------|--------|--------|--------|\n"
        + "|        | ws 6   | ws 7   | ws 8   | ws 9   | ws 10  |                    | full   |  left  | down   | up     | right  | scratch|\n"
        + "|--------|--------|--------|--------|--------|--------|                    |--------|--------|--------|--------|--------|--------|\n"
        + "|        | ncmpcp | audio  | music  | net    |  help  |                    | splitt |  w-    |  h+    |  h-    |  w+    |  help  |\n"
        + "\\--------|--------|--------|--------|--------|--------|--------\\  /--------|--------|--------|--------|--------|--------|--------/\n"
        + "                                    |        |  mod   |        |  | menu   |        |  $mod  |\n"
        + "                                    \\--------|--------|--------/  \\--------|--------|--------/"
  }
}
