pragma Singleton

import Quickshell
import QtQuick

// Palette and metrics for the whole shell. Greyscale, carried over from the
// waybar stylesheet this replaces: white on a translucent dark ground, with
// colour reserved for state.
Singleton {
  readonly property color base: "#111111"
  readonly property color overlay: "#2b2b2b"
  readonly property color muted: "#888888"
  readonly property color subtle: "#969896"
  readonly property color text: "#ffffff"
  // The two state colours, used as text (an enabled toggle, the active sink)
  // and, through the tints below, as chip fills. Nothing else is coloured.
  readonly property color good: "#26a65b"
  readonly property color crit: "#f53c3c"

  // Bar and dropdown ground, shared so there is no seam where a panel meets the
  // strip: rgba(17,17,17,0.88). Waybar's stylesheet used 0.7, but Hyprland
  // blurred what was behind the dropdowns, and that blur is what made 0.7
  // legible over arbitrary windows. Sway has none, so this sits well above it
  // -- still translucent over the wallpaper, opaque enough to read a list on.
  readonly property color ground: "#e0111111"
  // Chip fill on that ground, and its hover: rgba(255,255,255,0.07) and 0.12.
  readonly property color chip: "#12ffffff"
  readonly property color chipHover: "#1fffffff"
  // Focused workspace pill, and the grey a muted audio chip takes.
  readonly property color chipActive: "#2effffff"
  readonly property color mutedTint: "#40888888"
  // Chip fills for those states: charging and playing, critical battery and
  // no network. The same two hues at 55% alpha, so white text keeps its
  // contrast on them. Solid accents are too light for white text (3.1:1) and
  // the muted grey vanishes on them entirely (1.1:1); over the dark ground
  // the light-on-dark hierarchy survives -- white reads at 7:1, grey stays
  // legibly dimmer.
  readonly property color goodTint: "#8c26a65b"
  readonly property color critTint: "#8cf53c3c"

  // The sway config asks for RobotoMono, which fontconfig may know under
  // either name. QML's font value type takes one family, not a list, so the
  // first installed candidate is picked here instead.
  readonly property string mono: Theme.pickFont(["Roboto Mono", "RobotoMono"], "monospace")

  function pickFont(candidates: var, fallback: string): string {
    const installed = Qt.fontFamilies();
    for (const c of candidates) {
      if (installed.includes(c)) return c;
    }
    return fallback;
  }

  // The wallpaper sway sets, reused by the lock screen. install.sh links the
  // repo's background/ to ~/.background, which is the path the sway config
  // names too.
  readonly property string wallpaper:
    Quickshell.env("HOME") + "/.background/midnight_basil.jpg"
  // Dimmed rather than blurred, so the lock screen stays legible without a
  // MultiEffect pass over a 5k image.
  readonly property color scrim: "#99111111"

  // Single source of truth for the bar's height, which the dropdowns hang from.
  // Sized so a 22px chip clears the strip by 3px above and below.
  readonly property int barHeight: 28
  readonly property int fontSize: 12
  // Symbolic icons are drawn on a 16px grid, and the chips' content height is
  // 16 too, so this is the one size at which they render pixel-exact.
  readonly property int iconSize: 16
  readonly property int radius: 4
  readonly property int menuRadius: 8
}
