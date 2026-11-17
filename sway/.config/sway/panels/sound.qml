import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import "common"
import "sound/sound.mjs" as Sound

// Sound panel for the waybar volume icon: output and input volume, mute and live level, default device pick, and
// per-app volume, straight from PipeWire (Quickshell.Services.Pipewire). Volume stops at 100%. Arrows step the output
// volume, M mutes it, Esc or a click outside closes. One process per open, like the calendar.
ShellRoot {
  PanelShell {
    id: win

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var all: Pipewire.nodes.values.filter(node => node.audio)
    // Lists and names: sound/sound.mjs (tested).
    readonly property var lists: Sound.devices(all)
    readonly property var sinks: lists.outputs
    readonly property var sources: lists.inputs
    readonly property var apps: lists.apps

    function label(node) { return Sound.label(node) }
    function appLabel(node) { return Sound.appLabel(node) }
    function setVolume(node, volume) { if (node && node.audio) node.audio.volume = Sound.clampVolume(volume) }

    WlrLayershell.namespace: "sway-sound"

    // Volume and mute are only valid on nodes bound by a tracker.
    PwObjectTracker { objects: win.all }

    // Icon (click = mute), name, slider, percentage; optional live level bar under the slider.
    component VolumeRow: Column {
      id: vr

      required property var node
      property string name: ""
      property list<string> icons: ["󰕿", "󰖀", "󰕾"]
      property string mutedIcon: "󰝟"
      property bool meter: false
      readonly property real vol: node && node.audio ? node.audio.volume : 0
      readonly property bool muted: node && node.audio ? node.audio.muted : false
      width: parent.width
      spacing: 4

      Text {
        visible: vr.name !== ""
        width: parent.width
        text: vr.name
        elide: Text.ElideRight
        color: win.dim
        font.family: win.font
        font.pixelSize: 12
      }

      Item {
        width: parent.width
        height: 24

        Text {
          id: icon
          width: 24
          anchors.verticalCenter: parent.verticalCenter
          text: vr.muted ? vr.mutedIcon : vr.icons[Math.min(vr.icons.length - 1, Math.floor(vr.vol * vr.icons.length))]
          color: vr.muted ? win.dim : win.fg
          font.family: win.font
          font.pixelSize: 16
          MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; anchors.margins: -4; onClicked: if (vr.node) vr.node.audio.muted = !vr.muted }
        }

        Rectangle {
          id: bar
          anchors.left: icon.right
          anchors.leftMargin: 8
          anchors.right: pct.left
          anchors.rightMargin: 10
          anchors.verticalCenter: parent.verticalCenter
          height: 6
          radius: 3
          color: win.track

          Rectangle {
            width: parent.width * vr.vol
            height: parent.height
            radius: 3
            color: vr.muted ? win.dim : win.accent
          }

          Rectangle {
            x: parent.width * vr.vol - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: 14
            height: 14
            radius: 7
            color: vr.muted ? win.dim : win.fg
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            anchors.margins: -8
            function apply(mouse) { win.setVolume(vr.node, (mouse.x - 8) / bar.width) }
            onPressed: mouse => apply(mouse)
            onPositionChanged: mouse => { if (pressed) apply(mouse) }
            onWheel: wheel => win.setVolume(vr.node, vr.vol + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))
          }
        }

        Text {
          id: pct
          width: 40
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          horizontalAlignment: Text.AlignRight
          text: Math.round(vr.vol * 100) + "%"
          color: win.dim
          font.family: win.font
          font.pixelSize: 12
        }
      }

      Rectangle {
        visible: vr.meter
        x: 32
        width: parent.width - 32 - 50
        height: 3
        radius: 1.5
        color: win.track

        Rectangle {
          width: parent.width * Math.min(1, peak.peak)
          height: parent.height
          radius: 1.5
          color: win.dim
        }

        PwNodePeakMonitor { id: peak; node: vr.node; enabled: vr.meter && vr.node !== null }
      }
    }

    // Devices of one kind, the default one checked; click makes it the default.
    component DeviceList: Column {
      id: dl

      required property var nodes
      required property var current
      property bool isSink: true
      width: parent.width
      visible: nodes.length > 1

      Repeater {
        model: dl.nodes
        Rectangle {
          required property var modelData
          width: dl.width
          height: 28
          radius: 6
          color: devMouse.containsMouse ? win.track : "transparent"

          Text {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: (modelData === dl.current ? "󰄬  " : "    ") + win.label(modelData)
            elide: Text.ElideRight
            color: modelData === dl.current ? win.accent : win.fg
            font.family: win.font
            font.pixelSize: 12
          }

          MouseArea {
            id: devMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
              if (dl.isSink) Pipewire.preferredDefaultAudioSink = parent.modelData
              else Pipewire.preferredDefaultAudioSource = parent.modelData
            }
          }
        }
      }
    }

    component Heading: Text {
      color: win.fg
      font.family: win.font
      font.pixelSize: 13
      font.bold: true
    }

    PanelCard {
      id: card

      anchors.rightMargin: 8
      width: 380
      height: content.implicitHeight + 32


      Item {
        focus: true
        Keys.onPressed: event => {
          if (event.key === Qt.Key_Escape) Qt.quit()
          else if (event.key === Qt.Key_Up || event.key === Qt.Key_Right) win.setVolume(win.sink, win.sink.audio.volume + 0.05)
          else if (event.key === Qt.Key_Down || event.key === Qt.Key_Left) win.setVolume(win.sink, win.sink.audio.volume - 0.05)
          else if (event.key === Qt.Key_M && win.sink) win.sink.audio.muted = !win.sink.audio.muted
        }
      }

      Column {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
        spacing: 10

        Heading { text: "Output" }
        Text {
          visible: win.sink === null
          text: "No output device"
          color: win.dim
          font.family: win.font
          font.pixelSize: 12
        }
        VolumeRow { visible: win.sink !== null; node: win.sink; name: win.sink ? win.label(win.sink) : ""; meter: true }
        DeviceList { nodes: win.sinks; current: win.sink; isSink: true }

        Rectangle { width: parent.width; height: 1; color: win.track }

        Heading { text: "Input" }
        Text {
          visible: win.source === null
          text: "No input device"
          color: win.dim
          font.family: win.font
          font.pixelSize: 12
        }
        VolumeRow {
          visible: win.source !== null
          node: win.source
          name: win.source ? win.label(win.source) : ""
          icons: ["󰍬"]
          mutedIcon: "󰍭"
          meter: true
        }
        DeviceList { nodes: win.sources; current: win.source; isSink: false }

        Rectangle { width: parent.width; height: 1; color: win.track }

        Heading { text: "Apps" }
        Text {
          visible: win.apps.length === 0
          text: "Nothing playing"
          color: win.dim
          font.family: win.font
          font.pixelSize: 12
        }
        Repeater {
          model: win.apps
          VolumeRow {
            required property var modelData
            node: modelData
            name: win.appLabel(modelData)
          }
        }

        Rectangle { width: parent.width; height: 1; color: win.track }

        AdvancedLink {
          text: "󰒓  Advanced (wiremix)"
          command: ["wiremix", "-c", Quickshell.env("HOME") + "/.config/sway/apps/wiremix.toml"]
        }
      }
    }
  }
}
