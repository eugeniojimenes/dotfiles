#!/usr/bin/env bash
# Stop hook: parse the <!-- english-notes ... --> HTML comment block from
# the last assistant message in the session transcript and INSERT each
# correction into ~/.claude/english-notes.db.
#
# Hook input (stdin, JSON): { "session_id", "transcript_path", "cwd",
#   "hook_event_name", "stop_hook_active", ... }
#
# Failures are silent — never block the session. Errors written to
# ~/.claude/english-notes.log for debugging.

set -uo pipefail

DB="${ENGLISH_NOTES_DB:-$HOME/.claude/english-notes.db}"
LOG="$HOME/.claude/english-notes.log"

log() { printf '[%s] %s\n' "$(date -Iseconds)" "$*" >> "$LOG"; }

# 1. Read hook payload from stdin.
payload="$(cat)"
[[ -z "$payload" ]] && { log "empty payload"; exit 0; }

transcript_path="$(jq -r '.transcript_path // empty' <<<"$payload")"
session_id="$(jq -r '.session_id // empty' <<<"$payload")"
cwd="$(jq -r '.cwd // empty' <<<"$payload")"
project="$(basename "${cwd:-unknown}")"

[[ -f "$transcript_path" ]] || { log "no transcript at $transcript_path"; exit 0; }

# 2. Get the last assistant text block that contains an english-notes marker,
# scoped to the CURRENT turn only (entries after the last user message).
# Whole-transcript scope re-inserts the previous turn's block whenever a
# follow-up prompt produces no new notes. Trailing sub-agent texts in the
# same turn are still handled because we take `last` within the slice.
last_text="$(
  jq -rs '
    # tool_result entries also have type=="user", so filter on content shape
    # to find the last actual human prompt.
    def is_human_user:
      .type == "user"
      and (.message.content | if type == "string" then true
           else (.[0].type // "") != "tool_result" end);
    (map(is_human_user) | rindex(true)) as $u
    | .[(($u // -1) + 1):]
    | [.[] | select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text | select(test("<!-- english-notes"))] | last // ""
  ' "$transcript_path" 2>/dev/null
)"

[[ -z "$last_text" ]] && exit 0  # No english-notes block this session — normal.

# 3. Extract the JSON inside <!-- english-notes ... -->.
json_block="$(
  printf '%s' "$last_text" \
    | awk '
        /^<!-- english-notes[[:space:]]*$/ { flag=1; next }
        flag && /^-->[[:space:]]*$/        { flag=0; exit }
        flag                               { print }
      '
)"

[[ -z "$json_block" ]] && { exit 0; }  # No notes this turn — normal.

# 4. Validate JSON.
if ! jq -e 'type == "array"' >/dev/null 2>&1 <<<"$json_block"; then
  log "invalid JSON block (session=$session_id)"
  log "block: $json_block"
  exit 0
fi

count="$(jq 'length' <<<"$json_block")"
[[ "$count" == "0" ]] && exit 0  # Empty array — no corrections, nothing to log.

# 5. Ensure DB exists (auto-init on first run).
if [[ ! -f "$DB" ]]; then
  "$HOME/.claude/hooks/init-english-db.sh" >/dev/null 2>&1 || {
    log "init-english-db.sh failed"; exit 0;
  }
fi

# 6. Insert each correction.
inserted=0
while IFS= read -r row; do
  wrong="$(jq -r '.wrong // ""'       <<<"$row")"
  correct="$(jq -r '.correct // ""'   <<<"$row")"
  rule_id="$(jq -r '.rule_id // ""'   <<<"$row")"
  category="$(jq -r '.category // ""' <<<"$row")"
  pt_calque="$(jq -r 'if .pt_calque then 1 else 0 end' <<<"$row")"
  explanation="$(jq -r '.explanation // ""' <<<"$row")"
  raw="$row"

  sqlite3 "$DB" <<SQL
INSERT INTO notes (session_id, project, wrong, correct, rule_id, category, pt_calque, explanation, raw, source)
VALUES (
  $(printf "'%s'" "$(printf '%s' "$session_id" | sed "s/'/''/g")"),
  $(printf "'%s'" "$(printf '%s' "$project"    | sed "s/'/''/g")"),
  $(printf "'%s'" "$(printf '%s' "$wrong"      | sed "s/'/''/g")"),
  $(printf "'%s'" "$(printf '%s' "$correct"    | sed "s/'/''/g")"),
  $(printf "'%s'" "$(printf '%s' "$rule_id"    | sed "s/'/''/g")"),
  $(printf "'%s'" "$(printf '%s' "$category"   | sed "s/'/''/g")"),
  $pt_calque,
  $(printf "'%s'" "$(printf '%s' "$explanation" | sed "s/'/''/g")"),
  $(printf "'%s'" "$(printf '%s' "$raw"        | sed "s/'/''/g")"),
  'live'
);
SQL
  inserted=$((inserted + 1))
done < <(jq -c '.[]' <<<"$json_block")

log "inserted=$inserted session=$session_id project=$project"
exit 0
