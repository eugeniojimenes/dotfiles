import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Wayland
import "power/power.mjs" as Power
import "common"

// Power panel for the waybar battery icon (menu Setup › Power too): charge, time left or to full, power draw, battery health, the
// power-profiles-daemon profile, and the charge limit (UPower charge threshold, Lenovo conservation mode here).
// Left/Right step the profile. Esc or a click outside closes it. One process per open: nothing runs once it is closed.
ShellRoot {
  PanelShell {
    id: win

    readonly property var dev: UPower.displayDevice
    readonly property var battery: UPower.devices.values.find(d => d.isLaptopBattery) ?? null
    readonly property bool charging: dev.state === UPowerDeviceState.Charging
    readonly property list<var> profiles: [
      { id: PowerProfile.PowerSaver, icon: "󰌪", label: "Saver" },
      { id: PowerProfile.Balanced, icon: "󰗶", label: "Balanced" },
      { id: PowerProfile.Performance, icon: "󱐋", label: "Performance" }
    ].filter(p => p.id !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)

    // Charge limit through UPower over D-Bus: Quickshell does not expose it. polkit lets the active user change it
    // without a password. shortcut: object path built from the kernel name (battery_BAT1), UPower's own naming.
    readonly property string batteryPath: battery ? "/org/freedesktop/UPower/devices/battery_" + battery.nativePath : ""
    property bool limitSupported: false
    property bool limitEnabled: false

    function readLimit() {
      limitRead.command = ["busctl", "get-property", "org.freedesktop.UPower", batteryPath, "org.freedesktop.UPower.Device",
                           "ChargeThresholdSupported", "ChargeThresholdEnabled"]
      limitRead.running = true
    }

    function stepProfile(delta) {
      const i = profiles.findIndex(p => p.id === PowerProfiles.profile)
      PowerProfiles.profile = profiles[Math.max(0, Math.min(profiles.length - 1, i + delta))].id
    }

    WlrLayershell.namespace: "sway-power"

    onBatteryPathChanged: if (batteryPath !== "") readLimit()

    Process {
      id: limitRead
      stdout: StdioCollector {
        waitForEnd: true
        onStreamFinished: {
          const lines = String(text).trim().split("\n")   // "b true" / "b false", one per property
          win.limitSupported = lines[0] === "b true"
          win.limitEnabled = lines[1] === "b true"
        }
      }
    }

    Process {
      id: limitWrite
      onRunningChanged: if (!running) win.readLimit()
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
          else if (event.key === Qt.Key_Left) win.stepProfile(-1)
          else if (event.key === Qt.Key_Right) win.stepProfile(1)
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
          cursorShape: Qt.PointingHandCursor
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

        // Charge: icon, percentage, state and estimate, bar, draw and health. Only with a laptop battery: on a desktop
        // UPower's display device reads 0% with an unknown state, which would draw an empty red battery.
        Column {
          visible: win.battery !== null
          width: parent.width
          spacing: 8

          Row {
            spacing: 10
            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: Power.icon(win.dev.percentage, !UPower.onBattery)
              color: win.dev.percentage <= 0.1 && !win.charging ? win.error : win.fg
              font.family: win.font
              font.pixelSize: 28
            }
            Column {
              anchors.verticalCenter: parent.verticalCenter
              Text {
                text: Math.round(win.dev.percentage * 100) + "%"
                color: win.fg
                font.family: win.font
                font.pixelSize: 18
                font.bold: true
              }
              Text {
                text: Power.status(win.dev.state, win.dev.timeToEmpty, win.dev.timeToFull)
                color: win.dim
                font.family: win.font
                font.pixelSize: 11
              }
            }
          }

          Rectangle {
            width: parent.width
            height: 8
            radius: 4
            color: win.track
            Rectangle {
              width: parent.width * win.dev.percentage
              height: parent.height
              radius: 4
              color: win.dev.percentage <= 0.1 && !win.charging ? win.error : win.accent
            }
          }

          Text {
            text: [win.dev.changeRate > 0 ? win.dev.changeRate.toFixed(1) + " W" : "",
                   win.battery && win.battery.healthSupported ? "health " + Math.round(win.battery.healthPercentage) + "%" : ""]
                  .filter(s => s !== "").join("  ·  ")
            visible: text !== ""
            color: win.dim
            font.family: win.font
            font.pixelSize: 11
          }
        }

        // Power profile: click, or Left/Right.
        Column {
          width: parent.width
          spacing: 8
          Label { text: "󰓅  Power profile" }
          Row {
            spacing: 6
            Repeater {
              model: win.profiles
              Chip {
                label: modelData.icon + " " + modelData.label
                active: PowerProfiles.profile === modelData.id
                onPressed: PowerProfiles.profile = modelData.id
              }
            }
          }
          Text {
            visible: PowerProfiles.degradationReason !== PerformanceDegradationReason.None
            text: "Performance limited: " + PerformanceDegradationReason.toString(PowerProfiles.degradationReason)
            color: win.error
            font.family: win.font
            font.pixelSize: 11
          }
        }

        // Charge limit, only when the battery supports one.
        Column {
          visible: win.limitSupported
          width: parent.width
          spacing: 8
          Label { text: "󰂃  Charge limit" }
          Chip {
            label: win.limitEnabled ? "On" : "Off"
            active: win.limitEnabled
            onPressed: {
              limitWrite.command = ["busctl", "call", "org.freedesktop.UPower", win.batteryPath, "org.freedesktop.UPower.Device",
                                    "EnableChargeThreshold", "b", String(!win.limitEnabled)]
              limitWrite.running = true
            }
          }
          Text {
            width: parent.width
            wrapMode: Text.Wrap
            text: "Stops charging below 100% so a battery that stays plugged in wears less."
            color: win.dim
            font.family: win.font
            font.pixelSize: 11
          }
        }
      }
    }
  }
}
