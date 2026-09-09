pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// A small mpd client. mpd has no MPRIS interface of its own, so without this
// the bar shows nothing while music is playing; mpdris2 would fill that gap,
// but then mpd would also appear as a second source the moment anything else
// proxies it.
//
// The socket path is mpd's own default, so this needs no mpd.conf. There is no
// TCP fallback: Quickshell's Socket speaks unix sockets only, and a host that
// has disabled the default socket has opted out of this.
Singleton {
  id: mpd

  readonly property string socketPath:
    (Quickshell.env("XDG_RUNTIME_DIR") || "/run/user/1000") + "/mpd/socket"

  // --- what the rest of the shell reads ------------------------------------
  property bool playing: false
  // Distinct from !playing: paused still has a current track.
  property bool stopped: true
  property string artist: ""
  property string title: ""
  property string album: ""
  property string date: ""

  // Detail for the now-playing panel. Queue position and audio format are
  // things only a local library knows, which is what makes mpd's readout
  // different from a streaming player's.
  property real elapsed: 0
  property real duration: 0
  property int queuePos: 0
  property int queueLength: 0
  property string audioFormat: ""
  property int bitrate: 0

  // Queue position and audio format: the things a local library knows that a
  // streaming player cannot say.
  readonly property string detail: {
    const bits = [];
    if (mpd.queueLength > 0)
      bits.push((mpd.queuePos + 1) + " of " + mpd.queueLength + " in queue");
    // mpd reports "44100:16:2" -- rate, sample size, channels.
    const f = mpd.audioFormat.split(":");
    if (f.length >= 2 && Number(f[0]) > 0)
      bits.push((Number(f[0]) / 1000).toFixed(1) + " kHz " + f[1] + " bit");
    if (mpd.bitrate > 0) bits.push(mpd.bitrate + " kbps");
    return bits.join("  \u00b7  ");
  }
  readonly property bool active: mpd.title !== ""

  // [{ name, songs }], for the music picker. `albumartist`, not `artist`: this
  // picker mirrors a shelf of records, so the unit is whoever the album is
  // credited to. That drops ~26 names who only ever appear as featured
  // artists on someone else's record, which is the intended omission.
  property var artists: []

  // albumartist -> true for anyone who has an album that is theirs alone.
  // An album title listed under more than one albumartist is a compilation
  // -- a "Now" CD or a label sampler, where every track carries its own
  // artist as albumartist and there is no "Various Artists" to key on. An
  // artist whose only appearances are on those has no release of their own.
  // A one-track single counts, since its one albumartist is the artist.
  property var ownRelease: ({})

  // Albums of one artist, fetched when the picker drills in. `albumsArtist`
  // says who they belong to, so a slow reply for a previous artist cannot be
  // mistaken for the current one's.
  property var albums: []
  property string albumsArtist: ""

  // --- protocol ------------------------------------------------------------
  // mpd is line oriented: a command is answered by any number of "key: value"
  // lines then a bare OK (or ACK on error). `pending` holds the labels of
  // commands whose OK has not arrived, so each response can be matched to the
  // command that asked for it. Responses accumulate into `rows` as an array,
  // not a map: `count group artist` repeats every key.
  property bool idling: false
  property var pending: []
  property var rows: []

  function quote(v: string): string {
    return '"' + v.replace(/\\/g, "\\\\").replace(/"/g, '\\"') + '"';
  }

  // The live socket, or null while there is none. Quickshell's Socket cannot
  // re-attempt a connection once one has failed, so reconnecting means
  // building a new one rather than poking this.
  readonly property var conn: sockLoader.item
  readonly property bool connected: mpd.conn !== null && mpd.conn.connected

  function send(text: string, label: string): void {
    if (!mpd.connected) return;
    mpd.pending.push(label);
    mpd.conn.write(text + "\n");
    mpd.conn.flush();
  }

  function refresh(): void {
    mpd.send("status", "status");
    mpd.send("currentsong", "currentsong");
  }

  function loadArtists(): void {
    // Releases first: mpd answers in order, so ownRelease is populated by the
    // time the artist list lands and anything filtering on it sees both.
    mpd.send("list album group albumartist", "releases");
    mpd.send("count group albumartist", "artists");
  }

  function loadAlbums(name: string): void {
    mpd.albumsArtist = name;
    mpd.albums = [];
    mpd.query("count albumartist " + mpd.quote(name) + " group album", "albums");
  }

  // `idle` is what makes this push rather than poll: mpd holds the request
  // open and answers only when something changes, so nothing ticks on an idle
  // laptop. `database` is included so the picker reloads after an update.
  function enterIdle(): void {
    if (mpd.idling || mpd.pending.length > 0) return;
    mpd.idling = true;
    mpd.send("idle player database", "idle");
  }

  // A pending idle must be cancelled before mpd will look at anything else.
  // noidle produces no reply of its own -- it makes the outstanding idle
  // return -- so nothing is pushed onto `pending` for it.
  function command(text: string, label: string): void {
    if (mpd.idling) {
      mpd.conn.write("noidle\n");
      mpd.conn.flush();
      mpd.idling = false;
    }
    mpd.send(text, label);
    mpd.refresh();
  }

  // A read that changes nothing, so it skips the status refresh a command
  // would otherwise trigger.
  function query(text: string, label: string): void {
    if (mpd.idling) {
      mpd.conn.write("noidle\n");
      mpd.conn.flush();
      mpd.idling = false;
    }
    mpd.send(text, label);
  }

  function togglePlaying(): void { mpd.command(mpd.playing ? "pause 1" : "play", "cmd"); }
  function next(): void { mpd.command("next", "cmd"); }
  function previous(): void { mpd.command("previous", "cmd"); }

  // Replace the queue with one artist, shuffled, and start it. A command list
  // so mpd applies the four as a unit and answers with a single OK.
  function playArtist(name: string): void {
    mpd.command(
      "command_list_begin\n"
      + "clear\n"
      + "findadd albumartist " + mpd.quote(name) + "\n"
      + "shuffle\n"
      + "play 0\n"
      + "command_list_end",
      "cmd");
  }

  // One album, in its own order -- shuffling an album is rarely what anyone
  // means, which is why this does not reuse playArtist's shuffle.
  function playAlbum(name: string, album: string): void {
    mpd.command(
      "command_list_begin\n"
      + "clear\n"
      + "findadd albumartist " + mpd.quote(name) + " album " + mpd.quote(album) + "\n"
      + "play 0\n"
      + "command_list_end",
      "cmd");
  }

  function handleLine(line: string): void {
    if (line.startsWith("OK MPD")) {
      // Greeting: any state from a previous connection is stale.
      mpd.pending = [];
      mpd.rows = [];
      mpd.idling = false;
      mpd.refresh();
      mpd.loadArtists();
      return;
    }

    if (line === "OK" || line.startsWith("ACK")) {
      // Tolerant of an empty queue rather than throwing: a desync should heal
      // on the next command instead of wedging the connection.
      const label = mpd.pending.length > 0 ? mpd.pending.shift() : "";
      mpd.finish(label);
      return;
    }

    const i = line.indexOf(": ");
    if (i > 0) mpd.rows.push([line.slice(0, i), line.slice(i + 2)]);
  }

  function value(key: string): string {
    for (const r of mpd.rows) {
      if (r[0] === key) return r[1];
    }
    return "";
  }

  function finish(label: string): void {
    if (label === "idle") {
      mpd.idling = false;
      // Reload the artist list only when the library itself changed; a track
      // change must not drag 400 lines across the socket.
      const dbChanged = mpd.rows.some(r => r[0] === "changed" && r[1] === "database");
      mpd.rows = [];
      mpd.refresh();
      if (dbChanged) mpd.loadArtists();
      return;
    }

    if (label === "status") {
      const state = mpd.value("state");
      mpd.playing = state === "play";
      // Only "stop" means there is no current track. Paused still has one,
      // and this must be tracked separately from `playing` -- keying the
      // currentsong handler off `playing` meant a connection opened while
      // paused never populated the track at all.
      mpd.stopped = state === "stop";
      if (mpd.stopped) {
        mpd.artist = "";
        mpd.title = "";
        mpd.album = "";
        mpd.date = "";
      }
      mpd.elapsed = Number(mpd.value("elapsed")) || 0;
      mpd.duration = Number(mpd.value("duration")) || 0;
      // `song` is the 0-based queue index; the panel shows it 1-based.
      mpd.queuePos = Number(mpd.value("song")) || 0;
      mpd.queueLength = Number(mpd.value("playlistlength")) || 0;
      mpd.audioFormat = mpd.value("audio");
      mpd.bitrate = Number(mpd.value("bitrate")) || 0;
    } else if (label === "currentsong") {
      if (!mpd.stopped) {
        mpd.artist = mpd.value("Artist") || mpd.value("AlbumArtist") || "";
        // Fall back to the filename for untagged files, as ncmpcpp does.
        mpd.title = mpd.value("Title") || mpd.value("Name") || mpd.value("file") || "";
        mpd.album = mpd.value("Album");
        mpd.date = mpd.value("Date");
      }
    } else if (label === "artists") {
      // "AlbumArtist: x" then "songs: n" then "playtime: n", repeating.
      const out = [];
      let name = "";
      for (const r of mpd.rows) {
        if (r[0] === "AlbumArtist") name = r[1];
        else if (r[0] === "songs" && name !== "") {
          out.push({ name: name, songs: Number(r[1]) || 0 });
          name = "";
        }
      }
      mpd.artists = out;
    } else if (label === "releases") {
      // "AlbumArtist: x" then that artist's "Album: y" lines, repeating.
      const byAlbum = {};
      let who = "";
      for (const r of mpd.rows) {
        if (r[0] === "AlbumArtist") who = r[1];
        else if (r[0] === "Album" && who !== "")
          (byAlbum[r[1]] = byAlbum[r[1]] || []).push(who);
      }
      const own = {};
      for (const album in byAlbum) {
        if (byAlbum[album].length === 1) own[byAlbum[album][0]] = true;
      }
      mpd.ownRelease = own;
    } else if (label === "albums") {
      // "Album: x" then "songs: n" then "playtime: n", repeating.
      const out = [];
      let name = "";
      for (const r of mpd.rows) {
        if (r[0] === "Album") name = r[1];
        else if (r[0] === "songs" && name !== "") {
          out.push({ name: name, songs: Number(r[1]) || 0 });
          name = "";
        }
      }
      mpd.albums = out;
    }

    mpd.rows = [];
    mpd.enterIdle();
  }


  Loader {
    id: sockLoader
    active: true

    sourceComponent: Socket {
      path: mpd.socketPath
      connected: true

      parser: SplitParser {
        splitMarker: "\n"
        onRead: data => mpd.handleLine(data)
      }

      onConnectionStateChanged: if (!connected) mpd.reset()
    }
  }

  function reset(): void {
    mpd.playing = false;
    mpd.stopped = true;
    mpd.artist = "";
    mpd.title = "";
    mpd.album = "";
    mpd.date = "";
    mpd.idling = false;
    mpd.pending = [];
    mpd.rows = [];
  }

  // `idle` answers on track changes, not on the clock, so elapsed would sit
  // still between them. Poll it only while the music panel is on screen and
  // something is playing -- which is the only time anyone can see it.
  Timer {
    interval: 1000
    repeat: true
    running: Session.openMenu === "music" && mpd.playing
    onTriggered: mpd.query("status", "status")
  }

  // Retry whenever there is no connection, rather than only after losing one.
  // mpd's user service can still be starting when the shell comes up at
  // login. Rebuilding the Loader's contents makes a fresh Socket: the same
  // object will not try again after a failed connect, so poking `connected`
  // -- in any combination -- is silently ignored.
  Timer {
    interval: 5000
    repeat: true
    running: !mpd.connected
    onTriggered: {
      sockLoader.active = false;
      sockLoader.active = true;
    }
  }
}
