import QtQuick
import Quickshell

// Link at the bottom of a panel, e.g. "󰒓  Advanced (nmtui)". A click opens the full program in a floating terminal
// (bin/float) and closes the panel. Use: AdvancedLink { text: "...  Advanced (nmtui)"; command: ["nmtui"] }
Text {
  id: link

  required property list<string> command

  color: area.containsMouse ? Theme.fg : Theme.dim
  font.family: Theme.font
  font.pixelSize: 13

  MouseArea {
    id: area
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    onClicked: {
      Quickshell.execDetached([Quickshell.env("HOME") + "/.config/sway/bin/float"].concat(link.command))
      Qt.quit()
    }
  }
}
