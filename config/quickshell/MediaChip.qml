import QtQuick
import QtQuick.Layouts

// The now-playing readout, shared by the bar and the lock screen. Which player
// it describes is Player.qml's decision; this is only the visual, and the bar
// adds the buttons.
Chip {
  id: media

  // Hidden once it has been paused long enough to stop being news.
  visible: Player.active && !Player.stale
  interactive: false
  accent: Player.playing ? Theme.goodTint : "transparent"

  // The one chip that gives way when the bar runs short: the title elides down
  // to nothing before the icon or any neighbouring chip loses a pixel. The
  // maximum pins the natural width, so fillWidth means "may shrink", not grow.
  Layout.fillWidth: true
  Layout.maximumWidth: media.implicitWidth
  Layout.minimumWidth: media.paddingH * 2 + mediaIcon.implicitWidth + media.spacing

  MonoText {
    Layout.fillWidth: true
    Layout.maximumWidth: 200
    elide: Text.ElideRight
    text: (Player.artist ? Player.artist + " - " : "") + Player.title
  }

  Icon {
    id: mediaIcon
    Layout.minimumWidth: mediaIcon.implicitWidth
    name: Player.playing ? "media-playback-start-symbolic" : "media-playback-pause-symbolic"
  }
}
