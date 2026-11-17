import QtQuick
import QtTest
import "../../../../../../../sway/.config/sway/panels/sound/sound.mjs" as Sound

// sound.mjs with fake PipeWire nodes. Run one function at a time by sound.bats.
TestCase {
  name: "sound"

  function node(fields) {
    var base = { audio: {}, isSink: false, isStream: false, description: "", nickname: "", name: "", properties: {} }
    for (var key in fields) base[key] = fields[key]
    return base
  }

  function test_devices() {
    var nodes = [
      node({ name: "speakers", isSink: true }),
      node({ name: "mic" }),
      node({ name: "firefox", isStream: true, properties: { "media.class": "Stream/Output/Audio" } }),
      node({ name: "meet-mic", isStream: true, properties: { "media.class": "Stream/Input/Audio" } }),
      node({ name: "video", audio: null })
    ]
    var lists = Sound.devices(nodes)
    compare(lists.outputs.map(function (n) { return n.name }), ["speakers"])
    compare(lists.inputs.map(function (n) { return n.name }), ["mic"])
    compare(lists.apps.map(function (n) { return n.name }), ["firefox"])
  }

  function test_labels() {
    compare(Sound.label(node({ description: "Built-in Audio", nickname: "hda", name: "alsa_output" })), "Built-in Audio")
    compare(Sound.label(node({ nickname: "hda", name: "alsa_output" })), "hda")
    compare(Sound.label(node({ name: "alsa_output" })), "alsa_output")
    compare(Sound.appLabel(node({ name: "stream", properties: { "application.name": "Firefox" } })), "Firefox")
    compare(Sound.appLabel(node({ description: "Playback", properties: {} })), "Playback")
  }

  function test_clamp() {
    compare(Sound.clampVolume(1.05), 1)
    compare(Sound.clampVolume(-0.05), 0)
    compare(Sound.clampVolume(0.5), 0.5)
  }
}
