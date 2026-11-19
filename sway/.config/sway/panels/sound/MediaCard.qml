import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "sound.mjs" as Sound
import "../common"

// Media card on top of the sound panel: player name (arrows switch players when more than one has a track), cover,
// title, artist, album, previous / play-pause / next and the track progress of the player Sound.mediaPlayer picks.
// Cover or title click = bring the player's window up. Hidden when no player has a track.
Column {
  id: media

  // Instance picked with the arrows, shared with the bar (bin/media pick); "" = follow the playing player.
  property string chosen: ""
  readonly property var players: Sound.mediaPlayers(Mpris.players.values)
  readonly property var player: Sound.mediaPlayer(Mpris.players.values, chosen)
  readonly property bool timed: player !== null && player.positionSupported && player.lengthSupported && player.length > 0

  function switchPlayer(step) {
    chosen = Sound.instance(Sound.stepPlayer(Mpris.players.values, player, step))
    Quickshell.execDetached([Quickshell.env("HOME") + "/.config/sway/bin/media", "pick", chosen])
  }
  function raise() {
    if (!player || !player.canRaise) return
    player.raise()
    Qt.quit()
  }

  visible: player !== null
  width: parent.width
  spacing: 8

  // The bar's pick: read at open, again when bin/media changes it (a pick, or cleared when another player starts).
  FileView {
    id: choiceFile
    path: Quickshell.env("XDG_RUNTIME_DIR") + "/sway-media-player"
    blockLoading: true
    printErrors: false
    watchChanges: true
    onFileChanged: reload()
    onLoaded: media.chosen = text().trim()
  }

  // MPRIS sends no signal while the position moves: re-read it every second while playing.
  Timer {
    running: media.player !== null && media.player.isPlaying
    interval: 1000
    repeat: true
    onTriggered: media.player.positionChanged()
  }

  component Control: Text {
    id: control

    property bool active: true
    property int size: 18

    signal clicked

    textFormat: Text.PlainText
    width: size + 10
    horizontalAlignment: Text.AlignHCenter
    color: active ? Theme.fg : Theme.dim
    font.family: Theme.font
    font.pixelSize: size
    MouseArea {
      anchors.fill: parent
      anchors.margins: -4
      cursorShape: control.active ? Qt.PointingHandCursor : Qt.ArrowCursor
      onClicked: if (control.active) control.clicked()
    }
  }

  component Line: Text {
    textFormat: Text.PlainText
    width: parent.width
    visible: text !== ""
    elide: Text.ElideRight
    color: Theme.dim
    font.family: Theme.font
    font.pixelSize: 12
  }

  // Player name; arrows only when more than one player has a track.
  Row {
    spacing: 2

    Control {
      visible: media.players.length > 1
      text: "󰅁"
      size: 12
      onClicked: media.switchPlayer(-1)
    }
    Text {
      anchors.verticalCenter: parent.verticalCenter
      textFormat: Text.PlainText
      text: media.player ? media.player.identity : ""
      color: Theme.dim
      font.family: Theme.font
      font.pixelSize: 11
    }
    Control {
      visible: media.players.length > 1
      text: "󰅂"
      size: 12
      onClicked: media.switchPlayer(1)
    }
  }

  Row {
    width: parent.width
    spacing: 12

    Rectangle {
      width: 64
      height: 64
      radius: 6
      clip: true
      color: Theme.track

      Text {
        anchors.centerIn: parent
        visible: cover.status !== Image.Ready
        text: "󰎆"
        color: Theme.dim
        font.family: Theme.font
        font.pixelSize: 28
      }

      Image {
        id: cover
        anchors.fill: parent
        source: media.player ? media.player.trackArtUrl : ""
        sourceSize: Qt.size(128, 128)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
      }

      MouseArea {
        anchors.fill: parent
        enabled: media.player !== null && media.player.canRaise
        cursorShape: Qt.PointingHandCursor
        onClicked: media.raise()
      }
    }

    Column {
      width: parent.width - 64 - 12
      anchors.verticalCenter: parent.verticalCenter
      spacing: 2

      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: media.player ? media.player.trackTitle || media.player.identity : ""
        elide: Text.ElideRight
        color: Theme.fg
        font.family: Theme.font
        font.pixelSize: 13
        font.bold: true

        MouseArea {
          anchors.fill: parent
          enabled: media.player !== null && media.player.canRaise
          cursorShape: Qt.PointingHandCursor
          onClicked: media.raise()
        }
      }
      Line { text: media.player ? media.player.trackArtist : ""; color: Theme.fg }
      Line { text: media.player ? media.player.trackAlbum : "" }
      Row {
        spacing: 4
        Control {
          text: "󰒮"
          active: media.player !== null && media.player.canGoPrevious
          onClicked: media.player.previous()
        }
        Control {
          text: media.player && media.player.isPlaying ? "󰏤" : "󰐊"
          active: media.player !== null && media.player.canTogglePlaying
          onClicked: media.player.togglePlaying()
        }
        Control {
          text: "󰒭"
          active: media.player !== null && media.player.canGoNext
          onClicked: media.player.next()
        }
      }
    }
  }

  // Progress: click seeks when the player allows it.
  Item {
    visible: media.timed
    width: parent.width
    height: 16

    Rectangle {
      id: track
      anchors.left: parent.left
      anchors.right: time.left
      anchors.rightMargin: 10
      anchors.verticalCenter: parent.verticalCenter
      height: 4
      radius: 2
      color: Theme.track

      Rectangle {
        width: media.timed ? parent.width * Math.min(1, media.player.position / media.player.length) : 0
        height: parent.height
        radius: 2
        color: Theme.accent
      }

      MouseArea {
        anchors.fill: parent
        anchors.margins: -6
        enabled: media.timed && media.player.canSeek
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: mouse => media.player.position = Math.max(0, Math.min(1, (mouse.x - 6) / track.width)) * media.player.length
      }
    }

    Text {
      id: time
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      textFormat: Text.PlainText
      text: media.timed ? Sound.clock(media.player.position) + " / " + Sound.clock(media.player.length) : ""
      color: Theme.dim
      font.family: Theme.font
      font.pixelSize: 11
    }
  }
}
