import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Widgets
import "notifications/notify.mjs" as Notify
import "common"

// Notification daemon: owns org.freedesktop.Notifications (instead of mako) and draws the popups, top right of the
// focused output. Always running, started by ./notifications/run (sway autostart), unlike the other panels.
// Rules (what pops up, for how long, modes, history cap) live in notifications/notify.mjs. bin/dnd drives the modes
// over Quickshell IPC: `quickshell ipc -p <this file> call notifications <function>`.
// Every notification stays tracked after its popup is gone, up to Notify.HISTORY_MAX: the notification centre lists
// them and can still run their actions.
ShellRoot {
  id: root

  property list<string> modes: []
  property var popups: []        // Notification objects on screen, newest first
  property var kept: []          // ids of tracked notifications, arrival order
  property var arrived: ({})     // id -> Date.now() at arrival
  // Card standing for notifications hidden by a screen share or recording: how many since it last closed, and whether
  // one was critical (then it stays until clicked, red border).
  property int hiddenCount: 0
  property bool hiddenCritical: false

  function closeHidden() {
    hiddenCount = 0
    hiddenCritical = false
  }

  function hidePopup(n) { popups = popups.filter(p => p !== n) }

  function forget(n) {
    hidePopup(n)
    kept = kept.filter(id => id !== n.id)
  }

  function trim() {
    const drop = Notify.overflow(kept, popups.map(p => p.id))
    for (const n of server.trackedNotifications.values) if (drop.includes(n.id)) n.expire()
  }

  NotificationServer {
    id: server

    keepOnReload: true
    persistenceSupported: true
    bodySupported: true
    bodyMarkupSupported: true
    actionsSupported: true
    imageSupported: true

    onNotification: n => {
      n.tracked = true
      root.arrived[n.id] = Date.now()
      root.kept = root.kept.filter(id => id !== n.id).concat([n.id])
      n.closed.connect(() => root.forget(n))
      // Carried over by a Quickshell reload (keepOnReload): back in the history, never a popup again.
      const how = n.lastGeneration ? "silent" : Notify.delivery({ appName: n.appName, urgency: n.urgency }, root.modes)
      if (how === "show") {
        root.popups = [n].concat(root.popups.filter(p => p !== n))
      } else if (how === "hidden") {
        root.hiddenCount += 1
        if (n.urgency === NotificationUrgency.Critical) root.hiddenCritical = true
        hiddenTimer.restart()
      }
      // A transient one only lives as long as its popup.
      if (n.transient && !root.popups.includes(n)) n.expire()
      root.trim()
    }
  }

  // 5 s after the latest hidden one, unless a critical one is among them.
  Timer {
    id: hiddenTimer
    interval: Notify.DEFAULT_TIMEOUT_MS
    onTriggered: if (!root.hiddenCritical) root.closeHidden()
  }

  IpcHandler {
    target: "notifications"

    function modes(): string { return root.modes.join(" ") }
    function modeOn(name: string): void { root.modes = Notify.setMode(root.modes, name, "on") }
    function modeOff(name: string): void { root.modes = Notify.setMode(root.modes, name, "off") }
    function modeToggle(name: string): void { root.modes = Notify.setMode(root.modes, name, "toggle") }
  }

  // Created while there is something to show: each time it maps, Sway puts it on the focused output.
  LazyLoader {
    active: root.popups.length > 0 || root.hiddenCount > 0

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
          visible: root.hiddenCount > 0
          width: stack.width
          height: hiddenRow.implicitHeight + 24
          radius: 10
          color: Theme.bg
          border.color: root.hiddenCritical ? Theme.error : Theme.accent
          border.width: 2

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: root.closeHidden()
          }

          Row {
            id: hiddenRow
            x: 12
            y: 12
            width: parent.width - 24
            spacing: 10
            Text {
              text: "󰂛"
              color: root.hiddenCritical ? Theme.error : Theme.dim
              font.family: Theme.font
              font.pixelSize: 18
            }
            Text {
              width: parent.width - 28
              anchors.verticalCenter: parent.verticalCenter
              text: Notify.hiddenText(root.hiddenCount, root.modes)
              color: Theme.fg
              font.family: Theme.font
              font.pixelSize: 12
              wrapMode: Text.Wrap
            }
          }
        }

        // Deck: the newest card in front, older ones behind it, 8 px higher and a bit smaller, their top edges showing (up
        // to three), so the count and their border colours read at a glance. Pointer over it = fanned out into a list to read and
        // click, and every timer waits.
        Item {
          id: deck

          readonly property int gap: 8
          readonly property int edges: 3
          property var heights: []           // natural height per card index
          readonly property bool open: hover.hovered && root.popups.length > 1
          readonly property int peek: Math.min(root.popups.length - 1, edges) // edges showing above the front card

          function setHeight(i, h) {
            const next = heights.slice(0, root.popups.length)
            next[i] = h
            heights = next
          }
          function above(i) {
            let y = 0
            for (let j = 0; j < i; j++) y += (heights[j] ?? 0) + gap
            return y
          }

          width: stack.width
          height: root.popups.length === 0 ? 0
                  : open ? above(root.popups.length) - gap
                  : (heights[0] ?? 0) + Math.min(root.popups.length - 1, edges) * gap
          visible: root.popups.length > 0

          HoverHandler { id: hover }

          Repeater {
            model: root.popups

            Rectangle {
              id: card

              required property var modelData
              readonly property var n: modelData
              readonly property var defaultAction: n.actions.find(a => a.identifier === "default") ?? null
              readonly property var buttons: n.actions.filter(a => a.identifier !== "default")

              required property int index
              readonly property real natural: content.implicitHeight + 24

              width: deck.width
              // Behind the front card: its height, so every edge sticks out the same 8 px above it.
              height: deck.open || index === 0 ? natural : (deck.heights[0] ?? natural)
              y: deck.open ? deck.above(index) : (deck.peek - Math.min(index, deck.edges)) * deck.gap
              z: -index
              scale: deck.open ? 1 : Math.max(0.92, 1 - index * 0.04)
              transformOrigin: Item.Top
              opacity: deck.open || index <= deck.edges ? 1 : 0
              clip: true
              onNaturalChanged: deck.setHeight(index, natural)
              onIndexChanged: deck.setHeight(index, natural)
              Component.onCompleted: deck.setHeight(index, natural)

              Behavior on y { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
              Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
              radius: 10
              // Opaque: the cards behind must not show through the front one.
              color: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, 1)
              border.color: n.urgency === NotificationUrgency.Critical ? Theme.error : Theme.accent
              border.width: 2

              Timer {
                readonly property int ms: Notify.timeoutMs({ appName: card.n.appName, urgency: card.n.urgency,
                                                             expireTimeout: card.n.expireTimeout })
                interval: Math.max(1, ms)
                running: ms > 0 && !hover.hovered
                onTriggered: root.hidePopup(card.n)
              }

              // Left = default action (or just close), right = dismiss: mako's buttons.
              MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                  if (mouse.button === Qt.RightButton) card.n.dismiss()
                  else if (card.defaultAction) card.defaultAction.invoke()
                  else root.hidePopup(card.n)
                }
              }

              Row {
                id: content
                x: 12
                y: 12
                width: parent.width - 24
                spacing: 10

                IconImage {
                  readonly property string src: card.n.image !== "" ? card.n.image
                                                : (card.n.appIcon !== "" ? Quickshell.iconPath(card.n.appIcon, true) : "")
                  visible: src !== ""
                  source: src
                  implicitSize: 36
                }

                Column {
                  width: parent.width - (parent.children[0].visible ? 46 : 0)
                  spacing: 4

                  Text {
                    width: parent.width
                    text: card.n.appName
                    visible: text !== ""
                    color: Theme.dim
                    font.family: Theme.font
                    font.pixelSize: 11
                    elide: Text.ElideRight
                  }
                  Text {
                    width: parent.width
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
                    text: card.n.body
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
                      Rectangle {
                        required property var modelData
                        width: label.implicitWidth + 16
                        height: 24
                        radius: 6
                        color: press.containsMouse ? Theme.track : "transparent"
                        border.color: Theme.track
                        Text {
                          id: label
                          anchors.centerIn: parent
                          text: parent.modelData.text
                          color: Theme.fg
                          font.family: Theme.font
                          font.pixelSize: 11
                        }
                        MouseArea {
                          id: press
                          anchors.fill: parent
                          hoverEnabled: true
                          cursorShape: Qt.PointingHandCursor
                          onClicked: parent.modelData.invoke()
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
