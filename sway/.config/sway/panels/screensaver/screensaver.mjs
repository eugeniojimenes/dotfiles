// Screensaver logic, kept out of screensaver.qml so tests/unit can run it with plain numbers.
// `step` = slide number since the screensaver started (0 first). `screen` / `screens` = this output's index and the
// number of outputs. `count` = number of wallpaper images.

export const SLIDE_MS = 20000;

// Image an output shows at a step. Outputs start on different images and advance together, so two outputs never show
// the same one while there are as many images as outputs. -1 = no image: the clock alone.
export function imageIndex(step, screen, screens, count) {
  if (count === 0) return -1;
  return (step * screens + screen) % count;
}

// Where the clock sits at a step, as fractions of the room around it (0 = left or top edge, 1 = right or bottom).
// Golden-ratio steps spread the spots over the screen, so the clock never stays in one place.
export function clockSpot(step, screen) {
  const fraction = (value) => value - Math.floor(value);
  const n = step + screen;
  return { x: fraction(0.5 + n * 0.618034), y: fraction(0.3 + n * 0.381966) };
}
