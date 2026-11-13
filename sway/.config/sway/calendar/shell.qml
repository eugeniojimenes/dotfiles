import QtQuick
import Quickshell
import Quickshell.Wayland

// Calendar popup for the waybar clock: month grid with ISO week numbers, today
// marked, year progress. Esc, a click outside or clicking the clock again closes it. Arrows and the wheel step
// months, Up/Down step years, Home goes back to today. One process per open: nothing runs while it is closed.
ShellRoot {
  PanelWindow {
    id: win

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "sway-calendar"

    readonly property color bg: "#f21e1e2e"
    readonly property color fg: "#cdd6f4"
    readonly property color dim: "#6c7086"
    readonly property color accent: "#89b4fa"
    readonly property string font: "JetBrainsMono Nerd Font"

    readonly property var months: ["January", "February", "March", "April", "May", "June", "July", "August",
                                   "September", "October", "November", "December"]
    readonly property var weekdays: ["M", "T", "W", "T", "F", "S", "S"]

    property date today: new Date()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth()

    function step(delta) {
      var m = viewMonth + delta
      viewYear += Math.floor(m / 12)
      viewMonth = ((m % 12) + 12) % 12
    }

    function goToday() {
      viewYear = today.getFullYear()
      viewMonth = today.getMonth()
    }

    function isoWeek(d) {
      var t = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()))
      t.setUTCDate(t.getUTCDate() + 4 - (t.getUTCDay() || 7))
      return Math.ceil(((t - new Date(Date.UTC(t.getUTCFullYear(), 0, 1))) / 86400000 + 1) / 7)
    }

    function sameDay(a, b) {
      return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate()
    }

    // 6 weeks x 7 days from the Monday on or before the 1st. Noon, so a DST change at midnight cannot shift a day.
    readonly property var cells: {
      var offset = (new Date(viewYear, viewMonth, 1, 12).getDay() + 6) % 7
      var out = []
      for (var i = 0; i < 42; i++) out.push(new Date(viewYear, viewMonth, 1 - offset + i, 12))
      return out
    }

    readonly property real yearDone: {
      var start = new Date(today.getFullYear(), 0, 1)
      return (today - start) / (new Date(today.getFullYear() + 1, 0, 1) - start)
    }

    // Anywhere outside the card closes.
    MouseArea {
      anchors.fill: parent
      onClicked: Qt.quit()
    }

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
              readonly property bool isToday: !weekCol && win.sameDay(day, win.today)
              readonly property bool inMonth: day.getMonth() === win.viewMonth

              width: weekCol ? 30 : 40
              height: 32
              radius: 8
              color: isToday ? win.accent : "transparent"

              Text {
                anchors.centerIn: parent
                text: parent.weekCol ? win.isoWeek(parent.day) : parent.day.getDate()
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
