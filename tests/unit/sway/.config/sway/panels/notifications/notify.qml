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
}
