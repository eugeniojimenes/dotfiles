import QtQuick
import QtTest
import "../../../../../../../sway/.config/sway/panels/menu/menu.mjs" as Menu

// menu.mjs with plain values. Run one function at a time by menu.bats.
TestCase {
  name: "menu"

  readonly property var state: ({ opacity: "0.92", profile: "balanced", hibernates: false })
  readonly property var apps: [
    { id: "firefox.desktop", name: "Firefox", icon: "firefox", generic: "Web Browser" },
    { id: "evil.desktop", name: "Evil\tapp; rm -rf ~", icon: "", generic: "" },
    { id: "org.gnome.Nautilus.desktop", name: "Files", icon: "org.gnome.Nautilus", generic: "File Manager" }
  ]

  function item(list, id) {
    return list.find(entry => entry.id === id)
  }

  function labels(rows) {
    return rows.map(row => row.label)
  }

  function test_root() {
    const list = Menu.items(state, apps)
    compare(labels(Menu.rows(list, "", "")), ["Apps", "Keybindings", "Notifications", "Clipboard history", "Emoji",
                                              "Capture", "Style", "Setup", "Toggle", "System"])
    const root = Menu.rows(list, "", "")
    verify(root[0].submenu)
    compare(root[0].icon, "󰀻")
    compare(root.filter(row => row.appIcon !== "").length, 0)
  }

  function test_apps() {
    const list = Menu.items(state, apps)
    const rows = Menu.rows(list, "apps", "")
    compare(labels(rows), ["Evil\tapp; rm -rf ~", "Files", "Firefox"])
    compare(rows[2].appIcon, "firefox")
    compare(rows[0].appIcon, "application-x-executable")
    compare(rows[0].run, ["gtk-launch", "evil.desktop"])
    compare(rows[1].run, ["gtk-launch", "org.gnome.Nautilus.desktop"])
  }

  function test_actions() {
    const list = Menu.items(state, apps)
    const run = id => item(list, id).run
    compare(run("setup.bluetooth"), ["sh", "-c", "~/.config/sway/panels/bluetooth/toggle"])
    compare(run("toggle.awake"), ["sh", "-c", "~/.config/sway/bin/idle toggle"])
    compare(run("toggle.night"), ["sh", "-c", "~/.config/sway/bin/nightlight toggle"])
    compare(run("toggle.dnd"), ["sh", "-c", "~/.config/sway/bin/dnd toggle"])
    compare(run("clipboard"), ["sh", "-c", "~/.config/sway/bin/clipboard pick"])
    compare(run("emoji"), ["sh", "-c", "~/.config/sway/bin/emoji"])
    compare(run("system.clear"), ["sh", "-c", "~/.config/sway/bin/clipboard clear"])
    compare(run("system.update"),
            ["sh", "-c", '~/.config/sway/bin/float "$(readlink -f ~/.config/sway/../../..)/bin/update" --pause'])
    compare(run("setup.reload"), ["swaymsg", "reload"])
  }

  function test_power_profile() {
    const list = Menu.items(state, apps)
    const rows = Menu.rows(list, "toggle.profile", "")
    compare(labels(rows), ["power-saver", "balanced", "performance"])
    compare(rows.map(row => row.icon), ["󰝦", "󰄬", "󰝦"])
    compare(rows[2].run,
            ["sh", "-c", "powerprofilesctl set performance && ~/.config/sway/bin/osd switch profile performance"])
  }

  function test_opacity() {
    const rows = Menu.rows(Menu.items(state, apps), "style.opacity", "")
    compare(labels(rows), ["100%", "99%", "98%", "97%", "96%", "94%", "92%", "88%", "85%", "80%"])
    compare(rows[6].icon, "󰄬")
    compare(rows.filter(row => row.icon === "󰄬").length, 1)
    compare(rows[9].run, ["sh", "-c", "~/.config/sway/bin/opacity 0.80"])
  }

  function test_hibernation() {
    compare(Menu.hibernates("259:2\n"), true)
    compare(Menu.hibernates("0:0\n"), false)
    compare(Menu.hibernates(""), false)
    const plain = Menu.rows(Menu.items(state, apps), "system", "")
    compare(item(plain, "system.suspend").run, ["systemctl", "suspend"])
    compare(item(plain, "system.hibernate"), undefined)
    const sleeps = Menu.rows(Menu.items({ opacity: "0.92", profile: "balanced", hibernates: true }, apps), "system", "")
    compare(item(sleeps, "system.suspend").run, ["systemctl", "suspend-then-hibernate"])
    compare(item(sleeps, "system.hibernate").run, ["systemctl", "hibernate"])
  }

  function test_search() {
    const list = Menu.items(state, apps)
    // From the root: deeper hits only, each with its path; apps found by name and by generic name.
    const shots = Menu.rows(list, "", "screensh")
    compare(labels(shots), ["Screenshot (area)", "Screenshot (screen)"])
    compare(shots[0].detail, "Capture")
    compare(shots[0].section, "deeper")
    compare(labels(Menu.rows(list, "", "fire")), ["Firefox"])
    compare(Menu.rows(list, "", "fire")[0].detail, "Apps")
    compare(labels(Menu.rows(list, "", "browser")), ["Firefox"])
    // Every word must match; case does not matter.
    compare(labels(Menu.rows(list, "", "RECORD mic")), ["Record area with microphone", "Record screen with microphone"])
    compare(Menu.rows(list, "", "zzz").length, 0)
    // Own level first, then deeper; a deeper hit shows its full path.
    compare(item(Menu.rows(list, "", "opacity"), "style.opacity").detail, "Style")
    compare(item(Menu.rows(list, "", "92"), "style.opacity.0.92").detail, "Style › Terminal opacity")
    const here = Menu.rows(list, "", "s")
    compare(here.filter(row => row.section === "here").length > 0, true)
    verify(here.findIndex(row => row.section === "deeper") > here.findIndex(row => row.section === "here"))
    compare(here.slice(here.findIndex(row => row.section === "deeper")).every(row => row.section === "deeper"), true)
    // Better match first: label start before a word start before anywhere.
    compare(labels(Menu.rows(list, "", "lock")).slice(0, 1), ["Lock"])
    // Inside a submenu only its own subtree.
    compare(labels(Menu.rows(list, "capture", "screen")),
            ["Screenshot (area)", "Screenshot (screen)", "Record screen", "Record screen with microphone"])
    compare(Menu.rows(list, "capture", "screen")[0].section, "here")
    compare(Menu.rows(list, "capture", "firefox").length, 0)
  }

  function test_back() {
    const list = Menu.items(state, apps)
    compare(Menu.parentOf(list, "style.opacity"), "style")
    compare(Menu.parentOf(list, "style"), "")
    compare(Menu.path(list, "style.opacity.0.92"), "Style › Terminal opacity")
    compare(Menu.path(list, "style"), "")
  }

  function test_step() {
    compare(Menu.step(0, 1, 3), 1)
    compare(Menu.step(2, 1, 3), 2)
    compare(Menu.step(0, -1, 3), 0)
    compare(Menu.step(0, 11, 3), 2)
    compare(Menu.step(0, 1, 0), -1)
  }
}
