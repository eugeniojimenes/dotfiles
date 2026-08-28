# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
# /etc/omarchy.conf is written by omarchy-dev-link. When absent, force the
# package default instead of preserving a stale inherited dev-link value before
# we decide which rc file to source.
if [[ -f /etc/omarchy.conf ]]; then
  source /etc/omarchy.conf
  export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
else
  export OMARCHY_PATH=/usr/share/omarchy
fi
source "$OMARCHY_PATH/default/bash/rc"

# Read the clipboard in nvim, so render-markdown.nvim and treesitter handle what the terminal cannot. Filetype has
# to be stated: extension is the arg name (`.ruby`, `.json`), which detection mostly misses.
# Defaults to markdown, pairs with Claude Code `/copy` and `/copy N`. `md ruby`, `md json` for anything else.
# Piped input works too: `some-command | md`.
# Content lands in a real temp file first, so it survives the quit: path shows in the statusline, `:saveas ~/foo.md`
# moves it out, `:w!` overwrites it (buffer is read-only). Left behind on purpose, systemd-tmpfiles clears $TMPDIR.
md() {
  local f
  f=$(mktemp "${TMPDIR:-/tmp}/md-XXXXXX.${1:-markdown}") || return
  { [[ -t 0 ]] && wl-paste || cat; } >"$f"
  nvim -R -c "set ft=${1:-markdown}" "$f"
}
