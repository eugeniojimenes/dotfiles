#!/usr/bin/env bats

# Temp repo with its own tests/manual.md; fake /proc, DMI and /run/current-system. Real git ahead of the stubs, lspci
# and swaymsg stubbed.
setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  mkdir -p "$BATS_TEST_TMPDIR/real"
  ln -s "$(PATH=${PATH#"$REPO/tests/helpers/stubs:"} command -v git)" "$BATS_TEST_TMPDIR/real/git"
  PATH=$BATS_TEST_TMPDIR/real:$PATH
  today=$(date +%F)

  export PROCFS=$BATS_TEST_TMPDIR/proc DMI_SYSFS=$BATS_TEST_TMPDIR/dmi CURRENT_SYSTEM=$BATS_TEST_TMPDIR/system
  mkdir -p "$PROCFS/sys/kernel" "$PROCFS/driver/nvidia" "$DMI_SYSFS" "$CURRENT_SYSTEM"
  echo laptop >"$PROCFS/sys/kernel/hostname"
  echo 6.18.63 >"$PROCFS/sys/kernel/osrelease"
  printf 'processor\t: 0\nmodel name\t: Some CPU i5\n' >"$PROCFS/cpuinfo"
  echo 'NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  595.71.05  Release Build  (nixbld@)' \
    >"$PROCFS/driver/nvidia/version"
  echo LENOVO >"$DMI_SYSFS/sys_vendor"
  echo 'LOQ 15IRH8' >"$DMI_SYSFS/product_version"
  echo 83EU >"$DMI_SYSFS/product_name"
  echo SERIAL-MUST-NOT-SHOW >"$DMI_SYSFS/product_serial"
  echo 26.05.20261113.f1e5c35 >"$CURRENT_SYSTEM/nixos-version"
  stub lspci '00:02.0 "VGA compatible controller" "Intel Corporation" "UHD Graphics" -r0c -p00 "Lenovo" "Device 3c90"
00:1f.3 "Audio device" "Intel Corporation" "HD Audio" -r01 -p80 "Lenovo" "Device 3c90"
01:00.0 "3D controller" "NVIDIA Corporation" "GA107BM [GeForce RTX 3050 6GB Laptop GPU]" -ra1 -p00 "Lenovo" "Device 3c90"'
  stub swaymsg '[{"name":"eDP-1","make":"Chimei","model":"0x1552","serial":"EDID-SERIAL-X","active":true},
{"name":"HDMI-A-1","make":"LG","model":"27UL","serial":"EDID-SERIAL-Y","active":true},
{"name":"DP-5","make":"Off","model":"Screen","serial":"Z","active":false}]'

  r=$BATS_TEST_TMPDIR/repo
  mkdir -p "$r/tests"
  cat >"$r/tests/manual.md" <<'EOF'
# Manual checklist

## laptop (notebook)

| Item | How to check |
| --- | --- |
| Wi-Fi | Connect. |
| Spec lock | Criteria 7 to 10. |

## desktop (two monitors)

| Item | How to check |
| --- | --- |
| Second monitor | Plug it in. |
EOF
  cd "$r" && git init -q
}

@test "dry run: machine once, one table per item with versions, displays without serial, nothing written" {
  run "$REPO/bin/manual-pass" -n --with 'Sony headset' 'Spec lock' Wi-Fi
  assert_success
  assert_output "# Last pass of each tests/manual.md item per machine, written by bin/manual-pass. History: git log -p tests/manual-passes.toml

[laptop]
machine = \"LENOVO LOQ 15IRH8 83EU\"
cpu = \"Some CPU i5\"
gpus = [
  \"Intel Corporation UHD Graphics\",
  \"NVIDIA Corporation GA107BM [GeForce RTX 3050 6GB Laptop GPU]\",
]

[laptop.items.\"Spec lock\"]
date = \"$today\"
nixos = \"26.05.20261113.f1e5c35\"
kernel = \"6.18.63\"
nvidia = \"595.71.05\"
displays = [\"Chimei 0x1552\", \"LG 27UL\"]
with = \"Sony headset\"

[laptop.items.Wi-Fi]
date = \"$today\"
nixos = \"26.05.20261113.f1e5c35\"
kernel = \"6.18.63\"
nvidia = \"595.71.05\"
displays = [\"Chimei 0x1552\", \"LG 27UL\"]
with = \"Sony headset\""
  refute_output --partial SERIAL
  [ ! -e tests/manual-passes.toml ]
}

@test "write: passed item replaced in place, new one added, other items and hosts kept" {
  cat >tests/manual-passes.toml <<'EOF'
# old header

[desktop]
machine = "MSI"

[desktop.items."Second monitor"]
date = "2026-01-01"

[laptop]
machine = "OLD"

[laptop.items.Wi-Fi]
date = "2026-01-01"
kernel = "6.1"

[laptop.items."Old item"]
date = "2026-01-02"
EOF
  run "$REPO/bin/manual-pass" Wi-Fi 'Spec lock'
  assert_success
  assert_output --partial 'tests/manual-passes.toml updated, 2 item(s) on laptop'
  run yq -p toml -o json -I0 '[keys, .laptop.machine, (.laptop.items | keys), .laptop.items["Wi-Fi"].kernel,
    .laptop.items["Spec lock"].date, .laptop.items["Old item"].date, .desktop.items["Second monitor"].date]' \
    tests/manual-passes.toml
  assert_output "[[\"desktop\",\"laptop\"],\"LENOVO LOQ 15IRH8 83EU\",[\"Wi-Fi\",\"Old item\",\"Spec lock\"],\"6.18.63\",\"$today\",\"2026-01-02\",\"2026-01-01\"]"
  run head -1 tests/manual-passes.toml
  assert_output --partial '# Last pass of each tests/manual.md item'
}

@test "quotes and backslashes typed in --with stay valid TOML" {
  run "$REPO/bin/manual-pass" --with 'say "hi" \ there' Wi-Fi
  assert_success
  run yq -p toml -o json '.laptop.items["Wi-Fi"].with' tests/manual-passes.toml
  assert_output '"say \"hi\" \\ there"'
}

@test "item unknown or of another host: refused with this host's items, nothing written" {
  run "$REPO/bin/manual-pass" Wi-Fi 'Second monitor'
  assert_failure
  assert_output --partial 'not an item of laptop'
  assert_line '  Wi-Fi'
  assert_line '  Spec lock'
  refute_line '  Second monitor'
  refute_line '  Item'
  [ ! -e tests/manual-passes.toml ]
}

@test "no NVIDIA, no Sway, DMI placeholders: those fields left out" {
  rm -r "$PROCFS/driver"
  echo 'To Be Filled By O.E.M.' >"$DMI_SYSFS/product_version"
  echo MSI >"$DMI_SYSFS/board_vendor"
  echo 'B550 TOMAHAWK' >"$DMI_SYSFS/board_name"
  rm "$STUBS/swaymsg.out" && stub swaymsg --rc 1
  run "$REPO/bin/manual-pass" -n Wi-Fi
  assert_success
  assert_line 'machine = "LENOVO 83EU"'
  assert_line 'board = "MSI B550 TOMAHAWK"'
  refute_output --partial 'nvidia ='
  refute_output --partial 'displays ='
  refute_output --partial 'with ='
}

@test "no item: usage, exit 2" {
  run "$REPO/bin/manual-pass"
  assert_failure 2
  assert_output --partial 'bin/manual-pass [-n] [--with TEXT]'
}
