import QtQuick

// Small rounded button of the panels: filled with the accent colour when active. Use:
// Chip { label: "1.25x"; active: current === 1.25; onPressed: ... }
Rectangle {
  id: chip

  property string label
  property bool active

  signal pressed

  width: Math.max(38, chipText.implicitWidth + 16)
  height: 28
  radius: 8
  color: active ? Theme.accent : (area.containsMouse ? Theme.track : "transparent")
  border.color: active ? Theme.accent : Theme.track
  border.width: 1

  Text {
    id: chipText
    anchors.centerIn: parent
    text: chip.label
    color: chip.active ? "#1e1e2e" : Theme.fg
    font.family: Theme.font
    font.pixelSize: 12
    font.bold: chip.active
  }

  MouseArea {
    id: area
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    onClicked: chip.pressed()
  }
}
