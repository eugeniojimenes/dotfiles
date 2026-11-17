// Notification rules, kept out of notifications.qml so tests/unit can check them with plain values.
// `n` = { appName, urgency, expireTimeout }: urgency 0 low, 1 normal, 2 critical (D-Bus values, Quickshell's
// NotificationUrgency); expireTimeout as sent over D-Bus, in ms: -1 = server default, 0 = never expire.

// Modes that hide popups. One name per source, so an automatic one never undoes a manual Do not disturb: dnd = menu,
// bar and key; screenshare = share-picker, cleared by the portal's exec_after; recording = bin/record.
export const MODES = ["dnd", "screenshare", "recording"];
export const DEFAULT_TIMEOUT_MS = 5000;
// Kept for the notification centre; the oldest beyond this are let go.
export const HISTORY_MAX = 50;

// What a new notification gets: "show" = its popup, "hidden" = counted in the hidden-notifications card (screen share or
// recording: you learn something arrived, the screen never shows what), "silent" = nothing on screen.
// poweralertd (battery) sends every charge state change as normal: silent. Its warnings are critical: shown through any
// mode. Do not disturb stays silent even during a share: being left alone wins.
export function delivery(n, modes) {
  if (n.appName === "poweralertd") return n.urgency === 2 ? "show" : "silent";
  if (modes.includes("dnd")) return "silent";
  if (modes.includes("screenshare") || modes.includes("recording")) return "hidden";
  return "show";
}

// Text of the hidden-notifications card. The share wins when both modes are on.
export function hiddenText(count, modes) {
  const what = count === 1 ? "New notification" : `${count} new notifications`;
  const why = modes.includes("screenshare") || !modes.includes("recording") ? "share your screen" : "record the screen";
  return `${what}, hidden while you ${why}`;
}

// How long the popup stays, in ms; 0 = until clicked. Critical stays (freedesktop spec: critical should not expire),
// otherwise the sender's timeout, or 5 s when it left the choice to the server.
export function timeoutMs(n) {
  if (n.urgency === 2) return 0;
  if (n.expireTimeout > 0) return n.expireTimeout;
  if (n.expireTimeout === 0) return 0;
  return DEFAULT_TIMEOUT_MS;
}

// Mode list after a change: on adds once, off removes, toggle flips. Unknown names are ignored.
export function setMode(modes, name, how) {
  if (!MODES.includes(name)) return modes;
  const has = modes.includes(name);
  const on = how === "on" || (how === "toggle" && !has);
  if (on === has) return modes;
  return on ? MODES.filter((m) => m === name || modes.includes(m)) : modes.filter((m) => m !== name);
}

// Ids to let go when more than `max` are kept, oldest first. `ids` = kept ids in arrival order; `showing` = ids whose
// popup is on screen, never dropped.
export function overflow(ids, showing, max = HISTORY_MAX) {
  const extra = ids.length - max;
  if (extra <= 0) return [];
  return ids.filter((id) => !showing.includes(id)).slice(0, extra);
}
