import QtQuick
import QtTest
import "../../../../../../../sway/.config/sway/panels/notifications/notify.mjs" as Notify

// notify.mjs with plain values. Run one function at a time by notify.bats.
TestCase {
  name: "notify"

  function n(appName, urgency, expireTimeout) { return { appName: appName, urgency: urgency, expireTimeout: expireTimeout } }

  function test_delivery() {
    compare(Notify.delivery(n("Slack", 1, -1), []), "show")
    compare(Notify.delivery(n("Slack", 1, -1), ["dnd"]), "silent")
    compare(Notify.delivery(n("Slack", 1, -1), ["screenshare"]), "hidden")
    compare(Notify.delivery(n("Slack", 2, -1), ["recording"]), "hidden")
    compare(Notify.delivery(n("Slack", 1, -1), ["dnd", "screenshare"]), "silent")
    compare(Notify.delivery(n("poweralertd", 1, -1), []), "silent")
    compare(Notify.delivery(n("poweralertd", 1, -1), ["screenshare"]), "silent")
    compare(Notify.delivery(n("poweralertd", 2, -1), []), "show")
    compare(Notify.delivery(n("poweralertd", 2, -1), ["dnd", "screenshare"]), "show")
  }

  function test_screen_hidden() {
    verify(Notify.screenHidden(["screenshare"]))
    verify(Notify.screenHidden(["recording"]))
    verify(Notify.screenHidden(["dnd", "recording"]))
    verify(!Notify.screenHidden(["dnd"]))
    verify(!Notify.screenHidden([]))
  }

  function test_hidden_text() {
    compare(Notify.hiddenText(1, ["screenshare"]), "New notification, hidden while you share your screen")
    compare(Notify.hiddenText(3, ["screenshare"]), "3 new notifications, hidden while you share your screen")
    compare(Notify.hiddenText(2, ["recording"]), "2 new notifications, hidden while you record the screen")
    compare(Notify.hiddenText(1, ["screenshare", "recording"]), "New notification, hidden while you share your screen")
  }

  function test_timeout() {
    compare(Notify.timeoutMs(n("a", 1, -1)), 5000)
    compare(Notify.timeoutMs(n("a", 0, 3000)), 3000)
    compare(Notify.timeoutMs(n("a", 1, 0)), 0)
    compare(Notify.timeoutMs(n("a", 2, 3000)), 0)
    compare(Notify.timeoutMs(n("poweralertd", 2, -1)), 0)
  }

  function test_set_mode() {
    compare(Notify.setMode([], "dnd", "on"), ["dnd"])
    compare(Notify.setMode(["dnd"], "dnd", "on"), ["dnd"])
    compare(Notify.setMode(["dnd"], "dnd", "toggle"), [])
    compare(Notify.setMode([], "dnd", "toggle"), ["dnd"])
    compare(Notify.setMode(["recording"], "screenshare", "on"), ["screenshare", "recording"])
    compare(Notify.setMode(["dnd", "screenshare"], "screenshare", "off"), ["dnd"])
    compare(Notify.setMode([], "screenshare", "off"), [])
    compare(Notify.setMode([], "bogus", "on"), [])
  }

  function test_overflow() {
    compare(Notify.overflow([1, 2, 3], [], 5), [])
    compare(Notify.overflow([1, 2, 3, 4], [], 2), [1, 2])
    compare(Notify.overflow([1, 2, 3, 4], [1], 2), [2, 3])
  }

  function test_keep() {
    compare(Notify.keep(n("Slack", 1, -1)), true)
    compare(Notify.keep(n("poweralertd", 1, -1)), false)
    compare(Notify.keep(n("poweralertd", 2, -1)), true)
  }

  // Local time, no TZ needed: only differences and the clock of a Date built here.
  function test_ago() {
    var now = new Date(2026, 10, 17, 21, 30).getTime()
    compare(Notify.ago(now - 20000, now), "now")
    compare(Notify.ago(now - 5 * 60000, now), "5 min")
    compare(Notify.ago(now - 59 * 60000, now), "59 min")
    compare(Notify.ago(now - 2 * 3600000 - 60000, now), "2 h")
    compare(Notify.ago(new Date(2026, 10, 17, 8, 5).getTime(), now), "08:05")
  }

  function test_bell() {
    compare(Notify.bell([], 0).class, "idle")
    compare(Notify.bell([], 0).text, "󰂚")
    compare(Notify.bell([], 3).class, "unread")
    compare(Notify.bell([], 3).text, "󰂚 3")
    compare(Notify.bell(["dnd"], 2).class, "dnd")
    compare(Notify.bell(["dnd"], 2).text, "󰂛 2")
    compare(Notify.bell(["dnd", "screenshare"], 0).class, "share")
    verify(Notify.bell(["dnd", "screenshare"], 0).tooltip.indexOf("sharing") >= 0)
    verify(Notify.bell(["screenshare", "recording"], 0).tooltip.indexOf("recording") >= 0)
  }

  function test_deck_closed() {
    var h = [60, 80, 40, 50, 70]
    compare(Notify.deckCard(0, 1, false, h), { y: 0, scale: 1, height: 60, shown: true })
    // Three behind the front: the front sits 3 gaps down, each older one a gap higher, all as tall as the front.
    compare(Notify.deckCard(0, 5, false, h).y, 24)
    compare(Notify.deckCard(1, 5, false, h), { y: 16, scale: 0.96, height: 60, shown: true })
    compare(Notify.deckCard(3, 5, false, h).y, 0)
    compare(Notify.deckCard(4, 5, false, h).shown, false)
    compare(Notify.deckHeight(5, false, h), 84)
    compare(Notify.deckHeight(0, false, h), 0)
  }

  function test_deck_open() {
    var h = [60, 80, 40]
    compare(Notify.deckCard(0, 3, true, h), { y: 0, scale: 1, height: 60, shown: true })
    compare(Notify.deckCard(2, 3, true, h).y, 60 + 8 + 80 + 8)
    compare(Notify.deckHeight(3, true, h), 60 + 8 + 80 + 8 + 40)
  }

  function test_safe_body() {
    compare(Notify.safeBody("hi <img src=\"http://x/p.png\"> there"), "hi &lt;img src=\"http://x/p.png\"> there")
    compare(Notify.safeBody("<IMG SRC='http://x/p.png'/>"), "&lt;IMG SRC='http://x/p.png'/>")
    compare(Notify.safeBody("cut <img src=\"http://x"), "cut &lt;img src=\"http://x")
    // Bypasses of the old removal filter: spacing, a tab, a tag rebuilt from the pieces around a removed one.
    compare(Notify.safeBody("< img src=http://x>"), "&lt; img src=http://x>")
    compare(Notify.safeBody("<\timg src=http://x>"), "&lt;\timg src=http://x>")
    compare(Notify.safeBody("<im<img>g src=\"http://x\">"), "&lt;im&lt;img>g src=\"http://x\">")
    compare(Notify.safeBody("<b>bold</b> <i>it</i> <u>u</u><br/><a href=\"https://x\">link</a>"),
            "<b>bold</b> <i>it</i> <u>u</u><br/><a href=\"https://x\">link</a>")
    compare(Notify.safeBody("<abbr>x</abbr> <font color=red>y</font>"), "&lt;abbr>x&lt;/abbr> &lt;font color=red>y&lt;/font>")
    compare(Notify.safeBody("1 < 2 &lt; 3"), "1 &lt; 2 &lt; 3")
    compare(Notify.safeBody(""), "")
  }

  function test_centre_items() {
    var list = [{ id: 1 }, { id: 2 }, { id: 3 }]
    compare(Notify.centreItems(list, [1, 3], { 1: 100, 3: 300 }).map(i => i.id), [3, 1])
    compare(Notify.centreItems(list, [], {}), [])
    compare(Notify.meta("Slack", "5 min"), "Slack  ·  5 min")
    compare(Notify.meta("", "now"), "now")
  }

  function test_arrive_history() {
    const empty = { kept: [], arrived: {}, hiddenCount: 0, hiddenCritical: false }
    const slack = { id: 1, appName: "Slack", urgency: 1, transient: false, reloaded: false }
    let next = Notify.arrive(empty, slack, [], 1000, 500)
    compare(next.kept, [1])
    compare(next.arrived[1], 1000)
    verify(next.show)
    verify(!next.expire)
    compare(Notify.unread(next.kept, next.arrived, 500), 1)
    compare(Notify.unread(next.kept, next.arrived, 1000), 0)
    next = Notify.arrive(next, { id: 2, appName: "Mail", urgency: 1, transient: false, reloaded: false }, [], 2000, 500)
    next = Notify.arrive(next, slack, [], 3000, 500)
    compare(next.kept, [2, 1])
    compare(next.arrived[1], 3000)
    compare(empty.kept, [])
    const carried = Notify.arrive(empty, Object.assign({}, slack, { reloaded: true }), [], 9000, 500)
    compare(carried.kept, [1])
    compare(carried.arrived[1], 499)
    verify(!carried.show)
    verify(!carried.expire)
    compare(Notify.unread(carried.kept, carried.arrived, 500), 0)
  }

  function test_arrive_hidden_and_ephemeral() {
    const empty = { kept: [], arrived: {}, hiddenCount: 0, hiddenCritical: false }
    const note = (id, appName, urgency, transient) => ({ id: id, appName: appName, urgency: urgency, transient: transient, reloaded: false })
    let next = Notify.arrive(empty, note(1, "Slack", 2, false), ["screenshare"], 1000, 0)
    compare([next.hiddenCount, next.hiddenCritical, next.show, next.restartHidden], [1, true, false, true])
    next = Notify.arrive(next, note(2, "Slack", 1, false), ["screenshare"], 2000, 0)
    compare([next.hiddenCount, next.hiddenCritical], [2, true])
    next = Notify.arrive(empty, note(1, "Slack", 2, false), ["dnd"], 1000, 0)
    compare([next.hiddenCount, next.hiddenCritical, next.show, next.restartHidden], [0, false, false, false])
    verify(Notify.arrive(empty, note(1, "poweralertd", 1, false), [], 1000, 0).expire)
    verify(!Notify.arrive(empty, note(1, "poweralertd", 2, false), [], 1000, 0).expire)
    verify(!Notify.arrive(empty, note(1, "Slack", 1, true), [], 1000, 0).expire)
    verify(Notify.arrive(empty, note(1, "Slack", 1, true), ["dnd"], 1000, 0).expire)
    verify(Notify.arrive(empty, note(1, "Slack", 1, true), ["recording"], 1000, 0).expire)
  }

  function test_osd_icon() {
    compare(Notify.osdIcon("volume", 0, false), "󰕿")
    compare(Notify.osdIcon("volume", 33, false), "󰕿")
    compare(Notify.osdIcon("volume", 34, false), "󰖀")
    compare(Notify.osdIcon("volume", 67, false), "󰕾")
    compare(Notify.osdIcon("volume", 100, false), "󰕾")
    compare(Notify.osdIcon("volume", 80, true), "󰝟")
    compare(Notify.osdIcon("mic", 100, false), "󰍬")
    compare(Notify.osdIcon("mic", 100, true), "󰍭")
    compare(Notify.osdIcon("brightness", 10, false), "󰃞")
    compare(Notify.osdIcon("brightness", 50, false), "󰃟")
    compare(Notify.osdIcon("brightness", 100, false), "󰃠")
  }

  function test_track_text() {
    compare(Notify.trackText("Artist", "Song", "spotify"), "Artist - Song")
    compare(Notify.trackText("", "Video", "brave"), "Video")
    compare(Notify.trackText("Artist", "", "spotify"), "spotify")
  }

  function test_switch_popup() {
    compare(Notify.switchPopup("awake", "on"),
      { icon: "󰅶", title: "Stay awake on", detail: "No lock or screen off when idle", on: true })
    compare(Notify.switchPopup("awake", "off"),
      { icon: "󰾪", title: "Stay awake off", detail: "Screensaver at 5 min, lock at 7", on: false })
    compare(Notify.switchPopup("nightlight", "on").icon, "󰖔")
    compare(Notify.switchPopup("nightlight", "off").on, false)
    compare(Notify.switchPopup("dnd", "on").title, "Do not disturb on")
    compare(Notify.switchPopup("dnd", "off").icon, "󰂚")
    compare(Notify.switchPopup("profile", "power-saver"),
      { icon: "󰌪", title: "Power saver", detail: "Power profile", on: true })
    compare(Notify.switchPopup("profile", "performance").icon, "󱐋")
    compare(Notify.switchPopup("profile", "toString"), null)
    compare(Notify.switchPopup("awake", "maybe"), null)
    compare(Notify.switchPopup("volume", "on"), null)
  }

  function test_track_icon() {
    compare(Notify.trackIcon("toggle", true), "󰐊")
    compare(Notify.trackIcon("toggle", false), "󰏤")
    compare(Notify.trackIcon("next", false), "󰒭")
    compare(Notify.trackIcon("previous", true), "󰒮")
  }

  function test_centre_hidden_text() {
    compare(Notify.centreHiddenText(1, ["screenshare"]), "1 notification hidden while you share your screen")
    compare(Notify.centreHiddenText(5, ["recording"]), "5 notifications hidden while you record the screen")
    compare(Notify.centreHiddenText(2, ["screenshare", "recording"]), "2 notifications hidden while you share your screen")
  }
}
