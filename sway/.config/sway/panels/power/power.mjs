// Power panel text, kept out of power.qml so tests/unit can check it with fixed values. `state` = UPower's device state
// number (D-Bus and Quickshell's UPowerDeviceState): 1 Charging, 2 Discharging, 3 Empty, 4 FullyCharged,
// 5 PendingCharge (plugged in, not charging), 6 PendingDischarge.

// "2 h 05 min", "45 min", "under 1 min"; "" when UPower has no estimate (0).
export function duration(seconds) {
  if (!(seconds > 0)) return "";
  const minutes = Math.floor(seconds / 60);
  if (minutes < 1) return "under 1 min";
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return h > 0 ? `${h} h ${String(m).padStart(2, "0")} min` : `${m} min`;
}

// The line under the percentage.
export function status(state, timeToEmpty, timeToFull) {
  switch (state) {
    case 1: {
      const t = duration(timeToFull);
      return t ? `Charging, full in ${t}` : "Charging";
    }
    case 2:
    case 3:
    case 6: {
      const t = duration(timeToEmpty);
      return t ? `On battery, ${t} left` : "On battery";
    }
    case 4:
      return "Fully charged";
    case 5:
      return "Plugged in, not charging";
    default:
      return "";
  }
}

// Battery glyph (Nerd Font, Material Design) for a 0..1 charge: eleven steps, with a plug while on AC.
export function icon(fraction, plugged) {
  const discharging = ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"];
  const onAc = ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"];
  const step = Math.max(0, Math.min(10, Math.round(fraction * 10)));
  return (plugged ? onAc : discharging)[step];
}

// Line under the charge bar: draw in watts while above zero, battery health when the battery reports it (null when it
// does not): "11.5 W  ·  health 98%". "" when neither.
export function detail(changeRate, health) {
  const parts = [];
  if (changeRate > 0) parts.push(`${changeRate.toFixed(1)} W`);
  if (health !== null) parts.push(`health ${Math.round(health)}%`);
  return parts.join("  ·  ");
}
