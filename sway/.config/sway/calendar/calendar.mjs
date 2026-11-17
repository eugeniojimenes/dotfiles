// Date math of the calendar panel. ES module apart from the QML (isolated), so tests/unit checks it on fixed dates (year edges,
// week 53, DST) instead of whatever today is.

// Month `delta` away from year/month (month 0-based), across year edges both ways.
export function step(year, month, delta) {
  var m = month + delta;
  return { year: year + Math.floor(m / 12), month: ((m % 12) + 12) % 12 };
}

// ISO 8601 week: weeks start on Monday, week 1 holds the year's first Thursday. UTC, so DST cannot shift the day.
export function isoWeek(d) {
  var t = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
  t.setUTCDate(t.getUTCDate() + 4 - (t.getUTCDay() || 7));
  return Math.ceil(((t - new Date(Date.UTC(t.getUTCFullYear(), 0, 1))) / 86400000 + 1) / 7);
}

export function sameDay(a, b) {
  return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
}

// 6 weeks x 7 days from the Monday on or before the 1st. Noon, so a DST change at midnight cannot shift a day.
export function cells(year, month) {
  var offset = (new Date(year, month, 1, 12).getDay() + 6) % 7;
  var out = [];
  for (var i = 0; i < 42; i++) out.push(new Date(year, month, 1 - offset + i, 12));
  return out;
}

// Share of the year gone by at `now`, 0..1.
export function yearDone(now) {
  var start = new Date(now.getFullYear(), 0, 1);
  return (now - start) / (new Date(now.getFullYear() + 1, 0, 1) - start);
}
