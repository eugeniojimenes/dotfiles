#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  toml=$HOME/.config/alacritty/alacritty.toml
  mkdir -p "${toml%/*}"
  printf '%s\n' '[window]' 'size = 99' '[font]' 'normal = { family = "Mono" }' 'size = 12' '[colors]' 'size = 7' >"$toml"
  # ddcutil: one monitor on bus 7 (HDMI-A-1), brightness 30 of max 60. Any other bus fails like a moved monitor.
  cat >"$STUBS/ddcutil.sh" <<'SH'
case "$1 $3" in
  "detect "*) printf '%s\n' 'Display 1' '   I2C bus:  /dev/i2c-7' '   DRM connector:  card1-HDMI-A-1' ; exit 0 ;;
  "--bus getvcp") [[ $2 == 7 ]] && echo 'VCP 10 C 30 60' && exit 0; exit 1 ;;
esac
SH
}

cache() { echo "$XDG_RUNTIME_DIR/sway-ddc-$1"; }

@test "no argument: usage, exit 2" {
  run "$SWAY/panels/display/ctl"
  assert_failure 2
  assert_line --partial 'ctl brightness get|set OUT [PCT]'
}

@test "state: outputs with the internal flag, text size from alacritty.toml [font]" {
  stub swaymsg '[{"name":"eDP-1","make":"BOE","model":"X","active":true,"focused":true,"scale":1.25,"rect":{}},
                 {"name":"HDMI-A-1","make":"LG","model":"Y","active":true,"focused":false,"scale":1}]'
  run "$SWAY/panels/display/ctl" state
  assert_success
  [[ $(jq -c '[.text, [.outputs[] | [.name, .internal, .scale]]]' <<<"$output") == '[12,[["eDP-1",true,1.25],["HDMI-A-1",false,1]]]' ]]
}

@test "state: no size in [font] means 12" {
  sed -i '/^size = 12/d' "$toml"
  stub swaymsg '[]'
  run "$SWAY/panels/display/ctl" state
  [[ $(jq .text <<<"$output") == 12 ]]
}

@test "brightness get, built-in panel: backlight percent" {
  stub brightnessctl 'intel_backlight,backlight,19200,40%,48000'
  run "$SWAY/panels/display/ctl" brightness get eDP-1
  assert_success
  assert_output 40
}

@test "brightness get, external: DDC bus detected once, then cached" {
  run "$SWAY/panels/display/ctl" brightness get HDMI-A-1
  assert_output 50
  [[ $(cat "$(cache HDMI-A-1)") == 7 ]]
  run "$SWAY/panels/display/ctl" brightness get HDMI-A-1
  assert_output 50
  [[ $(calls | grep -c detect) == 1 ]]
}

@test "brightness get, stale cache: dropped, unavailable, next call detects again" {
  echo 9 >"$(cache HDMI-A-1)"
  run "$SWAY/panels/display/ctl" brightness get HDMI-A-1
  assert_output unavailable
  [[ ! -e $(cache HDMI-A-1) ]]
}

@test "brightness get, monitor without DDC: unavailable" {
  run "$SWAY/panels/display/ctl" brightness get DP-5
  assert_output unavailable
  [[ ! -e $(cache DP-5) ]]
}

@test "brightness set: backlight for the panel, VCP 10 scaled to the monitor's max for DDC" {
  run "$SWAY/panels/display/ctl" brightness set eDP-1 30
  run "$SWAY/panels/display/ctl" brightness set HDMI-A-1 50
  run calls
  assert_line 'brightnessctl -c backlight -q set 30%'
  assert_line 'ddcutil --bus 7 --noverify setvcp 10 30'
}

@test "output names and numbers validated before they reach swaymsg or arithmetic" {
  run "$SWAY/panels/display/ctl" brightness get 'eDP-1;exit'
  assert_failure 2
  assert_output 'bad output name'
  run "$SWAY/panels/display/ctl" brightness set eDP-1 50%
  assert_failure 2
  run "$SWAY/panels/display/ctl" scale 'eDP-1 ; exit' 1
  assert_failure 2
  run "$SWAY/panels/display/ctl" scale eDP-1 1,5
  assert_failure 2
  assert_output 'bad scale'
  run calls
  assert_output ''
}

@test "scale and toggle: one swaymsg output command" {
  run "$SWAY/panels/display/ctl" scale eDP-1 1.5
  assert_success
  run "$SWAY/panels/display/ctl" toggle eDP-1
  run calls
  assert_output $'swaymsg -q output eDP-1 scale 1.5\nswaymsg -q output eDP-1 toggle'
}

@test "text: size inside [font] only, GTK factor quantized to whole points" {
  run "$SWAY/panels/display/ctl" text 14
  assert_success
  run cat "$toml"
  assert_output "$(printf '%s\n' '[window]' 'size = 99' '[font]' 'normal = { family = "Mono" }' 'size = 14' '[colors]' 'size = 7')"
  run calls
  assert_output 'gsettings set org.gnome.desktop.interface text-scaling-factor 1.1818'
}

@test "text: 12 = factor 1.0, the anchor" {
  run "$SWAY/panels/display/ctl" text 12
  run calls
  assert_output 'gsettings set org.gnome.desktop.interface text-scaling-factor 1.0000'
}

@test "brightness without get or set: usage, exit 2" {
  for sub in '' foo; do
    run "$SWAY/panels/display/ctl" brightness $sub eDP-1
    assert_failure 2
    assert_line --partial 'ctl brightness get|set OUT [PCT]'
  done
}

@test "text: outside 9..20 or not a number: exit 2, file untouched" {
  run "$SWAY/panels/display/ctl" text 21
  assert_failure 2
  run "$SWAY/panels/display/ctl" text 8
  assert_failure 2
  run "$SWAY/panels/display/ctl" text big
  assert_failure 2
  grep -qx 'size = 12' "$toml"
}
