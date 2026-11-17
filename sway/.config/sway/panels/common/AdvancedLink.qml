import QtQuick
import Quickshell

// Footer link to the full TUI of a panel: opens `command` in a floating terminal (bin/float), then closes the panel.
// `command` = argv after float, e.g. ["nmtui"].
Text {
  id: link
  required property var command

  color: area.containsMouse ? Theme.fg : Theme.dim
  font.family: Theme.font
  font.pixelSize: 13

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    onClicked: {
      Quickshell.execDetached([Quickshell.env("HOME") + "/.config/sway/bin/float"].concat(link.command))
      Qt.quit()
    }
  }
}
