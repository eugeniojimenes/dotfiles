---
name: update-media
description: Audit and refresh the screenshots and GIFs of this repo's README and docs - find media gone stale since a change, features with no media, broken references - then capture, mask private names, publish to the dotfiles-media repo and update the alt texts in both languages. Use when the owner asks for screenshots, prints, GIFs, media, or after a visible change to the desktop.
---

# update-media

Media files live in the public repo `eugeniojimenes/dotfiles-media` (local clone `~/dotfiles-media`), never in this repo: every version of a binary would stay in this repo's history. This repo keeps only `docs/media.json` (manifest) and the image lines in the docs.

## Targets

- `README.md` + `README-pt-br.md`: one desktop screenshot under the intro, at most one GIF.
- `docs/sway.md` + `docs/sway.pt-br.md`, section "Panels" / "Painéis": one PNG per Quickshell panel (dir under `sway/.config/sway/` with a `toggle`).

## Manifest

`docs/media.json`, one entry per published file:

```json
{
  "file": "bluetooth-panel-2026-11-17.png",
  "used_in": ["docs/sway.md", "docs/sway.pt-br.md"],
  "alt": { "en": "Bluetooth panel: headphones connected with battery level, nearby devices hidden", "pt-br": "Painel de Bluetooth: fone conectado com nível de bateria, aparelhos próximos ocultos" },
  "shows": ["sway/.config/sway/panels/bluetooth/", "sway/.config/sway/apps/waybar.jsonc"],
  "captured": { "commit": "<full 40-char hash>", "date": "2026-11-17" },
  "how": "Bluetooth on, headphones connected. Open with bluetooth/toggle, crop the card on eDP-1."
}
```

Image line in a doc: `![<alt in that doc's language>](<url><file>)`, `url` from the manifest. Caption optional, plain line under it.

## Steps

1. Audit (read-only), report as one table: target, status, reason.
   - Stale: `git merge-base --is-ancestor <captured.commit> HEAD` fails (rebase or squash dropped it) = stale. Else `git log --oneline <captured.commit>..HEAD -- <shows...>` not empty = stale. List the commits: a refactor with no visible change does not need a new capture.
   - Missing: target with no manifest entry (new panel, no README hero yet).
   - Broken: only image lines whose URL starts with the manifest `url` (shields.io badges and other hosts are not ours). `curl -sfI <url><file>` not 200 or not `image/*`; such a line with no manifest entry, or the reverse.
2. Owner picks what to capture. Nothing else happens without that list.
3. Before capture: `git status --porcelain -- <shows...>` must be empty (the manifest records a commit, so the screen must match it). Owner prepares the screen: clean workspace, no work windows, browser, chat or private files; wallpaper owned or CC-licensed (credit it in the media repo README). Hide popups: `~/.config/sway/bin/dnd share-on` (undo: `share-off`); bell turns red, crossed. Shot showing the bar: no mode on, centre opened and closed once first (`~/.config/sway/panels/notifications/toggle` twice) = grey bell, no count.
4. Capture into the scratchpad, never into a repo:
   - Panel: `setsid -f ~/.config/sway/panels/<panel>/toggle`, wait ~1.5 s, `grim -o <output> full.png`, crop the card with `magick full.png -crop WxH+X+Y +repage card.png`. Geometry from that panel's QML card (`y`, `width`, `anchors.*Margin`, `scale` + `transformOrigin`): wifi, bluetooth, sound = right 8 px in, y 34, width 380; display = right 10 px in, y 34, width 300 at `scale: 1.2` from top right; calendar = centred, y 34, `scale: 1.2` from top. Check the crop by reading it. Close with the same toggle (`setsid -f`).
   - Desktop: `grim -o <output> full.png`, then `magick full.png -resize 1600x desktop.png`.
   - GIF: one Bash call, action and recorder together (a background PID does not survive to the next call): `(sleep 1; swaymsg exec '<action>') & timeout -s INT <secs> wf-recorder -o <output> -g "<geom>" -f clip.mp4`. Exit 124 = expected, MP4 finalized. Odd width or height is rounded down: read the real size (`ffprobe -v error -show_entries stream=width,height clip.mp4`) before placing masks. Then
     `ffmpeg -i clip.mp4 -vf "fps=12,scale=800:-1:flags=lanczos,split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=5" -loop 0 out.gif`.
5. Privacy, before anyone else sees the file. Mask = solid fill, not blur (blur keeps word shape and length; a short SSID can be guessed):
   - PNG: `magick in.png -fill '#1e1e2e' -draw 'rectangle X0,Y0 X1,Y1' out.png`, one `-draw` per area.
   - GIF: mask the MP4 before converting, ffmpeg `drawbox=x=X:y=Y:w=W:h=H:color=0x1e1e2e:t=fill`, one per area, for the whole clip. A list that grows while recording (Bluetooth "Nearby" during scan) = mask the whole list area, not the rows of frame 1.
   - Network panel: every network name, connected one too. Icons and lock marks stay.
   - Bluetooth panel: every row under "Nearby". "My devices": check each alias per capture (owner may have renamed one, e.g. a person's name); mask any that names a person.
   - Sound panel: app stream names (`application.name`) can name work apps or media: mask unless clearly generic.
   - Waybar: tray icons (work apps), and tooltips (network shows SSID and IP, Bluetooth shows device alias). Move the cursor off the bar before capture: `swaymsg seat - cursor set <x> <y>` to the screen centre.
   - Terminals: tmux status (`#S` session and window names = repo names), prompt paths, any text. Menu (fuzzel) GIF lists installed apps: check them.
   - Anything else naming a person, a place, a network or work: notifications, window titles.
   - Review: PNG = read the image. GIF = every frame: `ffmpeg -i out.gif -vf fps=2 frame%03d.png`, read each (or `magick montage frame*.png -geometry +2+2 sheet.png`). Nothing legible, then show the owner. Owner approves each file.
6. Size and metadata: `magick in.png -strip -define png:compression-level=9 out.png`. Budget: panel PNG ~250 KB, desktop PNG ~600 KB, GIF 2 MB. Over budget = lower fps, width or length, never skip the mask.
7. Publish: `git -C ~/dotfiles-media` (clone `git@github.com:eugeniojimenes/dotfiles-media.git` if missing). New name per capture, `<target>-<YYYY-MM-DD>.<ext>`: a published file never changes (raw URLs cache ~5 min, and older commits of this repo still point at it). Keep the file it replaces: removing it breaks the images of every older commit of this repo. Commit, push only with owner OK, **before** this repo's push (else the docs point at a missing file). Check the raw URL answers 200 with `image/*`.
8. Update this repo: manifest entry (`captured.commit` = full hash of this repo's HEAD at capture, `git rev-parse HEAD`; today's date), image lines in each doc of the pair with the alt in its language, `bin/check`, commit `docs(media): <targets>`, push with owner OK.
9. Delete the raw captures (`full.png`, `clip.mp4`, frames) from the scratchpad: they hold the unmasked names.

## Alt text

- Says what the image shows and why it is there: "Bluetooth panel: headphones connected with battery level", not "screenshot" or the file name.
- One sentence, no "image of". Mention what is hidden, so a screen reader user knows it is masked.
- `alt.en` in `.md` files, `alt.pt-br` in `.pt-br.md` and `README-pt-br.md`.

## Acceptance

- Every target either ok or captured in this run, as the owner chose.
- Every image line resolves (200, `image/*`), has an alt in its doc's language, and has a manifest entry.
- No legible name of a network, a nearby device, a person or work in any published file or any GIF frame.
- Sizes within budget. Raw captures deleted. `bin/check` passes.

## Pitfalls

- Video (`.mp4`, `.webm`) plays on GitLab but not from a repo file on GitHub. Animated media = GIF.
- Media committed into this repo: stays in history forever. Only `docs/media.json` and image lines belong here.
- `pkill -f '<pattern>'` from a shell whose command line holds the pattern kills the agent shell. Close panels with their toggle; stop wf-recorder with `timeout -s INT`.
- A workspace switch closes every panel (I3IpcListener). Capture on the current workspace.
- `dnd share-on` hides notifications but shows the bell in waybar: in a screenshot, call the daemon directly: `quickshell ipc -p ~/.config/sway/panels/notifications.qml call notifications modeOn screenshare`. A later `dnd` call or a waybar restart during capture brings the bell back.
- The unmasked capture is read by the model to place masks. Keep it in the scratchpad only, delete it after (step 9).
- Squashing the media repo history to drop old versions: force push, owner decides. Old raw URLs then 404, and so do images in older commits of this repo.
