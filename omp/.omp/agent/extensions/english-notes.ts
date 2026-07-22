/**
 * English Notes Logger — omp port of the Claude Code Stop hook.
 *
 * On `session_stop` (main session only — never fires for task/subagent
 * sessions), reads the session branch, finds the last assistant message
 * (scoped to the current turn) containing a `<!-- english-notes -->` block,
 * parses the JSON corrections array, and INSERTs each into the same
 * `~/.claude/english-notes.db` the Claude Code hook uses.
 *
 * Failures are silent and logged to `~/.claude/english-notes.log` — never
 * blocks the session.
 */
import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { Database } from "bun:sqlite";
import { appendFileSync, existsSync, mkdirSync } from "node:fs";
import { basename } from "node:path";

const HOME = process.env.HOME ?? "/home/callmarx";
const DB_PATH = process.env.ENGLISH_NOTES_DB ?? `${HOME}/.claude/english-notes.db`;
const LOG_PATH = `${HOME}/.claude/english-notes.log`;

function log(msg: string): void {
  try {
    appendFileSync(LOG_PATH, `[${new Date().toISOString()}] ${msg}\n`);
  } catch {
    // Never block the session.
  }
}

// ── Session-entry narrowing ──────────────────────────────────────────────
// Entries arrive from the session store (persisted/external data) — narrow
// with `in`/`typeof` guards rather than asserting shapes.

interface MessageEntry {
  type: "message";
  message: { role: string; content: unknown };
}

function isMessageEntry(entry: unknown): entry is MessageEntry {
  if (typeof entry !== "object" || entry === null) return false;
  if (!("type" in entry) || entry.type !== "message") return false;
  if (!("message" in entry)) return false;
  const msg = entry.message;
  return (
    typeof msg === "object" &&
    msg !== null &&
    "role" in msg &&
    typeof msg.role === "string" &&
    "content" in msg
  );
}

function isTextBlock(block: unknown): block is { type: "text"; text: string } {
  return (
    typeof block === "object" &&
    block !== null &&
    "type" in block &&
    block.type === "text" &&
    "text" in block &&
    typeof block.text === "string"
  );
}

function entryText(content: unknown): string {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";
  return content.filter(isTextBlock).map((b) => b.text).join("\n");
}

/** Distinguish a real human prompt from a tool-result entry (both role "user"). */
function isHumanPrompt(msg: MessageEntry["message"]): boolean {
  if (msg.role !== "user") return false;
  const content = msg.content;
  if (!Array.isArray(content) || content.length === 0) return true;
  const first = content[0];
  return !(
    typeof first === "object" &&
    first !== null &&
    "type" in first &&
    first.type === "tool_result"
  );
}

// ── Correction narrowing (parsed JSON — external data) ───────────────────

interface Correction {
  wrong?: unknown;
  correct?: unknown;
  rule_id?: unknown;
  category?: unknown;
  pt_calque?: unknown;
  explanation?: unknown;
}

/** Any non-null object is structurally a `Correction` (all fields optional). */
function isCorrection(note: unknown): note is Correction {
  return typeof note === "object" && note !== null;
}

function strField(c: Correction, key: keyof Correction): string {
  const val = c[key];
  return typeof val === "string" ? val : "";
}

// ── JSON extraction ──────────────────────────────────────────────────────

function extractNotes(text: string): Correction[] | null {
  const match = text.match(/<!-- english-notes\s*\n([\s\S]*?)\n-->/);
  if (!match) return null;
  try {
    const parsed: unknown = JSON.parse(match[1].trim());
    if (!Array.isArray(parsed)) return null;
    return parsed.filter(isCorrection);
  } catch {
    return null;
  }
}

// ── DB schema (idempotent — mirrors init-english-db.sh) ──────────────────

const CORE_SCHEMA = `
PRAGMA journal_mode=WAL;
CREATE TABLE IF NOT EXISTS notes (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  ts          TEXT NOT NULL DEFAULT (datetime('now')),
  session_id  TEXT,
  project     TEXT,
  wrong       TEXT,
  correct     TEXT,
  rule_id     TEXT,
  category    TEXT,
  pt_calque   INTEGER DEFAULT 0,
  explanation TEXT,
  raw         TEXT,
  source      TEXT DEFAULT 'live'
);
CREATE INDEX IF NOT EXISTS idx_notes_rule     ON notes(rule_id);
CREATE INDEX IF NOT EXISTS idx_notes_category ON notes(category);
CREATE INDEX IF NOT EXISTS idx_notes_calque   ON notes(pt_calque);
CREATE INDEX IF NOT EXISTS idx_notes_ts       ON notes(ts);
CREATE INDEX IF NOT EXISTS idx_notes_project  ON notes(project);
`;

// FTS5 + sync trigger — best-effort. If the SQLite build lacks FTS5 the core
// table + inserts still work; only full-text search is lost.
const FTS_SCHEMA = `
CREATE VIRTUAL TABLE IF NOT EXISTS notes_fts USING fts5(
  wrong, correct, explanation, content='notes', content_rowid='id'
);
CREATE TRIGGER IF NOT EXISTS notes_ai AFTER INSERT ON notes BEGIN
  INSERT INTO notes_fts(rowid, wrong, correct, explanation)
  VALUES (new.id, new.wrong, new.correct, new.explanation);
END;
`;

// ── Extension ────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI): void {
  pi.setLabel("English Notes Logger");

  pi.on("session_stop", async (_event, ctx) => {
    try {
      const getBranch = ctx.sessionManager?.getBranch;
      const branch: unknown[] = typeof getBranch === "function" ? getBranch.call(ctx.sessionManager) : [];

      // 1. Find the last real human prompt (not a tool-result entry).
      let lastUserIdx = -1;
      for (let i = 0; i < branch.length; i++) {
        if (isMessageEntry(branch[i]) && isHumanPrompt(branch[i].message)) {
          lastUserIdx = i;
        }
      }

      // 2. Find the last assistant english-notes block after that prompt.
      let corrections: Correction[] | null = null;
      for (let i = branch.length - 1; i > lastUserIdx; i--) {
        const entry = branch[i];
        if (!isMessageEntry(entry) || entry.message.role !== "assistant") continue;
        const text = entryText(entry.message.content);
        if (text.includes("<!-- english-notes")) {
          corrections = extractNotes(text);
          break;
        }
      }

      if (!corrections || corrections.length === 0) return; // No notes this turn — normal.

      // 3. Resolve session id + project.
      let sessionId = "omp";
      const sm = ctx.sessionManager;
      const getFile = sm?.getSessionFile;
      if (typeof getFile === "function") {
        const file = getFile.call(sm);
        if (typeof file === "string") {
          const m = basename(file).match(/_([0-9a-f]+)\.jsonl$/);
          if (m) sessionId = m[1];
        }
      }
      const project = typeof ctx.cwd === "string" && ctx.cwd ? basename(ctx.cwd) : "unknown";

      // 4. Open DB (ensure dir + schema).
      const dir = DB_PATH.slice(0, DB_PATH.lastIndexOf("/"));
      if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
      const db = new Database(DB_PATH);
      db.exec(CORE_SCHEMA);
      try { db.exec(FTS_SCHEMA); } catch { /* FTS5 optional — core still works */ }

      const insert = db.prepare(
        `INSERT INTO notes (session_id, project, wrong, correct, rule_id, category, pt_calque, explanation, raw, source)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'live')`,
      );

      const insertAll = db.transaction((items: Correction[]) => {
        for (const c of items) {
          insert.run(
            sessionId,
            project,
            strField(c, "wrong"),
            strField(c, "correct"),
            strField(c, "rule_id"),
            strField(c, "category"),
            typeof c.pt_calque === "boolean" ? (c.pt_calque ? 1 : 0) : 0,
            strField(c, "explanation"),
            JSON.stringify(c),
          );
        }
      });

      insertAll(corrections);
      db.close();

      log(`inserted=${corrections.length} session=${sessionId} project=${project}`);
    } catch (err) {
      log(`error: ${String(err)}`);
    }
  });
}
