import QtQuick
import QtTest
import "../../../../../../../sway/.config/sway/panels/power/power.mjs" as Power

// power.mjs with fixed values. Run one function at a time by power.bats.
TestCase {
  name: "power"

  function test_duration() {
    compare(Power.duration(0), "")
    compare(Power.duration(-5), "")
    compare(Power.duration(30), "under 1 min")
    compare(Power.duration(45 * 60), "45 min")
    compare(Power.duration(2 * 3600 + 5 * 60 + 59), "2 h 05 min")
  }

  // UPower states: 1 Charging, 2 Discharging, 4 FullyCharged, 5 PendingCharge, 0 Unknown.
  function test_status() {
    compare(Power.status(1, 0, 1800), "Charging, full in 30 min")
    compare(Power.status(1, 0, 0), "Charging")
    compare(Power.status(2, 7500, 0), "On battery, 2 h 05 min left")
    compare(Power.status(2, 0, 0), "On battery")
    compare(Power.status(4, 0, 0), "Fully charged")
    compare(Power.status(5, 0, 0), "Plugged in, not charging")
    compare(Power.status(0, 0, 0), "")
  }

  function test_icon() {
    compare(Power.icon(0, false), "󰂎")
    compare(Power.icon(1, false), "󰁹")
    compare(Power.icon(1, true), "󰂅")
    compare(Power.icon(0.04, false), Power.icon(0, false))
    compare(Power.icon(0.97, true), Power.icon(1, true))
    compare(Power.icon(1.5, false), Power.icon(1, false))
  }
}
