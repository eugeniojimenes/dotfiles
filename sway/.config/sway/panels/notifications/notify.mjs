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
  if (screenHidden(modes)) return "hidden";
  return "show";
}

// A share or recording is on: the screen goes out, so popups stay off it, those already up included.
export function screenHidden(modes) {
  return modes.includes("screenshare") || modes.includes("recording");
}

// Text of the hidden-notifications card. The share wins when both modes are on.
export function hiddenText(count, modes) {
  const what = count === 1 ? "New notification" : `${count} new notifications`;
  return `${what}, hidden while you ${hiddenReason(modes)}`;
}

// Centre while a share or recording hides popups: the list would show on the shared screen too, so only a count.
export function centreHiddenText(count, modes) {
  const what = count === 1 ? "1 notification" : `${count} notifications`;
  return `${what} hidden while you ${hiddenReason(modes)}`;
}

// Share wins over recording, as for the bell.
function hiddenReason(modes) {
  return modes.includes("screenshare") || !modes.includes("recording") ? "share your screen" : "record the screen";
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

// Whether a notification goes to the history at all: poweralertd's charge state changes are noise there too.
export function keep(n) {
  return !(n.appName === "poweralertd" && n.urgency !== 2);
}

// Ones the history does not keep end with their popup: transient (sender's hint) or not kept (keep above).
export function ephemeral(n) {
  return n.transient || !keep(n);
}

// What a new notification changes. `state` = { kept, arrived, hiddenCount, hiddenCritical } (kept = ids in arrival
// order, arrived = id -> ms, hidden* = the hidden-notifications card); `n` = { id, appName, urgency, transient,
// reloaded } (reloaded = carried over by a Quickshell reload: back in the history, never a popup again, not unread).
// Returns the next state plus what the daemon does: show = its popup in front, restartHidden = the card's timer again,
// expire = let it go now (ephemeral and no popup). `now`, `seenAt` = ms; seenAt = last time the centre was opened.
export function arrive(state, n, modes, now, seenAt) {
  const how = n.reloaded ? "silent" : delivery(n, modes);
  const hidden = how === "hidden";
  return {
    kept: state.kept.filter((id) => id !== n.id).concat([n.id]),
    arrived: Object.assign({}, state.arrived, { [n.id]: n.reloaded ? seenAt - 1 : now }),
    hiddenCount: hidden ? state.hiddenCount + 1 : state.hiddenCount,
    hiddenCritical: state.hiddenCritical || (hidden && n.urgency === 2),
    show: how === "show",
    restartHidden: hidden,
    expire: how !== "show" && ephemeral(n),
  };
}

// Bell count: kept ones that arrived after the centre was last opened.
export function unread(kept, arrived, seenAt) {
  return kept.filter((id) => (arrived[id] ?? 0) > seenAt).length;
}

// Arrival time for the centre: "now", "5 min", "2 h", then the clock time ("09:41") from 12 h on, which is enough for a
// history that only lives for the session. `then` and `now` in ms.
export function ago(then, now) {
  const min = Math.floor((now - then) / 60000);
  if (min < 1) return "now";
  if (min < 60) return `${min} min`;
  if (min < 720) return `${Math.floor(min / 60)} h`;
  const d = new Date(then);
  return `${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;
}

// Waybar bell (JSON for the custom module): crossed out while a mode hides popups, the reason in the tooltip, and the
// number of notifications that arrived since the centre was last opened.
export function bell(modes, unread) {
  const count = unread > 0 ? ` ${unread}` : "";
  const open = " (click: notifications, middle click: do not disturb)";
  if (modes.includes("recording"))
    return { text: `󰂛${count}`, tooltip: `Notifications hidden: recording the screen${open}`, class: "share" };
  if (modes.includes("screenshare"))
    return { text: `󰂛${count}`, tooltip: `Notifications hidden: sharing the whole screen${open}`, class: "share" };
  if (modes.includes("dnd")) return { text: `󰂛${count}`, tooltip: `Do not disturb${open}`, class: "dnd" };
  if (unread > 0) return { text: `󰂚${count}`, tooltip: `${unread} new${open}`, class: "unread" };
  return { text: "󰂚", tooltip: `No new notifications${open}`, class: "idle" };
}

// Popup deck geometry. `heights` = each card's natural height by index (0 = newest, in front). Closed: older cards
// behind the front one, each `gap` px higher and 4% smaller, as tall as the front card so their top edges show the same,
// up to `edges` of them. Open (pointer over it): a plain list, newest on top.
export const DECK = { gap: 8, edges: 3 };

export function deckCard(index, count, open, heights) {
  const natural = heights[index] ?? 0;
  if (open) {
    let y = 0;
    for (let i = 0; i < index; i++) y += (heights[i] ?? 0) + DECK.gap;
    return { y, scale: 1, height: natural, shown: true };
  }
  const peek = Math.min(count - 1, DECK.edges);
  return {
    y: (peek - Math.min(index, DECK.edges)) * DECK.gap,
    scale: Math.max(0.92, 1 - index * 0.04),
    height: index === 0 ? natural : (heights[0] ?? natural),
    shown: index <= DECK.edges,
  };
}

export function deckHeight(count, open, heights) {
  if (count === 0) return 0;
  if (!open) return (heights[0] ?? 0) + Math.min(count - 1, DECK.edges) * DECK.gap;
  const last = deckCard(count - 1, count, true, heights);
  return last.y + last.height;
}

// Body markup for Text.StyledText, allowlist: <b>, <i>, <u>, <a>, <br> (and their closing tags) stay, every other `<`
// becomes `&lt;` and shows as text. StyledText fetches an <img> src, http included, so a sender's text relayed by an
// app (chat preview, mail subject) could make this machine call out (IP leak, read receipt, GET into the LAN). Escaping
// instead of removing: nothing to reassemble (`<im<img>g`), no spacing trick (`< img`) to miss.
export function safeBody(body) {
  return body.replace(/<(?!\/?(?:b|i|u|a|br)\b)/gi, "&lt;");
}

// Centre list: the notifications whose id is kept, newest first. `arrived` maps id -> arrival time in ms.
export function centreItems(notifications, kept, arrived) {
  return notifications
    .filter((item) => kept.includes(item.id))
    .sort((a, b) => (arrived[b.id] ?? 0) - (arrived[a.id] ?? 0));
}

// First line of a centre entry: "Slack  ·  5 min", or only the time when the app sent no name.
export function meta(appName, when) {
  return [appName, when].filter((part) => part !== "").join("  ·  ");
}

// OSD popup icon (Osd.qml): volume and brightness in three steps by level (as the sound panel), muted ones apart.
export function osdIcon(kind, value, muted) {
  const step = (icons) => icons[Math.min(icons.length - 1, Math.floor((value / 100) * icons.length))];
  if (kind === "mic") return muted ? "󰍭" : "󰍬";
  if (kind === "brightness") return step(["󰃞", "󰃟", "󰃠"]);
  return muted ? "󰝟" : step(["󰕿", "󰖀", "󰕾"]);
}

// Track popup text (Osd.qml): "Artist - Title", the title alone without an artist, the player name without a title.
export function trackText(artist, title, playerName) {
  if (!title) return playerName;
  return artist ? artist + " - " + title : title;
}

// Track popup icon (Osd.qml): the action for next and previous, else the player's state (play while it plays).
export function trackIcon(action, playing) {
  if (action === "next") return "󰒭";
  if (action === "previous") return "󰒮";
  return playing ? "󰐊" : "󰏤";
}
