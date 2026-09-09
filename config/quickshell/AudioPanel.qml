pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

// Master volume plus an output picker, replacing scripts/audio-switch.sh.
Dropdown {
  id: audio

  menu: "audio"
  width: 260
  panelHeight: audioBody.implicitHeight + 20
  // Centred rather than anchored under its chip: the chips resize as their
  // text changes (volume, ssid), which made an attached panel jitter.
  anchors.horizontalCenter: parent.horizontalCenter

  readonly property var sink: Pipewire.defaultAudioSink
  // Real output devices only, in a stable order so the selection index means
  // something.
  readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream)
  property int selected: 0

  onOpened: {
    audioKeys.forceActiveFocus();
    // Preselect the current output so down+enter swaps devices.
    const cur = audio.sinks.indexOf(Pipewire.defaultAudioSink);
    audio.selected = cur >= 0 ? cur : 0;
  }

  // Keys.* only fire on an item that holds focus, so the handlers live on a
  // focused item rather than on the window.
  Item {
    id: audioKeys
    anchors.fill: parent

    Keys.onEscapePressed: audio.hide()
    Keys.onUpPressed: audio.selected = Math.max(0, audio.selected - 1)
    Keys.onDownPressed: audio.selected =
        Math.min(audio.sinks.length - 1, audio.selected + 1)
    Keys.onLeftPressed: if (audio.sink && audio.sink.audio)
        audio.sink.audio.volume = Math.max(0, audio.sink.audio.volume - 0.05)
    Keys.onRightPressed: if (audio.sink && audio.sink.audio)
        audio.sink.audio.volume = Math.min(1, audio.sink.audio.volume + 0.05)
    Keys.onSpacePressed: if (audio.sink && audio.sink.audio)
        audio.sink.audio.muted = !audio.sink.audio.muted
    Keys.onReturnPressed: {
      const l = audio.sinks;
      if (audio.selected < l.length)
        Pipewire.preferredDefaultAudioSink = l[audio.selected];
      audio.hide();
    }
  }

  ColumnLayout {
    id: audioBody
    anchors.fill: parent
    anchors.margins: 10
    spacing: 8

    MonoText {
      text: "output"
      color: Theme.muted
      font.pixelSize: 11
    }

    // Master volume: a plain rectangle track, no Controls styling.
    Rectangle {
      Layout.fillWidth: true
      implicitHeight: 14
      radius: 3
      color: Theme.base

      Rectangle {
        width: parent.width * (audio.sink && audio.sink.audio && !audio.sink.audio.muted
                               ? audio.sink.audio.volume : 0)
        height: parent.height
        radius: 3
        color: audio.sink && audio.sink.audio && audio.sink.audio.muted
               ? Theme.muted : Theme.text
      }

      MouseArea {
        anchors.fill: parent
        function setVol(mx: real): void {
          if (!audio.sink || !audio.sink.audio) return;
          audio.sink.audio.volume = Math.max(0, Math.min(1, mx / width));
        }
        onPressed: mouse => setVol(mouse.x)
        onPositionChanged: mouse => { if (pressed) setVol(mouse.x); }
      }
    }

    RowLayout {
      Layout.fillWidth: true

      MonoText {
        Layout.fillWidth: true
        elide: Text.ElideRight
        text: audio.sink
              ? (audio.sink.nickname || audio.sink.description || audio.sink.name)
              : "no sink"
        font.pixelSize: 11
      }

      MonoText {
        text: audio.sink && audio.sink.audio && audio.sink.audio.muted ? "unmute" : "mute"
        font.pixelSize: 11

        MouseArea {
          anchors.fill: parent
          onClicked: {
            if (audio.sink && audio.sink.audio)
              audio.sink.audio.muted = !audio.sink.audio.muted;
          }
        }
      }
    }

    Rectangle {
      Layout.fillWidth: true
      implicitHeight: 1
      color: Theme.overlay
    }

    MonoText {
      text: "devices"
      color: Theme.muted
      font.pixelSize: 11
    }

    Repeater {
      model: audio.sinks

      Rectangle {
        id: sinkRow
        required property var modelData
        required property int index

        Layout.fillWidth: true
        implicitHeight: 20
        radius: Theme.radius
        color: sinkRow.index === audio.selected ? Theme.chipHover : "transparent"

        Behavior on color { ColorAnimation { duration: 100 } }

        MonoText {
          anchors.verticalCenter: parent.verticalCenter
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: 6
          anchors.rightMargin: 6
          elide: Text.ElideRight
          text: (Pipewire.defaultAudioSink === sinkRow.modelData ? "> " : "  ")
                + (sinkRow.modelData.nickname || sinkRow.modelData.description
                   || sinkRow.modelData.name)
          color: Pipewire.defaultAudioSink === sinkRow.modelData ? Theme.good : Theme.text
          font.pixelSize: 11
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onEntered: audio.selected = sinkRow.index
          onClicked: {
            Pipewire.preferredDefaultAudioSink = sinkRow.modelData;
            audio.hide();
          }
        }
      }
    }
  }
}
