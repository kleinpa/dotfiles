pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

// A filterable list overlay: search field plus ranked results. The launcher and
// the power menu are both instances of this.
Dropdown {
  id: picker

  // Each entry: { name, sub, icon, run }.
  property var entries: []
  property string placeholder: "search"
  // Whether `sub` is searchable as well as `name`. Off for pickers whose sub
  // is a stat rather than a second name -- matching "2" against "12 tracks"
  // is noise, not a result.
  property bool matchSub: true
  // Entry ids or names to sort ahead of the rest when results tie -- which,
  // with an empty query, is all of them. Lets a picker park its most likely
  // answer under the cursor so Enter alone does the common thing.
  property var pinned: []
  // Optional replacement for the alphabetical tiebreak: a function taking an
  // entry and returning something comparable. Null leaves ordering by name.
  property var sortKey: null
  // Optional block above the search field. Null for a plain picker, so the
  // launcher and power menu are unchanged.
  property Component header: null

  // Set when the picker has nothing to offer -- a backend that is not there,
  // say. The search field goes dead and this is shown instead of the results,
  // rather than leaving an empty list that looks like a failed search.
  property string notice: ""
  readonly property bool usable: picker.notice === ""
  property string query: ""
  property int selected: 0

  readonly property var results: {
    const q = picker.query.trim().toLowerCase();
    const scored = [];
    for (const e of picker.entries) {
      if (q === "") { scored.push({ e: e, rank: 0 }); continue; }
      const name = (e.name || "").toLowerCase();
      const sub = (e.sub || "").toLowerCase();
      let rank = -1;
      if (name.startsWith(q)) rank = 0;
      else if (name.includes(q)) rank = 1;
      else if (picker.matchSub && sub.includes(q)) rank = 2;
      if (rank >= 0) scored.push({ e: e, rank: rank });
    }
    const key = picker.sortKey;
    scored.sort((a, b) => {
      const byRank = a.rank - b.rank;
      if (byRank !== 0) return byRank;
      const byPin = picker.pinRank(a.e) - picker.pinRank(b.e);
      if (byPin !== 0) return byPin;
      if (key) {
        const ka = key(a.e), kb = key(b.e);
        if (ka !== kb) return ka < kb ? -1 : 1;
        return 0;
      }
      return a.e.name.localeCompare(b.e.name);
    });
    return scored.slice(0, 40).map(x => x.e);
  }

  onQueryChanged: picker.selected = 0

  // Optional hierarchy. Unconnected by default, so a flat picker is unchanged
  // and Tab/Left/Right keep their ordinary meaning there.
  signal drillIn(entry: var)
  signal drillOut

  // Matches an entry against `pinned` by id or name, case-insensitively and
  // ignoring a .desktop suffix, so callers do not have to know which form a
  // given backend hands back.
  function pinRank(entry: var): int {
    if (picker.pinned.length === 0) return 0;
    const keys = [];
    if (entry.id) keys.push(String(entry.id).toLowerCase().replace(/\.desktop$/, ""));
    if (entry.name) keys.push(String(entry.name).toLowerCase());
    for (let i = 0; i < picker.pinned.length; i++) {
      if (keys.includes(String(picker.pinned[i]).toLowerCase())) return i;
    }
    return picker.pinned.length;
  }

  function currentEntry(): var {
    const r = picker.results;
    if (r.length === 0) return null;
    return r[Math.max(0, Math.min(picker.selected, r.length - 1))];
  }

  function run(): void {
    const item = picker.currentEntry();
    if (item === null) return;
    picker.hide();
    item.run();
  }

  function tryDrill(): void {
    const item = picker.currentEntry();
    if (item !== null) picker.drillIn(item);
  }

  anchors.horizontalCenter: parent.horizontalCenter
  width: 560
  panelHeight: Math.min(420, pickerBody.implicitHeight + 24)

  // Several panels share one window, so claim focus explicitly on open rather
  // than relying on the initial value. With the field disabled it cannot hold
  // focus, and the bar keeps an exclusive keyboard grab while a menu is open,
  // so Escape needs somewhere else to land or there is no way out but the
  // mouse.
  onOpened: {
    if (picker.usable) pickerInput.forceActiveFocus();
    else pickerKeys.forceActiveFocus();
  }

  Item {
    id: pickerKeys
    anchors.fill: parent
    Keys.onEscapePressed: picker.hide()
  }
  onClosed: {
    picker.query = "";
    picker.selected = 0;
  }

  ColumnLayout {
    id: pickerBody
    anchors.fill: parent
    anchors.margins: 12
    spacing: 10

    Loader {
      Layout.fillWidth: true
      active: picker.header !== null
      sourceComponent: picker.header
    }

    TextInput {
      id: pickerInput
      Layout.fillWidth: true
      Layout.preferredHeight: 24
      verticalAlignment: TextInput.AlignVCenter
      enabled: picker.usable
      color: Theme.text
      font.family: Theme.mono
      font.pixelSize: 15
      text: picker.query
      onTextChanged: picker.query = text

      MonoText {
        anchors.verticalCenter: parent.verticalCenter
        text: picker.placeholder
        color: Theme.muted
        font.pixelSize: 15
        visible: pickerInput.text === ""
      }

      Keys.onEscapePressed: picker.hide()
      Keys.onReturnPressed: picker.run()
      Keys.onEnterPressed: picker.run()
      Keys.onDownPressed: picker.selected =
          Math.min(picker.selected + 1, picker.results.length - 1)
      Keys.onUpPressed: picker.selected = Math.max(picker.selected - 1, 0)

      // Tab is unambiguous. The arrows have to share with the text cursor, so
      // they only navigate the hierarchy from the end or the start of the
      // query, where there is no character left to move over -- editing what
      // you typed still works normally.
      Keys.onTabPressed: event => {
        picker.tryDrill();
        event.accepted = true;
      }

      Keys.onRightPressed: event => {
        const atEnd = pickerInput.cursorPosition === pickerInput.text.length;
        if (atEnd) picker.tryDrill();
        event.accepted = atEnd;
      }

      Keys.onLeftPressed: event => {
        const atStart = pickerInput.cursorPosition === 0;
        if (atStart) picker.drillOut();
        event.accepted = atStart;
      }

      // Backspace on an empty query pops out, the way it would erase the last
      // thing typed if there were anything to erase.
      Keys.onPressed: event => {
        if (event.key === Qt.Key_Backspace && pickerInput.text === "") {
          picker.drillOut();
          event.accepted = true;
        }
      }
    }

    MonoText {
      Layout.fillWidth: true
      visible: !picker.usable
      text: picker.notice
      color: Theme.muted
    }

    ListView {
      id: pickerList
      visible: picker.usable
      Layout.fillWidth: true
      Layout.fillHeight: true
      implicitHeight: contentHeight
      clip: true
      model: picker.results
      currentIndex: picker.selected
      boundsBehavior: Flickable.StopAtBounds

      delegate: Rectangle {
        id: pickRow
        required property var modelData
        required property int index

        width: pickerList.width
        height: 28
        radius: Theme.radius
        color: pickRow.index === picker.selected ? Theme.chipHover : "transparent"

        Behavior on color { ColorAnimation { duration: 100 } }

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 8
          anchors.rightMargin: 8
          spacing: 9

          Image {
            source: pickRow.modelData.icon
                    ? Quickshell.iconPath(pickRow.modelData.icon, true) : ""
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            // Without these, non-square icons stretch to the box and scalable
            // ones rasterise at the wrong size.
            fillMode: Image.PreserveAspectFit
            sourceSize.width: 18
            sourceSize.height: 18
            mipmap: true
            smooth: true
            asynchronous: true
            visible: source !== ""
          }

          MonoText {
            Layout.fillWidth: true
            elide: Text.ElideRight
            text: pickRow.modelData.name
            font.pixelSize: 13
          }

          MonoText {
            Layout.maximumWidth: 240
            elide: Text.ElideRight
            visible: text !== ""
            text: pickRow.modelData.sub || ""
            color: Theme.muted
            font.pixelSize: 11
          }
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onEntered: picker.selected = pickRow.index
          onClicked: {
            picker.selected = pickRow.index;
            picker.run();
          }
        }
      }
    }
  }
}
