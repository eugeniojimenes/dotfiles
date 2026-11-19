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

  function player(dbusName, isPlaying, trackTitle) {
    return { dbusName: "org.mpris.MediaPlayer2." + dbusName, isPlaying: isPlaying, trackTitle: trackTitle }
  }

  function test_media_player() {
    var spotify = player("spotify", false, "Song")
    var brave = player("brave", true, "Video")
    var stale = player("chromium", false, "")
    compare(Sound.mediaPlayers([spotify, stale, brave]), [spotify, brave])
    compare(Sound.mediaPlayer([spotify, brave], ""), brave)
    compare(Sound.mediaPlayer([spotify, brave], "spotify"), spotify)
    compare(Sound.mediaPlayer([spotify, brave], "gone"), brave)
    compare(Sound.mediaPlayer([stale, spotify], ""), spotify)
    compare(Sound.mediaPlayer([stale], "chromium"), null)
    compare(Sound.mediaPlayer([], ""), null)
  }

  function test_instance() {
    compare(Sound.instance(player("brave.instance123", true, "Video")), "brave.instance123")
  }

  function test_step_player() {
    var spotify = player("spotify", true, "Song")
    var stale = player("chromium", false, "")
    var brave = player("brave", false, "Video")
    compare(Sound.stepPlayer([spotify, stale, brave], spotify, 1), brave)
    compare(Sound.stepPlayer([spotify, stale, brave], brave, 1), spotify)
    compare(Sound.stepPlayer([spotify, stale, brave], spotify, -1), brave)
    compare(Sound.stepPlayer([spotify], spotify, 1), spotify)
  }

  function test_clock() {
    compare(Sound.clock(0), "0:00")
    compare(Sound.clock(65.9), "1:05")
    compare(Sound.clock(3725), "1:02:05")
    compare(Sound.clock(-3), "0:00")
  }
}
