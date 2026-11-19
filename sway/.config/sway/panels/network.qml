import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Wayland
import "network/flow.mjs" as Flow
import "common"

// Network panel for the waybar network icon: the wired connection while a cable is in (connect, disconnect), Wi-Fi
// networks live from NetworkManager (Quickshell.Networking), radio switch, password prompt for a secured network with
// no saved profile. Esc or a click outside closes it. One process per
// open, like the calendar: the scanner runs only while the panel is up.
ShellRoot {
  PanelShell {
    id: win

    readonly property list<string> bars: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]

    readonly property var device: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var networks: device ? Flow.visibleNetworks(device.networks.values) : []
    readonly property var wired: Networking.devices.values.find(d => d.type === DeviceType.Wired) ?? null
    // Flow.wiredRow on the wired device's fields: null = no row.
    readonly property var wiredRow: Flow.wiredRow(wired ? {
      hasLink: wired.hasLink,
      connected: wired.connected,
      connecting: wired.state === ConnectionState.Connecting,
      disconnecting: wired.state === ConnectionState.Disconnecting,
      speed: wired.linkSpeed
    } : null)
    readonly property bool scanning: scan.running

    // Pick, password and connect state, driven by flow.mjs.
    property var asking: null          // network whose password row is open
    property string failure: ""
    property var joining: null         // network the user picked; close once it connects

    function closePanel() { Qt.quit() }
    function pick(network) { Flow.pick(win, network) }

    // WPA/WPA2 personal or SAE: a password typed in the panel can connect it.
    function takesPassword(network) {
      return network.security === WifiSecurityType.WpaPsk || network.security === WifiSecurityType.Wpa2Psk
        || network.security === WifiSecurityType.Sae
    }

    WlrLayershell.namespace: "sway-network"

    Binding { target: win.device; property: "scannerEnabled"; value: true; when: win.device !== null }

    // Quickshell exposes no "scan finished": a blocking nmcli rescan does. Its output is unused, the list comes from
    // the scanner. `auto` returns at once when NetworkManager scanned in the last seconds.
    Process {
      id: scan
      running: Networking.wifiEnabled
      command: ["nmcli", "-t", "-f", "SSID", "device", "wifi", "list", "--rescan", "auto"]
      stdout: SplitParser {}
    }

    PanelCard {
      id: card

      anchors.rightMargin: 8
      width: 380
      height: content.implicitHeight + 32


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

        Text {
          textFormat: Text.PlainText
          text: "Network"
          color: win.fg
          font.family: win.font
          font.pixelSize: 16
          font.bold: true
        }

        // Wired: shown while a cable is plugged in or the wired connection is up. It wins the default route over Wi-Fi.
        Column {
          visible: win.wiredRow !== null
          width: parent.width
          spacing: 6

          SectionLabel { text: "󰈀  Wired" }

          Rectangle {
            width: parent.width
            height: 36
            radius: 8
            color: win.wired && win.wired.connected ? win.track : "transparent"

            Text {
              id: wiredName
              anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
              textFormat: Text.PlainText
              text: win.wired ? win.wired.name : ""
              color: win.wired && win.wired.connected ? win.accent : win.fg
              font.family: win.font
              font.pixelSize: 13
              font.bold: win.wired ? win.wired.connected : false
            }

            Text {
              anchors { left: wiredName.right; leftMargin: 10; right: wiredButton.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
              textFormat: Text.PlainText
              text: win.wiredRow ? win.wiredRow.status : ""
              elide: Text.ElideRight
              color: win.dim
              font.family: win.font
              font.pixelSize: 12
            }

            Chip {
              id: wiredButton
              anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
              visible: win.wiredRow !== null && win.wiredRow.action !== ""
              label: win.wiredRow && win.wiredRow.action === "disconnect" ? "Disconnect" : "Connect"
              onPressed: {
                if (win.wiredRow.action === "disconnect") win.wired.disconnect()
                else if (win.wired.network) win.wired.network.connect()
              }
            }
          }
        }

        // Wi-Fi line: scan status, radio switch.
        Item {
          width: parent.width
          height: 28

          SectionLabel {
            id: title
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "󰖩  Wi-Fi"
          }

          Row {
            anchors.left: title.right
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            visible: Networking.wifiEnabled

            Text {
              id: spinner
              textFormat: Text.PlainText
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
              textFormat: Text.PlainText
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
              color: Networking.wifiEnabled ? Theme.base : win.dim
              Behavior on x { NumberAnimation { duration: 120 } }
            }

            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Networking.wifiEnabled = !Networking.wifiEnabled }
          }
        }

        // Radio off needs no line of its own: the switch above already says so.
        Text {
          visible: win.device === null
          textFormat: Text.PlainText
          text: "No Wi-Fi device"
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
                Flow.connectFailed(win, row.net, {
                  missingPassword: reason === ConnectionFailReason.NoSecrets,
                  takesPassword: win.takesPassword(row.net),
                })
              }
              function onConnectedChanged() { Flow.closeWhenPickedIsUp(win, row.net) }
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
                textFormat: Text.PlainText
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
                textFormat: Text.PlainText
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
                textFormat: Text.PlainText
                text: row.net.stateChanging ? "…"
                  : (row.net.connected ? "󰄬" : (row.net.security === WifiSecurityType.Open ? "" : "󰌾"))
                color: win.dim
                font.family: win.font
                font.pixelSize: 14
              }

              MouseArea {
                id: rowMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
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
                Keys.onEscapePressed: Flow.cancelPassword(win)
                Keys.onReturnPressed: Flow.submitPassword(win, row.net, text)
                Keys.onEnterPressed: Flow.submitPassword(win, row.net, text)

                Text {
                  anchors.verticalCenter: parent.verticalCenter
                  visible: pass.text === ""
                  textFormat: Text.PlainText
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
          textFormat: Text.PlainText
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
