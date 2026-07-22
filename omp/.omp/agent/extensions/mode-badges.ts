/**
 * Caveman/Ponytail mode toggles for omp.
 *
 * Registers `/caveman` and `/ponytail` slash commands that:
 *   - toggle the mode at a given intensity level
 *   - store durable state in the session (survives /tree, /branch, resume)
 *   - inject a steering instruction on the next turn so the model adopts the mode
 *
 * Modes default on at `full`. No statusline badge — the session-start steering
 * message and the per-toggle `notify` popup carry mode state.
 */
import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

interface BadgeState {
  caveman?: string;
  ponytail?: string;
}

interface CustomEntry {
  type: "custom";
  customType: string;
  data: unknown;
}

function isCustomEntry(entry: unknown): entry is CustomEntry {
  return (
    typeof entry === "object" &&
    entry !== null &&
    "type" in entry &&
    entry.type === "custom" &&
    "customType" in entry &&
    typeof entry.customType === "string" &&
    "data" in entry
  );
}

function badgeFromData(data: unknown): BadgeState {
  if (typeof data !== "object" || data === null) return {};
  const state: BadgeState = {};
  if ("caveman" in data && typeof data.caveman === "string") state.caveman = data.caveman;
  if ("ponytail" in data && typeof data.ponytail === "string") state.ponytail = data.ponytail;
  return state;
}

const CAVEMAN_LEVELS = ["lite", "full", "ultra", "wenyan-lite", "wenyan-full", "wenyan-ultra"];
const PONYTAIL_LEVELS = ["lite", "full", "ultra"];
const OFF_WORDS: Record<string, true> = {
  off: true, stop: true, normal: true, end: true, disable: true, exit: true,
};

const CUSTOM_TYPE = "mode-badges";
const DEFAULTS: BadgeState = { caveman: "full", ponytail: "full" };

export default function (pi: ExtensionAPI): void {
  pi.setLabel("Caveman/Ponytail Modes");

  /** Read the latest mode state from the session branch. */
  function readState(ctx: { sessionManager?: { getBranch?: () => unknown[] } }): BadgeState {
    const getBranch = ctx.sessionManager?.getBranch;
    const branch: unknown[] = typeof getBranch === "function" ? getBranch.call(ctx.sessionManager) : [];
    let state: BadgeState = {};
    let sawEntry = false;
    for (const entry of branch) {
      if (isCustomEntry(entry) && entry.customType === CUSTOM_TYPE) {
        state = badgeFromData(entry.data);
        sawEntry = true;
      }
    }
    // Fresh session with no persisted choice → default-on both modes.
    return sawEntry ? state : { ...DEFAULTS };
  }

  /** Re-inject the activation steering for every active mode (survives compaction pruning). */
  function steerActiveModes(state: BadgeState): void {
    for (const mode of ["caveman", "ponytail"] as const) {
      const level = state[mode];
      if (!level) continue;
      const label = mode.toUpperCase();
      pi.sendMessage(
        `${label} mode activated at ${level.toUpperCase()} intensity. Read skill://${mode} and apply it to ALL responses until told "stop ${mode}" or "normal mode".`,
        { deliverAs: "nextTurn" },
      );
    }
  }

  // Re-anchor the model's active modes on a (re)start.
  pi.on("session_start", async (_event, ctx) => {
    steerActiveModes(readState(ctx));
  });

  function makeCommand(mode: "caveman" | "ponytail") {
    const levels = mode === "caveman" ? CAVEMAN_LEVELS : PONYTAIL_LEVELS;
    const label = mode.toUpperCase();

    return async (args: string, ctx: { ui?: { notify?: (m: string, l: string) => void }; sessionManager?: { getBranch?: () => unknown[] }; cwd?: string }) => {
      const level = args.trim().toLowerCase() || "full";

      // Load current state, then apply the toggle.
      let state = readState(ctx);
      const turningOff = OFF_WORDS[level] === true;

      if (!turningOff && !levels.includes(level)) {
        ctx.ui?.notify?.(
          `${label}: unknown level "${level}". Valid: ${levels.join(", ")}, off`,
          "warn",
        );
        return;
      }

      if (turningOff) {
        delete state[mode];
      } else {
        state[mode] = level;
      }

      // Persist state.
      pi.appendEntry(CUSTOM_TYPE, state);

      if (turningOff) {
        ctx.ui?.notify?.(`${label} mode OFF`, "info");
        // Tell the model to revert on its next turn.
        pi.sendMessage(
          `${label} mode deactivated. Return to normal output style.`,
          { deliverAs: "nextTurn" },
        );
      } else {
        ctx.ui?.notify?.(`${label} mode: ${level.toUpperCase()}`, "info");
        // Inject the mode instruction so the model adopts it on the next prompt.
        // References the skill so the model reads the full rules.
        pi.sendMessage(
          `${label} mode activated at ${level.toUpperCase()} intensity. Read skill://${mode} and apply it to ALL responses until told "stop ${mode}" or "normal mode".`,
          { deliverAs: "nextTurn" },
        );
      }
    };
  }

  pi.registerCommand("caveman", {
    description: "Toggle caveman compression [lite|full|ultra|wenyan-*|off]",
    handler: makeCommand("caveman"),
  });

  pi.registerCommand("ponytail", {
    description: "Toggle ponytail lazy mode [lite|full|ultra|off]",
    handler: makeCommand("ponytail"),
  });
}
