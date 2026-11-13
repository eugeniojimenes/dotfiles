# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# Shell setup split by concern under ~/.config/bash: environment, history, aliases, tool hooks, then readline.
for f in env shell aliases init; do
  # shellcheck source=/dev/null
  source ~/.config/bash/$f
done
bind -f ~/.config/bash/inputrc

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
