import QtQuick
import Quickshell
import Quickshell.Wayland
import "notify.mjs" as Notify
import "../common"

// Notification centre of the daemon (../notifications.qml): every kept notification, newest first, with its time and
// actions, plus the Do not disturb switch. Built on PanelShell like the popup panels (Esc, outside click and workspace
// switch close it), with keepAlive: closing hides the window, the daemon keeps running.
LazyLoader {
  id: loader

  required property var daemon

  active: daemon.centerOpen

  PanelShell {
    id: win

    readonly property var items: Notify.centreItems(loader.daemon.tracked, loader.daemon.kept, loader.daemon.arrived)
    readonly property string hiddenBy: loader.daemon.modes.includes("screenshare") ? "screenshare"
                                       : loader.daemon.modes.includes("recording") ? "recording" : ""
    property real now: Date.now()

    keepAlive: true
    WlrLayershell.namespace: "sway-notification-centre"
    onDismissed: loader.daemon.centerOpen = false

    // Times in the list ("5 min") move on while it stays open.
    Timer {
      interval: 30000
      repeat: true
      running: true
      onTriggered: win.now = Date.now()
    }

    Rectangle {
      id: card

      anchors.right: parent.right
      anchors.rightMargin: 10
      y: 34
      width: 420
      height: Math.min(content.implicitHeight + 32, win.height - 34 - 20)
      radius: 12
      color: win.bg
      border.color: win.accent
      border.width: 2

      MouseArea { anchors.fill: parent }

      Item {
        focus: true
        Keys.onPressed: event => { if (event.key === Qt.Key_Escape) win.dismiss() }
      }

      Column {
        id: content

        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
        spacing: 12

        Item {
          width: parent.width
          height: 28

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
              active: loader.daemon.modes.includes("dnd")
              onPressed: loader.daemon.modes = Notify.setMode(loader.daemon.modes, "dnd", "toggle")
            }
            Chip {
              label: "Clear"
              active: false
              visible: win.items.length > 0
              onPressed: {
                for (const item of win.items.slice()) item.dismiss()
              }
            }
          }
        }

        // A share or recording mode left on (say, the daemon restarted mid-share and missed the end): one click brings
        // the popups back.
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
            onPressed: loader.daemon.modes = Notify.setMode(loader.daemon.modes, win.hiddenBy, "off")
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

              CentreEntry {
                width: list.width
                arrivedAt: loader.daemon.arrived[modelData.id] ?? win.now
                now: win.now
                onDone: win.dismiss()
              }
            }
          }
        }
      }
    }
  }
}
