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

  function test_centre_items() {
    var list = [{ id: 1 }, { id: 2 }, { id: 3 }]
    compare(Notify.centreItems(list, [1, 3], { 1: 100, 3: 300 }).map(i => i.id), [3, 1])
    compare(Notify.centreItems(list, [], {}), [])
    compare(Notify.meta("Slack", "5 min"), "Slack  ·  5 min")
    compare(Notify.meta("", "now"), "now")
  }
}
