# Text from the screen (OCR)

Files: `sway/.config/sway/bin/ocr`, bound to `Super + Print` in `sway/.config/sway/config.d/60-media` and listed under Capture in `sway/.config/sway/bin/menu`. The tesseract package with English and Portuguese data is in `nixos/common.nix`.

## Purpose

Copy text that is only on the screen as pixels: in an image, a video call, a shared screen or a scanned document. The user drags a region, the text read from it lands on the clipboard, and a notification confirms what was read.

## Acceptance criteria

1. The dragged region is captured with grim and read by tesseract in English and Portuguese. The text goes to the clipboard without the blank lines and the form feed around it, and the notification shows its first 200 characters with markup characters escaped. Test: `tests/unit/sway/.config/sway/bin/ocr.bats: "area read: grim's PNG to tesseract (English and Portuguese), text on the clipboard, escaped preview"`
2. Esc while dragging cancels: nothing is captured or copied. Test: `tests/unit/sway/.config/sway/bin/ocr.bats: "Esc in slurp: nothing read, nothing copied"`
3. When no text is found, a notification says so and the clipboard is left as it was. Test: `tests/unit/sway/.config/sway/bin/ocr.bats: "no text found: notification says so, clipboard untouched"`
4. `Super + Print` and Capture › Text from area (OCR) in the menu run it, and text in a real window (a web page, a photo of a document) comes out readable, accents included. Test: manual
