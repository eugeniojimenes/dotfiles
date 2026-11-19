import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Wayland
import "notify.mjs" as Notify
import "../common"

// Volume, microphone, brightness, track and switch popup of the notification daemon (../notifications.qml), over IPC:
// `call osd popup <volume|mic|brightness> <percent> <muted>` from bin/osd (not `show`: the CLI takes that for
// `ipc show`), `call osd track <instance> <toggle|next|previous>` from bin/media, `call osd switched <kind> <value>`
// from bin/osd switch (stay awake, night light, power profile; do not disturb from the daemon itself). The track popup reads the player live: the play/pause icon
// and the track after next/previous show once the player reports them. The window exists only while shown, so each
// time it maps Sway puts it on the focused output. Empty mask = clicks pass through; no keyboard focus.
Scope {
  id: osd

  property string kind: "volume"
  property int value: 0
  property bool muted: false
  property bool shown: false
  property var player: null // MprisPlayer of a track popup
  property string action: "toggle"
  // Switch popup: Notify.switchPopup of the last kind and value.
  property string switchIcon: ""
  property string switchTitle: ""
  property string switchDetail: ""
  property bool switchOn: false
  readonly property bool playing: player ? player.isPlaying : false
  readonly property color trackColor: playing ? Theme.playing : Theme.dim // as the waybar track

  function showSwitch(kind, value) {
    const popup = Notify.switchPopup(kind, value)
    if (!popup)
      return
    osd.switchIcon = popup.icon
    osd.switchTitle = popup.title
    osd.switchDetail = popup.detail
    osd.switchOn = popup.on
    osd.kind = "switch"
    osd.shown = true
    hide.interval = 1500
    hide.restart()
  }

  IpcHandler {
    target: "osd"

    function popup(kind: string, value: int, muted: bool): void {
      osd.kind = kind
      osd.value = Math.max(0, Math.min(100, value))
      osd.muted = muted
      osd.shown = true
      hide.interval = 1500
      hide.restart()
    }

    // instance = playerctl's name for the player: its D-Bus name without the MPRIS prefix.
    function track(instance: string, action: string): void {
      const found = Mpris.players.values.find(p => p.dbusName === "org.mpris.MediaPlayer2." + instance)
      if (!found)
        return
      osd.player = found
      osd.action = action
      osd.kind = "track"
      osd.shown = true
      hide.interval = 2500
      hide.restart()
    }

    function switched(kind: string, value: string): void { osd.showSwitch(kind, value) }
  }

  // next/previous: the new title arrives after the command, the popup stays for it.
  Connections {
    target: osd.kind === "track" && osd.shown ? osd.player : null

    function onTrackTitleChanged() { hide.restart() }
  }

  // Each key press restarts it: the popup stays while keys repeat and goes 1.5 s (track: 2.5 s) after the last one.
  Timer {
    id: hide

    interval: 1500
    onTriggered: osd.shown = false
  }

  LazyLoader {
    active: osd.shown

    PanelWindow {
      anchors.bottom: true
      margins.bottom: 80 // qmllint disable unresolved-type
      implicitWidth: 320
      implicitHeight: 56
      color: "transparent"
      mask: Region {}
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "sway-osd"
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

      Rectangle {
        anchors.fill: parent
        radius: 12
        color: Theme.bg
        border.color: Theme.track
        border.width: 1

        Row {
          anchors.centerIn: parent
          spacing: 14

          Text {
            width: 26
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: osd.kind === "track" ? Notify.trackIcon(osd.action, osd.playing)
              : osd.kind === "switch" ? osd.switchIcon : Notify.osdIcon(osd.kind, osd.value, osd.muted)
            color: osd.kind === "track" ? osd.trackColor
              : osd.kind === "switch" ? (osd.switchOn ? Theme.fg : Theme.dim) : osd.muted ? Theme.dim : Theme.fg
            font.family: Theme.font
            font.pixelSize: 22
          }

          Text {
            visible: osd.kind === "track"
            width: 254
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: osd.player ? Notify.trackText(osd.player.trackArtist, osd.player.trackTitle, osd.player.identity) : ""
            elide: Text.ElideRight
            color: osd.trackColor
            font.family: Theme.font
            font.pixelSize: 13
          }

          Column {
            visible: osd.kind === "switch"
            width: 254
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
              width: parent.width
              textFormat: Text.PlainText
              text: osd.switchTitle
              elide: Text.ElideRight
              color: osd.switchOn ? Theme.fg : Theme.dim
              font.family: Theme.font
              font.pixelSize: 13
            }

            Text {
              width: parent.width
              textFormat: Text.PlainText
              text: osd.switchDetail
              elide: Text.ElideRight
              color: Theme.dim
              font.family: Theme.font
              font.pixelSize: 11
            }
          }

          Rectangle {
            visible: osd.kind !== "track" && osd.kind !== "switch"
            width: 200
            height: 6
            radius: 3
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.track

            Rectangle {
              width: parent.width * osd.value / 100
              height: parent.height
              radius: parent.radius
              color: osd.muted ? Theme.dim : Theme.accent
            }
          }

          Text {
            visible: osd.kind !== "track" && osd.kind !== "switch"
            width: 40
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignRight
            textFormat: Text.PlainText
            text: osd.value + "%"
            color: osd.muted ? Theme.dim : Theme.fg
            font.family: Theme.font
            font.pixelSize: 13
          }
        }
      }
    }
  }
}
