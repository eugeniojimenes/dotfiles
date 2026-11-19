import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import "share/share.mjs" as Share
import "common"

// Screen-share picker, started by bin/share-picker for xdg-desktop-portal-wlr: one card per monitor and window the
// portal offers, side by side, so any number of windows fits the screen. Left/Right and the wheel move, Enter or a
// click picks, Esc or a click outside cancels. Cards come from the file in $SHARE_PICKER_IN (format in share.mjs); the
// pick's portal line goes to $SHARE_PICKER_OUT, read by the script once this process ends.
ShellRoot {
  PanelShell {
    id: win

    readonly property var cards: Share.parse(input.text())
    property int current: cards.length > 0 ? 0 : -1

    function move(delta) {
      current = Share.step(current, delta, cards.length)
    }

    function pick(index) {
      if (index < 0 || index >= cards.length) return
      output.setText(cards[index].line + "\n")
      Qt.quit()
    }

    WlrLayershell.namespace: "sway-share"

    // Env unset (panels-load in bin/check): no file, no cards.
    FileView {
      id: input

      path: Quickshell.env("SHARE_PICKER_IN") ?? ""
      blockLoading: true
      printErrors: false
    }

    // Blocking: the process quits right after the write.
    FileView {
      id: output

      path: Quickshell.env("SHARE_PICKER_OUT") ?? ""
      blockWrites: true
      atomicWrites: false
    }

    PanelCard {
      anchors.right: undefined
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      transformOrigin: Item.Center
      width: Math.min(parent.width - 80, strip.contentWidth + 32)
      height: content.implicitHeight + 32

      // Swallows clicks (outside closes) and turns the wheel, either axis, into card steps.
      MouseArea {
        anchors.fill: parent
        onWheel: wheel => {
          const delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : -wheel.angleDelta.x
          win.move(delta > 0 ? -1 : 1)
        }
      }

      Item {
        focus: true
        Keys.onPressed: event => {
          if (event.key === Qt.Key_Escape) Qt.quit()
          else if (event.key === Qt.Key_Left) win.move(-1)
          else if (event.key === Qt.Key_Right) win.move(1)
          else if (event.key === Qt.Key_Home) win.current = Share.step(0, 0, win.cards.length)
          else if (event.key === Qt.Key_End) win.current = Share.step(win.cards.length - 1, 0, win.cards.length)
          else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) win.pick(win.current)
        }
      }

      Column {
        id: content

        x: 16
        y: 16
        width: parent.width - 32
        spacing: 12

        Text {
          text: "Share which screen or window?"
          color: win.fg
          font.family: win.font
          font.pixelSize: 15
          font.bold: true
        }

        ListView {
          id: strip

          width: parent.width
          height: 230
          orientation: ListView.Horizontal
          spacing: 12
          clip: true
          interactive: false
          model: win.cards
          currentIndex: win.current
          onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

          delegate: Rectangle {
            id: card

            required property var modelData
            required property int index
            readonly property bool selected: index === win.current

            width: 320
            height: strip.height
            radius: 10
            color: selected ? win.track : "transparent"
            border.color: selected ? win.accent : win.track
            border.width: 2

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onEntered: win.current = card.index
              onClicked: win.pick(card.index)
            }

            // Thumbnail, else the app's icon, else a glyph for the kind.
            Item {
              id: preview

              x: 10
              y: 10
              width: parent.width - 20
              height: 170

              Image {
                anchors.fill: parent
                visible: card.modelData.thumbnail !== ""
                source: card.modelData.thumbnail !== "" ? "file://" + card.modelData.thumbnail : ""
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: false
              }
              IconImage {
                anchors.centerIn: parent
                implicitSize: 72
                visible: card.modelData.thumbnail === "" && card.modelData.app !== ""
                source: card.modelData.app !== "" ? Quickshell.iconPath(card.modelData.app, true) : ""
              }
              Text {
                anchors.centerIn: parent
                visible: card.modelData.thumbnail === "" && card.modelData.app === ""
                textFormat: Text.PlainText
                text: card.modelData.kind === "monitor" ? "󰍹" : "󰖯"
                color: card.selected ? win.accent : win.dim
                font.family: win.font
                font.pixelSize: 64
              }
            }

            Column {
              x: 12
              anchors.top: preview.bottom
              anchors.topMargin: 8
              width: parent.width - 24
              spacing: 2

              Text {
                width: parent.width
                textFormat: Text.PlainText
                text: card.modelData.label
                elide: Text.ElideRight
                color: win.fg
                font.family: win.font
                font.pixelSize: 13
              }
              Text {
                width: parent.width
                textFormat: Text.PlainText
                text: card.modelData.detail
                elide: Text.ElideRight
                color: win.dim
                font.family: win.font
                font.pixelSize: 11
              }
            }
          }
        }

        Text {
          text: "←/→ or wheel to move, Enter or click to share, Esc to cancel"
          color: win.dim
          font.family: win.font
          font.pixelSize: 11
        }
      }
    }
  }
}
