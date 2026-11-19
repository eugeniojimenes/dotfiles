---
name: manual-check
description: Run tests/manual.md items on the owner's live Sway session as the agent - drive keyboard and mouse, capture the screen, read daemon state, time behaviour - then report what each criterion showed so the owner decides the pass. Use when the owner asks the agent to run, verify or check manual items or a spec's manual criteria itself.
---

# manual-check

Rules: `harness/rules/tests.md` (manual passes). Items: `tests/manual.md`, criteria: `docs/specs/<feature>.md`. Pass recorded only on owner's word.

## Before

1. Read the row + the spec criteria it names. Split: agent drives (live session: panels, popups, bindings, IPC, timing) vs needs a human ("Not agent-checkable" below). Human part = short steps for owner, never faked.
2. Ask owner OK first, full sentences, naming:
   - agent drives mouse and keyboard ~N minutes: hands off;
   - destructive steps: Clear in the centre, `clear all`, daemon kill (history lives in memory, gone), mode toggles;
   - screenshots show open windows (chat, work): owner hides private ones. Reading a shot sends it to the model; shots stay in scratchpad, deleted at end, never committed or published;
   - a test that writes the clipboard: saved and restored, its history entries removed.
3. Session locked = stop, tell owner, wait. Never type at it (`wtype` lands in the password field), never unlock. Check: `pgrep -af '^[^ ]*quickshell -p .*lock.qml'`. Owner away: Stay awake on (`Super + Ctrl + I`) before leaving, or the 7-min lock comes mid-run.
4. Note start state to restore: focused workspace (`swaymsg -t get_workspaces`), modes (`quickshell ipc -p ~/.config/sway/panels/notifications.qml call notifications modes`), clipboard (`t=$(wl-paste -l | head -1); wl-paste -n -t "$t" >clip.bak`).
5. Every run of input: one tool call with the whole sequence, so the owner's Esc on a prompt cannot cut it midway. Cut anyway = redo the restore step before anything else.

## Toolbox

- Keys: `wtype -M logo -M ctrl -k comma -m ctrl -m logo` (Sway bindings fire from the virtual keyboard). Text: `wtype Notifications`. Single key: `wtype -k Escape`, `-k Return`.
- Before typing text or Enter: work on an empty workspace (`swaymsg workspace 8`) and check the target has focus (`swaymsg -t get_tree | jq -r '.. | objects | select(.focused? == true) | .app_id'`, or the panel's process with `pgrep -fx`). Not there = skip the keys: text plus Enter in a terminal or chat runs a command or sends a message. Workspace switch: `swaymsg workspace N`, never `wtype` (workspace keys are `bindcode`).
- Mouse: `swaymsg -q seat seat0 cursor set X Y` (hover too: surfaces get the motion), then `swaymsg -q seat seat0 cursor press button1` + `cursor release button1` (`button2` middle, `button3` right, wheel `button4`/`button5`). X Y = layout pixels (`swaymsg -t get_outputs`: rect, scale).
- Screen: `grim -s 1 -g "X,Y WxH" shot.png` (`-s 1`: image pixels = layout pixels on a scaled output), then Read the png. Several states in one look: `magick a.png b.png -append out.png` (`+append` = side by side). Coordinate read off a stacked image: subtract that tile's offset first.
- State over pixels when possible: `quickshell ipc -p <qml> show` (targets), `... call notifications status|modes`, `swaymsg -t get_tree|get_workspaces`, `busctl --user status <name>` (who owns a D-Bus name), `pgrep -fx "<exact cmdline>"`.
- Action results: `notify-send -A default=Open -A other=Other "<summary>" x >out` prints the invoked action. Process must outlive the tool call's shell: `setsid -f sh -c '... >file'` (plain `&` job dies with that shell).
- Timing: empty workspace (`swaymsg workspace 8`) = constant background. Print time of each change of a region:
  ```sh
  t0=$(date +%s%N) prev=
  while (( ($(date +%s%N) - t0) / 1000000 < 15000 )); do
    h=$(grim -g "1520,30 400x150" - | md5sum | cut -c1-8)
    [[ $h != "$prev" ]] && echo "$(( ($(date +%s%N) - t0) / 1000000 )) ms $h"
    prev=$h; sleep 0.2
  done
  ```
  Which state a hash is: screenshots at fixed times in the same run.
- Kill a daemon from the agent shell: `pkill -fx "<exact cmdline>"` only. A loose `pkill -f` pattern matches the agent's own shell and kills it.

## Not agent-checkable

Physical keys (Fn, media, brightness), suspend/resume, lid, hotplug of a monitor or USB device, sound heard, mic picking up a voice, Bluetooth pairing with a real device, battery charge limit, GPU offload in a game, anything across a reboot or relogin. Hand those to owner as steps.

Partial: the command a key runs can run directly (`~/.config/sway/bin/osd volume up`) = script works, not that the key reaches it. Say which.

## After

1. Restore: workspace, modes as found, cursor to centre, no test popup left. Leftover process = kill by exact cmdline.
2. Delete the scratchpad shots. Clipboard back (by type) and test entries gone from history.
3. Report per criterion: number, what was done, what was seen (measured times, outputs). Failures and surprises first. Bug found = options to owner, fix in own `fix(...)` commit.
4. Owner says passed = `bin/manual-pass --with agent-driven "<item>"`. Owner did the human-only steps = `--with "agent-driven, <what owner did>"`.

## Pitfalls (from this repo)

- Edit a QML file the always-running daemon loads = Quickshell reloads it; a measurement started right after may run on old code. Wait for `Configuration Loaded` in `quickshell log -p <qml>` before timing.
- Terminal under a popup changes as the agent prints: hash on an empty workspace, never over the agent's terminal.
- Opening the notification centre clears the unread count and the popups: read the count before opening it.
- Panel closes on any click outside its card: miscomputed coordinate shows as "closed", not as a missed button. Shot the card, compute, then click.
- Clipboard restore by type, not plain `wl-copy <file` (it guesses the type: text came back as `application/x-trash`): `wl-copy -t "$t" <clip.bak`. Then drop test entries from history: `cliphist -db-path "$XDG_RUNTIME_DIR/cliphist/db" list | awk -F'\t' '<match test entries>' | cliphist -db-path ... delete`. Never print entries: compare sizes or hashes.
- Debug: temporary `console.log` in QML, read with `quickshell log -p <qml>`. Back up the file first, restore after, check `git diff` clean of it.
