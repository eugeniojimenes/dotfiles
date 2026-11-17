import QtQuick

// The card a popup panel draws its content on: under the bar at the right edge, rounded, panel background, accent
// border. It swallows clicks, so they never reach PanelShell's close-on-outside area. A panel sets width and height,
// and zoom when it draws bigger (display, power and calendar: 1.2, grown from the top right corner). A centred panel
// (calendar) re-anchors and sets transformOrigin itself.
Rectangle {
  property real zoom: 1

  anchors.right: parent.right
  anchors.rightMargin: 10
  y: 34
  scale: zoom
  transformOrigin: Item.TopRight
  radius: 12
  color: Theme.bg
  border.color: Theme.accent
  border.width: 2

  MouseArea { anchors.fill: parent }
}
