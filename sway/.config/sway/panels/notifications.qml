import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "notifications"
import "notifications/notify.mjs" as Notify

// Notification daemon: owns org.freedesktop.Notifications (instead of mako); popups in notifications/Popups.qml, the
// centre in notifications/Centre.qml. Always running, started by ./notifications/run (sway autostart), unlike the
// other panels.
// Rules (what pops up, for how long, modes, history cap) live in notifications/notify.mjs. bin/dnd drives the modes
// over Quickshell IPC: `quickshell ipc -p <this file> call notifications <function>`.
// Every notification stays tracked after its popup is gone, up to Notify.HISTORY_MAX: the notification centre (Centre,
// toggled by ./notifications/toggle) lists them and can still run their actions. Modes survive a restart of this process
// through a file in $XDG_RUNTIME_DIR; the waybar bell (`dnd status`) is poked on every change.
ShellRoot {
  id: root

  property list<string> modes: []
  property var popups: []        // Notification objects on screen, newest first
  property var kept: []          // ids of tracked notifications, arrival order
  property var arrived: ({})     // id -> Date.now() at arrival
  // Card standing for notifications hidden by a screen share or recording: how many since it last closed, and whether
  // one was critical (then it stays until clicked, red border).
  property int hiddenCount: 0
  property bool hiddenCritical: false
  property bool centerOpen: false
  property real seenAt: Date.now()   // last time the centre was opened
  readonly property int unread: kept.filter(id => (arrived[id] ?? 0) > seenAt).length
  readonly property var tracked: server.trackedNotifications.values

  onUnreadChanged: poke()
  onModesChanged: {
    poke()
    modesFile.setText(modes.join(" "))
  }

  // Waybar bell, signal 8 (see bin/dnd).
  function poke() { Quickshell.execDetached(["pkill", "-RTMIN+8", "-f", "^waybar "]) }

  // Ones the history does not keep (transient, poweralertd state changes) end with their popup.
  function ephemeral(n) { return n.transient || !Notify.keep({ appName: n.appName, urgency: n.urgency }) }

  function openCenter() {
    seenAt = Date.now()
    popups = []
    closeHidden()
    centerOpen = true
  }

  function closeHidden() {
    hiddenCount = 0
    hiddenCritical = false
  }

  function hidePopup(n) {
    popups = popups.filter(p => p !== n)
    if (ephemeral(n) && n.tracked) n.expire()
  }

  function forget(n) {
    hidePopup(n)
    kept = kept.filter(id => id !== n.id)
  }

  function trim() {
    const drop = Notify.overflow(kept, popups.map(p => p.id))
    for (const n of server.trackedNotifications.values) if (drop.includes(n.id)) n.expire()
  }

  NotificationServer {
    id: server

    keepOnReload: true
    persistenceSupported: true
    bodySupported: true
    bodyMarkupSupported: true
    actionsSupported: true
    imageSupported: true

    onNotification: n => {
      n.tracked = true
      // A reload's carry-overs keep no time and do not count as new.
      root.arrived[n.id] = n.lastGeneration ? root.seenAt - 1 : Date.now()
      root.kept = root.kept.filter(id => id !== n.id).concat([n.id])
      n.closed.connect(() => root.forget(n))
      // Carried over by a Quickshell reload (keepOnReload): back in the history, never a popup again.
      const how = n.lastGeneration ? "silent" : Notify.delivery({ appName: n.appName, urgency: n.urgency }, root.modes)
      if (how === "show") {
        root.popups = [n].concat(root.popups.filter(p => p !== n))
      } else if (how === "hidden") {
        root.hiddenCount += 1
        if (n.urgency === NotificationUrgency.Critical) root.hiddenCritical = true
        hiddenTimer.restart()
      }
      if (root.ephemeral(n) && !root.popups.includes(n)) n.expire()
      root.trim()
    }
  }

  // 5 s after the latest hidden one, unless a critical one is among them.
  Timer {
    id: hiddenTimer
    interval: Notify.DEFAULT_TIMEOUT_MS
    onTriggered: if (!root.hiddenCritical) root.closeHidden()
  }

  FileView {
    id: modesFile
    path: Quickshell.env("XDG_RUNTIME_DIR") + "/sway-notification-modes"
    blockLoading: true
    atomicWrites: false
    printErrors: false
  }

  Component.onCompleted: {
    const saved = modesFile.text().trim()
    if (saved !== "") modes = saved.split(" ").filter(m => Notify.MODES.includes(m))
  }

  IpcHandler {
    target: "notifications"

    function status(): string { return JSON.stringify(Notify.bell(root.modes, root.unread)) }
    function toggleCenter(): void {
      if (root.centerOpen) root.centerOpen = false
      else root.openCenter()
    }
    function modes(): string { return root.modes.join(" ") }
    function modeOn(name: string): void { root.modes = Notify.setMode(root.modes, name, "on") }
    function modeOff(name: string): void { root.modes = Notify.setMode(root.modes, name, "off") }
    function modeToggle(name: string): void { root.modes = Notify.setMode(root.modes, name, "toggle") }
  }

  Popups { daemon: root }
  Centre { daemon: root }
}
