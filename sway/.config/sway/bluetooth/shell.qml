import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.I3
import Quickshell.Io
import Quickshell.Wayland
import "flow.js" as Flow

// Bluetooth panel for the waybar Bluetooth icon: paired devices (click connects or disconnects) and nearby ones (click
// pairs, trusts, connects), straight from BlueZ (Quickshell.Bluetooth). Power switch in the header. Esc or a click
// outside closes. One process per open, like the calendar: BlueZ ends the scan when this client goes away.
// No pairing agent here: a device that asks for a PIN or passkey goes through Advanced (bluetoothctl).
ShellRoot {
  PanelWindow {
    id: win

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "sway-bluetooth"

    // Exclusive keyboard focus follows nothing: switching workspace (key or click on another output) would leave every
    // window without input until this closes. Close with it, like a popup. Sway skips its mouse_warping while a layer
    // surface holds the keyboard, so a jump to another output warps the cursor here instead.
    I3IpcListener {
      subscriptions: ["workspace"]
      onIpcEvent: event => {
        if (event.type !== "workspace") return
        const e = JSON.parse(event.data)
        if (e.change !== "focus") return
        if (e.old && e.current && e.old.output !== e.current.output) {
          const r = e.current.rect
          Quickshell.execDetached(["swaymsg", "seat", "-", "cursor", "set",
                                   String(Math.round(r.x + r.width / 2)), String(Math.round(r.y + r.height / 2))])
        }
        Qt.quit()
      }
    }

    readonly property color bg: "#f21e1e2e"
    readonly property color fg: "#cdd6f4"
    readonly property color dim: "#6c7086"
    readonly property color accent: "#89b4fa"
    readonly property color error: "#f38ba8"
    readonly property color track: "#313244"
    readonly property string font: "JetBrainsMono Nerd Font"

    // Quickshell 0.3 qmltypes names the property type BluetoothAdapter, the class qs::bluetooth::BluetoothAdapter: lint
    // cannot match them. Works at runtime.
    readonly property var adapter: Bluetooth.defaultAdapter // qmllint disable unresolved-type
    readonly property bool on: adapter !== null && adapter.enabled
    readonly property var all: adapter ? adapter.devices.values : []
    readonly property var paired: all.filter(d => d.paired || d.bonded)
      .sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))
    // No deviceName = BlueZ only knows the address: nothing to recognise the device by.
    readonly property var nearby: all.filter(d => !d.paired && !d.bonded && d.deviceName !== "")
      .sort((a, b) => a.name.localeCompare(b.name))
    readonly property var rows: on ? paired.concat(nearby) : []
    // Click, pair and connect state, driven by flow.js.
    property var joining: null         // device the user picked to connect
    property bool fresh: false         // joining came from Nearby: stays open once connected
    property bool connecting: false    // joining reached Connecting, so a fall back to Disconnected = failure
    property string failure: ""

    function closePanel() { Qt.quit() }

    function busy(d) {
      return d.pairing || d.state === BluetoothDeviceState.Connecting || d.state === BluetoothDeviceState.Disconnecting
    }

    function pick(d) { Flow.pick(win, d, busy(d)) }
    function forget(d) { Flow.forget(win, d) }

    // Device1.Connect straight over D-Bus, see flow.js paired(). A failed reply = non-zero exit.
    function connectAfterPair(d) {
      profiles.command = ["busctl", "--system", "--timeout=30", "call", "org.bluez", d.dbusPath, "org.bluez.Device1",
                          "Connect"]
      profiles.running = true
    }

    Process {
      id: profiles
      onExited: code => { if (code !== 0) Flow.fail(win, Flow.CONNECT_FAILED) }
    }

    // BlueZ icon names (audio-headset, input-keyboard...) to Nerd Font glyphs.
    function glyph(d) {
      const i = d.icon
      if (i.startsWith("audio-headset")) return "󰋎"
      if (i.startsWith("audio-headphones")) return "󰋋"
      if (i.startsWith("audio")) return "󰓃"
      if (i === "input-keyboard") return "󰌌"
      if (i === "input-mouse" || i === "input-tablet") return "󰍽"
      if (i === "input-gaming") return "󰊴"
      if (i === "phone") return "󰏲"
      if (i === "computer") return "󰌢"
      return "󰂯"
    }

    // Scan only while open and on. Not stopped on close: BlueZ drops a discovery session when its client exits.
    Binding { target: win.adapter; property: "discovering"; value: true; when: win.on }

    Connections {
      target: win.joining
      ignoreUnknownSignals: true
      function onPairedChanged() { Flow.pairedChanged(win) }
      function onPairingChanged() { Flow.pairingChanged(win) }
      function onStateChanged() {
        const s = win.joining.state
        Flow.stateChanged(win, s === BluetoothDeviceState.Connecting, s === BluetoothDeviceState.Disconnected)
      }
      function onConnectedChanged() { Flow.connectedChanged(win) }
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
        focus: true
        Keys.onPressed: event => {
          const d = list.currentIndex >= 0 ? win.rows[list.currentIndex] : null
          if (event.key === Qt.Key_Escape) Qt.quit()
          else if (event.key === Qt.Key_Down) list.incrementCurrentIndex()
          else if (event.key === Qt.Key_Up) list.decrementCurrentIndex()
          else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && d) win.pick(d)
          else if (event.key === Qt.Key_Delete && d && (d.paired || d.bonded)) win.forget(d)
        }
      }

      Column {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
        spacing: 12

        // Header: title, scan status, power switch.
        Item {
          width: parent.width
          height: 28

          Text {
            id: title
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Bluetooth"
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
            visible: win.on && win.adapter.discovering

            Text {
              id: spinner
              text: "󰑓"
              color: win.accent
              font.family: win.font
              font.pixelSize: 13
              RotationAnimation on rotation {
                running: spinner.visible
                from: 0; to: 360; duration: 1000; loops: Animation.Infinite
              }
            }

            Text {
              text: "Searching…"
              color: win.dim
              font.family: win.font
              font.pixelSize: 12
            }
          }

          Rectangle {
            visible: win.adapter !== null
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 22
            radius: 11
            color: win.on ? win.accent : win.track

            Rectangle {
              x: win.on ? parent.width - width - 3 : 3
              anchors.verticalCenter: parent.verticalCenter
              width: 16
              height: 16
              radius: 8
              color: win.on ? "#1e1e2e" : win.dim
              Behavior on x { NumberAnimation { duration: 120 } }
            }

            MouseArea { anchors.fill: parent; onClicked: win.adapter.enabled = !win.adapter.enabled }
          }
        }

        Text {
          visible: !win.on || win.rows.length === 0
          text: win.adapter === null ? "No Bluetooth adapter"
            : win.adapter.state === BluetoothAdapterState.Blocked ? "Bluetooth is blocked"
            : !win.on ? "Bluetooth is off" : "No devices found yet"
          color: win.dim
          font.family: win.font
          font.pixelSize: 13
        }

        ListView {
          id: list
          visible: win.rows.length > 0
          width: parent.width
          height: Math.min(contentHeight, 440)
          clip: true
          currentIndex: -1
          model: win.rows
          spacing: 2

          delegate: Column {
            id: row
            required property var modelData
            required property int index
            readonly property var dev: modelData
            readonly property bool mine: dev.paired || dev.bonded
            width: ListView.view.width

            // Section heading above the first row of each group.
            Text {
              visible: row.index === 0 || row.index === win.paired.length
              height: visible ? implicitHeight + 6 : 0
              topPadding: row.index === 0 ? 0 : 6
              text: row.mine ? "My devices" : "Nearby"
              color: win.dim
              font.family: win.font
              font.pixelSize: 12
            }

            Rectangle {
              width: parent.width
              height: 36
              radius: 8
              color: rowMouse.containsMouse || list.currentIndex === row.index ? win.track : "transparent"

              MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: { list.currentIndex = row.index; win.pick(row.dev) }
              }

              Text {
                id: kind
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                text: win.glyph(row.dev)
                color: row.dev.connected ? win.accent : win.fg
                font.family: win.font
                font.pixelSize: 16
              }

              Text {
                anchors.left: kind.right
                anchors.leftMargin: 10
                anchors.right: side.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: row.dev.name
                elide: Text.ElideRight
                color: row.dev.connected ? win.accent : win.fg
                font.family: win.font
                font.pixelSize: 13
                font.bold: row.dev.connected
              }

              Row {
                id: side
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Text {
                  visible: row.dev.batteryAvailable
                  text: Math.round(row.dev.battery * 100) + "%"
                  color: win.dim
                  font.family: win.font
                  font.pixelSize: 12
                  anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                  text: win.busy(row.dev) ? "…" : (row.dev.connected ? "󰄬" : "")
                  color: win.dim
                  font.family: win.font
                  font.pixelSize: 14
                  anchors.verticalCenter: parent.verticalCenter
                }

                // Forget: paired devices only, on hover so a stray click on the row never removes a pairing.
                Text {
                  visible: row.mine && (rowMouse.containsMouse || forgetMouse.containsMouse)
                  text: "󰆴"
                  color: forgetMouse.containsMouse ? win.error : win.dim
                  font.family: win.font
                  font.pixelSize: 14
                  anchors.verticalCenter: parent.verticalCenter
                  MouseArea {
                    id: forgetMouse
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    onClicked: win.forget(row.dev)
                  }
                }
              }
            }
          }
        }

        Text {
          visible: win.failure !== ""
          width: parent.width
          wrapMode: Text.Wrap
          text: win.failure
          color: win.error
          font.family: win.font
          font.pixelSize: 12
        }

        Rectangle { width: parent.width; height: 1; color: win.track }

        Text {
          text: "󰒓  Advanced (bluetoothctl)"
          color: advMouse.containsMouse ? win.fg : win.dim
          font.family: win.font
          font.pixelSize: 13
          MouseArea {
            id: advMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              Quickshell.execDetached([Quickshell.env("HOME") + "/.config/sway/bin/float", "bluetoothctl"])
              Qt.quit()
            }
          }
        }
      }
    }
  }
}
