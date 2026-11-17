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

# Each panel with a toggle, loaded for real by Quickshell in a headless Sway (pixman, no GPU, no seat). qmllint follows
# plain QML import rules; Quickshell does not (it refuses imports outside the panel's own dir), so only a real load
# proves the panel starts. Pass = "Configuration Loaded" in its log; D-Bus and PipeWire errors on the way are expected
# here. Lock left out: it would lock this session.
panels_load() {
  local run=$tmp/qsrun dir qml q sock='' rc=0 sp _
  mkdir -p "$run" && chmod 700 "$run"
  printf 'output HEADLESS-1 resolution 1920x1080\n' >"$tmp/sway.cfg"
  env -i PATH="$PATH" HOME="$tmp/home" XDG_RUNTIME_DIR="$run" WLR_BACKENDS=headless WLR_RENDERER=pixman \
    WLR_LIBINPUT_NO_DEVICES=1 DBUS_SESSION_BUS_ADDRESS=disabled: sway -c "$tmp/sway.cfg" >"$tmp/sway.log" 2>&1 &
  sp=$!
  for _ in $(seq 100); do
    for sock in "$run"/sway-ipc.*; do [[ -S $sock ]] && break 2; done
    sock=''
    sleep 0.1
  done
  [[ -n $sock ]] || {
    cat "$tmp/sway.log"
    kill "$sp"
    return 1
  }
  for dir in sway/.config/sway/*/; do
    [[ -f $dir/toggle ]] || continue
    qml=$dir$(grep -o '[a-z]*\.qml' "$dir/toggle" | head -1)
    env -i PATH="$PATH" HOME="$tmp/home" XDG_RUNTIME_DIR="$run" WAYLAND_DISPLAY=wayland-1 SWAYSOCK="$sock" \
      QT_QPA_PLATFORM=wayland quickshell -p "$PWD/$qml" >"$tmp/qs.log" 2>&1 &
    q=$!
    for _ in $(seq 100); do
      grep -q 'Configuration Loaded' "$tmp/qs.log" && break
      kill -0 "$q" 2>/dev/null || break
      sleep 0.1
    done
    kill "$q" 2>/dev/null
    wait "$q" 2>/dev/null
    if grep -q 'Configuration Loaded' "$tmp/qs.log"; then
      echo "ok   $qml"
    else
      echo "FAIL $qml"
      grep -E 'ERROR|caused' "$tmp/qs.log"
      rc=1
    fi
  done
  kill "$sp"
  wait "$sp" 2>/dev/null
  return $rc
}

# waybar config is plain JSON today. Comments added later: strip the `//` lines first.
json() { jq empty sway/.config/sway/apps/waybar.jsonc docs/media.json; }

# claude-code/.claude/ = prompt text, em-dash used as a list separator the model reads (see docs/claude-code.md).
em_dash() {
  local hits
  hits=$(grep -rnIP --exclude-dir=.git '\x{2014}' .)
  (($? < 2)) || return 1 # 1 = no match, 2 = grep broke
  hits=$(grep -v '^\./claude-code/\.claude/' <<<"$hits")
  [[ -z $hits ]] || {
    echo "$hits"
    return 1
  }
}

# Human docs come in pairs, <x>.md + <x>.pt-br.md (docs/specs/ excluded: English only), root README-pt-br.md the odd
# name out. Warns, never fails: only a missing file is checkable here, not drift between the two.
doc_pairs() {
  local f
  [[ -f README.md && -f README-pt-br.md ]] || echo "warning: README.md or README-pt-br.md missing"
  for f in docs/*.md harness/*.md; do
    [[ -e $f ]] || continue
    case $f in
      *.pt-br.md) [[ -f ${f%.pt-br.md}.md ]] || echo "warning: $f has no English pair" ;;
      *) [[ -f ${f%.md}.pt-br.md ]] || echo "warning: $f has no pt-br pair" ;;
    esac
  done
}

# `nix fmt` would change nothing: treefmt (treefmt.nix) on a writable copy, the diff shown when it would.
format_check() {
  local src=$tmp/fmt d
  cp -r . "$src" && chmod -R u+w "$src" || return 1
  (cd "$src" && treefmt --no-cache --quiet) || return 1
  d=$(diff -ru --no-dereference . "$src") && return 0
  head -80 <<<"$d"
  echo "fix: nix fmt"
  return 1
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
step format format_check
step sway-config sway_config
step qmllint qml_lint
step panels-load panels_load
step json json
step em-dash em_dash
step doc-pairs doc_pairs
step stow stow_dry
step gitleaks leaks

if ((${#failed[@]})); then
  printf '\nFAILED: %s\n' "${failed[*]}"
  exit 1
fi
printf '\nstatic: all passed\n'
