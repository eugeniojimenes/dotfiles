// Calendar panel date math, kept out of calendar.qml so tests/unit can check it on fixed dates (year edges, week 53,
// DST) instead of whatever today is. Months are 0-based, as in JavaScript's Date: 0 = January.

// The month `delta` months away, crossing year edges both ways: step(2026, 11, 1) = { year: 2027, month: 0 }.
export function step(year, month, delta) {
  const total = month + delta;
  return { year: year + Math.floor(total / 12), month: ((total % 12) + 12) % 12 };
}

// ISO 8601 week number: weeks start on Monday, week 1 holds the year's first Thursday. So the Thursday of `date`'s
// week decides the year, and its position in that year gives the week. UTC, so a DST change cannot shift the day.
export function isoWeek(date) {
  const thursday = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const weekday = thursday.getUTCDay() || 7; // Monday 1 .. Sunday 7
  thursday.setUTCDate(thursday.getUTCDate() + 4 - weekday);
  const january1 = new Date(Date.UTC(thursday.getUTCFullYear(), 0, 1));
  const dayOfYear = (thursday - january1) / 86400000 + 1;
  return Math.ceil(dayOfYear / 7);
}

export function sameDay(a, b) {
  return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
}

// The 42 days the grid shows: 6 weeks from the Monday on or before the 1st. Each at noon, so a DST change at midnight
// cannot move a day into the next cell.
export function cells(year, month) {
  const daysBeforeFirst = (new Date(year, month, 1, 12).getDay() + 6) % 7; // Monday 0 .. Sunday 6
  const days = [];
  for (let i = 0; i < 42; i++) days.push(new Date(year, month, 1 - daysBeforeFirst + i, 12));
  return days;
}

// Share of the year gone by at `now`, from 0 to 1.
export function yearDone(now) {
  const start = new Date(now.getFullYear(), 0, 1);
  const end = new Date(now.getFullYear() + 1, 0, 1);
  return (now - start) / (end - start);
}
