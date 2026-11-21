import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import "notify.mjs" as Notify
import "../common"

// One notification in Centre.qml. Click = default action, action buttons run theirs (both close the centre: the app
// takes over), the close mark dismisses it.
Rectangle {
  id: entry

  required property var modelData   // the Notification
  property real arrivedAt
  property real now

  readonly property var n: modelData
  readonly property var defaultAction: n.actions.find(action => action.identifier === "default") ?? null
  readonly property var buttons: n.actions.filter(action => action.identifier !== "default")

  // WARN: The centre closes before the action runs: invoking a non-resident notification destroys this entry, and the
  // handler with it.
  signal done

  function run(action) {
    done()
    action.invoke()
  }

  height: row.implicitHeight + 20
  radius: 8
  color: area.containsMouse && defaultAction ? Theme.track : "transparent"
  border.color: n.urgency === NotificationUrgency.Critical ? Theme.error : Theme.track
  border.width: 1

  MouseArea {
    id: area

    anchors.fill: parent
    hoverEnabled: true
    cursorShape: entry.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: if (entry.defaultAction) entry.run(entry.defaultAction)
  }

  Row {
    id: row

    x: 10
    y: 10
    width: parent.width - 20
    spacing: 10

    IconImage {
      id: icon

      readonly property string src: entry.n.image !== "" ? entry.n.image
                                    : (entry.n.appIcon !== "" ? Quickshell.iconPath(entry.n.appIcon, true) : "")

      visible: src !== ""
      source: src
      implicitSize: 28
    }

    Column {
      width: parent.width - (icon.visible ? 38 : 0)
      spacing: 3

      Item {
        width: parent.width
        height: meta.implicitHeight

        Text {
          id: meta

          width: parent.width - 24
          textFormat: Text.PlainText
          text: Notify.meta(entry.n.appName, Notify.ago(entry.arrivedAt, entry.now))
          color: Theme.dim
          font.family: Theme.font
          font.pixelSize: 10
          elide: Text.ElideRight
        }
        // Dismiss this one.
        Text {
          anchors.right: parent.right
          text: "󰅖"
          color: closeArea.containsMouse ? Theme.fg : Theme.dim
          font.family: Theme.font
          font.pixelSize: 13

          MouseArea {
            id: closeArea

            anchors.fill: parent
            anchors.margins: -6
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: entry.n.dismiss()
          }
        }
      }
      Text {
        width: parent.width
        textFormat: Text.PlainText
        text: entry.n.summary
        color: Theme.fg
        font.family: Theme.font
        font.pixelSize: 12
        font.bold: true
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
      }
      Text {
        width: parent.width
        text: Notify.safeBody(entry.n.body)
        visible: text !== ""
        textFormat: Text.StyledText
        color: Theme.fg
        font.family: Theme.font
        font.pixelSize: 11
        wrapMode: Text.Wrap
        maximumLineCount: 4
        elide: Text.ElideRight
      }
      Flow {
        width: parent.width
        visible: entry.buttons.length > 0
        spacing: 6

        Repeater {
          model: entry.buttons

          Chip {
            required property var modelData

            label: modelData.text
            active: false
            onPressed: entry.run(modelData)
          }
        }
      }
    }
  }
}
