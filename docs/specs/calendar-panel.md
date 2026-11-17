# Calendar panel

Files: `sway/.config/sway/calendar/shell.qml` (Quickshell), `sway/.config/sway/calendar/calendar.mjs` (date math), `sway/.config/sway/calendar/toggle` (run by a click on the waybar clock).

## Purpose

The panel shows a month grid with ISO week numbers under the waybar clock, marks today and shows how much of the year has gone by. It only reads the date, so it runs nothing while it is closed.

## Acceptance criteria

1. The panel file parses, every type, property and import resolves against Qt and Quickshell, and Quickshell loads it in a headless Sway. Test: `tests/static.sh: qmllint`, `tests/static.sh: panels-load`
2. A click on the waybar clock opens the panel, and a second click closes it. Test: manual
3. The grid has six weeks starting on the Monday on or before the 1st of the month, with one day per cell even across a DST change. Test: `tests/unit/sway/.config/sway/calendar/calendar.bats: "grid: 6 weeks from the Monday on or before the 1st"`, `tests/unit/sway/.config/sway/calendar/calendar.bats: "grid: one day per cell across a DST change"`
4. Each row starts with its ISO 8601 week number, so the last days of December can belong to week 1 and the first days of January to week 52 or 53. Test: `tests/unit/sway/.config/sway/calendar/calendar.bats: "ISO week numbers at year edges, week 53 included"`
5. Today is marked in the grid, whatever the time of day. Test: `tests/unit/sway/.config/sway/calendar/calendar.bats: "today mark: same day whatever the time"`, manual
6. Left and Right or the mouse wheel step one month, Up and Down step one year, and Home goes back to the current month. Stepping crosses year edges in both directions. Test: `tests/unit/sway/.config/sway/calendar/calendar.bats: "month step wraps across year edges both ways"`, manual
7. The footer shows the year, the share of the year gone by as a percentage, and a bar of the same length. Test: `tests/unit/sway/.config/sway/calendar/calendar.bats: "year progress: 0 on 1 January, half in early July"`, manual
8. Esc, a click outside the panel or a workspace switch closes it. When the switch lands on another output, the cursor moves to the centre of that output. Test: manual
