#!/usr/bin/env bash
# Best-effort backfill: scan all Claude Code transcripts under
# ~/.claude/projects/**/*.jsonl, extract free-form "English Notes" sections
# from assistant messages, and INSERT them into the DB with source='backfill'.
#
# Most historical notes pre-date the JSON block contract, so wrong/correct
# come from a regex on the bullet shape. Anything that doesn't parse cleanly
# lands in the `raw` column with rule_id='novel'.
#
# Idempotent-ish: re-running adds duplicate rows. Use --reset to wipe
# previous backfill first.

set -uo pipefail

DB="${ENGLISH_NOTES_DB:-$HOME/.claude/english-notes.db}"
PROJECTS_DIR="$HOME/.claude/projects"

if [[ "${1:-}" == "--reset" ]]; then
  echo "Wiping previous backfill rows..."
  sqlite3 "$DB" "DELETE FROM notes WHERE source='backfill';"
fi

[[ -f "$DB" ]] || "$HOME/.claude/hooks/init-english-db.sh"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# 1. Find transcripts that mention "English Notes".
mapfile -t files < <(grep -rl "English Notes" "$PROJECTS_DIR" --include="*.jsonl" 2>/dev/null || true)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No transcripts with English Notes found."
  exit 0
fi

echo "Scanning ${#files[@]} transcript(s)..."

total_inserted=0

for f in "${files[@]}"; do
  project="$(basename "$(dirname "$f")")"
  session_id="$(basename "$f" .jsonl)"

  # Extract all assistant text from this transcript.
  jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text' \
    "$f" 2>/dev/null > "$tmpdir/text.md" || continue

  # Pull out English Notes blocks (handles #, ##, ###, **bold** headers).
  awk '
    /English [Nn]otes/ && (/^#/ || /^\*\*/) { flag=1; print "===NOTE==="; next }
    flag && /^(#|---$)/                     { flag=0 }
    flag                                    { print }
  ' "$tmpdir/text.md" > "$tmpdir/notes.txt"

  # For each correction bullet matching `*"X"* → **"Y"**` or `"X" → "Y"`,
  # extract wrong/correct and INSERT.
  inserted_this_file=0
  while IFS=$'\t' read -r wrong correct rest; do
    [[ -z "$wrong$correct" ]] && continue

    explanation="$(printf '%s' "$rest" | head -c 500)"
    raw="$wrong → $correct. $rest"

    sqlite3 "$DB" <<SQL >/dev/null 2>&1
INSERT INTO notes (session_id, project, wrong, correct, rule_id, category, pt_calque, explanation, raw, source)
VALUES (
  $(printf "'%s'" "$(printf '%s' "$session_id" | sed "s/'/''/g")"),
  $(printf "'%s'" "$(printf '%s' "$project"    | sed "s/'/''/g")"),
  $(printf "'%s'" "$(printf '%s' "$wrong"      | sed "s/'/''/g")"),
  $(printf "'%s'" "$(printf '%s' "$correct"    | sed "s/'/''/g")"),
  'novel',
  '',
  0,
  $(printf "'%s'" "$(printf '%s' "$explanation" | sed "s/'/''/g")"),
  $(printf "'%s'" "$(printf '%s' "$raw"         | sed "s/'/''/g")"),
  'backfill'
);
SQL
    inserted_this_file=$((inserted_this_file + 1))
  done < <(
    grep -E '→' "$tmpdir/notes.txt" \
      | sed -E '
          # *"X"* → **"Y"**. rest
          s/^[-*][[:space:]]*\*?"([^"]+)"\*?[[:space:]]*→[[:space:]]*\*\*"([^"]+)"\*\*\.?[[:space:]]*(.*)$/\1\t\2\t\3/
          # *"X"* → "Y" rest
          t done
          s/^[-*][[:space:]]*\*?"([^"]+)"\*?[[:space:]]*→[[:space:]]*"([^"]+)".*?\.?[[:space:]]*(.*)$/\1\t\2\t\3/
          t done
          # "X" → "Y" rest
          s/^[-*][[:space:]]*"([^"]+)"[[:space:]]*→[[:space:]]*\*?\*?"([^"]+)"\*?\*?\.?[[:space:]]*(.*)$/\1\t\2\t\3/
          t done
          # No match — drop
          d
          : done
        '
  )

  total_inserted=$((total_inserted + inserted_this_file))
  [[ $inserted_this_file -gt 0 ]] && echo "  $project / $session_id  →  $inserted_this_file rows"
done

echo
echo "Backfill complete. Inserted $total_inserted rows (source='backfill')."
echo "Review with: sqlite3 $DB 'SELECT count(*), source FROM notes GROUP BY source;'"
