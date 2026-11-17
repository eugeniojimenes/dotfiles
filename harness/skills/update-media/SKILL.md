---
name: update-media
description: Audit and refresh the screenshots and GIFs of this repo's README and docs - find media gone stale since a change, features with no media, broken references - then capture, blur private names, publish to the dotfiles-media repo and update the alt texts in both languages. Use when the owner asks for screenshots, prints, GIFs, media, or after a visible change to the desktop.
---

# update-media

Media files live in the public repo `eugeniojimenes/dotfiles-media` (local clone `~/dotfiles-media`), never in this repo: every version of a binary would stay in this repo's history. This repo keeps only `docs/media.json` (manifest) and the image lines in the docs.

## Targets

- `README.md` + `README-pt-br.md`: one desktop screenshot under the intro, at most one GIF.
- `docs/sway.md` + `docs/sway.pt-br.md`, section "Panels": one PNG per Quickshell panel (dir under `sway/.config/sway/` with a `toggle`).

## Manifest

`docs/media.json`, one entry per published file:

```json
{
  "file": "bluetooth-panel-2026-11-17.png",
  "used_in": ["docs/sway.md", "docs/sway.pt-br.md"],
  "alt": { "en": "Bluetooth panel: headphones connected with battery level, nearby devices blurred", "pt-br": "Painel de Bluetooth: fone conectado com nível de bateria, aparelhos próximos desfocados" },
  "shows": ["sway/.config/sway/bluetooth/", "sway/.config/sway/apps/waybar.jsonc"],
  "captured": { "commit": "8b98c7c", "date": "2026-11-17" },
  "how": "Bluetooth on, headphones connected. Open with bluetooth/toggle, crop the card on eDP-1."
}
```

Image line in a doc: `![<alt in that doc's language>](<url><file>)`, `url` from the manifest. Caption optional, plain line under it.

## Steps

1. Audit (read-only), report as one table: target, status, reason.
   - Stale: `git log --oneline <captured.commit>..HEAD -- <shows...>` not empty. List the commits: a refactor with no visible change does not need a new capture.
   - Missing: target with no manifest entry (new panel, no README hero yet).
   - Broken: `curl -sfI <url><file>` not 200 or not `image/*`; image line in a doc with no manifest entry, or the reverse.
2. Owner picks what to capture. Nothing else happens without that list.
3. Owner prepares the screen: a clean workspace, no work windows, browser, chat or private files; wallpaper chosen. Then hide notifications without the waybar bell: `makoctl dismiss --all; makoctl mode -a screenshare` (undo: `makoctl mode -r screenshare`).
4. Capture into the scratchpad, never into a repo:
   - Panel: `setsid -f ~/.config/sway/<panel>/toggle`, wait ~1.5 s, `grim -o <output> full.png`, crop the card (right edge 8 px in, top at y 34, width 380, height as rendered) with `magick full.png -crop WxH+X+Y +repage`. Close with the same toggle.
   - Desktop: `grim -o <output>`, scale to 1600 px wide.
   - GIF: `wf-recorder -o <output> -g "<geom>" -f clip.mp4 &`, run the action, stop with `kill -INT <pid>` (the PID from `$!`), then
     `ffmpeg -i clip.mp4 -vf "fps=12,scale=800:-1:flags=lanczos,split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=5" -loop 0 out.gif`.
5. Privacy, before anyone else sees the file:
   - Wi-Fi panel: blur every network name, the connected one too. Icons and lock marks stay.
   - Bluetooth panel: blur every row under "Nearby". "My devices" stays (model names, no person).
   - Anything else naming a person, a place, a network or work: notifications, window titles, terminal text.
   - Blur: `magick in.png -region WxH+X+Y -blur 0x8 +region out.png`, one `-region` per area. GIF: blur the same areas in the MP4 with ffmpeg `boxblur` on a `crop`/`overlay` before converting.
   - Open the result (Read the image) and check nothing is legible, then show it to the owner. Owner approves each file.
6. Size and metadata: `magick in.png -strip -define png:compression-level=9 out.png`. Budget: panel PNG ~250 KB, desktop PNG ~600 KB, GIF 2 MB. Over budget = lower fps, width or length, never skip the blur.
7. Publish: `git -C ~/dotfiles-media` (clone `git@github.com:eugeniojimenes/dotfiles-media.git` if missing). New name per capture, `<target>-<YYYY-MM-DD>.<ext>`: GitHub's image proxy caches by URL, so a reused name can keep showing the old image. Remove the file it replaces in the same commit. Commit, then push only with owner OK. Check the raw URL answers 200 with `image/*`.
8. Update this repo: manifest entry (`captured.commit` = this repo's HEAD at capture, today's date), image lines in each doc of the pair with the alt in its language, `bin/check`, commit `docs(media): <targets>`, push with owner OK.

## Alt text

- Says what the image shows and why it is there: "Bluetooth panel: headphones connected with battery level", not "screenshot" or the file name.
- One sentence, no "image of". Mention what is blurred, so a screen reader user knows it is hidden on purpose.
- `alt.en` in `.md` files, `alt.pt-br` in `.pt-br.md` and `README-pt-br.md`.

## Acceptance

- Every target either ok or captured in this run, as the owner chose.
- Every image line resolves (200, `image/*`), has an alt in its doc's language, and has a manifest entry.
- No legible name of a network, a nearby device, a person or work in any published file.
- Sizes within budget. `bin/check` passes.

## Pitfalls

- Video (`.mp4`, `.webm`) plays on GitLab but not from a repo file on GitHub. Animated media = GIF.
- Media committed into this repo: stays in history forever. Only `docs/media.json` and image lines belong here.
- `pkill -f '<pattern>'` from a shell whose command line holds the pattern kills the agent shell. Close panels with their toggle, stop wf-recorder by PID.
- A workspace switch closes every panel (I3IpcListener). Capture on the current workspace.
- `dnd share-on` hides notifications but shows the bell in waybar: in a screenshot, use `makoctl mode` directly.
- Squashing the media repo history to drop old versions: force push, owner decides. Old raw URLs then 404, so only after every doc points at current files.
