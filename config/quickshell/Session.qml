pragma Singleton

import Quickshell

// Shell-wide state. Both fields are read from every output's bar and written
// from the IPC handlers in shell.qml.
Singleton {
  id: session

  // Only one menu surface is open at a time. Mirrors the sway config's
  // `pkill -x fuzzel || ...` idiom: pressing a menu key while a menu is up
  // dismisses it rather than stacking another on top.
  property string openMenu: ""

  property bool locked: false

  function toggleMenu(name: string): void {
    session.openMenu = session.openMenu === name ? "" : name;
  }
}
