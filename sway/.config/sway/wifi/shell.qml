import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Wayland

// Wi-Fi panel for the waybar network icon: networks live from NetworkManager (Quickshell.Networking), radio switch,
// password prompt for a secured network with no saved profile. Esc or a click outside closes it. One process per
// open, like the calendar: the scanner runs only while the panel is up.
ShellRoot {
  PanelWindow {
    id: win

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "sway-wifi"

    readonly property color bg: "#f21e1e2e"
    readonly property color fg: "#cdd6f4"
    readonly property color dim: "#6c7086"
    readonly property color accent: "#89b4fa"
    readonly property color error: "#f38ba8"
    readonly property color track: "#313244"
    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property var bars: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]

    readonly property var device: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    // Connected first, then strongest. Unnamed (hidden) networks left out: nothing to show or type for them.
    readonly property var networks: device ? device.networks.values.filter(n => n.name !== "")
      .sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength)) : []
    readonly property bool scanning: scan.running
    property var asking: null          // network whose password row is open
    property string failure: ""
    property var joining: null         // network the user picked; close once it connects

    function pick(n) {
      failure = ""
      if (n.connected || n.stateChanging) return
      joining = n
      n.connect()   // saved profile or open network: no prompt; otherwise connectionFailed(NoSecrets) asks below
    }

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

    MouseArea {
      anchors.fill: parent
      onClicked: Qt.quit()
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
                if (reason === ConnectionFailReason.NoSecrets && win.psk(row.net)) {
                  win.asking = row.net
                  win.failure = row.net.known ? "Wrong password" : ""
                } else {
                  win.failure = reason === ConnectionFailReason.NoSecrets
                    ? "Enterprise network: use Advanced (nmtui)" : "Connection failed"
                }
                win.joining = null
              }
              function onConnectedChanged() { if (row.net.connected && win.joining === row.net) Qt.quit() }
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
                Keys.onEscapePressed: { win.asking = null; win.failure = "" }
                Keys.onReturnPressed: submit()
                Keys.onEnterPressed: submit()
                function submit() {
                  if (text === "") return
                  win.failure = ""
                  win.joining = row.net
                  win.asking = null
                  row.net.connectWithPsk(text)
                }

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

        Text {
          text: "  Advanced (nmtui)"
          color: advMouse.containsMouse ? win.fg : win.dim
          font.family: win.font
          font.pixelSize: 13
          MouseArea {
            id: advMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              Quickshell.execDetached([Quickshell.env("HOME") + "/.config/sway/bin/float", "nmtui"])
              Qt.quit()
            }
          }
        }
      }
    }
  }
}
