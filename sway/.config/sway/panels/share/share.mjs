// Screen-share picker logic (../share.qml), kept apart so tests/unit can check it without a screen.
// `text` = the rows file bin/share-picker writes, one card per line, tab separated:
//   kind (monitor|window|other)  label  detail  thumbnail path  app_id  portal line
// The portal line comes last and may hold tabs of its own (a window title), so it takes the rest of the row.

export function parse(text) {
  return (text || "")
    .split("\n")
    .filter((row) => row !== "")
    .map((row) => {
      const fields = row.split("\t");
      return {
        kind: fields[0],
        label: fields[1] ?? "",
        detail: fields[2] ?? "",
        thumbnail: fields[3] ?? "",
        app: fields[4] ?? "",
        line: fields.slice(5).join("\t"),
      };
    })
    .filter((card) => card.line !== "");
}

// Card `delta` steps away from `index`, held at both ends (no wrap: the strip scrolls, a jump to the far end would lose
// the place). No cards = -1.
export function step(index, delta, count) {
  if (count === 0) return -1;
  return Math.max(0, Math.min(count - 1, index + delta));
}
