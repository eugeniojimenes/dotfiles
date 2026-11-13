import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Display panel for the waybar monitor icon: brightness, scale, laptop screen on/off and
// text size, per monitor (chevrons switch between them). Drawing only; all reads and writes go through ./ctl.
// Esc or a click outside closes it. One process per open, like the calendar.
ShellRoot {
  PanelWindow {
    id: win

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "sway-display"

    readonly property string ctl: Quickshell.env("HOME") + "/.config/sway/display/ctl"
    readonly property color bg: "#f21e1e2e"
    readonly property color fg: "#cdd6f4"
    readonly property color dim: "#6c7086"
    readonly property color accent: "#89b4fa"
    readonly property color track: "#313244"
    readonly property string font: "JetBrainsMono Nerd Font"

    readonly property var scales: [1, 1.25, 1.6, 2]
    readonly property var textStops: [9, 10, 11, 12, 14, 16, 20]

    property var outputs: []
    property int current: -1
    property int textPx: 12
    property int brightness: -1          // -1 = unknown/unavailable
    property bool loadingBrightness: false
    readonly property var out: current >= 0 && current < outputs.length ? outputs[current] : null
    readonly property bool hasLaptopToggle: outputs.length > 1 && outputs.some(o => o.internal)

    function run(args) {
      action.command = [ctl].concat(args)
      action.running = true
    }

    function select(i) {
      current = (i + outputs.length) % outputs.length
      brightness = -1
      loadingBrightness = true
      brightRead.command = [ctl, "brightness", "get", outputs[current].name]
      brightRead.running = true
    }

    function setBrightness(pct) {
      brightness = Math.max(1, Math.min(100, Math.round(pct)))
      writeDelay.restart()
    }

    Process {
      id: stateRead
      command: [win.ctl, "state"]
      running: true
      stdout: StdioCollector {
        waitForEnd: true
        onStreamFinished: {
          var s = JSON.parse(text)
          var keep = win.out ? win.out.name : ""
          win.outputs = s.outputs
          win.textPx = s.text
          var idx = s.outputs.findIndex(o => keep ? o.name === keep : o.focused)
          if (keep === "" || idx !== win.current) win.select(idx >= 0 ? idx : 0)
        }
      }
    }

    Process {
      id: brightRead
      stdout: StdioCollector {
        waitForEnd: true
        onStreamFinished: {
          var v = parseInt(String(text).trim(), 10)
          win.brightness = isNaN(v) ? -1 : v
          win.loadingBrightness = false
        }
      }
    }

    // DDC/CI writes are slow; send only the last value of a drag or wheel burst.
    Timer {
      id: writeDelay
      interval: 250
      onTriggered: brightWrite.running ? restart() : (brightWrite.command = [win.ctl, "brightness", "set", win.out.name,
                                                                             String(win.brightness)],
                                                      brightWrite.running = true)
    }
    Process { id: brightWrite }

    // Brightness changed elsewhere (Fn keys, wheel on the bar icon): those call ./refresh, which reaches this over
    // Quickshell IPC. Event-driven, no polling. Ignored while a write is pending, so a drag never bounces back.
    IpcHandler {
      target: "display"
      function refresh(): void {
        if (win.out === null || writeDelay.running || brightWrite.running || brightRead.running) return
        brightRead.command = [win.ctl, "brightness", "get", win.out.name]
        brightRead.running = true
      }
    }

    Process {
      id: action
      onRunningChanged: if (!running) stateRead.running = true
    }

    MouseArea {
      anchors.fill: parent
      onClicked: Qt.quit()
    }

    Rectangle {
      id: card

      anchors.right: parent.right
      anchors.rightMargin: 10
      y: 34
      scale: 1.2
      transformOrigin: Item.TopRight
      width: 300
      height: content.implicitHeight + 32
      radius: 12
      color: win.bg
      border.color: win.accent
      border.width: 2

      MouseArea { anchors.fill: parent }

      Item {
        focus: true
        Keys.onPressed: event => {
          if (event.key === Qt.Key_Escape) Qt.quit()
          else if (event.key === Qt.Key_Left && win.outputs.length > 1) win.select(win.current - 1)
          else if (event.key === Qt.Key_Right && win.outputs.length > 1) win.select(win.current + 1)
          else if (event.key === Qt.Key_Up && win.brightness >= 0) win.setBrightness(win.brightness + 5)
          else if (event.key === Qt.Key_Down && win.brightness >= 0) win.setBrightness(win.brightness - 5)
        }
      }

      component Label: Text {
        color: win.dim
        font.family: win.font
        font.pixelSize: 11
        font.capitalization: Font.AllUppercase
      }

      component Chip: Rectangle {
        property string label
        property bool active
        signal pressed

        width: Math.max(38, chipText.implicitWidth + 16)
        height: 28
        radius: 8
        color: active ? win.accent : (hover.containsMouse ? win.track : "transparent")
        border.color: active ? win.accent : win.track
        border.width: 1

        Text {
          id: chipText
          anchors.centerIn: parent
          text: parent.label
          color: parent.active ? "#1e1e2e" : win.fg
          font.family: win.font
          font.pixelSize: 12
          font.bold: parent.active
        }

        MouseArea {
          id: hover
          anchors.fill: parent
          hoverEnabled: true
          onClicked: parent.pressed()
        }
      }

      Column {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        y: 16
        width: parent.width - 36
        spacing: 16

        // Which monitor: chevrons only when there is more than one.
        Item {
          width: parent.width
          height: 38

          Text {
            visible: win.outputs.length > 1
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "󰅁"
            color: win.fg
            font.family: win.font
            font.pixelSize: 18
            MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: win.select(win.current - 1) }
          }

          Column {
            anchors.centerIn: parent
            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: win.out ? (win.out.internal ? "Laptop screen" : (win.out.make.split(" ")[0] + " " + win.out.model)) : ""
              color: win.fg
              font.family: win.font
              font.pixelSize: 14
              font.bold: true
            }
            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: win.out ? win.out.name + (win.out.active ? "" : "  ·  off") : ""
              color: win.dim
              font.family: win.font
              font.pixelSize: 11
            }
          }

          Text {
            visible: win.outputs.length > 1
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: "󰅂"
            color: win.fg
            font.family: win.font
            font.pixelSize: 18
            MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: win.select(win.current + 1) }
          }
        }

        // Brightness: click or drag on the bar, wheel/arrows in 5% steps.
        Column {
          width: parent.width
          spacing: 8

          Item {
            width: parent.width
            height: 14
            Label { text: "󰃠  Brightness" }
            Text {
              anchors.right: parent.right
              text: win.loadingBrightness ? "…" : (win.brightness >= 0 ? win.brightness + "%" : "unavailable")
              color: win.fg
              font.family: win.font
              font.pixelSize: 12
            }
          }

          Rectangle {
            id: bar
            width: parent.width
            height: 8
            radius: 4
            color: win.track
            opacity: win.brightness >= 0 ? 1 : 0.4

            Rectangle {
              width: parent.width * Math.max(0, win.brightness) / 100
              height: parent.height
              radius: 4
              color: win.accent
            }

            MouseArea {
              anchors.fill: parent
              anchors.margins: -8
              enabled: win.brightness >= 0
              onPressed: mouse => win.setBrightness((mouse.x - 8) / bar.width * 100)
              onPositionChanged: mouse => { if (pressed) win.setBrightness((mouse.x - 8) / bar.width * 100) }
              onWheel: wheel => win.setBrightness(win.brightness + (wheel.angleDelta.y > 0 ? 5 : -5))
            }
          }
        }

        // Scale presets (3x/4x make no sense at 1080p).
        Column {
          width: parent.width
          spacing: 8
          Label { text: "󰍉  Scale" }
          Row {
            spacing: 6
            Repeater {
              model: win.scales
              Chip {
                label: modelData + "x"
                active: win.out !== null && Math.abs(win.out.scale - modelData) < 0.01
                onPressed: win.run(["scale", win.out.name, String(modelData)])
              }
            }
          }
        }

        // Laptop screen on/off, only while another monitor is connected (never leave zero screens).
        Column {
          visible: win.hasLaptopToggle
          width: parent.width
          spacing: 8
          Label { text: "󰌢  Laptop screen" }
          Chip {
            readonly property var laptop: win.outputs.find(o => o.internal)
            label: laptop && laptop.active ? "Turn off" : "Turn on"
            active: false
            onPressed: win.run(["toggle", laptop.name])
          }
        }

        // Text size: one knob for every monitor (terminal + GTK).
        Column {
          width: parent.width
          spacing: 8
          Label { text: "󰛖  Text size" }
          Flow {
            width: parent.width
            spacing: 6
            Repeater {
              model: win.textStops
              Chip {
                label: String(modelData)
                active: win.textPx === modelData
                onPressed: { win.textPx = modelData; win.run(["text", String(modelData)]) }
              }
            }
          }
        }
      }
    }
  }
}
