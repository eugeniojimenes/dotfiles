// Bluetooth panel logic, kept out of bluetooth.qml so tests/unit can replay BlueZ's events in their real order.
//
// `panel` = bluetooth.qml: fields joining, fresh, connecting, failure; methods closePanel(), connectAfterPair(device).
// `device` = a Quickshell Bluetooth device (or a fake one in tests). Its state arrives as booleans: the
// BluetoothDeviceState enum stays in bluetooth.qml.
//
// Fields while the user joins a device:
//   joining      the device the user picked, null when nothing is in flight
//   fresh        it came from Nearby: pair first, and keep the panel open afterwards
//   connecting   BlueZ reported Connecting, so falling back to Disconnected means the connection failed
// A paired device closes the panel once connected, like Wi-Fi. A new one stays open and shows under My devices.

export const PAIR_FAILED =
  "Pairing failed. Put the device in pairing mode, or use Advanced (bluetoothctl) if it asks for a code";
export const CONNECT_FAILED = "Connection failed";

export function isPaired(device) {
  return device.paired || device.bonded;
}

// My devices: the paired ones, connected first, then by name.
export function myDevices(devices) {
  return devices.filter(isPaired).sort((a, b) => {
    if (a.connected !== b.connected) return a.connected ? -1 : 1;
    return a.name.localeCompare(b.name);
  });
}

// Nearby: unpaired ones that have a name, by name. Without deviceName BlueZ only knows the address: nothing to
// recognise the device by.
export function nearbyDevices(devices) {
  return devices
    .filter((device) => !isPaired(device) && device.deviceName !== "")
    .sort((a, b) => a.name.localeCompare(b.name));
}

// Click or Enter on a device. `busy` (pairing, connecting or disconnecting) = ignored. A connected device
// disconnects, a paired one connects, a new one pairs.
export function pick(panel, device, busy) {
  panel.failure = "";
  if (busy) return;
  if (device.connected) {
    panel.joining = null;
    device.disconnect();
    return;
  }
  panel.joining = device;
  panel.connecting = false;
  panel.fresh = !isPaired(device);
  if (panel.fresh) device.pair();
  else device.connect();
}

export function forget(panel, device) {
  if (panel.joining === device) panel.joining = null;
  device.forget();
}

export function showFailure(panel, message) {
  panel.failure = message;
  panel.joining = null;
  panel.connecting = false;
}

// WARN: The joined device is paired and connected: done. Not on `connected` alone: the link comes up in the middle of a
// pairing, and BlueZ cancels a pairing whose caller left the bus, so closing then killed the pair.
function finishIfConnected(panel) {
  const device = panel.joining;
  if (!device || !device.connected || device.pairing || !isPaired(device)) return;
  if (!panel.fresh) panel.closePanel();
  panel.joining = null;
  panel.connecting = false;
}

// HACK: Pairing done: trust the device (it reconnects on its own later) and connect its profiles. Not device.connect():
// Quickshell refuses it while the pairing link is up ("already connected"), and that link drops a moment later with
// no audio profile.
function afterPairing(panel) {
  const device = panel.joining;
  device.trusted = true;
  panel.connectAfterPair(device);
  finishIfConnected(panel);
}

// Signal handlers for `panel.joining`, called by bluetooth.qml.

// BlueZ sets Paired before its Pair() reply ends `pairing`.
export function pairedChanged(panel) {
  const device = panel.joining;
  if (device.paired && !device.pairing) afterPairing(panel);
}

export function pairingChanged(panel) {
  const device = panel.joining;
  if (device.pairing) return;
  if (device.paired) afterPairing(panel);
  else showFailure(panel, PAIR_FAILED);
}

export function stateChanged(panel, { connecting, disconnected }) {
  if (connecting) panel.connecting = true;
  else if (disconnected && panel.connecting) showFailure(panel, CONNECT_FAILED);
}

export function connectedChanged(panel) {
  finishIfConnected(panel);
}
