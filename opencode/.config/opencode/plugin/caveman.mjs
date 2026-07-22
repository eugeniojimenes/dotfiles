import fs from 'fs';
import os from 'os';
import path from 'path';

const LEVELS = ['lite', 'full', 'ultra', 'wenyan-lite', 'wenyan-full', 'wenyan-ultra', 'off'];
const DEFAULT_MODE = 'full';

const skillPath = process.env.CAVEMAN_SKILL_PATH ||
  path.join(process.env.HOME || os.homedir(), '.agents', 'skills', 'caveman', 'SKILL.md');

const statePath = path.join(
  process.env.XDG_CONFIG_HOME || path.join(os.homedir(), '.config'),
  'opencode',
  '.caveman-active',
);

function readMode() {
  try {
    const m = fs.readFileSync(statePath, 'utf8').trim();
    return LEVELS.includes(m) ? m : DEFAULT_MODE;
  } catch {
    return DEFAULT_MODE;
  }
}

function writeMode(mode) {
  fs.mkdirSync(path.dirname(statePath), { recursive: true });
  fs.writeFileSync(statePath, mode);
}

// ponytail: read SKILL fresh each turn (~5KB); cache only if it ever shows in profiles.
function skillText() {
  try {
    return fs.readFileSync(skillPath, 'utf8');
  } catch {
    return '';
  }
}

const CAVEMAN_COMMAND = {
  description: 'Toggle caveman compression [lite|full|ultra|wenyan-lite|wenyan-full|wenyan-ultra|off]',
  template: '$ARGUMENTS\n\nCaveman mode toggled. Apply the caveman skill at the now-active level to all following responses until the user says "stop caveman" or "normal mode". Confirm the switch in one terse caveman line naming the active level.',
};

export default async () => ({
  config: async (config) => {
    config.command = config.command || {};
    config.command.caveman = CAVEMAN_COMMAND;
  },

  'experimental.chat.system.transform': (_input, output) => {
    const mode = readMode();
    if (mode === 'off') return;
    const text = skillText();
    if (text) output.system.push(`[CAVEMAN ACTIVE LEVEL: ${mode}]\n\n${text}`);
  },

  'command.execute.before': (input) => {
    if (!input || input.command !== 'caveman') return;
    const req = (input.arguments || '').trim().toLowerCase();
    if (!LEVELS.includes(req)) return;
    writeMode(req);
  },
});
