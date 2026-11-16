#!/usr/bin/env bats

setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  export DRM_SYSFS=$BATS_TEST_TMPDIR/drm
  echo 'echo "${WLR_DRM_DEVICES-unset}" >"$STUBS/wlr"' >"$STUBS/sway.sh"
}

# card NAME DRIVER: fake /sys/class/drm/NAME bound to DRIVER.
card() {
  mkdir -p "$DRM_SYSFS/$1/device" "$BATS_TEST_TMPDIR/drivers/$2"
  ln -s "$BATS_TEST_TMPDIR/drivers/$2" "$DRM_SYSFS/$1/device/driver"
}

@test "iGPU first when both exist, whatever the card order" {
  card card0 nvidia
  card card1 i915
  mkdir -p "$DRM_SYSFS/card1-eDP-1"
  run "$SWAY/bin/start" -d
  assert_success
  [[ $(cat "$STUBS/wlr") == /dev/dri/card1:/dev/dri/card0 ]]
  run calls
  assert_output 'sway --unsupported-gpu -d'
}

@test "one GPU: nothing exported, wlroots picks" {
  card card0 i915
  run "$SWAY/bin/start"
  assert_success
  [[ $(cat "$STUBS/wlr") == unset ]]
}

@test "NVIDIA alone: nothing exported" {
  card card0 nvidia
  run "$SWAY/bin/start"
  [[ $(cat "$STUBS/wlr") == unset ]]
}
