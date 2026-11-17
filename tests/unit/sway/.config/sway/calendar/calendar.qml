import QtQuick
import QtTest
import "../../../../../../sway/.config/sway/calendar/calendar.js" as Cal

// calendar.js on fixed dates. Run one function at a time by calendar.bats (TZ set there).
TestCase {
  name: "calendar"

  function ymd(d) { return [d.getFullYear(), d.getMonth() + 1, d.getDate()] }

  function test_step_across_year_edges() {
    compare(Cal.step(2026, 11, 1), { year: 2027, month: 0 })
    compare(Cal.step(2026, 0, -1), { year: 2025, month: 11 })
    compare(Cal.step(2026, 5, 12), { year: 2027, month: 5 })
    compare(Cal.step(2026, 5, -12), { year: 2025, month: 5 })
    compare(Cal.step(2026, 1, -25), { year: 2024, month: 0 })
  }

  // 2026 starts on a Thursday, so it has 53 ISO weeks and 1 Jan 2027 still belongs to week 53.
  function test_iso_week_at_year_edges() {
    compare(Cal.isoWeek(new Date(2026, 0, 1, 12)), 1)
    compare(Cal.isoWeek(new Date(2025, 11, 29, 12)), 1)
    compare(Cal.isoWeek(new Date(2026, 11, 31, 12)), 53)
    compare(Cal.isoWeek(new Date(2027, 0, 1, 12)), 53)
    compare(Cal.isoWeek(new Date(2021, 0, 3, 12)), 53)
    compare(Cal.isoWeek(new Date(2026, 10, 1, 12)), 44)
  }

  function test_grid_starts_on_monday() {
    var c = Cal.cells(2026, 10)   // November 2026, the 1st is a Sunday
    compare(c.length, 42)
    compare(ymd(c[0]), [2026, 10, 26])
    compare(c[0].getDay(), 1)
    compare(ymd(c[6]), [2026, 11, 1])
    var j = Cal.cells(2026, 5)    // June 2026, the 1st is a Monday: no days from May
    compare(ymd(j[0]), [2026, 6, 1])
  }

  // TZ with DST from calendar.bats: 8 March 2026 has 23 hours. Every cell still one day after the previous, at noon.
  function test_grid_across_dst_change() {
    var c = Cal.cells(2026, 2)
    for (var i = 1; i < c.length; i++) {
      compare(c[i].getHours(), 12)
      var prev = new Date(c[i - 1].getFullYear(), c[i - 1].getMonth(), c[i - 1].getDate() + 1, 12)
      compare(ymd(c[i]), ymd(prev))
    }
    verify(c[13].getTimezoneOffset() !== c[0].getTimezoneOffset(), "TZ without DST: test proves nothing")
  }

  function test_same_day_ignores_time() {
    verify(Cal.sameDay(new Date(2026, 10, 16, 0, 1), new Date(2026, 10, 16, 23, 59)))
    verify(!Cal.sameDay(new Date(2026, 10, 16, 23, 59), new Date(2026, 10, 17, 0, 1)))
  }

  function test_year_progress() {
    compare(Cal.yearDone(new Date(2026, 0, 1)), 0)
    fuzzyCompare(Cal.yearDone(new Date(2026, 6, 2, 12)), 0.5, 0.001)
  }
}
