pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

// One place deciding which player the shell means, so the bar chip and the
// media keys can never disagree about it. Same role Net.qml plays for network
// devices.
//
// Two backends sit behind this: MPRIS for ordinary desktop apps, and Mpd,
// which speaks mpd's own protocol because mpd exposes no MPRIS interface.
// Library browsing deliberately stays off this interface -- MPRIS cannot
// express it, so a picker has to talk to a backend directly.
Singleton {
  id: player

  // Proxies, not players. Each mirrors a real player, so counting them shows
  // the same media twice -- which inflates playingCount into thinking two
  // things are playing when only one is -- and playerctld additionally keeps
  // advertising the last track it saw long after that player is gone, a stale
  // entry that would outrank anything actually playing.
  readonly property var proxySuffixes: [
    ".playerctld",
    ".plasma-browser-integration"
  ]

  readonly property var candidates: Mpris.players.values.filter(
    p => !player.proxySuffixes.some(suffix => p.dbusName.endsWith(suffix)))

  // Which MPRIS player last played. "mpris" alone is too coarse a memory:
  // pause the browser and the fallback would hand the next press to whichever
  // player happened to sort first, which is how pausing YouTube twice started
  // Spotify.
  property string lastMprisName: ""

  readonly property var mprisPlayer: {
    for (const p of player.candidates) {
      if (p.playbackState === MprisPlaybackState.Playing) return p;
    }
    // Nothing playing: the one that played most recently, while it lasts.
    for (const p of player.candidates) {
      if (p.dbusName === player.lastMprisName) return p;
    }
    return player.candidates.length > 0 ? player.candidates[0] : null;
  }

  readonly property bool mprisPlaying:
    player.mprisPlayer !== null
    && player.mprisPlayer.playbackState === MprisPlaybackState.Playing

  // Which source last actually played. Selection needs a memory: deciding
  // purely on who is playing right now means pausing something makes it lose
  // priority, so a second press of play/pause lands on a different player --
  // pause mpd, and the next press starts whatever else happens to be open.
  property string lastSource: ""

  readonly property bool mpdPlaying: Mpd.playing
  onMpdPlayingChanged: {
    if (!player.mpdPlaying) return;
    player.lastSource = "mpd";
    // Starting mpd is an explicit "play this now", so anything else making
    // noise gets out of the way. Only in this direction: mpd never pauses
    // itself for something else, which would be guessing.
    player.pauseMpris();
  }

  // Track changes count too, including mpd advancing through its own queue.
  readonly property string mpdTitle: Mpd.title
  onMpdTitleChanged: if (Mpd.playing) player.pauseMpris()

  function pauseMpris(): void {
    for (const p of player.candidates) {
      if (p.playbackState === MprisPlaybackState.Playing && p.canPause) p.pause();
    }
  }
  onMprisPlayingChanged: {
    if (!player.mprisPlaying) return;
    player.lastSource = "mpris";
    player.lastMprisName = player.mprisPlayer ? player.mprisPlayer.dbusName : "";
  }

  readonly property bool useMpd: {
    // Exactly one playing is unambiguous.
    if (Mpd.playing && !player.mprisPlaying) return true;
    if (player.mprisPlaying && !Mpd.playing) return false;

    // Both, or neither: stay with whatever played last, so pausing does not
    // hand the next keypress away.
    //
    // Keyed on the source still being *available*, not on it currently having
    // a track. Testing Mpd.active here meant the memory evaporated the moment
    // mpd stopped -- so running off the end of the queue read as "you meant
    // the other player", and the next press started Spotify. Which source you
    // mean and whether it has anything queued are different questions.
    if (player.lastSource === "mpd" && Mpd.connected) return true;
    if (player.lastSource === "mpris" && player.mprisPlayer !== null) return false;

    // Nothing has played yet this session. A paused mpd with a track loaded
    // is a better guess than a merely-open MPRIS app, which is often just a
    // background window someone never closed.
    return Mpd.active;
  }

  readonly property bool active:
    player.useMpd ? Mpd.active : player.mprisPlayer !== null
  readonly property bool playing:
    player.useMpd ? Mpd.playing : player.mprisPlaying

  readonly property string artist: {
    if (player.useMpd) return Mpd.artist;
    return player.mprisPlayer && player.mprisPlayer.trackArtist
         ? player.mprisPlayer.trackArtist : "";
  }

  readonly property string title: {
    if (player.useMpd) return Mpd.title;
    return player.mprisPlayer && player.mprisPlayer.trackTitle
         ? player.mprisPlayer.trackTitle : "";
  }

  // --- now playing, for the music panel ------------------------------------
  // The uniform half: whatever is playing, whichever source it came from.
  readonly property string sourceName:
    player.useMpd ? "mpd"
    : player.mprisPlayer ? player.mprisPlayer.identity : ""

  readonly property string album: {
    if (player.useMpd) return Mpd.album;
    return player.mprisPlayer && player.mprisPlayer.trackAlbum
         ? player.mprisPlayer.trackAlbum : "";
  }

  readonly property real elapsed: {
    if (player.useMpd) return Mpd.elapsed;
    if (!player.mprisPlayer || !player.mprisPlayer.positionSupported) return 0;
    return player.mprisPlayer.position;
  }

  readonly property real duration: {
    if (player.useMpd) return Mpd.duration;
    if (!player.mprisPlayer || !player.mprisPlayer.lengthSupported) return 0;
    return player.mprisPlayer.length;
  }

  // Only mpd earns a detail line. Queue position and audio format are things
  // a local library knows; MPRIS's equivalent was a bare "track 2", which
  // said nothing the album line above it had not already said.
  readonly property string detail: player.useMpd ? Mpd.detail : ""

  // A player that has sat paused for this long stops being news. MPRIS
  // sources self-remove when the app quits, but mpd is a daemon that never
  // goes away, so without this a track paused days ago still occupies the bar.
  // Cosmetic only -- the media keys still act on whatever is selected.
  readonly property int staleAfterMs: 60000
  property bool stale: false

  onPlayingChanged: if (player.playing) player.stale = false
  readonly property string nowTitle: player.title
  onNowTitleChanged: player.stale = false

  Timer {
    interval: player.staleAfterMs
    // Stops itself by making this false once it fires, rather than repeating.
    running: player.active && !player.playing && !player.stale
    onTriggered: player.stale = true
  }

  // Everything currently making sound. More than one is a state worth naming:
  // two sources playing at once is never intentional, and the key that gets
  // reached for is play/pause.
  readonly property int playingCount: {
    let n = Mpd.playing ? 1 : 0;
    for (const p of player.candidates) {
      if (p.playbackState === MprisPlaybackState.Playing) n++;
    }
    return n;
  }

  function pauseAll(): void {
    if (Mpd.playing) Mpd.togglePlaying();
    for (const p of player.candidates) {
      if (p.playbackState === MprisPlaybackState.Playing && p.canPause) p.pause();
    }
  }

  function togglePlaying(): void {
    // With several sources playing, the key silences all of them rather than
    // toggling whichever one happens to be selected -- otherwise pausing one
    // just leaves the other audible and the key feels broken. A second press
    // then starts the one source that was playing last, so double-tapping is
    // the way out of the tangle.
    if (player.playingCount > 1) {
      player.pauseAll();
      return;
    }

    if (player.useMpd) Mpd.togglePlaying();
    else if (player.mprisPlayer) player.mprisPlayer.togglePlaying();
  }

  function next(): void {
    if (player.useMpd) Mpd.next();
    else if (player.mprisPlayer) player.mprisPlayer.next();
  }

  function previous(): void {
    if (player.useMpd) Mpd.previous();
    else if (player.mprisPlayer) player.mprisPlayer.previous();
  }
}
