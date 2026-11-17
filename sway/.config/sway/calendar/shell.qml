import QtQuick
import Quickshell
import Quickshell.Wayland
import "calendar.js" as Cal
import "../common"

// Calendar popup for the waybar clock: month grid with ISO week numbers, today
// marked, year progress. Esc, a click outside or clicking the clock again closes it. Arrows and the wheel step
// months, Up/Down step years, Home goes back to today. One process per open: nothing runs while it is closed.
ShellRoot {
  PanelShell {
    id: win

    WlrLayershell.namespace: "sway-calendar"


    readonly property var months: ["January", "February", "March", "April", "May", "June", "July", "August",
                                   "September", "October", "November", "December"]
    readonly property var weekdays: ["M", "T", "W", "T", "F", "S", "S"]

    property date today: new Date()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth()

    function step(delta) {
      const v = Cal.step(viewYear, viewMonth, delta)
      viewYear = v.year
      viewMonth = v.month
    }

    function goToday() {
      viewYear = today.getFullYear()
      viewMonth = today.getMonth()
    }

    // Date math in calendar.js (tested there).
    readonly property var cells: Cal.cells(viewYear, viewMonth)
    readonly property real yearDone: Cal.yearDone(today)

    Rectangle {
      id: card

      anchors.horizontalCenter: parent.horizontalCenter
      y: 34
      // Whole card 20% bigger, grown from its top edge so it stays right under the clock. Text is distance-field
      // rendered, so it stays sharp when scaled.
      scale: 1.2
      transformOrigin: Item.Top
      width: content.implicitWidth + 40
      height: content.implicitHeight + 32
      radius: 12
      color: win.bg
      border.color: win.accent
      border.width: 2

      // Swallows clicks so they do not reach the close-on-outside area, and turns the wheel into month steps.
      MouseArea {
        anchors.fill: parent
        onWheel: wheel => win.step(wheel.angleDelta.y > 0 ? -1 : 1)
      }

      Item {
        focus: true
        Keys.onPressed: event => {
          if (event.key === Qt.Key_Escape) Qt.quit()
          else if (event.key === Qt.Key_Left) win.step(-1)
          else if (event.key === Qt.Key_Right) win.step(1)
          else if (event.key === Qt.Key_Up) win.step(-12)
          else if (event.key === Qt.Key_Down) win.step(12)
          else if (event.key === Qt.Key_Home) win.goToday()
        }
      }

      Column {
        id: content
        anchors.centerIn: parent
        spacing: 14

        // Header: chevrons around "Month Year". Clicking the title goes back to today.
        Item {
          width: grid.width
          height: 28

          Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "󰅁"
            color: win.fg
            font.family: win.font
            font.pixelSize: 18
            MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: win.step(-1) }
          }

          Text {
            anchors.centerIn: parent
            text: win.months[win.viewMonth] + " " + win.viewYear
            color: win.fg
            font.family: win.font
            font.pixelSize: 16
            font.bold: true
            MouseArea { anchors.fill: parent; onClicked: win.goToday() }
          }

          Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: "󰅂"
            color: win.fg
            font.family: win.font
            font.pixelSize: 18
            MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: win.step(1) }
          }
        }

        Grid {
          id: grid
          columns: 8
          columnSpacing: 2
          rowSpacing: 2

          // Header row: week column, then Monday-first day initials.
          Repeater {
            model: ["", ...win.weekdays]
            Text {
              width: index === 0 ? 30 : 40
              height: 24
              text: modelData
              color: win.dim
              font.family: win.font
              font.pixelSize: 12
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
            }
          }

          // 6 rows x (week number + 7 days).
          Repeater {
            model: 48
            Rectangle {
              readonly property int row: Math.floor(index / 8)
              readonly property bool weekCol: index % 8 === 0
              readonly property date day: win.cells[row * 7 + (weekCol ? 0 : index % 8 - 1)]
              readonly property bool isToday: !weekCol && Cal.sameDay(day, win.today)
              readonly property bool inMonth: day.getMonth() === win.viewMonth

              width: weekCol ? 30 : 40
              height: 32
              radius: 8
              color: isToday ? win.accent : "transparent"

              Text {
                anchors.centerIn: parent
                text: parent.weekCol ? Cal.isoWeek(parent.day) : parent.day.getDate()
                color: parent.isToday ? "#1e1e2e" : (parent.weekCol || !parent.inMonth ? win.dim : win.fg)
                font.family: win.font
                font.pixelSize: parent.weekCol ? 11 : 14
                font.bold: parent.isToday
              }
            }
          }
        }

        // Year progress, pinned to today regardless of the month on screen.
        Column {
          width: grid.width
          spacing: 6

          Text {
            text: win.today.getFullYear() + "  ·  " + Math.round(win.yearDone * 100) + "% of the year"
            color: win.dim
            font.family: win.font
            font.pixelSize: 12
          }

          Rectangle {
            width: parent.width
            height: 4
            radius: 2
            color: "#313244"

            Rectangle {
              width: parent.width * win.yearDone
              height: parent.height
              radius: 2
              color: win.accent
            }
          }
        }
      }
    }
  }
}
