#!/usr/bin/env bash
# Static layer: lint, format, config parse, packaging, leak scan. Every step runs, exit 1 if any failed.
# Run from the repo root through `bin/check static`: the flake source holds only tracked files, a working tree also
# holds ignored ones that would trip gitleaks.

set -uo pipefail
export LC_ALL=C.UTF-8 # grep -P needs it for \x{2014}, qmllint warns without it

failed=()
# Panel Text with a bound value, or a component root Text whose users set it, declares its textFormat. The default
# AutoText turns a string holding a tag into rich text, and rich text fetches <img src> over the network: a
# notification title, window title, track name or SSID could make the machine call out. Literal text needs nothing.
plain_text() {
  local hits
  hits=$(find sway/.config/sway/panels -name '*.qml' -print0 | xargs -0 awk '
    function code(s) { gsub(/"([^"\\]|\\.)*"/, "\"\"", s); sub(/\/\/.*/, "", s); return s }
    FNR == 1 { depth = 0; open = 0 }
    {
      c = code($0)
      if (!open && match(c, /(^|[^A-Za-z0-9_.])Text[ \t]*\{/)) {
        rest = substr(c, RSTART + RLENGTH)
        if (gsub(/\}/, "}", rest) > gsub(/\{/, "{", rest)) {
          # One-line block: Text { text: "x"; color: ... }
          fmt = $0 ~ /textFormat[ \t]*:/
          lit = $0 ~ /[{;][ \t]*text[ \t]*:[ \t]*"[^"]*"[ \t]*[;}]/
          if (!fmt && !lit) print FILENAME ":" FNR
          next
        }
        open = 1; start = FNR; base = depth; fmt = 0; lit = 0
      } else if (open && depth == base + 1) {
        if ($0 ~ /^[ \t]*textFormat[ \t]*:/) fmt = 1
        if ($0 ~ /^[ \t]*text[ \t]*:/) lit = $0 ~ /^[ \t]*text[ \t]*:[ \t]*"[^"]*"[ \t]*(\/\/.*)?$/
      }
      depth += gsub(/\{/, "{", c) - gsub(/\}/, "}", c)
      if (open && depth <= base) {
        if (!fmt && !lit) print FILENAME ":" start
        open = 0
      }
    }')
  [[ -z $hits ]] && return 0
  echo "Text without textFormat (bound text = textFormat: Text.PlainText, or StyledText for vetted markup):"
  echo "$hits"
  return 1
}

# tmux.conf loads in an isolated server with the pinned tmux: a command or option a new tmux dropped fails here, and
# bin/update runs bin/check right after moving nixpkgs. Plugin run-shell lines skipped (/etc/tmux absent in the sandbox).
tmux_config() {
  local dir rc=0 out
  dir=$(mktemp -d)
  grep -v '^run-shell ' tmux/.config/tmux/tmux.conf >"$dir/tmux.conf"
  out=$(TMUX_TMPDIR=$dir tmux -S "$dir/s" -f /dev/null new-session -d 'sleep 60' \; source-file "$dir/tmux.conf" 2>&1) ||
    rc=1
  [[ -z $out ]] || { echo "$out" && rc=1; }
  tmux -S "$dir/s" kill-server 2>/dev/null
  rm -rf "$dir"
  return "$rc"
}

# Rule and skill frontmatter is valid YAML with its keys: a loader that cannot parse it skips the skill (OpenCode,
# Codex) or loads the rule without its paths (Claude Code).
frontmatter() {
  local f rc=0 fm
  for f in harness/rules/*.md harness/skills/*/SKILL.md; do
    fm=$(awk 'NR == 1 && /^---$/ { on = 1; next } on && /^---$/ { exit } on' "$f")
    if [[ -z $fm ]] || ! yq -e . <<<"$fm" >/dev/null 2>&1; then
      echo "$f: frontmatter missing or not valid YAML" && rc=1
      continue
    fi
    case $f in
      harness/rules/*) yq -e '.description and .paths and .globs' <<<"$fm" >/dev/null 2>&1 ;;
      *) yq -e '.name and .description' <<<"$fm" >/dev/null 2>&1 ;;
    esac || { echo "$f: frontmatter lacks a required key" && rc=1; }
  done
  return "$rc"
}

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

# Lint only: the format step already runs nixfmt (treefmt.nix). hardware.nix = nixos-generate-config output, verbatim.
statix_check() { statix check -i 'nixos/hosts/*/hardware.nix' .; }

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
    # HACK: -C exits 0 on errors inside an included file: the log decides too. Full log only on a crash, it is mostly
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

# Every entry file in panels/ (lock included, in its dry mode) loaded for real by Quickshell in a headless Sway (pixman,
# no GPU, no seat). qmllint follows plain QML import rules; Quickshell does not (it refuses imports outside the entry
# file's dir), so only a real load proves the panel starts. Pass = "Configuration Loaded" in its log; D-Bus and PipeWire
# errors on the way are expected here.
panels_load() {
  local run=$tmp/qsrun qml q sock='' rc=0 sp _
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
  for qml in sway/.config/sway/panels/*.qml; do
    env -i PATH="$PATH" HOME="$tmp/home" XDG_RUNTIME_DIR="$run" WAYLAND_DISPLAY=wayland-1 SWAYSOCK="$sock" \
      QT_QPA_PLATFORM=wayland SWAY_LOCK_DRY=1 quickshell -p "$PWD/$qml" >"$tmp/qs.log" 2>&1 &
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

# TODO: waybar config is plain JSON today. Comments added later: strip the `//` lines first.
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
# name out. A missing pair only warns (a new page lands in one language first). One paragraph = one line in both, so
# a pair holds the same count of non-empty lines: a mismatch fails (heading, paragraph, bullet or row on one side only).
# A sentence edited inside a line is out of reach here: the pre-commit hook warns when one side is staged alone.
doc_pairs() {
  local f pt n_en n_pt rc=0
  for f in README.md docs/*.md harness/*.md; do
    case $f in
      *.pt-br.md)
        [[ -f ${f%.pt-br.md}.md ]] || echo "warning: $f has no English pair"
        continue
        ;;
      README.md) pt=README-pt-br.md ;;
      *) pt=${f%.md}.pt-br.md ;;
    esac
    [[ -f $pt ]] || { echo "warning: $f has no pt-br pair" && continue; }
    n_en=$(grep -cv '^[[:space:]]*$' "$f") n_pt=$(grep -cv '^[[:space:]]*$' "$pt")
    ((n_en == n_pt)) || { echo "$f has $n_en non-empty lines, $pt has $n_pt" && rc=1; }
  done
  return "$rc"
}

# Every `Test:` reference in docs/specs points at something that exists: a bats file holding that exact @test name, or
# a step of this file. A renamed @test would otherwise leave its criterion pointing at nothing.
spec_tests() {
  local ref file name cited rc=0
  cited=$(grep -ohP '`tests/unit/[^`]+\.bats: "[^"]+"`' docs/specs/*.md | tr -d '`' | sort -u)
  while IFS= read -r ref; do
    file=${ref%%: *} name=${ref#*: \"} name=${name%\"}
    # sed: a name holding `$` is written `\$` in the bats source.
    [[ -f $file ]] && sed 's/\\\$/$/g' "$file" | grep -qF "@test \"$name\"" || { echo "missing: $ref" && rc=1; }
  done <<<"$cited"
  # Reverse: a bats file some spec cites = every test in it cited, so a new test gets its criterion. Files no spec
  # cites yet (script not specced) skipped.
  while IFS= read -r file; do
    while IFS= read -r name; do
      grep -qxF "$file: \"$name\"" <<<"$cited" || { echo "uncited: $file: \"$name\"" && rc=1; }
    done < <(sed -n 's/\\\$/$/g; s/^@test "\(.*\)" {.*$/\1/p' "$file")
  done < <(cut -d: -f1 <<<"$cited" | sort -u)
  while IFS= read -r ref; do
    grep -qx "step ${ref#*: } .*" "${BASH_SOURCE[0]}" || { echo "missing: $ref" && rc=1; }
  done < <(grep -ohP '`tests/static\.sh: [a-z-]+`' docs/specs/*.md | tr -d '`')
  # QtTest: each test function runs only through its `qt <fn>;` line in the bats file beside it.
  while IFS= read -r file; do
    while IFS= read -r name; do
      grep -qF "qt $name;" "${file%.qml}.bats" 2>/dev/null || { echo "no bats wrapper: $file: $name" && rc=1; }
    done < <(grep -oP 'function \Ktest_\w+' "$file")
  done < <(grep -rlF 'import QtTest' tests/unit --include='*.qml')
  return "$rc"
}

# Wiring a manual pass per panel would only re-check: every Sway path the bar, the Sway config, the panels (the menu's
# tree in panels/menu/menu.mjs included) and the NixOS config (session start, screen-share portal hooks) run exists; each panel toggle names only its own entry file; a toggle that starts a panel starts a PanelShell one and
# closes it by its exact command line.
sway_paths() {
  local s=sway/.config/sway p f name rc=0
  while IFS= read -r p; do
    [[ -e $s/$p ]] || { echo "missing: $p" && rc=1; }
  done < <(grep -ohP '(\.config/sway|\$dir)/\K[a-z][^ "'"'"';)`$]*' "$s"/config "$s"/config.d/* "$s"/apps/waybar.jsonc \
    "$s"/panels/*.qml "$s"/panels/*/*.qml "$s"/panels/*/*.mjs nixos/*.nix nixos/hosts/*/*.nix |
    sort -u)
  for f in "$s"/panels/*/toggle; do
    name=${f%/toggle} name=${name##*/}
    grep -oP 'panels/\K[a-z-]+(?=\.qml)' "$f" | grep -vqx "$name" && { echo "$f: names another panel" && rc=1; }
    grep -q 'exec quickshell -p' "$f" || continue
    grep -q 'PanelShell {' "$s/panels/$name.qml" || { echo "$s/panels/$name.qml: no PanelShell" && rc=1; }
    # Close by exact command line: a loose pkill -f pattern kills any process whose command line holds it.
    grep -q 'pkill -fx "quickshell -p $qml"' "$f" || { echo "$f: close with pkill -fx \"quickshell -p \$qml\"" && rc=1; }
  done
  return "$rc"
}

# Catppuccin Mocha only: every hex colour the desktop's own files use is one of its 26 (alpha aside), so a typo or a
# colour pasted from elsewhere fails here. QML writes #AARRGGBB, the others RRGGBB[AA]. The alacritty theme is the
# upstream file, left out; 00000000 = fully transparent.
palette() {
  local s=sway/.config/sway rc=0 file line hex
  local mocha='f5e0dc f2cdcd f5c2e7 cba6f7 f38ba8 eba0ac fab387 f9e2af a6e3a1 94e2d5 89dceb 74c7ec 89b4fa b4befe cdd6f4
    bac2de a6adc8 9399b2 7f849c 6c7086 585b70 45475a 313244 1e1e2e 181825 11111b'
  while IFS=: read -r file line hex; do
    hex=${hex,,}
    [[ $hex == 00000000 ]] && continue
    if [[ $file == *.qml ]]; then hex=${hex: -6}; else hex=${hex:0:6}; fi
    [[ " ${mocha//$'\n'/ } " == *" $hex "* ]] || { echo "$file:$line: #$hex is not a Catppuccin Mocha colour" && rc=1; }
  done < <(
    grep -rnoP '"#\K(?:[0-9a-fA-F]{2})?[0-9a-fA-F]{6}(?=")' --include='*.qml' "$s/panels"
    grep -noP '#\K[0-9a-fA-F]{6}(?:[0-9a-fA-F]{2})?\b' "$s/apps/waybar.css" "$s"/config.d/* "$s/bin/float"
    grep -noP '=\K[0-9a-fA-F]{6}(?:[0-9a-fA-F]{2})?$' "$s/apps/fuzzel.ini" "$s/apps/swaylock"
  )
  return "$rc"
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
step statix statix_check
step format format_check
step sway-config sway_config
step tmux-config tmux_config
step qmllint qml_lint
step panels-load panels_load
step json json
step sway-paths sway_paths
step palette palette
step plain-text plain_text
step em-dash em_dash
step doc-pairs doc_pairs
step spec-tests spec_tests
step frontmatter frontmatter
step stow stow_dry
step gitleaks leaks

if ((${#failed[@]})); then
  printf '\nFAILED: %s\n' "${failed[*]}"
  exit 1
fi
printf '\nstatic: all passed\n'
