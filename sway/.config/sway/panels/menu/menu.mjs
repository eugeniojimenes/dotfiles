// Super+Space menu logic (../menu.qml), kept apart so tests/unit can run it without a screen. Spec: docs/specs/menu.md.
// The whole tree is one flat list of items, each naming its parent ("" = root):
//   { id, parent, icon, label, run }      action: `run` = argv for Quickshell.execDetached
//   { id, parent, icon, label, submenu }  submenu: true, its children name it as parent
//   app items also carry appIcon (icon name for the image) and generic (generic name, searched too)
// `state` = what the menu shows live: { opacity: "0.92", profile: "balanced", hibernates: bool }.
// `apps` = [{ id, name, icon, generic }], desktop id and fields of each DesktopEntry to list.
// Commands spell out ~/.config/sway/...: sh expands it, and tests/static.sh sway-paths checks every path here exists.

const sh = (command) => ["sh", "-c", command];
const OPACITY = ["1.0", "0.99", "0.98", "0.97", "0.96", "0.94", "0.92", "0.88", "0.85", "0.80"];
const PROFILES = ["power-saver", "balanced", "performance"];
const radio = (on) => (on ? "󰄬" : "󰝦");

export function items(state, apps) {
  const list = [
    { id: "apps", parent: "", icon: "󰀻", label: "Apps", submenu: true },
    { id: "keybindings", parent: "", icon: "󰌌", label: "Keybindings", run: sh("~/.config/sway/bin/keybindings") },
    {
      id: "notifications",
      parent: "",
      icon: "󰂚",
      label: "Notifications",
      run: sh("~/.config/sway/panels/notifications/toggle"),
    },
    {
      id: "clipboard",
      parent: "",
      icon: "󰅌",
      label: "Clipboard history",
      run: sh("~/.config/sway/bin/clipboard pick"),
    },
    { id: "emoji", parent: "", icon: "󰞅", label: "Emoji", run: sh("~/.config/sway/bin/emoji") },
    { id: "capture", parent: "", icon: "󰄀", label: "Capture", submenu: true },
    { id: "style", parent: "", icon: "󰏘", label: "Style", submenu: true },
    { id: "setup", parent: "", icon: "󰒓", label: "Setup", submenu: true },
    { id: "toggle", parent: "", icon: "󰔡", label: "Toggle", submenu: true },
    { id: "system", parent: "", icon: "󰐥", label: "System", submenu: true },

    {
      id: "capture.shot-area",
      parent: "capture",
      icon: "󰩭",
      label: "Screenshot (area)",
      run: sh("~/.config/sway/bin/screenshot area"),
    },
    {
      id: "capture.shot-screen",
      parent: "capture",
      icon: "󰍹",
      label: "Screenshot (screen)",
      run: sh("~/.config/sway/bin/screenshot screen"),
    },
    {
      id: "capture.ocr",
      parent: "capture",
      icon: "󰊄",
      label: "Text from area (OCR)",
      run: sh("~/.config/sway/bin/ocr"),
    },
    {
      id: "capture.color",
      parent: "capture",
      icon: "󰈊",
      label: "Color picker",
      run: sh("~/.config/sway/bin/colorpick"),
    },
    // Any of these while recording stops it (bin/record).
    {
      id: "capture.rec-area",
      parent: "capture",
      icon: "󰑋",
      label: "Record area",
      run: sh("~/.config/sway/bin/record area"),
    },
    {
      id: "capture.rec-screen",
      parent: "capture",
      icon: "󰑋",
      label: "Record screen",
      run: sh("~/.config/sway/bin/record screen"),
    },
    {
      id: "capture.rec-area-mic",
      parent: "capture",
      icon: "󰍬",
      label: "Record area with microphone",
      run: sh("~/.config/sway/bin/record area audio"),
    },
    {
      id: "capture.rec-screen-mic",
      parent: "capture",
      icon: "󰍬",
      label: "Record screen with microphone",
      run: sh("~/.config/sway/bin/record screen audio"),
    },

    {
      id: "style.background",
      parent: "style",
      icon: "󰸉",
      label: "Background",
      run: sh("~/.config/sway/bin/wallpaper pick"),
    },
    {
      id: "style.next",
      parent: "style",
      icon: "󰒭",
      label: "Next background",
      run: sh("~/.config/sway/bin/wallpaper next"),
    },
    { id: "style.opacity", parent: "style", icon: "󰃚", label: "Terminal opacity", submenu: true },
    ...OPACITY.map((value) => ({
      id: "style.opacity." + value,
      parent: "style.opacity",
      icon: radio(value === state.opacity),
      label: Math.round(Number(value) * 100) + "%",
      run: sh("~/.config/sway/bin/opacity " + value),
    })),

    { id: "setup.wifi", parent: "setup", icon: "󰖩", label: "Wi-Fi", run: sh("~/.config/sway/panels/wifi/toggle") },
    {
      id: "setup.bluetooth",
      parent: "setup",
      icon: "󰂯",
      label: "Bluetooth",
      run: sh("~/.config/sway/panels/bluetooth/toggle"),
    },
    { id: "setup.sound", parent: "setup", icon: "󰕾", label: "Sound", run: sh("~/.config/sway/panels/sound/toggle") },
    {
      id: "setup.display",
      parent: "setup",
      icon: "󰍹",
      label: "Display",
      run: sh("~/.config/sway/panels/display/toggle"),
    },
    { id: "setup.power", parent: "setup", icon: "󰁹", label: "Power", run: sh("~/.config/sway/panels/power/toggle") },
    {
      id: "setup.sway",
      parent: "setup",
      icon: "󰏫",
      label: "Edit Sway config",
      run: sh("~/.config/sway/bin/float nvim ~/.config/sway/config.d"),
    },
    {
      id: "setup.bar",
      parent: "setup",
      icon: "󰏫",
      label: "Edit bar",
      run: sh("~/.config/sway/bin/float nvim ~/.config/sway/apps/waybar.jsonc"),
    },
    { id: "setup.reload", parent: "setup", icon: "󰑓", label: "Reload Sway", run: ["swaymsg", "reload"] },

    {
      id: "toggle.dnd",
      parent: "toggle",
      icon: "󰂛",
      label: "Do not disturb",
      run: sh("~/.config/sway/bin/dnd toggle"),
    },
    { id: "toggle.awake", parent: "toggle", icon: "󰅶", label: "Stay awake", run: sh("~/.config/sway/bin/idle toggle") },
    {
      id: "toggle.night",
      parent: "toggle",
      icon: "󰖔",
      label: "Night light",
      run: sh("~/.config/sway/bin/nightlight toggle"),
    },
    { id: "toggle.profile", parent: "toggle", icon: "󰾅", label: "Power profile", submenu: true },
    // power-profiles-daemon; the waybar module follows the change over D-Bus by itself, bin/osd shows the popup.
    ...PROFILES.map((name) => ({
      id: "toggle.profile." + name,
      parent: "toggle.profile",
      icon: radio(name === state.profile),
      label: name,
      run: sh("powerprofilesctl set " + name + " && ~/.config/sway/bin/osd switch profile " + name),
    })),

    // bin/update lives in the repo, not in a module: found through the stow link of ~/.config/sway.
    {
      id: "system.update",
      parent: "system",
      icon: "󰚰",
      label: "Update",
      run: sh('~/.config/sway/bin/float "$(readlink -f ~/.config/sway/../../..)/bin/update" --pause'),
    },
    { id: "system.lock", parent: "system", icon: "󰌾", label: "Lock", run: sh("~/.config/sway/panels/lock/lock") },
    {
      id: "system.clear",
      parent: "system",
      icon: "󰎟",
      label: "Clear clipboard history",
      run: sh("~/.config/sway/bin/clipboard clear"),
    },
    // Hibernation set up on this machine (resume device in nixos/hosts/<host>): Suspend hibernates later on battery.
    state.hibernates
      ? {
          id: "system.suspend",
          parent: "system",
          icon: "󰤄",
          label: "Suspend",
          run: ["systemctl", "suspend-then-hibernate"],
        }
      : { id: "system.suspend", parent: "system", icon: "󰤄", label: "Suspend", run: ["systemctl", "suspend"] },
    ...(state.hibernates
      ? [{ id: "system.hibernate", parent: "system", icon: "󰒲", label: "Hibernate", run: ["systemctl", "hibernate"] }]
      : []),
    { id: "system.exit", parent: "system", icon: "󰍃", label: "Exit Sway", run: ["swaymsg", "exit"] },
    { id: "system.reboot", parent: "system", icon: "󰜉", label: "Reboot", run: ["systemctl", "reboot"] },
    { id: "system.poweroff", parent: "system", icon: "󰐥", label: "Power off", run: ["systemctl", "poweroff"] },
  ];
  // Apps by desktop id, handed to gtk-launch as one argument: nothing from a .desktop file reaches a shell.
  const sorted = apps
    .slice()
    .sort((a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase()) || a.id.localeCompare(b.id));
  for (const app of sorted)
    list.push({
      id: "app:" + app.id,
      parent: "apps",
      icon: "",
      appIcon: app.icon || "application-x-executable",
      generic: app.generic || "",
      label: app.name,
      run: ["gtk-launch", app.id],
    });
  return list;
}

// /sys/power/resume reads "0:0" without a resume device (the desktop has no swapfile).
export function hibernates(resume) {
  const value = (resume || "").trim();
  return value !== "" && value !== "0:0";
}

function byId(list, id) {
  return list.find((item) => item.id === id);
}

// Labels from the root down to the item's parent: "Capture", "Style › Terminal opacity". Root items: "".
export function path(list, id) {
  const labels = [];
  for (let item = byId(list, byId(list, id)?.parent); item; item = byId(list, item.parent)) labels.unshift(item.label);
  return labels.join(" › ");
}

export function parentOf(list, id) {
  return byId(list, id)?.parent ?? "";
}

function within(list, item, menu) {
  for (let parent = item.parent; parent !== undefined; parent = byId(list, parent)?.parent) {
    if (parent === menu) return true;
    if (parent === "") return false;
  }
  return false;
}

// Lower = better: label equal, label starts with it, a word of the label starts with it, label holds it, then the
// generic name only. Every word of the query must be in the label or the generic name, else -1.
export function score(item, query) {
  const label = item.label.toLowerCase();
  const all = (label + " " + (item.generic || "")).toLowerCase();
  const words = query
    .toLowerCase()
    .trim()
    .split(/\s+/)
    .filter((word) => word !== "");
  if (words.length === 0 || !words.every((word) => all.includes(word))) return -1;
  const needle = words.join(" ");
  if (label === needle) return 0;
  if (label.startsWith(needle)) return 1;
  if (label.split(/[\s(]+/).some((word) => word.startsWith(needle))) return 2;
  if (label.includes(needle)) return 3;
  return 4;
}

// What the list shows in `menu` ("" = root). No query: its children in order. A query: every item under it that
// matches, its own children first, then deeper ones with their path as detail (section "deeper"), each group by score,
// then shallower first, then label. Rows: { id, icon, appIcon, label, detail, submenu, run, section }.
export function rows(list, menu, query) {
  const row = (item, section) => ({
    id: item.id,
    icon: item.icon,
    appIcon: item.appIcon || "",
    label: item.label,
    detail: section === "deeper" ? path(list, item.id) : "",
    submenu: item.submenu === true,
    run: item.run || [],
    section,
  });
  if ((query || "").trim() === "") return list.filter((item) => item.parent === menu).map((item) => row(item, "here"));
  const depth = (item) => path(list, item.id).split(" › ").length;
  const hits = list
    .filter((item) => within(list, item, menu))
    .map((item) => ({ item, score: score(item, query) }))
    .filter((hit) => hit.score >= 0);
  const order = (a, b) =>
    a.score - b.score || depth(a.item) - depth(b.item) || a.item.label.localeCompare(b.item.label);
  const here = hits.filter((hit) => hit.item.parent === menu).sort(order);
  const deeper = hits.filter((hit) => hit.item.parent !== menu).sort(order);
  return here.map((hit) => row(hit.item, "here")).concat(deeper.map((hit) => row(hit.item, "deeper")));
}

// Cursor `delta` rows away, held at both ends. No rows = -1.
export function step(index, delta, count) {
  if (count === 0) return -1;
  return Math.max(0, Math.min(count - 1, index + delta));
}
