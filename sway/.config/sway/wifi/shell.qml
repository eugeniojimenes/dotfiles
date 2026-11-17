import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Wayland
import "flow.js" as Flow
import "../common"

// Wi-Fi panel for the waybar network icon: networks live from NetworkManager (Quickshell.Networking), radio switch,
// password prompt for a secured network with no saved profile. Esc or a click outside closes it. One process per
// open, like the calendar: the scanner runs only while the panel is up.
ShellRoot {
  PanelShell {
    id: win

    WlrLayershell.namespace: "sway-wifi"

    readonly property var bars: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]

    readonly property var device: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var networks: device ? Flow.listed(device.networks.values) : []
    readonly property bool scanning: scan.running
    // Pick, password and connect state, driven by flow.js.
    property var asking: null          // network whose password row is open
    property string failure: ""
    property var joining: null         // network the user picked; close once it connects

    function closePanel() { Qt.quit() }
    function pick(n) { Flow.pick(win, n) }

    function psk(n) {
      return n.security === WifiSecurityType.WpaPsk || n.security === WifiSecurityType.Wpa2Psk
        || n.security === WifiSecurityType.Sae
    }

    Binding { target: win.device; property: "scannerEnabled"; value: true; when: win.device !== null }

    // Quickshell exposes no "scan finished": a blocking nmcli rescan does. Its output is unused, the list comes from
    // the scanner. `auto` returns at once when NetworkManager scanned in the last seconds.
    Process {
      id: scan
      running: Networking.wifiEnabled
      command: ["nmcli", "-t", "-f", "SSID", "device", "wifi", "list", "--rescan", "auto"]
      stdout: SplitParser {}
    }

    Rectangle {
      id: card

      anchors.right: parent.right
      anchors.rightMargin: 8
      y: 34
      width: 380
      height: content.implicitHeight + 32
      radius: 12
      color: win.bg
      border.color: win.accent
      border.width: 2

      MouseArea { anchors.fill: parent }   // swallows clicks so they do not reach the close-on-outside area

      Item {
        focus: win.asking === null
        Keys.onPressed: event => {
          if (event.key === Qt.Key_Escape) Qt.quit()
          else if (event.key === Qt.Key_Down) list.incrementCurrentIndex()
          else if (event.key === Qt.Key_Up) list.decrementCurrentIndex()
          else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && list.currentIndex >= 0)
            win.pick(win.networks[list.currentIndex])
        }
      }

      Column {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
        spacing: 12

        // Header: title, scan status, radio switch.
        Item {
          width: parent.width
          height: 28

          Text {
            id: title
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Wi-Fi"
            color: win.fg
            font.family: win.font
            font.pixelSize: 16
            font.bold: true
          }

          Row {
            anchors.left: title.right
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            visible: Networking.wifiEnabled

            Text {
              id: spinner
              text: win.scanning ? "󰑓" : "󰄬"
              color: win.scanning ? win.accent : win.dim
              font.family: win.font
              font.pixelSize: 13
              RotationAnimation on rotation {
                running: win.scanning
                from: 0; to: 360; duration: 1000; loops: Animation.Infinite
                onStopped: spinner.rotation = 0
              }
            }

            Text {
              text: win.scanning ? "Searching…" : "Scanned"
              color: win.dim
              font.family: win.font
              font.pixelSize: 12
            }
          }

          // Radio switch (rfkill soft block).
          Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 22
            radius: 11
            color: Networking.wifiEnabled ? win.accent : win.track

            Rectangle {
              x: Networking.wifiEnabled ? parent.width - width - 3 : 3
              anchors.verticalCenter: parent.verticalCenter
              width: 16
              height: 16
              radius: 8
              color: Networking.wifiEnabled ? "#1e1e2e" : win.dim
              Behavior on x { NumberAnimation { duration: 120 } }
            }

            MouseArea { anchors.fill: parent; onClicked: Networking.wifiEnabled = !Networking.wifiEnabled }
          }
        }

        Text {
          visible: !Networking.wifiEnabled || win.device === null
          text: win.device === null ? "No Wi-Fi device" : "Wi-Fi is off"
          color: win.dim
          font.family: win.font
          font.pixelSize: 13
        }

        ListView {
          id: list
          visible: Networking.wifiEnabled && win.device !== null
          width: parent.width
          height: Math.min(contentHeight, 420)
          clip: true
          currentIndex: -1
          model: win.networks
          spacing: 2

          delegate: Column {
            id: row
            required property var modelData
            required property int index
            readonly property var net: modelData
            width: ListView.view.width

            Connections {
              target: row.net
              function onConnectionFailed(reason) {
                Flow.failed(win, row.net, reason === ConnectionFailReason.NoSecrets, win.psk(row.net))
              }
              function onConnectedChanged() { Flow.connectedChanged(win, row.net) }
            }

            Rectangle {
              width: parent.width
              height: 36
              radius: 8
              color: rowMouse.containsMouse || list.currentIndex === row.index ? win.track : "transparent"

              Text {
                id: bars
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: win.bars[Math.min(4, Math.floor(row.net.signalStrength * 5))]
                color: row.net.connected ? win.accent : win.fg
                font.family: win.font
                font.pixelSize: 16
              }

              Text {
                anchors.left: bars.right
                anchors.leftMargin: 12
                anchors.right: status.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: row.net.name
                elide: Text.ElideRight
                color: row.net.connected ? win.accent : win.fg
                font.family: win.font
                font.pixelSize: 13
                font.bold: row.net.connected
              }

              Text {
                id: status
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: row.net.stateChanging ? "…"
                  : (row.net.connected ? "󰄬" : (row.net.security === WifiSecurityType.Open ? "" : "󰌾"))
                color: win.dim
                font.family: win.font
                font.pixelSize: 14
              }

              MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: { list.currentIndex = row.index; win.pick(row.net) }
              }
            }

            // Password row, only for the network that asked for one.
            Rectangle {
              visible: win.asking === row.net
              width: parent.width
              height: visible ? 40 : 0
              radius: 8
              color: "transparent"
              border.width: 2
              border.color: win.failure !== "" ? win.error : win.accent

              TextInput {
                id: pass
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter
                focus: win.asking === row.net
                echoMode: TextInput.Password
                passwordCharacter: "●"
                color: win.fg
                font.family: win.font
                font.pixelSize: 13
                onVisibleChanged: if (visible) { text = ""; forceActiveFocus() }
                Keys.onEscapePressed: Flow.cancel(win)
                Keys.onReturnPressed: Flow.submit(win, row.net, text)
                Keys.onEnterPressed: Flow.submit(win, row.net, text)

                Text {
                  anchors.verticalCenter: parent.verticalCenter
                  visible: pass.text === ""
                  text: "Password for " + row.net.name
                  color: win.dim
                  font: pass.font
                }
              }
            }
          }
        }

        Text {
          visible: win.failure !== ""
          text: win.failure
          color: win.error
          font.family: win.font
          font.pixelSize: 12
        }

        Rectangle { width: parent.width; height: 1; color: win.track }

        AdvancedLink {
          text: "  Advanced (nmtui)"
          command: ["nmtui"]
        }
      }
    }
  }
}
