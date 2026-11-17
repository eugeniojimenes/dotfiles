// Pick, password and connect flow of the Wi-Fi panel. ES module apart from the QML (isolated), so tests/unit drives it with fake
// networks. `p` = the panel: asking, joining, failure, closePanel(). Network enums stay in shell.qml: they arrive here
// as booleans.

export const WRONG_PASSWORD = "Wrong password";
export const ENTERPRISE = "Enterprise network: use Advanced (nmtui)";
export const FAILED = "Connection failed";

// Connected first, then strongest. Unnamed (hidden) networks left out: nothing to show or type for them.
export function listed(nets) {
  return nets
    .filter((n) => n.name !== "")
    .sort((a, b) => b.connected - a.connected || b.signalStrength - a.signalStrength);
}

// Row click or Enter. Saved profile or open network: connects with no prompt; otherwise NetworkManager fails with
// NoSecrets and failed() opens the password row.
export function pick(p, n) {
  p.failure = "";
  if (n.connected || n.stateChanging) return;
  p.joining = n;
  n.connect();
}

// psk = WPA/WPA2 personal or SAE: a password row can fix it. Anything else missing a secret is enterprise.
export function failed(p, n, noSecrets, psk) {
  if (noSecrets && psk) {
    p.asking = n;
    p.failure = n.known ? WRONG_PASSWORD : "";
  } else {
    p.failure = noSecrets ? ENTERPRISE : FAILED;
  }
  p.joining = null;
}

// Enter in the password row. Empty = ignored.
export function submit(p, n, password) {
  if (password === "") return;
  p.failure = "";
  p.joining = n;
  p.asking = null;
  n.connectWithPsk(password);
}

// Esc in the password row: row closes, panel stays.
export function cancel(p) {
  p.asking = null;
  p.failure = "";
}

// Close once the network the user picked is up, like a menu. Another network connecting does not count.
export function connectedChanged(p, n) {
  if (n.connected && p.joining === n) p.closePanel();
}
