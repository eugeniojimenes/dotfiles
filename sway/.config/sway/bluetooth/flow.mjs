// Click, pair and connect flow of the Bluetooth panel. ES module apart from the QML (isolated: sees nothing of the
// panel but what is passed in), so tests/unit drives it with fake devices in BlueZ's event order. `p` = the panel:
// joining, fresh, connecting, failure, closePanel(), connectAfterPair(d). Device state arrives as booleans: the
// BluetoothDeviceState enum stays in shell.qml.

export const PAIR_FAILED =
  "Pairing failed. Put the device in pairing mode, or use Advanced (bluetoothctl) if it asks for a code";
export const CONNECT_FAILED = "Connection failed";

export function mine(d) {
  return d.paired || d.bonded;
}

// Row click or Enter. busy = pairing, connecting or disconnecting: ignored.
export function pick(p, d, busy) {
  p.failure = "";
  if (busy) return;
  if (d.connected) {
    p.joining = null;
    d.disconnect();
    return;
  }
  p.joining = d;
  p.connecting = false;
  p.fresh = !mine(d);
  if (p.fresh) d.pair();
  else d.connect();
}

export function forget(p, d) {
  if (p.joining === d) p.joining = null;
  d.forget();
}

export function fail(p, msg) {
  p.failure = msg;
  p.joining = null;
  p.connecting = false;
}

// Paired device connected: close, like Wi-Fi. New device: stay open, it shows under My devices. BlueZ cancels a
// pairing whose caller left the bus (create_bond_req_exit), and the link comes up mid-pairing: closing on `connected`
// killed the pair.
export function settle(p) {
  var d = p.joining;
  if (!d || !d.connected || d.pairing || !mine(d)) return;
  if (!p.fresh) p.closePanel();
  p.joining = null;
  p.connecting = false;
}

// Pair() done: trust (reconnects on its own later) and connect the profiles. Not d.connect(): Quickshell refuses it
// while the pairing link is up ("already connected"), and that link drops a moment later with no audio profile.
export function paired(p) {
  var d = p.joining;
  d.trusted = true;
  p.connectAfterPair(d);
  settle(p);
}

// Signal handlers for the joining device. BlueZ sets Paired before its Pair() reply ends `pairing`.
export function pairedChanged(p) {
  var d = p.joining;
  if (d.paired && !d.pairing) paired(p);
}

export function pairingChanged(p) {
  var d = p.joining;
  if (d.pairing) return;
  if (d.paired) paired(p);
  else fail(p, PAIR_FAILED);
}

export function stateChanged(p, connecting, disconnected) {
  if (connecting) p.connecting = true;
  else if (disconnected && p.connecting) fail(p, CONNECT_FAILED);
}

export function connectedChanged(p) {
  settle(p);
}
