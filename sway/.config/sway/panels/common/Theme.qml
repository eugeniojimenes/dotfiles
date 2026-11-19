pragma Singleton
import QtQuick

// Colours and font of every panel: Catppuccin Mocha, same as waybar and the terminal. The only place panels take a
// colour from; a translucent one = Qt.alpha(Theme.<name>, a). Names: Catppuccin's, then what the panels use them for.
QtObject {
  readonly property color base: "#1e1e2e" // text on an accent fill (chips, today, switches)
  readonly property color crust: "#11111b" // screensaver backdrop
  readonly property color surface1: "#45475a" // lock field border at rest
  readonly property color subtext0: "#a6adc8" // secondary text over a photo (lock, screensaver)
  readonly property color bg: Qt.alpha(base, 0.95)
  readonly property color fg: "#cdd6f4"
  readonly property color dim: "#6c7086"
  readonly property color accent: "#89b4fa"
  readonly property color error: "#f38ba8"
  readonly property color track: "#313244"
  readonly property color playing: "#89dceb" // waybar track while it plays
  readonly property string font: "JetBrainsMono Nerd Font"
}
