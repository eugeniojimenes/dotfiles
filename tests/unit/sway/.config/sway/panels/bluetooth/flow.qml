import QtQuick
import QtTest
import "../../../../../../../sway/.config/sway/panels/bluetooth/flow.mjs" as Flow

// flow.mjs against fake devices, events fed in the order BlueZ sends them. Run one function at a time by flow.bats.
TestCase {
  name: "flow"

  // Methods only record their call: the order of calls is what the flow decides.
  function device(isPaired) {
    var d = { paired: isPaired, bonded: isPaired, pairing: false, connected: false, trusted: isPaired, calls: [] }
    ;["pair", "connect", "disconnect", "forget"].forEach(function (m) { d[m] = function () { d.calls.push(m) } })
    return d
  }

  function panel() {
    var p = { joining: null, fresh: false, connecting: false, failure: "", closed: 0, afterPair: [] }
    p.closePanel = function () { p.closed++ }
    p.connectAfterPair = function (d) { p.afterPair.push(d) }
    return p
  }

  // The bug this file exists for: closing on `connected` mid-pairing made BlueZ cancel the pair.
  function test_new_device_pairing() {
    var p = panel(), d = device(false)
    Flow.pick(p, d, false)
    compare(d.calls, ["pair"])
    d.pairing = true
    d.connected = true
    Flow.connectedChanged(p)
    d.paired = true
    Flow.pairedChanged(p)
    compare(p.closed, 0)
    compare(d.calls, ["pair"])
    d.pairing = false
    Flow.pairingChanged(p)
    verify(d.trusted)
    // Quickshell's connect() is a no-op while the pairing link is up: the connect goes around it.
    compare(d.calls, ["pair"])
    compare(p.afterPair, [d])
    compare(p.closed, 0)
    compare(p.joining, null)
    compare(p.failure, "")
  }

  function test_new_device_connects_later() {
    var p = panel(), d = device(false)
    Flow.pick(p, d, false)
    d.pairing = true
    Flow.pairingChanged(p)
    d.paired = true
    d.pairing = false
    Flow.pairingChanged(p)
    compare(p.afterPair, [d])
    compare(p.joining, d)
    d.connected = true
    Flow.connectedChanged(p)
    compare(p.closed, 0)
    compare(p.joining, null)
  }

  function test_pairing_fails() {
    var p = panel(), d = device(false)
    Flow.pick(p, d, false)
    d.pairing = true
    Flow.pairingChanged(p)
    d.pairing = false
    Flow.pairingChanged(p)
    compare(p.failure, Flow.PAIR_FAILED)
    compare(d.calls, ["pair"])
    compare(p.closed, 0)
    compare(p.joining, null)
  }

  function test_paired_device_closes_once_connected() {
    var p = panel(), d = device(true)
    Flow.pick(p, d, false)
    compare(d.calls, ["connect"])
    Flow.stateChanged(p, true, false)
    d.connected = true
    Flow.connectedChanged(p)
    compare(p.closed, 1)
  }

  function test_paired_device_connect_fails() {
    var p = panel(), d = device(true)
    Flow.pick(p, d, false)
    Flow.stateChanged(p, true, false)
    Flow.stateChanged(p, false, true)
    compare(p.failure, Flow.CONNECT_FAILED)
    compare(p.closed, 0)
    compare(p.joining, null)
  }

  function test_connected_device_disconnects() {
    var p = panel(), d = device(true)
    d.connected = true
    Flow.pick(p, d, false)
    compare(d.calls, ["disconnect"])
    compare(p.joining, null)
    compare(p.closed, 0)
  }

  function test_busy_device_ignored() {
    var p = panel(), d = device(true)
    Flow.pick(p, d, true)
    compare(d.calls, [])
    compare(p.joining, null)
  }

  function test_forget() {
    var p = panel(), d = device(true)
    Flow.pick(p, d, false)
    Flow.forget(p, d)
    compare(d.calls, ["connect", "forget"])
    compare(p.joining, null)
  }
}
