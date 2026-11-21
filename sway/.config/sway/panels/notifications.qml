import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "notifications"
import "notifications/notify.mjs" as Notify

// Notification daemon: owns org.freedesktop.Notifications (instead of mako); popups in notifications/Popups.qml, the
// centre in notifications/Centre.qml, the volume/brightness popup in notifications/Osd.qml. Always running, started by ./notifications/run (sway autostart), unlike the
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
  readonly property int unread: Notify.unread(kept, arrived, seenAt)
  readonly property var tracked: server.trackedNotifications.values

  onUnreadChanged: poke()
  onModesChanged: {
    poke()
    modesFile.setText(modes.join(" "))
    // A share or recording starting: popups already up leave the screen too (the centre keeps them).
    if (Notify.screenHidden(modes)) for (const n of popups.slice()) hidePopup(n)
  }

  // Waybar bell, signal 8 (see bin/dnd).
  function poke() { Quickshell.execDetached(["pkill", "-RTMIN+8", "-f", "^waybar "]) }

  function openCenter() {
    seenAt = Date.now()
    // WARN: hidePopup, not `popups = []`: an ephemeral one on screen must still expire, or it stays in the centre.
    for (const n of popups.slice()) hidePopup(n)
    closeHidden()
    centerOpen = true
  }

  function closeHidden() {
    hiddenCount = 0
    hiddenCritical = false
  }

  function hidePopup(n) {
    popups = popups.filter(p => p !== n)
    if (Notify.ephemeral(n) && n.tracked) n.expire()
  }

  function forget(n) {
    hidePopup(n)
    kept = kept.filter(id => id !== n.id)
    const left = Object.assign({}, arrived)
    delete left[n.id]
    arrived = left
  }

  // Rules in Notify.arrive (tested); here only applied. A new notification, or one its sender replaced in place.
  function arrive(n, reloaded) {
    const state = { kept: kept, arrived: arrived, hiddenCount: hiddenCount, hiddenCritical: hiddenCritical }
    const info = { id: n.id, appName: n.appName, urgency: n.urgency, transient: n.transient, reloaded: reloaded }
    const next = Notify.arrive(state, info, modes, Date.now(), seenAt)
    arrived = next.arrived
    kept = next.kept
    hiddenCount = next.hiddenCount
    hiddenCritical = next.hiddenCritical
    if (next.show) popups = [n].concat(popups.filter(p => p !== n))
    if (next.restartHidden) hiddenTimer.restart()
    // WARN: Later, not now: inside onNotification the server has not filed it yet, so expire() would do nothing, closed
    // would never come and its id would stay counted as unread.
    if (next.expire) Qt.callLater(() => { if (n.tracked) n.expire() })
    trim()
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
      n.closed.connect(() => root.forget(n))
      // Replaced in place (same id: a chat's "3 new messages", poweralertd's battery warnings): Quickshell updates this
      // object and sends no new `notification`, so its text changing is the arrival. One call per batch of changes.
      const again = () => root.arrive(n, false)
      n.summaryChanged.connect(() => Qt.callLater(again))
      n.bodyChanged.connect(() => Qt.callLater(again))
      root.arrive(n, n.lastGeneration)
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
    // Waybar may have asked for the bell while this process was down (login, restart): empty then, and with no mode
    // and nothing unread no change would ever poke it again.
    poke()
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
    function modeToggle(name: string): void {
      root.modes = Notify.setMode(root.modes, name, "toggle")
      // Only do not disturb is switched by hand (bin/dnd toggle); share and recording modes come from their scripts.
      if (name === "dnd") osdPopup.showSwitch("dnd", root.modes.includes("dnd") ? "on" : "off")
    }
    // ./notifications/clear: popups off the screen (the centre keeps them), or everything as Clear in the centre does.
    function dismissPopups(): void {
      for (const n of root.popups.slice()) root.hidePopup(n)
      root.closeHidden()
    }
    function clearAll(): void {
      for (const n of Array.from(root.tracked)) n.dismiss()
      root.closeHidden()
    }
  }

  Popups { daemon: root }
  Centre { daemon: root }
  Osd { id: osdPopup }
}
