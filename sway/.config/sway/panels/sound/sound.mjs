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
