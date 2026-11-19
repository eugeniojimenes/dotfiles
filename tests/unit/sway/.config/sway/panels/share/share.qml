import QtQuick
import QtTest
import "../../../../../../../sway/.config/sway/panels/share/share.mjs" as Share

// share.mjs with plain strings. Run one function at a time by share.bats.
TestCase {
  name: "share"

  function test_parse() {
    const text = "monitor\teDP-1\tChimei 0x1552\t\t\tMonitor: eDP-1 Chimei 0x1552\n"
               + "window\tNotes\tworkspace 3\t/run/t/1.png\teditor\tWindow: Notes\tdraft (42)\n"
               + "\n"
               + "other\tRegion\t\t\t\t\n"
    const cards = Share.parse(text)
    compare(cards.length, 2)
    compare(cards[0].kind, "monitor")
    compare(cards[0].label, "eDP-1")
    compare(cards[0].detail, "Chimei 0x1552")
    compare(cards[0].line, "Monitor: eDP-1 Chimei 0x1552")
    compare(cards[1].thumbnail, "/run/t/1.png")
    compare(cards[1].app, "editor")
    compare(cards[1].line, "Window: Notes\tdraft (42)")
    compare(Share.parse("").length, 0)
    compare(Share.parse(undefined).length, 0)
  }

  function test_step() {
    compare(Share.step(0, 1, 3), 1)
    compare(Share.step(2, 1, 3), 2)
    compare(Share.step(0, -1, 3), 0)
    compare(Share.step(1, -1, 3), 0)
    compare(Share.step(0, 1, 0), -1)
  }
}
