import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import "notify.mjs" as Notify
import "../common"

// One popup in the deck of Popups.qml. Left click = default action (or just close), right click = dismiss, other
// actions as buttons. Its timer waits while the pointer is over the deck.
Rectangle {
  id: card

  required property var modelData   // the Notification
  required property int index       // 0 = newest, in front
  required property var daemon      // ../notifications.qml root
  required property var deck        // the deck Item: open, heights, setHeight()

  readonly property var n: modelData
  readonly property var defaultAction: n.actions.find(action => action.identifier === "default") ?? null
  readonly property var buttons: n.actions.filter(action => action.identifier !== "default")
  readonly property real natural: content.implicitHeight + 24
  readonly property var place: Notify.deckCard(index, daemon.popups.length, deck.open, deck.heights)

  width: deck.width
  height: place.height || natural
  y: place.y
  z: -index
  scale: place.scale
  transformOrigin: Item.Top
  opacity: place.shown ? 1 : 0
  clip: true
  radius: 10
  // Opaque: the cards behind must not show through the front one.
  color: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, 1)
  border.color: n.urgency === NotificationUrgency.Critical ? Theme.error : Theme.accent
  border.width: 2
  onNaturalChanged: deck.setHeight(index, natural)
  onIndexChanged: deck.setHeight(index, natural)
  Component.onCompleted: deck.setHeight(index, natural)

  Behavior on y { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
  Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

  Timer {
    id: timer

    readonly property int ms: Notify.timeoutMs({ appName: card.n.appName, urgency: card.n.urgency,
                                                 expireTimeout: card.n.expireTimeout })

    interval: Math.max(1, ms)
    running: ms > 0 && !card.deck.open && !hover.hovered
    onTriggered: card.daemon.hidePopup(card.n)
  }

  HoverHandler { id: hover }

  // Replaced in place with new text: its full time again.
  Connections {
    target: card.n

    function onSummaryChanged() { timer.restart() }
    function onBodyChanged() { timer.restart() }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    // Default action runs, but the app's window stays put: Quickshell 0.3.0 never sends ActivationToken (docs/sway.md
    // "Notifications").
    onClicked: mouse => {
      if (mouse.button === Qt.RightButton) card.n.dismiss()
      else if (card.defaultAction) card.defaultAction.invoke()
      else card.daemon.hidePopup(card.n)
    }
  }

  Row {
    id: content

    x: 12
    y: 12
    width: parent.width - 24
    spacing: 10

    IconImage {
      id: icon

      readonly property string src: card.n.image !== "" ? card.n.image
                                    : (card.n.appIcon !== "" ? Quickshell.iconPath(card.n.appIcon, true) : "")

      visible: src !== ""
      source: src
      implicitSize: 36
    }

    Column {
      width: parent.width - (icon.visible ? 46 : 0)
      spacing: 4

      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: card.n.appName
        visible: text !== ""
        color: Theme.dim
        font.family: Theme.font
        font.pixelSize: 11
        elide: Text.ElideRight
      }
      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: card.n.summary
        color: Theme.fg
        font.family: Theme.font
        font.pixelSize: 13
        font.bold: true
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
      }
      Text {
        width: parent.width
        text: Notify.safeBody(card.n.body)
        visible: text !== ""
        textFormat: Text.StyledText
        color: Theme.fg
        font.family: Theme.font
        font.pixelSize: 12
        wrapMode: Text.Wrap
        maximumLineCount: 5
        elide: Text.ElideRight
      }
      Flow {
        width: parent.width
        visible: card.buttons.length > 0
        spacing: 6

        Repeater {
          model: card.buttons

          Chip {
            required property var modelData

            label: modelData.text
            active: false
            onPressed: modelData.invoke()
          }
        }
      }
    }
  }
}
