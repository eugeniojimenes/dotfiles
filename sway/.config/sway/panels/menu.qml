import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Wayland
import "common"
import "menu/menu.mjs" as Menu

// Super+Space menu (and the waybar menu icon): the desktop's categories and actions, apps under Apps. The whole tree
// is in memory (menu/menu.mjs), so typing searches every level below the current one: its own entries first, then the
// deeper ones with their path. Apps come from DesktopEntries with their icons. Every row keeps the same icon column,
// glyph or image, so nothing moves while the list fills. Esc clears the search, then goes up a level, then closes.
// One process per open: nothing runs once it is closed. Spec: docs/specs/menu.md.
ShellRoot {
  PanelShell {
    id: win

    property string menu: "" // submenu shown, "" = root
    property int cursor: 0
    readonly property string profile: PowerProfiles.profile === PowerProfile.PowerSaver ? "power-saver"
      : PowerProfiles.profile === PowerProfile.Performance ? "performance" : "balanced"
    readonly property var apps: DesktopEntries.applications.values.filter(entry => !entry.noDisplay).map(entry => ({
      id: entry.id, name: entry.name, icon: entry.icon, generic: entry.genericName
    }))
    readonly property var list: Menu.items({
      opacity: opacityFile.text().trim() || "0.92",
      profile: profile,
      hibernates: Menu.hibernates(resumeFile.text())
    }, apps)
    readonly property var rows: Menu.rows(list, menu, search.text)

    function open(id) {
      menu = id
      search.text = ""
    }

    function activate(row) {
      if (!row) return
      if (row.submenu) {
        open(row.id)
        return
      }
      Quickshell.execDetached(row.run)
      Qt.quit()
    }

    onRowsChanged: cursor = rows.length > 0 ? 0 : -1

    WlrLayershell.namespace: "sway-menu"

    // Terminal opacity saved by bin/opacity; 0.92 = its default.
    FileView {
      id: opacityFile

      path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/sway/terminal-opacity"
      blockLoading: true
      printErrors: false
    }

    // Resume device: "0:0" without hibernation. SYS_POWER = tests' stand-in for /sys/power.
    FileView {
      id: resumeFile

      path: (Quickshell.env("SYS_POWER") || "/sys/power") + "/resume"
      blockLoading: true
      printErrors: false
    }

    PanelCard {
      id: card

      anchors.right: undefined
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      // 20% bigger, grown from its centre. Text is distance-field rendered, so it stays sharp when scaled.
      zoom: 1.2
      transformOrigin: Item.Center
      // Fits the longest entry with its path beside it ("Record screen with microphone", "Capture").
      width: 380
      // Fixed: 12 rows, so the card never resizes while typing.
      height: header.height + 12 * 34 + 28

      Item {
        id: header

        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
        height: 36

        Text {
          id: prompt

          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          width: 28
          horizontalAlignment: Text.AlignHCenter
          textFormat: Text.PlainText
          text: ""
          color: win.accent
          font.family: win.font
          font.pixelSize: 16
        }

        TextInput {
          id: search

          anchors { left: prompt.right; right: crumb.left; leftMargin: 8; rightMargin: 8; verticalCenter: parent.verticalCenter }
          focus: true
          color: win.fg
          selectionColor: win.track
          font.family: win.font
          font.pixelSize: 15
          clip: true
          Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
              if (search.text !== "") search.text = ""
              else if (win.menu !== "") win.open(Menu.parentOf(win.list, win.menu))
              else Qt.quit()
            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
              win.cursor = Menu.step(win.cursor, 1, win.rows.length)
            } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) {
              win.cursor = Menu.step(win.cursor, -1, win.rows.length)
            } else if (event.key === Qt.Key_PageDown) {
              win.cursor = Menu.step(win.cursor, 11, win.rows.length)
            } else if (event.key === Qt.Key_PageUp) {
              win.cursor = Menu.step(win.cursor, -11, win.rows.length)
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              win.activate(win.rows[win.cursor])
            } else if ((event.key === Qt.Key_Left || event.key === Qt.Key_Backspace) && search.text === "" && win.menu !== "") {
              win.open(Menu.parentOf(win.list, win.menu))
            } else if (event.key === Qt.Key_Right && search.text === "" && win.rows[win.cursor]?.submenu) {
              win.open(win.rows[win.cursor].id)
            } else {
              return
            }
            event.accepted = true
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: search.text === ""
            textFormat: Text.PlainText
            text: win.menu === "" ? "Search apps and settings" : "Search"
            color: win.dim
            font: search.font
          }
        }

        // Where the list is: "Style › Terminal opacity", and how to get back.
        Text {
          id: crumb

          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          visible: win.menu !== ""
          width: visible ? Math.min(implicitWidth, 240) : 0
          elide: Text.ElideLeft
          textFormat: Text.PlainText
          text: [Menu.path(win.list, win.menu), win.list.find(item => item.id === win.menu)?.label ?? ""]
            .filter(part => part !== "").join(" › ") + "  ← Esc"
          color: win.dim
          font.family: win.font
          font.pixelSize: 12
        }
      }

      Rectangle {
        id: rule

        anchors { left: parent.left; right: parent.right; top: header.bottom; leftMargin: 14; rightMargin: 14; topMargin: 6 }
        height: 1
        color: win.track
      }

      ListView {
        id: view

        anchors { left: parent.left; right: parent.right; top: rule.bottom; bottom: parent.bottom; margins: 8 }
        clip: true
        model: win.rows
        currentIndex: win.cursor
        highlightMoveDuration: 0
        boundsBehavior: Flickable.StopAtBounds

        delegate: Item {
          id: row

          required property var modelData
          required property int index
          // First deeper hit after the current level's own: a line between the two groups.
          readonly property bool split: modelData.section === "deeper" && index > 0 && win.rows[index - 1].section === "here"

          width: ListView.view.width
          height: 34 + (split ? 9 : 0)

          Rectangle {
            visible: row.split
            anchors { left: parent.left; right: parent.right; top: parent.top; leftMargin: 6; rightMargin: 6; topMargin: 4 }
            height: 1
            color: win.track
          }

          Rectangle {
            id: body

            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 34
            radius: 8
            color: row.index === win.cursor ? win.track : "transparent"

            // Icon column, the same width for a glyph and an app's image.
            Item {
              id: iconBox

              anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
              width: 28
              height: 28

              Text {
                anchors.centerIn: parent
                visible: row.modelData.appIcon === ""
                textFormat: Text.PlainText
                text: row.modelData.icon
                color: win.fg
                font.family: win.font
                font.pixelSize: 16
              }

              Image {
                anchors.centerIn: parent
                visible: row.modelData.appIcon !== ""
                width: 20
                height: 20
                sourceSize { width: 40; height: 40 }
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                source: visible ? Quickshell.iconPath(row.modelData.appIcon, "application-x-executable") : ""
              }
            }

            Text {
              id: label

              anchors {
                left: iconBox.right
                right: detail.visible ? detail.left : arrow.left
                leftMargin: 8
                rightMargin: 8
                verticalCenter: parent.verticalCenter
              }
              elide: Text.ElideRight
              textFormat: Text.PlainText
              text: row.modelData.label
              color: win.fg
              font.family: win.font
              font.pixelSize: 14
            }

            // Deeper hit: the path it sits in.
            Text {
              id: detail

              anchors { right: arrow.left; rightMargin: arrow.width > 0 ? 8 : 0; verticalCenter: parent.verticalCenter }
              visible: row.modelData.detail !== ""
              width: Math.min(implicitWidth, 160)
              elide: Text.ElideLeft
              textFormat: Text.PlainText
              text: row.modelData.detail
              color: win.dim
              font.family: win.font
              font.pixelSize: 12
            }

            // Submenu mark; no room taken on other rows.
            Text {
              id: arrow

              anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
              width: row.modelData.submenu ? 10 : 0
              textFormat: Text.PlainText
              text: row.modelData.submenu ? "›" : ""
              color: win.dim
              font.family: win.font
              font.pixelSize: 16
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onEntered: win.cursor = row.index
              onClicked: win.activate(row.modelData)
            }
          }
        }
      }
    }
  }
}
