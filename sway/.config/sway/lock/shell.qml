import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland

// Lock screen: ext-session-lock, PAM, blurred backdrop, clock, password field.
// Backdrop = per-output screenshots the `lock` script takes with grim right before locking.
// Safety comes from the protocol, not from this file: if this process dies while locked, Sway keeps every output
// covered until another locker unlocks it. Unlock only happens on PAM success.
ShellRoot {
  id: root

  readonly property string shots: Quickshell.env("SWAY_LOCK_SHOTS")
  readonly property string marker: Quickshell.env("SWAY_LOCK_MARKER")
  readonly property bool dry: Quickshell.env("SWAY_LOCK_DRY") === "1"   // parse/run without locking, for testing

  readonly property color fg: "#cdd6f4"
  readonly property color dim: "#a6adc8"
  readonly property color accent: "#89b4fa"
  readonly property color error: "#f38ba8"
  readonly property string font: "JetBrainsMono Nerd Font"

  property string password: ""
  property bool checking: false
  property int failures: 0
  property string message: ""
  property date now: new Date()

  function submit() {
    if (checking || password === "") return
    checking = true
    message = ""
    if (!pam.start()) {
      checking = false
      message = "Authentication unavailable"
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.now = new Date()
  }

  // Tells the `lock` script the session is really locked, so swayidle's before-sleep can let the machine sleep.
  Process { id: signalLocked; command: ["touch", root.marker] }

  PamContext {
    id: pam
    config: "swaylock"   // /etc/pam.d/swaylock = `auth include login`, same rules as the console login

    onResponseRequiredChanged: if (responseRequired) respond(root.password)

    onCompleted: result => {
      root.checking = false
      if (result === PamResult.Success) {
        lock.locked = false
      } else {
        root.failures++
        root.password = ""
        root.message = "Wrong password" + (root.failures > 1 ? " (" + root.failures + ")" : "")
      }
    }

    onError: error => {
      root.checking = false
      root.password = ""
      root.message = "Authentication error"
    }
  }

  WlSessionLock {
    id: lock
    locked: !root.dry

    onSecureStateChanged: if (secure && root.marker !== "") signalLocked.running = true
    onLockStateChanged: if (!locked) Qt.quit()

    // One surface per output; each shows its own screenshot.
    WlSessionLockSurface {
      id: surface
      color: "#1e1e2e"

      Image {
        id: shot
        anchors.fill: parent
        source: root.shots !== "" && surface.screen ? "file://" + root.shots + "/" + surface.screen.name + ".png" : ""
        fillMode: Image.PreserveAspectCrop
        cache: false
        visible: false
      }

      MultiEffect {
        anchors.fill: parent
        source: shot
        visible: shot.status === Image.Ready
        blurEnabled: true
        blur: 1.0
        blurMax: 64
        blurMultiplier: 1.5
        brightness: -0.25
      }

      Rectangle {
        anchors.fill: parent
        color: "#661e1e2e"
      }

      Column {
        anchors.centerIn: parent
        spacing: 18

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: Qt.formatTime(root.now, "HH:mm")
          color: root.fg
          font.family: root.font
          font.pixelSize: 96
          font.bold: true
        }

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: Qt.formatDate(root.now, "dddd, MMMM d")
          color: root.dim
          font.family: root.font
          font.pixelSize: 20
        }

        Item { width: 1; height: 24 }

        Rectangle {
          anchors.horizontalCenter: parent.horizontalCenter
          width: 340
          height: 52
          radius: 26
          color: "#cc1e1e2e"
          border.width: 2
          border.color: root.message !== "" ? root.error : (field.activeFocus ? root.accent : "#45475a")

          Text {
            anchors.left: parent.left
            anchors.leftMargin: 22
            anchors.verticalCenter: parent.verticalCenter
            text: "󰌾"
            color: root.dim
            font.family: root.font
            font.pixelSize: 18
          }

          TextInput {
            id: field
            anchors.fill: parent
            anchors.leftMargin: 54
            anchors.rightMargin: 22
            verticalAlignment: TextInput.AlignVCenter
            focus: true
            enabled: !root.checking
            echoMode: TextInput.Password
            passwordCharacter: "●"
            color: root.fg
            font.family: root.font
            font.pixelSize: 16
            text: root.password
            onTextEdited: { root.password = text; root.message = "" }
            Keys.onReturnPressed: root.submit()
            Keys.onEnterPressed: root.submit()
            Keys.onEscapePressed: root.password = ""

            Text {
              anchors.verticalCenter: parent.verticalCenter
              visible: field.text === ""
              text: root.checking ? "Checking…" : "Password"
              color: "#6c7086"
              font: field.font
            }
          }
        }

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          height: 20
          text: root.message
          color: root.error
          font.family: root.font
          font.pixelSize: 14
        }
      }
    }
  }
}
