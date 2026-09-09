// The battery readout, shared by the bar and the lock screen. State lives in
// the Battery singleton so the polling happens once no matter how many of these
// exist; this is only the visual.
Chip {
  visible: Battery.present
  // The bar makes the chip a button; the lock screen does not.
  interactive: false

  accent: Battery.charging ? Theme.goodTint
        : !Battery.online && Battery.percent < 0.15 ? Theme.critTint
        : "transparent"

  // "5h 8w 97%": the muted details first, the percentage beside the icon it
  // belongs to.
  MonoText {
    visible: text !== ""
    text: Battery.time
    color: Theme.muted
  }

  MonoText {
    visible: Battery.watts > 0.1
    text: Battery.watts.toFixed(0) + "w"
    color: Theme.muted
  }

  MonoText { text: Math.round(Battery.percent * 100) + "%" }

  Icon { name: Battery.icon }
}
