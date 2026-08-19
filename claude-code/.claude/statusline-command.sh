#!/usr/bin/env bash
# Claude Code status line. Mirrors Starship-style prompt info.
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten home directory to ~/
case "$cwd" in
  "$HOME")    short_cwd="~/" ;;
  "$HOME"/*)  short_cwd="~/${cwd#$HOME/}" ;;
  *)          short_cwd="$cwd" ;;
esac

# Git branch (skip optional locks to avoid conflicts)
branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  branch=$(git -C "$cwd" -c core.hooksPath=/dev/null symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Build output
parts=()

# directory + branch
if [ -n "$branch" ]; then
  parts+=("$(printf '\033[34m%s\033[0m \033[32m \033[0m\033[32m%s\033[0m' "$short_cwd" "$branch")")
else
  parts+=("$(printf '\033[34m%s\033[0m' "$short_cwd")")
fi

# model
if [ -n "$model" ]; then
  parts+=("$(printf '\033[33m%s\033[0m' "$model")")
fi

# context usage
if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  if [ "$used_int" -ge 80 ]; then
    color='\033[31m'   # red
  elif [ "$used_int" -ge 50 ]; then
    color='\033[33m'   # yellow
  else
    color='\033[32m'   # green
  fi
  parts+=("$(printf "${color}ctx:%d%%\033[0m" "$used_int")")
fi

# Caveman badge. Always show mode suffix (e.g. [CAVEMAN:FULL]).
caveman_flag="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-active"
if [ -f "$caveman_flag" ] && [ ! -L "$caveman_flag" ]; then
  caveman_mode=$(head -c 64 "$caveman_flag" 2>/dev/null | tr -d '\n\r' | tr '[:upper:]' '[:lower:]')
  caveman_mode=$(printf '%s' "$caveman_mode" | tr -cd 'a-z0-9-')
  case "$caveman_mode" in
    lite|full|ultra|wenyan-lite|wenyan|wenyan-full|wenyan-ultra|commit|review|compress)
      suffix=$(printf '%s' "$caveman_mode" | tr '[:lower:]' '[:upper:]')
      parts+=("$(printf '\033[38;5;172m[CAVEMAN:%s]\033[0m' "$suffix")")
      ;;
  esac
fi

# Ponytail badge. Mirror of caveman block (flag written by ponytail-activate.js).
ponytail_flag="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.ponytail-active"
if [ -f "$ponytail_flag" ] && [ ! -L "$ponytail_flag" ]; then
  ponytail_mode=$(head -c 64 "$ponytail_flag" 2>/dev/null | tr -d '\n\r' | tr '[:upper:]' '[:lower:]')
  ponytail_mode=$(printf '%s' "$ponytail_mode" | tr -cd 'a-z0-9-')
  case "$ponytail_mode" in
    lite|full|ultra)
      suffix=$(printf '%s' "$ponytail_mode" | tr '[:lower:]' '[:upper:]')
      parts+=("$(printf '\033[38;5;108m[PONYTAIL:%s]\033[0m' "$suffix")")
      ;;
  esac
fi

# Join with separator
printf '%s' "${parts[0]}"
for part in "${parts[@]:1}"; do
  printf ' | %s' "$part"
done
printf '\n'
