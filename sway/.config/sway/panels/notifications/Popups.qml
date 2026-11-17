import QtQuick
import Quickshell
import Quickshell.Wayland
import "notify.mjs" as Notify
import "../common"

// Popup window of the notification daemon (../notifications.qml): the hidden-notifications card on top, the deck of
// popups under it. Created only while there is something to show, so each time it maps Sway puts it on the focused
// output.
LazyLoader {
  id: loader

  required property var daemon

  active: daemon.popups.length > 0 || daemon.hiddenCount > 0

  PanelWindow {
    anchors { top: true; right: true }
    margins.top: 8 // qmllint disable unresolved-type
    margins.right: 10 // qmllint disable unresolved-type
    implicitWidth: 380
    implicitHeight: stack.implicitHeight
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "sway-notifications"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Column {
      id: stack

      width: parent.width
      spacing: 8

      // Hidden-notifications card: a count and the reason, never an app, a title or a text. Any click closes it.
      Rectangle {
        visible: loader.daemon.hiddenCount > 0
        width: stack.width
        height: hiddenRow.implicitHeight + 24
        radius: 10
        color: Theme.bg
        border.color: loader.daemon.hiddenCritical ? Theme.error : Theme.accent
        border.width: 2

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          cursorShape: Qt.PointingHandCursor
          onClicked: loader.daemon.closeHidden()
        }

        Row {
          id: hiddenRow

          x: 12
          y: 12
          width: parent.width - 24
          spacing: 10

          Text {
            text: "󰂛"
            color: loader.daemon.hiddenCritical ? Theme.error : Theme.dim
            font.family: Theme.font
            font.pixelSize: 18
          }
          Text {
            width: parent.width - 28
            anchors.verticalCenter: parent.verticalCenter
            text: Notify.hiddenText(loader.daemon.hiddenCount, loader.daemon.modes)
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: 12
            wrapMode: Text.Wrap
          }
        }
      }

      // Deck (geometry in notify.mjs deckCard): newest in front, older ones peeking above it. Pointer over it = fanned
      // out into a list to read and click, and every timer waits.
      Item {
        id: deckItem

        property list<real> heights: []   // natural height per card index
        readonly property bool open: hover.hovered && loader.daemon.popups.length > 1

        function setHeight(index, height) {
          const next = heights.slice(0, loader.daemon.popups.length)
          next[index] = height
          heights = next
        }

        width: stack.width
        height: Notify.deckHeight(loader.daemon.popups.length, open, heights)
        visible: loader.daemon.popups.length > 0

        HoverHandler { id: hover }

        Repeater {
          model: loader.daemon.popups

          PopupCard {
            daemon: loader.daemon
            // Not `deck: deck`: inside PopupCard that name is its own (still empty) property.
            deck: deckItem
          }
        }
      }
    }
  }
}
