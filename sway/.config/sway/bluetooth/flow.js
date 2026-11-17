.pragma library
// Click, pair and connect flow of the Bluetooth panel. Plain JS, apart from the QML, so tests/unit drives it with fake
// devices in BlueZ's event order. `p` = the panel: joining, fresh, connecting, failure, closePanel(). Device state
// arrives as booleans: the BluetoothDeviceState enum stays in shell.qml.

var PAIR_FAILED = "Pairing failed, a device that asks for a code needs Advanced (bluetoothctl)"
var CONNECT_FAILED = "Connection failed"

function mine(d) { return d.paired || d.bonded }

// Row click or Enter. busy = pairing, connecting or disconnecting: ignored.
function pick(p, d, busy) {
  p.failure = ""
  if (busy) return
  if (d.connected) {
    p.joining = null
    d.disconnect()
    return
  }
  p.joining = d
  p.connecting = false
  p.fresh = !mine(d)
  if (p.fresh) d.pair()
  else d.connect()
}

function forget(p, d) {
  if (p.joining === d) p.joining = null
  d.forget()
}

function fail(p, msg) {
  p.failure = msg
  p.joining = null
  p.connecting = false
}

// Paired device connected: close, like Wi-Fi. New device: stay open, it shows under My devices. BlueZ cancels a
// pairing whose caller left the bus (create_bond_req_exit), and the link comes up mid-pairing: closing on `connected`
// killed the pair.
function settle(p) {
  var d = p.joining
  if (!d || !d.connected || d.pairing || !mine(d)) return
  if (!p.fresh) p.closePanel()
  p.joining = null
  p.connecting = false
}

// Pair() done: trust (reconnects on its own later) and connect the profiles.
function paired(p) {
  var d = p.joining
  d.trusted = true
  d.connect()
  settle(p)
}

// Signal handlers for the joining device. BlueZ sets Paired before its Pair() reply ends `pairing`.
function pairedChanged(p) {
  var d = p.joining
  if (d.paired && !d.pairing) paired(p)
}

function pairingChanged(p) {
  var d = p.joining
  if (d.pairing) return
  if (d.paired) paired(p)
  else fail(p, PAIR_FAILED)
}

function stateChanged(p, connecting, disconnected) {
  if (connecting) p.connecting = true
  else if (disconnected && p.connecting) fail(p, CONNECT_FAILED)
}

function connectedChanged(p) { settle(p) }
