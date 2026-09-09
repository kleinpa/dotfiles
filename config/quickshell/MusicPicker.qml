import QtQuick
import QtQuick.Layouts

// Search the library by artist, then Tab (or Right) into that artist's albums
// and search those. Replaces scripts/mpd-search.sh, which listed every file as
// a flat path -- Picker's startsWith tier never fires against a path, so all
// 1155 rows fell into one alphabetical bucket.
//
// Two levels, not ncmpcpp's three: the third column there is tracks, and the
// search box is a poor fit for picking one track out of an album you can
// already play in order.
Picker {
  id: music

  menu: "music"
  // mpd may simply not be running -- its user service can lose the race with
  // the shell at login. Say so rather than showing an empty list that reads
  // like a search that found nothing.
  notice: Mpd.connected ? "" : "mpd unavailable"
  // Empty at the artist level, otherwise the artist that was drilled into.
  property string artist: ""

  // The placeholder doubles as the breadcrumb, which is what the box shows at
  // exactly the moment it matters -- straight after drilling in, before
  // anything is typed.
  placeholder: music.artist === "" ? "artist" : music.artist
  // `sub` is a track count, not a second name, so leave it out of search:
  // matching "2" against "12 tracks" is noise, not a result.
  matchSub: false

  // Only artists with a release of their own. Someone whose every track is
  // on a compilation is not an artist you browse to; they are a track on
  // someone else's record. See Mpd.ownRelease for how that is decided.
  readonly property var artistEntries: Mpd.artists
    .filter(a => Mpd.ownRelease[a.name] === true)
    .map(a => ({
    name: a.name,
    sub: a.songs + (a.songs === 1 ? " track" : " tracks"),
    icon: "",
    run: () => Mpd.playArtist(a.name)
  }))

  readonly property var albumEntries:
    // Ignore a reply that belongs to a different artist than the one on screen.
    Mpd.albumsArtist !== music.artist ? [] : Mpd.albums.map(a => ({
      name: a.name,
      sub: a.songs + (a.songs === 1 ? " track" : " tracks"),
      icon: "",
      run: () => Mpd.playAlbum(music.artist, a.name)
    }))

  entries: music.artist === "" ? music.artistEntries : music.albumEntries

  onDrillIn: entry => {
    // Albums are the last level; Tab there has nowhere to go.
    if (music.artist !== "") return;
    music.artist = entry.name;
    music.query = "";
    music.selected = 0;
    Mpd.loadAlbums(entry.name);
  }

  onDrillOut: {
    if (music.artist === "") return;
    music.artist = "";
    music.query = "";
    music.selected = 0;
  }

  // Reshuffled every time the panel opens, so a bare Enter is "play me
  // something" rather than always the first artist alphabetically. Only with
  // an empty query: once you are typing, you are looking for a specific
  // artist and alphabetical order within each match tier is what helps.
  property int shuffleSeed: 0

  sortKey: music.artist === "" && music.query === ""
           ? (entry => music.shuffleRank(entry.name))
           : null

  // Hashed from the name rather than drawn per entry, so the order is stable
  // while the panel is open no matter when the artist list arrives, and
  // rerolls only when the seed does.
  function shuffleRank(name: string): int {
    let h = music.shuffleSeed >>> 0;
    for (let i = 0; i < name.length; i++) {
      h = Math.imul(h ^ name.charCodeAt(i), 16777619) >>> 0;
    }
    return h;
  }

  // Connections, not an onOpened handler: declaring one here would replace
  // Picker's own, which is what claims keyboard focus.
  Connections {
    target: music
    function onOpened(): void {
      music.shuffleSeed = Math.floor(Math.random() * 2147483647);
    }
  }

  // mm:ss, blank when there is no usable time.
  function clock(seconds: real): string {
    if (!(seconds > 0)) return "";
    const total = Math.floor(seconds);
    return Math.floor(total / 60) + ":" + String(total % 60).padStart(2, "0");
  }

  // What is playing, above the search field -- whichever source it is. The
  // track, artist and album read the same for any player; only the detail
  // line below them is mpd-specific, and it is simply absent otherwise.
  header: Component {
    ColumnLayout {
      spacing: 1
      visible: Player.active

      RowLayout {
        Layout.fillWidth: true
        spacing: 6

        MonoText {
          text: Player.sourceName
          color: Player.playing ? Theme.good : Theme.muted
          font.pixelSize: 11
        }

        Item { Layout.fillWidth: true }

        MonoText {
          visible: text !== ""
          text: {
            const d = music.clock(Player.duration);
            if (d === "") return "";
            const e = music.clock(Player.elapsed);
            return e === "" ? d : e + " / " + d;
          }
          color: Theme.muted
          font.pixelSize: 11
        }
      }

      MonoText {
        Layout.fillWidth: true
        elide: Text.ElideRight
        text: Player.title
        font.pixelSize: 14
      }

      MonoText {
        Layout.fillWidth: true
        elide: Text.ElideRight
        visible: text !== ""
        text: {
          const bits = [];
          if (Player.artist !== "") bits.push(Player.artist);
          if (Player.album !== "") bits.push(Player.album);
          return bits.join("  \u00b7  ");
        }
        color: Theme.subtle
        font.pixelSize: 11
      }

      MonoText {
        Layout.fillWidth: true
        elide: Text.ElideRight
        visible: text !== ""
        text: Player.detail
        color: Theme.muted
        font.pixelSize: 10
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.topMargin: 6
        implicitHeight: 1
        color: Theme.overlay
      }
    }
  }

  // Connections rather than an onClosed handler: declaring one here would
  // replace Picker's own, which is what clears the query.
  Connections {
    target: music
    function onClosed(): void { music.artist = ""; }
  }
}
