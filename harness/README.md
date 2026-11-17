# Harness

This directory holds instructions for AI coding agents working in this repo. If you do not use an AI agent, you can ignore it, along with `AGENTS.md`, `CLAUDE.md` and the `.claude/`, `.agents/` and `.cursor/` directories at the repo root. Nothing here changes how the dotfiles behave.

`AGENTS.md` at the repo root has the rules every agent needs on every task. This directory adds two kinds of files that only load when they matter:

- `rules/<area>.md`: rules for one part of the repo. Each file declares the paths it applies to in its frontmatter, and a tool that supports this loads the rule only when the agent works on a matching file.
- `skills/<name>/SKILL.md`: step-by-step procedures for recurring tasks, with acceptance criteria and known pitfalls. The agent loads a skill when the task matches its description. A skill may have a `references/` directory with examples.

The rules and skills are written in English, in the compressed style described in `AGENTS.md`. The reasons behind them are in [docs/](../docs/README.md).

## Current rules and skills

| Rule | Applies to |
| --- | --- |
| `rules/nixos.md` | `nixos/**`, `flake.nix`, `flake.lock` |
| `rules/sway.md` | `sway/**` |
| `rules/tests.md` | `tests/**`, `docs/specs/**`, `bin/check` |
| `rules/writing.md` | every `.md` file |

| Skill | Use |
| --- | --- |
| `nixos-change` | Change the system config, build, diff, hand the switch to the owner, verify. |
| `new-host` | Add a machine: host directory, flake entry, Sway outputs, manual checklist. |
| `add-keybinding` | Add a Sway binding with its title and a conflict check. |
| `add-panel` | Add a Quickshell panel following the existing panel pattern. |
| `new-feature` | Ship a feature spec first: criteria, tests, code, docs. |

## Which tool reads what

The files live only in `harness/`. Each tool finds them through symlinks in the directory it already reads.

| Tool | Instructions | Rules | Skills |
| --- | --- | --- | --- |
| Claude Code | `CLAUDE.md`, which imports `AGENTS.md` | `.claude/rules` links to `harness/rules` and reads the `paths:` key | `.claude/skills` links to `harness/skills` |
| Cursor | `AGENTS.md` | `.cursor/rules/<area>.mdc` links to each rule file and reads the `globs:` and `alwaysApply:` keys | reads `.claude/skills` and `.agents/skills` |
| Codex | `AGENTS.md` | none, `AGENTS.md` only | `.agents/skills` links to `harness/skills` |
| OpenCode | `AGENTS.md` | none, `AGENTS.md` only | reads `.claude/skills` and `.agents/skills` |

Notes on the table, checked against each tool's documentation in November 2026:

- Claude Code reads only `paths:` from a rule's frontmatter and ignores the other keys. Cursor reads `description`, `globs` (a comma-separated string) and `alwaysApply`. That is why each rule carries both `paths:` and `globs:` with the same patterns.
- Cursor only loads rule files with the `.mdc` extension, so `.cursor/rules/` holds one `.mdc` link per rule instead of a link to the whole directory. Cursor's documentation does not say whether it follows symlinks in that directory, and Cursor was not installed here to test it.
- Codex has no path-scoped rule files. Its instructions come from `AGENTS.md` files, one per directory. Its own "rules" feature controls which commands may run, which is a different thing.
- OpenCode has no path-scoped rules either. Its `instructions` setting always loads the listed files. It finds skills in `.claude/skills` and `.agents/skills` without any extra link.
- Cursor and OpenCode read both `.claude/skills` and `.agents/skills`, which point at the same files. `opencode debug skill` lists each skill once, from `.agents/skills`. Cursor may list a skill twice.
- Checked here in November 2026: a Claude Code session loads `AGENTS.md` through `CLAUDE.md`, sees the five skills, and loads `rules/sway.md` after reading a file under `sway/`.

## Adding a rule

1. Write `harness/rules/<area>.md` with this frontmatter, listing the same patterns in both keys:
   ```yaml
   ---
   description: <one line>
   paths:
     - "<glob>"
   globs: <glob>, <glob>
   alwaysApply: false
   ---
   ```
2. Link it for Cursor: `ln -s ../../harness/rules/<area>.md .cursor/rules/<area>.mdc`.
3. Add it to the table above and to `README.pt-br.md`.

## Adding a skill

1. Write `harness/skills/<name>/SKILL.md` with `name` and `description` in the frontmatter. The description says what the skill does and when to use it, since that is what the agent matches against. The body has the steps, the acceptance criteria and the pitfalls.
2. No link is needed: the directory links already cover new skills.
3. Add it to the table above and to `README.pt-br.md`.

`git add` the new files before running `bin/check`, which also sweeps them for em dashes.
