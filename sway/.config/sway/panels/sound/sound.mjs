// Sound panel logic, kept out of sound.qml so tests/unit can check it with plain objects.
// `node` = a PipeWire node from Quickshell.Services.Pipewire (or a fake one in tests): audio (null when the node has no
// audio), isSink, isStream, description, nickname, name, and properties (a map: "media.class", "application.name").

// What the panel lists: output devices, input devices, and apps playing sound. Recording streams (a microphone in use)
// are Stream/Input/Audio and stay out of the apps.
export function devices(nodes) {
  const audio = nodes.filter((node) => node.audio);
  return {
    outputs: audio.filter((node) => node.isSink && !node.isStream),
    inputs: audio.filter((node) => !node.isSink && !node.isStream),
    apps: audio.filter((node) => node.isStream && node.properties["media.class"] === "Stream/Output/Audio"),
  };
}

// Device name: PipeWire's description, else its nickname, else the node name.
export function label(node) {
  return node.description || node.nickname || node.name;
}

// App name for a stream, else the stream's own label.
export function appLabel(node) {
  return node.properties["application.name"] || label(node);
}

// Volume stops at 0 and at 100%.
export function clampVolume(volume) {
  return Math.max(0, Math.min(1, volume));
}

// Media card players = Mpris.players.values (isPlaying, trackTitle, dbusName). `chosen` = instance picked with the
// card's arrows, shared with bin/media through $XDG_RUNTIME_DIR/sway-media-player, "" when none.

// Players the card can show: playing, or holding a track. A browser keeps a stopped player with no track after its
// media ends; the card skips it.
export function mediaPlayers(players) {
  return players.filter((player) => player.isPlaying || player.trackTitle);
}

// playerctl's name for a player ("spotify", "brave.instance123"): its D-Bus name without the MPRIS prefix.
export function instance(player) {
  return player.dbusName.replace("org.mpris.MediaPlayer2.", "");
}

// Player the card shows: the chosen one while it still has a track, else the first playing, else the first with a
// track (paused), else null (card hidden).
export function mediaPlayer(players, chosen) {
  const list = mediaPlayers(players);
  return (
    list.find((player) => instance(player) === chosen) || list.find((player) => player.isPlaying) || list[0] || null
  );
}

// Player the card's arrows move to: `step` = -1 or 1 from `player`, wrapping around the list.
export function stepPlayer(players, player, step) {
  const list = mediaPlayers(players);
  const index = list.indexOf(player);
  return list[(index + step + list.length) % list.length];
}

// Track time from MPRIS seconds: m:ss, h:mm:ss from one hour on.
export function clock(seconds) {
  const total = Math.max(0, Math.floor(seconds));
  const hours = Math.floor(total / 3600);
  const minutes = Math.floor((total % 3600) / 60);
  const rest = String(total % 60).padStart(2, "0");
  if (hours > 0) return `${hours}:${String(minutes).padStart(2, "0")}:${rest}`;
  return `${minutes}:${rest}`;
}
