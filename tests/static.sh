#!/usr/bin/env bash
# Static layer: lint, format, config parse, packaging, leak scan. Every step runs, exit 1 if any failed.
# Run from the repo root through `bin/check static`: the flake source holds only tracked files, a working tree also
# holds ignored ones (mpv's uosc install trips gitleaks).

set -uo pipefail
export LC_ALL=C.UTF-8 # grep -P needs it for \x{2014}, qmllint warns without it

failed=()
step() {
  printf '\n== %s\n' "$1"
  "${@:2}" || failed+=("$1")
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Found by shebang, not extension: most scripts have none, the panel toggles are #!/bin/sh.
shell_files() {
  find . -path ./.git -prune -o -type f -exec awk '
    FNR == 1 { if (/^#!.*[\/ ](sh|bash|dash|bats)[ \t]*$/) print FILENAME; nextfile }' {} +
}

# warning and up: style notes (quoting a known-single word, A && B || C after a printf) are noise here.
# SC2088: `~` inside quotes is display text in these scripts, never a path to expand.
shellcheck_all() { shell_files | xargs -d '\n' shellcheck -S warning -e SC2088; }

# hardware.nix = nixos-generate-config output, committed verbatim.
nix_format() {
  find . -name '*.nix' -not -path './nixos/hosts/*/hardware.nix' -print0 | xargs -0 nixfmt --check &&
    statix check -i 'nixos/hosts/*/hardware.nix' .
}

# Once per host file, `hostname` faked so `include hosts/$(hostname)` loads it. Headless backend: no seat here. A set
# DBUS_SESSION_BUS_ADDRESS stops the nixpkgs wrapper from starting dbus-run-session, which has no config in a sandbox.
sway_config() {
  local host out status rc=0
  mkdir -p "$tmp/bin" "$tmp/run"
  chmod 700 "$tmp/run"
  for host in sway/.config/sway/hosts/*; do
    printf '#!%s\necho %s\n' "$BASH" "${host##*/}" >"$tmp/bin/hostname"
    chmod +x "$tmp/bin/hostname"
    out=$(PATH=$tmp/bin:$PATH XDG_RUNTIME_DIR=$tmp/run WLR_BACKENDS=headless WLR_RENDERER=pixman \
      DBUS_SESSION_BUS_ADDRESS=disabled: sway -C -c sway/.config/sway/config 2>&1)
    status=$?
    # -C exits 0 on errors inside an included file: the log decides too. Full log only on a crash, it is mostly
    # fontconfig noise.
    if ((status)); then
      printf '%s\nhost %s: sway -C exit %d\n' "$out" "${host##*/}" "$status"
      rc=1
    elif grep -F '[ERROR]' <<<"$out"; then
      echo "host ${host##*/}"
      rc=1
    fi
  done
  return $rc
}

# Types resolve against Qt and Quickshell, so a misspelt type, property or import fails. Off: unqualified and comma
# (style), uncreatable-type and signal-handler-parameters (Quickshell's type info misses PanelWindow's constructor and
# I3IpcEvent; both work at runtime).
qml_lint() {
  local qt qs
  qt=$(dirname "$(readlink -f "$(command -v qmllint)")")/../lib/qt-6/qml
  qs=$(dirname "$(readlink -f "$(command -v quickshell)")")/../lib/qt-6/qml
  find sway/.config/sway -name '*.qml' -print0 | xargs -0 qmllint -I "$qt" -I "$qs" -W 0 \
    --unqualified disable --comma disable --uncreatable-type disable --signal-handler-parameters disable
}

# Plain JSON today. Comments added later: strip the `//` lines first.
waybar_json() { jq empty sway/.config/sway/apps/waybar.jsonc; }

# claude-code/.claude/ = prompt text, em-dash used as a list separator the model reads (see CLAUDE.md).
em_dash() {
  local hits
  hits=$(grep -rnIP --exclude-dir=.git '\x{2014}' .)
  (($? < 2)) || return 1 # 1 = no match, 2 = grep broke
  hits=$(grep -v '^\./claude-code/\.claude/' <<<"$hits")
  [[ -z $hits ]] || { echo "$hits"; return 1; }
}

# Packaging only (two modules shipping one file, a bad name): live-home state is dotfiles-doctor's job.
stow_dry() {
  local d mods=()
  mkdir -p "$tmp/home"
  for d in */; do
    d=${d%/}
    [[ -n $(find "$d" -mindepth 1 -maxdepth 1 -name '.*' -print -quit) ]] && mods+=("$d")
  done
  echo "modules: ${mods[*]}"
  stow -n -d . -t "$tmp/home" "${mods[@]}"
}

leaks() { gitleaks dir --no-banner --redact -v .; }

step shellcheck shellcheck_all
step nix-format nix_format
step sway-config sway_config
step qmllint qml_lint
step waybar-json waybar_json
step em-dash em_dash
step stow stow_dry
step gitleaks leaks

if ((${#failed[@]})); then
  printf '\nFAILED: %s\n' "${failed[*]}"
  exit 1
fi
printf '\nstatic: all passed\n'
