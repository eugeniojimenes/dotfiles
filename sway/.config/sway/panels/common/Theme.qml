pragma Singleton
import QtQuick

// Colours and font of every panel: Catppuccin Mocha, same as waybar and the terminal.
QtObject {
  readonly property color bg: "#f21e1e2e"
  readonly property color fg: "#cdd6f4"
  readonly property color dim: "#6c7086"
  readonly property color accent: "#89b4fa"
  readonly property color error: "#f38ba8"
  readonly property color track: "#313244"
  readonly property string font: "JetBrainsMono Nerd Font"
}
