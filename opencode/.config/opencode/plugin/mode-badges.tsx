/** @jsxImportSource @opentui/solid */
// mode-badges: bottom statusline badges showing active caveman/ponytail levels.
// Mirrors the Claude Code statusline badges (~/.claude/statusline-command.sh).
// Display-only: reads the flag files the caveman.mjs / ponytail plugins write.
import { createRoot, createSignal } from "solid-js"
import type { TuiPlugin, TuiPluginModule } from "@opencode-ai/plugin/tui"
import fs from "fs"
import os from "os"
import path from "path"

const configHome = process.env.XDG_CONFIG_HOME || path.join(os.homedir(), ".config")

const MODES = [
  { name: "CAVEMAN", file: path.join(configHome, "opencode", ".caveman-active"), color: "#d78700" },
  { name: "PONYTAIL", file: path.join(configHome, "opencode", ".ponytail-active"), color: "#87af5f" },
]

// Absent flag = default-on "full" (both plugins default the same way). "off" hides the badge.
function readMode(file: string): string | null {
  try {
    const mode = fs.readFileSync(file, "utf8").trim().toLowerCase()
    if (mode === "off") return null
    return mode || "full"
  } catch {
    return "full"
  }
}

const tui: TuiPlugin = async (api) => {
  createRoot((dispose) => {
    const [modes, setModes] = createSignal(MODES.map((m) => readMode(m.file)))

    // ponytail: 1s poll of two tiny flag files. No event exists for state written
    // by sibling plugins. Upgrade to fs.watch if this ever shows in profiles.
    const timer = setInterval(() => setModes(MODES.map((m) => readMode(m.file))), 1000)
    api.lifecycle.onDispose(() => { clearInterval(timer); dispose() })

    api.slots.register({
      slots: {
        app_bottom: (ctx) => {
          const badges = MODES.map((m, i) => ({ ...m, mode: modes()[i] })).filter((m) => m.mode)
          if (badges.length === 0) return null
          return (
            <box paddingLeft={1} paddingRight={1} border={["top"]} borderColor={ctx.theme.current.borderSubtle}>
              <text>
                {badges.flatMap((m, i) => {
                  const badge = <span style={{ fg: m.color, bold: true } as never}>[{m.name}:{m.mode!.toUpperCase()}]</span>
                  return i < badges.length - 1 ? [badge, " "] : [badge]
                })}
              </text>
            </box>
          )
        },
      },
    })
  })
}

const plugin: TuiPluginModule & { id: string } = { id: "mode-badges", tui }
export default plugin
