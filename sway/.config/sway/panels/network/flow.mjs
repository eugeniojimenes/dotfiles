// Network panel logic, kept out of network.qml so tests/unit can run it with fake networks.
//
// `panel` = network.qml: fields joining, asking, failure; method closePanel().
// `network` = a Quickshell network (or a fake one in tests).
//
// States, read from the panel's fields:
//   idle      joining = null, asking = null
//   joining   connect sent for `joining`, waiting for NetworkManager
//   asking    password row open under `asking`
// The panel closes once the network in `joining` is up.

export const WRONG_PASSWORD = "Wrong password";
export const ENTERPRISE = "Enterprise network: use Advanced (nmtui)";
export const FAILED = "Connection failed";

// Networks to show: the connected one first, then by signal. Hidden networks (no name) are left out.
export function visibleNetworks(networks) {
  return networks
    .filter((network) => network.name !== "")
    .sort((a, b) => {
      if (a.connected !== b.connected) return a.connected ? -1 : 1;
      return b.signalStrength - a.signalStrength;
    });
}

// Click or Enter on a network. A saved or open network connects with no prompt. Any other answers through
// connectFailed(), which opens the password row.
export function pick(panel, network) {
  panel.failure = "";
  if (network.connected || network.stateChanging) return;
  panel.joining = network;
  network.connect();
}

// NetworkManager refused the connection. missingPassword: it had no secret, or the saved one was refused.
// takesPassword: WPA/WPA2 personal or SAE, so a password row can fix it. Anything else is enterprise.
export function connectFailed(panel, network, { missingPassword, takesPassword }) {
  if (missingPassword && takesPassword) {
    panel.asking = network;
    panel.failure = network.known ? WRONG_PASSWORD : "";
  } else {
    panel.failure = missingPassword ? ENTERPRISE : FAILED;
  }
  panel.joining = null;
}

// Enter in the password row. An empty password is ignored.
export function submitPassword(panel, network, password) {
  if (password === "") return;
  panel.failure = "";
  panel.joining = network;
  panel.asking = null;
  network.connectWithPsk(password);
}

// Esc in the password row: the row closes, the panel stays.
export function cancelPassword(panel) {
  panel.asking = null;
  panel.failure = "";
}

// A network came up. Close only if it is the one the user picked.
export function closeWhenPickedIsUp(panel, network) {
  if (network.connected && panel.joining === network) panel.closePanel();
}
