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
// Every notification stays tracked after its popup is gone, up to Notify.HISTORY_MAX: the notification centre (below,
// toggled by ./notifications/toggle) lists them and can still run their actions. Modes survive a restart of this process
// through a file in $XDG_RUNTIME_DIR; the waybar bell (`dnd status`) is poked on every change.
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
  property bool centerOpen: false
  property real seenAt: Date.now()   // last time the centre was opened
  readonly property int unread: kept.filter(id => (arrived[id] ?? 0) > seenAt).length

  onUnreadChanged: poke()
  onModesChanged: {
    poke()
    modesFile.setText(modes.join(" "))
  }

  // Waybar bell, signal 8 (see bin/dnd).
  function poke() { Quickshell.execDetached(["pkill", "-RTMIN+8", "-f", "^waybar "]) }

  // Ones the history does not keep (transient, poweralertd state changes) end with their popup.
  function ephemeral(n) { return n.transient || !Notify.keep({ appName: n.appName, urgency: n.urgency }) }

  function openCenter() {
    seenAt = Date.now()
    popups = []
    closeHidden()
    centerOpen = true
  }

  function closeHidden() {
    hiddenCount = 0
    hiddenCritical = false
  }

  function hidePopup(n) {
    popups = popups.filter(p => p !== n)
    if (ephemeral(n) && n.tracked) n.expire()
  }

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
      // A reload's carry-overs keep no time and do not count as new.
      root.arrived[n.id] = n.lastGeneration ? root.seenAt - 1 : Date.now()
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
      if (root.ephemeral(n) && !root.popups.includes(n)) n.expire()
      root.trim()
    }
  }

  // 5 s after the latest hidden one, unless a critical one is among them.
  Timer {
    id: hiddenTimer
    interval: Notify.DEFAULT_TIMEOUT_MS
    onTriggered: if (!root.hiddenCritical) root.closeHidden()
  }

  FileView {
    id: modesFile
    path: Quickshell.env("XDG_RUNTIME_DIR") + "/sway-notification-modes"
    blockLoading: true
    atomicWrites: false
    printErrors: false
  }

  Component.onCompleted: {
    const saved = modesFile.text().trim()
    if (saved !== "") modes = saved.split(" ").filter(m => Notify.MODES.includes(m))
  }

  IpcHandler {
    target: "notifications"

    function status(): string { return JSON.stringify(Notify.bell(root.modes, root.unread)) }
    function toggleCenter(): void {
      if (root.centerOpen) root.centerOpen = false
      else root.openCenter()
    }
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

  // Notification centre: every kept notification, newest first, with its time and actions. Built on PanelShell like the
  // popup panels (outside click, Esc, workspace switch close it), but this process stays: keepAlive.
  LazyLoader {
    active: root.centerOpen

    PanelShell {
      id: win

      // Kept notifications, newest first. `root.kept` in the binding: re-read on every arrival and close.
      readonly property var items: {
        const ids = root.kept
        return server.trackedNotifications.values.filter(n => ids.includes(n.id))
                                                 .sort((a, b) => (root.arrived[b.id] ?? 0) - (root.arrived[a.id] ?? 0))
      }
      readonly property string hiddenBy: root.modes.includes("screenshare") ? "screenshare"
                                         : root.modes.includes("recording") ? "recording" : ""
      property real now: Date.now()

      keepAlive: true
      onDismissed: root.centerOpen = false
      WlrLayershell.namespace: "sway-notification-centre"

      Timer {
        interval: 30000
        repeat: true
        running: true
        onTriggered: win.now = Date.now()
      }

      Rectangle {
        id: centreCard

        anchors.right: parent.right
        anchors.rightMargin: 10
        y: 34
        width: 420
        height: Math.min(centreContent.implicitHeight + 32, win.height - 34 - 20)
        radius: 12
        color: win.bg
        border.color: win.accent
        border.width: 2

        MouseArea { anchors.fill: parent }

        Item {
          focus: true
          Keys.onPressed: event => { if (event.key === Qt.Key_Escape) win.dismiss() }
        }

        component Chip: Rectangle {
          property string label
          property bool active
          signal pressed

          width: chipText.implicitWidth + 16
          height: 26
          radius: 8
          color: active ? win.accent : (chipArea.containsMouse ? win.track : "transparent")
          border.color: active ? win.accent : win.track
          border.width: 1

          Text {
            id: chipText
            anchors.centerIn: parent
            text: parent.label
            color: parent.active ? "#1e1e2e" : win.fg
            font.family: win.font
            font.pixelSize: 11
            font.bold: parent.active
          }
          MouseArea {
            id: chipArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.pressed()
          }
        }

        Column {
          id: centreContent
          anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
          spacing: 12

          Item {
            width: parent.width
            height: 26
            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "Notifications"
              color: win.fg
              font.family: win.font
              font.pixelSize: 15
              font.bold: true
            }
            Row {
              anchors.right: parent.right
              spacing: 6
              Chip {
                label: "󰂛  Do not disturb"
                active: root.modes.includes("dnd")
                onPressed: root.modes = Notify.setMode(root.modes, "dnd", "toggle")
              }
              Chip {
                label: "Clear"
                active: false
                visible: win.items.length > 0
                onPressed: {
                  for (const n of win.items.slice()) n.dismiss()
                }
              }
            }
          }

          // A share or recording mode left on (say, the daemon restarted mid-share and missed the end): one click
          // brings the popups back.
          Row {
            visible: win.hiddenBy !== ""
            spacing: 8
            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: win.hiddenBy === "screenshare" ? "Popups hidden while sharing the screen"
                                                   : "Popups hidden while recording the screen"
              color: win.error
              font.family: win.font
              font.pixelSize: 11
            }
            Chip {
              label: "Show popups"
              active: false
              onPressed: root.modes = Notify.setMode(root.modes, win.hiddenBy, "off")
            }
          }

          Text {
            visible: win.items.length === 0
            text: "No notifications"
            color: win.dim
            font.family: win.font
            font.pixelSize: 12
          }

          Flickable {
            visible: win.items.length > 0
            width: parent.width
            height: Math.min(list.implicitHeight, win.height * 0.7)
            contentHeight: list.implicitHeight
            clip: true

            Column {
              id: list
              width: parent.width
              spacing: 8

              Repeater {
                model: win.items

                Rectangle {
                  id: entry

                  required property var modelData
                  readonly property var n: modelData
                  readonly property var defaultAction: n.actions.find(a => a.identifier === "default") ?? null
                  readonly property var buttons: n.actions.filter(a => a.identifier !== "default")

                  width: list.width
                  height: row.implicitHeight + 20
                  radius: 8
                  color: entryArea.containsMouse && defaultAction ? win.track : "transparent"
                  border.color: n.urgency === NotificationUrgency.Critical ? win.error : win.track
                  border.width: 1

                  // Click = the default action (the app takes over, so the centre closes).
                  MouseArea {
                    id: entryArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: entry.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
                    // Close first: invoking a non-resident notification destroys this entry, and the handler with it.
                    onClicked: {
                      const action = entry.defaultAction
                      if (!action) return
                      win.dismiss()
                      action.invoke()
                    }
                  }

                  Row {
                    id: row
                    x: 10
                    y: 10
                    width: parent.width - 20
                    spacing: 10

                    IconImage {
                      readonly property string src: entry.n.image !== "" ? entry.n.image
                                                    : (entry.n.appIcon !== "" ? Quickshell.iconPath(entry.n.appIcon, true) : "")
                      visible: src !== ""
                      source: src
                      implicitSize: 28
                    }

                    Column {
                      width: parent.width - (parent.children[0].visible ? 38 : 0)
                      spacing: 3

                      Item {
                        width: parent.width
                        height: meta.implicitHeight
                        Text {
                          id: meta
                          width: parent.width - 24
                          text: [entry.n.appName, Notify.ago(root.arrived[entry.n.id] ?? win.now, win.now)]
                                .filter(s => s !== "").join("  ·  ")
                          color: win.dim
                          font.family: win.font
                          font.pixelSize: 10
                          elide: Text.ElideRight
                        }
                        // Dismiss this one.
                        Text {
                          anchors.right: parent.right
                          text: "󰅖"
                          color: closeArea.containsMouse ? win.fg : win.dim
                          font.family: win.font
                          font.pixelSize: 13
                          MouseArea {
                            id: closeArea
                            anchors.fill: parent
                            anchors.margins: -6
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: entry.n.dismiss()
                          }
                        }
                      }
                      Text {
                        width: parent.width
                        text: entry.n.summary
                        color: win.fg
                        font.family: win.font
                        font.pixelSize: 12
                        font.bold: true
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                      }
                      Text {
                        width: parent.width
                        text: entry.n.body
                        visible: text !== ""
                        textFormat: Text.StyledText
                        color: win.fg
                        font.family: win.font
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                        maximumLineCount: 4
                        elide: Text.ElideRight
                      }
                      Flow {
                        width: parent.width
                        visible: entry.buttons.length > 0
                        spacing: 6
                        Repeater {
                          model: entry.buttons
                          Chip {
                            required property var modelData
                            label: modelData.text
                            active: false
                            onPressed: {
                              const action = modelData
                              win.dismiss()
                              action.invoke()
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
  }
}
