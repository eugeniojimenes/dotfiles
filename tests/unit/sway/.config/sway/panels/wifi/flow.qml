import QtQuick
import QtTest
import "../../../../../../../sway/.config/sway/panels/wifi/flow.mjs" as Flow

// wifi/flow.mjs against fake networks, NetworkManager's answers fed by hand. Run one function at a time by flow.bats.
TestCase {
  name: "flow"

  // Methods only record their call (and the password): the order of calls is what the flow decides.
  function network(name, opts) {
    var n = { name: name, connected: false, stateChanging: false, known: false, signalStrength: 0.5, calls: [] }
    for (var k in opts) n[k] = opts[k]
    n.connect = function () { n.calls.push("connect") }
    n.connectWithPsk = function (pw) { n.calls.push("psk:" + pw) }
    return n
  }

  function panel() {
    var p = { asking: null, joining: null, failure: "", closed: 0 }
    p.closePanel = function () { p.closed++ }
    return p
  }

  function names(list) { return list.map(function (n) { return n.name }) }

  function test_list_connected_first_then_signal_hidden_left_out() {
    var nets = [network("weak", { signalStrength: 0.2 }), network("", { signalStrength: 0.9 }),
                network("strong", { signalStrength: 0.8 }), network("home", { connected: true, signalStrength: 0.4 })]
    compare(names(Flow.listed(nets)), ["home", "strong", "weak"])
  }

  function test_saved_network_connects_and_closes() {
    var p = panel(), n = network("home", { known: true }), other = network("cafe")
    Flow.pick(p, n)
    compare(n.calls, ["connect"])
    other.connected = true
    Flow.connectedChanged(p, other)
    compare(p.closed, 0)
    n.connected = true
    Flow.connectedChanged(p, n)
    compare(p.closed, 1)
  }

  function test_new_psk_network_asks_then_connects() {
    var p = panel(), n = network("cafe")
    Flow.pick(p, n)
    Flow.failed(p, n, true, true)
    compare(p.asking, n)
    compare(p.failure, "")
    compare(p.joining, null)
    Flow.submit(p, n, "")
    compare(n.calls, ["connect"])
    Flow.submit(p, n, "s3cret")
    compare(n.calls, ["connect", "psk:s3cret"])
    compare(p.asking, null)
    compare(p.joining, n)
    n.connected = true
    Flow.connectedChanged(p, n)
    compare(p.closed, 1)
  }

  function test_saved_network_refused_secret_says_wrong_password() {
    var p = panel(), n = network("home", { known: true })
    Flow.pick(p, n)
    Flow.failed(p, n, true, true)
    compare(p.asking, n)
    compare(p.failure, Flow.WRONG_PASSWORD)
    Flow.cancel(p)
    compare(p.asking, null)
    compare(p.failure, "")
    compare(p.closed, 0)
  }

  function test_enterprise_and_other_failures() {
    var p = panel(), n = network("corp")
    Flow.pick(p, n)
    Flow.failed(p, n, true, false)
    compare(p.failure, Flow.ENTERPRISE)
    compare(p.asking, null)
    compare(p.joining, null)
    Flow.pick(p, n)
    compare(p.failure, "")
    Flow.failed(p, n, false, true)
    compare(p.failure, Flow.FAILED)
    compare(p.closed, 0)
  }

  function test_connected_or_changing_network_ignored() {
    var p = panel(), up = network("home", { connected: true }), busy = network("cafe", { stateChanging: true })
    p.failure = "old"
    Flow.pick(p, up)
    Flow.pick(p, busy)
    compare(up.calls, [])
    compare(busy.calls, [])
    compare(p.joining, null)
    compare(p.failure, "")
  }
}
