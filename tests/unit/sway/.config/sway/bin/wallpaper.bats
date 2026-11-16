#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  W=$HOME/Pictures/Wallpapers
  mkdir -p "$W/sub"
  touch "$W/a.png" "$W/b.JPG" "$W/sub/c.webp" "$W/notes.txt"
  state=$XDG_STATE_HOME/sway/wallpaper
}

applied() { calls | sed -n 's/^setsid -f swaybg -o \* -i \(.*\) -m fill$/\1/p' | tail -1; }

@test "restore without state: first image, saved" {
  run "$SWAY/bin/wallpaper" restore
  assert_success
  [[ $(applied) == "$W/a.png" ]]
  [[ $(cat "$state") == "$W/a.png" ]]
}

@test "restore with state: that image" {
  mkdir -p "${state%/*}" && echo "$W/sub/c.webp" >"$state"
  run "$SWAY/bin/wallpaper" restore
  [[ $(applied) == "$W/sub/c.webp" ]]
}

@test "next and prev step through the sorted list and wrap" {
  mkdir -p "${state%/*}" && echo "$W/sub/c.webp" >"$state"
  run "$SWAY/bin/wallpaper" next
  [[ $(cat "$state") == "$W/a.png" ]]
  run "$SWAY/bin/wallpaper" next
  [[ $(cat "$state") == "$W/b.JPG" ]]
  run "$SWAY/bin/wallpaper" prev
  run "$SWAY/bin/wallpaper" prev
  [[ $(cat "$state") == "$W/sub/c.webp" ]]
}

@test "next from a state no longer in the folder: first image" {
  mkdir -p "${state%/*}" && echo "$W/gone.png" >"$state"
  run "$SWAY/bin/wallpaper" next
  [[ $(cat "$state") == "$W/a.png" ]]
}

@test "set: missing file fails, state untouched" {
  run "$SWAY/bin/wallpaper" set "$W/nope.png"
  assert_failure
  [[ ! -e $state ]]
  run calls
  refute_output --partial swaybg
}

@test "state honours XDG_STATE_HOME" {
  export XDG_STATE_HOME=$BATS_TEST_TMPDIR/state
  run "$SWAY/bin/wallpaper" set "$W/b.JPG"
  assert_success
  [[ $(cat "$XDG_STATE_HOME/sway/wallpaper") == "$W/b.JPG" ]]
}

@test "state defaults to ~/.local/state" {
  unset XDG_STATE_HOME
  run "$SWAY/bin/wallpaper" set "$W/b.JPG"
  [[ $(cat "$HOME/.local/state/sway/wallpaper") == "$W/b.JPG" ]]
}

@test "no images: next fails" {
  rm -r "$W"
  run "$SWAY/bin/wallpaper" next
  assert_failure
}

@test "no argument: usage, exit 2" {
  run "$SWAY/bin/wallpaper"
  assert_failure 2
  assert_line --partial 'wallpaper restore | next | prev | pick | set FILE'
}
