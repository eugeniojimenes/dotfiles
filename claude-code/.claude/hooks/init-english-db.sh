#!/usr/bin/env bash
# Initialize the SQLite schema for English Notes logging.
# Idempotent: safe to re-run. Never drops data.

set -euo pipefail

DB="${ENGLISH_NOTES_DB:-$HOME/.claude/english-notes.db}"

mkdir -p "$(dirname "$DB")"

sqlite3 "$DB" <<'SQL'
PRAGMA journal_mode=WAL;
PRAGMA foreign_keys=ON;

CREATE TABLE IF NOT EXISTS notes (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  ts            TEXT    NOT NULL DEFAULT (datetime('now')),
  session_id    TEXT,
  project       TEXT,
  wrong         TEXT,
  correct       TEXT,
  rule_id       TEXT,
  category      TEXT,
  pt_calque     INTEGER DEFAULT 0,
  explanation   TEXT,
  raw           TEXT,
  source        TEXT    DEFAULT 'live'
);

CREATE INDEX IF NOT EXISTS idx_notes_rule     ON notes(rule_id);
CREATE INDEX IF NOT EXISTS idx_notes_category ON notes(category);
CREATE INDEX IF NOT EXISTS idx_notes_calque   ON notes(pt_calque);
CREATE INDEX IF NOT EXISTS idx_notes_ts       ON notes(ts);
CREATE INDEX IF NOT EXISTS idx_notes_project  ON notes(project);

CREATE VIRTUAL TABLE IF NOT EXISTS notes_fts USING fts5(
  wrong, correct, explanation,
  content='notes', content_rowid='id'
);

CREATE TRIGGER IF NOT EXISTS notes_ai AFTER INSERT ON notes BEGIN
  INSERT INTO notes_fts(rowid, wrong, correct, explanation)
  VALUES (new.id, new.wrong, new.correct, new.explanation);
END;

CREATE TRIGGER IF NOT EXISTS notes_ad AFTER DELETE ON notes BEGIN
  INSERT INTO notes_fts(notes_fts, rowid, wrong, correct, explanation)
  VALUES ('delete', old.id, old.wrong, old.correct, old.explanation);
END;

CREATE TRIGGER IF NOT EXISTS notes_au AFTER UPDATE ON notes BEGIN
  INSERT INTO notes_fts(notes_fts, rowid, wrong, correct, explanation)
  VALUES ('delete', old.id, old.wrong, old.correct, old.explanation);
  INSERT INTO notes_fts(rowid, wrong, correct, explanation)
  VALUES (new.id, new.wrong, new.correct, new.explanation);
END;
SQL

# Drop legacy unused column on pre-existing DBs (sqlite >= 3.35).
if sqlite3 "$DB" "PRAGMA table_info(notes);" | grep -q '|is_correction|'; then
  sqlite3 "$DB" "ALTER TABLE notes DROP COLUMN is_correction;"
fi

echo "DB ready at $DB"
