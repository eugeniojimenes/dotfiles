#!/usr/bin/env bats

# Temp repo with flake.lock, lazy-lock.json and a fake bin/check; fake channel release list served by the curl stub;
# nix, vulnix, nvd, mise, nvim, fwupdmgr stubbed; fake running system with kernel, modules and initrd links.
setup() {
  load "${BATS_TEST_DIRNAME%/tests/unit/*}/tests/helpers/common"
  mkdir -p "$BATS_TEST_TMPDIR/real"
  ln -s "$(PATH=${PATH#"$REPO/tests/helpers/stubs:"} command -v git)" "$BATS_TEST_TMPDIR/real/git"
  PATH=$BATS_TEST_TMPDIR/real:$PATH
  export GIT_CONFIG_GLOBAL=$BATS_TEST_TMPDIR/gitconfig GIT_CONFIG_NOSYSTEM=1
  git config --global user.name t && git config --global user.email t@t

  export PROCFS=$BATS_TEST_TMPDIR/proc NIX_RELEASES_URL=http://releases.test REL=$BATS_TEST_TMPDIR/releases
  mkdir -p "$PROCFS/sys/kernel" && echo laptop >"$PROCFS/sys/kernel/hostname"
  : >"$REL"

  # Running system and the one the build returns: same kernel, modules and initrd unless a test changes one.
  export CURRENT_SYSTEM=$BATS_TEST_TMPDIR/sys/current NEW=$BATS_TEST_TMPDIR/sys/new
  mkdir -p "$BATS_TEST_TMPDIR/sys/k1" "$BATS_TEST_TMPDIR/sys/m1" "$BATS_TEST_TMPDIR/sys/i1" "$CURRENT_SYSTEM" "$NEW"
  for s in "$CURRENT_SYSTEM" "$NEW"; do
    ln -s ../k1 "$s/kernel" && ln -s ../m1 "$s/kernel-modules" && ln -s ../i1 "$s/initrd"
  done

  # Channel release list (S3 listing), each release's upload time and its git-revision.
  cat >"$STUBS/curl.sh" <<'EOF'
url=${!#}
case $url in
  *'?delimiter=/&prefix=nixos/26.05/')
    printf '<ListBucketResult><Prefix>nixos/26.05/</Prefix>'
    while read -r count short days full; do
      printf '<CommonPrefixes><Prefix>nixos/26.05/nixos-26.05.%s.%s/</Prefix></CommonPrefixes>' "$count" "$short"
    done <"$REL"
    printf '</ListBucketResult>\n'
    ;;
  *'?prefix='*git-revision)
    count=${url#*nixos-26.05.} count=${count%%.*}
    days=$(awk -v c="$count" '$1 == c { print $3 }' "$REL")
    printf '<Contents><Key>x</Key><LastModified>%s</LastModified></Contents>\n' \
      "$(date -u -d "-$days days" +%Y-%m-%dT%H:%M:%S.000Z)"
    ;;
  */git-revision)
    count=${url#*nixos-26.05.} count=${count%%.*}
    awk -v c="$count" '$1 == c { printf "%s", $4 }' "$REL"
    ;;
esac
exit 0
EOF
  # nix: drvPath of the locked (now) or overridden (head) system, a real lock edit, the built system.
  cat >"$STUBS/nix.sh" <<'EOF'
case "$*" in
  eval*--override-input*) echo /drv/head ;;
  eval*) echo /drv/now ;;
  'flake lock --override-input nixpkgs github:NixOS/nixpkgs/'*)
    rev=${!#}
    rev=${rev##*/}
    jq --arg rev "$rev" '.nodes.nixpkgs.locked.rev = $rev' flake.lock >flake.lock.new && mv flake.lock.new flake.lock
    ;;
  build*) echo "$NEW" ;;
  'path-info --recursive '*) cat "$BATS_TEST_TMPDIR/closure" ;;
esac
exit 0
EOF
  # vulnix: findings per scanned derivation, from vulnix-now.json / vulnix-head.json; exit 2 = findings.
  # Store paths the running system ships.
  printf '/nix/store/aaa-openssl-3.6.1\n/nix/store/bbb-zlib-1.3.1\n/nix/store/ccc-glibc-2.42-dev\n' >"$BATS_TEST_TMPDIR/closure"
  echo '[]' >"$BATS_TEST_TMPDIR/vulnix-now.json"
  echo '[]' >"$BATS_TEST_TMPDIR/vulnix-head.json"
  # vulnix-<now|head>.fail holding an exit code = that scan fails with it, nothing on stdout.
  cat >"$STUBS/vulnix.sh" <<'EOF'
drv=${!#}
fail=$BATS_TEST_TMPDIR/vulnix-${drv##*/}.fail
[[ -f $fail ]] && exit "$(cat "$fail")"
cat "$BATS_TEST_TMPDIR/vulnix-${drv##*/}.json"
exit 2
EOF
  stub fwupdmgr --rc 2

  r=$BATS_TEST_TMPDIR/repo
  mkdir -p "$r/bin" "$r/lazyvim/.config/nvim"
  # Fake bin/check: exit code from check.rc; check.int = Ctrl-C on the update while it runs.
  printf '#!%s\necho "bin/check $*" >>"$STUBS/calls"\n[[ -f $STUBS/check.int ]] && kill -INT $PPID\nexit "$(cat "$STUBS/check.rc" 2>/dev/null || echo 0)"\n' \
    "$BASH" >"$r/bin/check"
  chmod +x "$r/bin/check"
  echo '{}' >"$r/lazyvim/.config/nvim/lazy-lock.json"
  # The real script through a link: it works on the repo it is found in, this temp one.
  ln -s "$REPO/bin/update" "$r/bin/update"
  cd "$r" && git init -q
  lock rev100
}

# lock REV: flake.lock on nixos-26.05 locked at REV, committed.
lock() {
  jq -n --arg rev "$1" '{nodes: {nixpkgs: {locked: {rev: $rev}, original: {ref: "nixos-26.05"}}}}' >flake.lock
  git add -A && git commit -qm "lock $1"
}
# release COUNT DAYS_OLD: a channel release whose full revision is rev<COUNT>.
release() { echo "$1 ab$1 $2 rev$1" >>"$REL"; }
locked() { jq -r .nodes.nixpkgs.locked.rev flake.lock; }

@test "started outside the repo, as the menu does from ~: works on the repo it lives in" {
  release 100 9
  release 200 3
  cd "$BATS_TEST_TMPDIR"
  run "$r/bin/update"
  assert_success
  [ "$(jq -r .nodes.nixpkgs.locked.rev "$r/flake.lock")" = rev200 ]
}

@test "system: newest channel release at least 2 days old is locked, a younger one waits" {
  release 100 9
  release 200 3
  release 300 1
  run "$r/bin/update"
  assert_success
  [ "$(locked)" = rev200 ]
  run calls
  assert_line 'nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/rev200'
  assert_line 'bin/check '
  assert_line --regexp '^nvd diff .*/sys/current .*/sys/new$'
}

@test "system: a younger release fixing a high CVE skips the wait, the CVE is named" {
  release 200 3
  release 300 1
  echo '[{"pname":"openssl","cvssv3_basescore":{"CVE-2026-1":7.5}}]' >"$BATS_TEST_TMPDIR/vulnix-now.json"
  run "$r/bin/update"
  assert_success
  assert_output --partial 'openssl CVE-2026-1 7.5'
  [ "$(locked)" = rev300 ]
}

@test "system: a lower score, a CVE still present or a build-only package does not skip the wait" {
  release 200 3
  release 300 1
  echo '[{"pname":"zlib","cvssv3_basescore":{"CVE-2026-2":5.0,"CVE-2026-3":9.8}},
    {"pname":"ruby","cvssv3_basescore":{"CVE-2026-4":10.0}}]' >"$BATS_TEST_TMPDIR/vulnix-now.json"
  echo '[{"pname":"zlib","cvssv3_basescore":{"CVE-2026-3":9.8}}]' >"$BATS_TEST_TMPDIR/vulnix-head.json"
  run "$r/bin/update"
  assert_success
  [ "$(locked)" = rev200 ]
}

@test "--now: newest release locked whatever its age" {
  release 200 3
  release 300 0
  run "$r/bin/update" --now
  assert_success
  [ "$(locked)" = rev300 ]
  run calls
  refute_line --partial vulnix
}

@test "system: chosen release already locked, nothing built" {
  lock rev200
  release 200 3
  release 300 1
  run "$r/bin/update"
  assert_success
  assert_output --partial 'up to date: nixos-26.05.200.ab200'
  assert_output --partial 'waits out its 2 days'
  run calls
  refute_line --partial 'nix build'
  refute_line --partial 'nix flake lock'
}

@test "bin/check fails: flake.lock restored, later steps skipped" {
  release 200 3
  echo 1 >"$STUBS/check.rc"
  run "$r/bin/update"
  assert_failure
  assert_output --partial 'bin/check on the new nixpkgs failed'
  assert_output --partial 'flake.lock restored'
  [ "$(locked)" = rev100 ]
  git diff --quiet -- flake.lock
  run calls
  refute_line --partial 'nix build'
  refute_line --partial mise
}

@test "system: a locked release newer than the 2-day pick stays locked, nothing built" {
  lock rev300
  release 200 3
  release 300 1
  release 400 0
  run "$r/bin/update"
  assert_success
  assert_output --partial 'up to date: nixos-26.05.300.ab300'
  [ "$(locked)" = rev300 ]
  run calls
  refute_line --partial 'nix build'
  refute_line --partial 'nix flake lock'
}

@test "system: a failed CVE scan, or one with no findings list, keeps the 2-day wait" {
  release 200 3
  release 300 1
  echo '[{"pname":"openssl","cvssv3_basescore":{"CVE-2026-1":7.5}}]' >"$BATS_TEST_TMPDIR/vulnix-now.json"
  for rc in 1 2 3; do
    echo "$rc" >"$BATS_TEST_TMPDIR/vulnix-head.fail"
    run "$r/bin/update"
    assert_success
    assert_output --partial 'CVE check failed, keeping the 2-day wait'
    refute_output --partial 'no wait'
    [ "$(locked)" = rev200 ]
    git checkout -q -- flake.lock
  done
}

@test "failure after the build: the apply command and the lock commit still shown" {
  release 200 3
  stub mise --rc 1
  run "$r/bin/update"
  assert_failure
  assert_output --partial 'mise upgrade failed'
  assert_output --partial 'system: sudo nixos-rebuild test --flake ~/dotfiles'
  assert_output --partial 'git commit flake.lock'
  [ "$(locked)" = rev200 ]
}

@test "Ctrl-C while the new release is checked: flake.lock restored, nothing else runs" {
  release 200 3
  touch "$STUBS/check.int"
  run "$r/bin/update"
  assert_failure 130
  assert_output --partial 'interrupted'
  assert_output --partial 'flake.lock restored'
  [ "$(locked)" = rev100 ]
  run calls
  refute_line --partial 'nix build'
  refute_line --partial mise
}

@test "kernel or initrd changed: boot and reboot, else test then switch" {
  release 200 3
  run "$r/bin/update"
  assert_output --partial 'system: sudo nixos-rebuild test --flake ~/dotfiles'
  refute_output --partial 'nixos-rebuild boot'

  git checkout -q -- flake.lock
  mkdir -p "$BATS_TEST_TMPDIR/sys/i2" && ln -sfn ../i2 "$NEW/initrd"
  run "$r/bin/update"
  assert_output --partial 'system: sudo nixos-rebuild boot --flake ~/dotfiles, then reboot'
}

@test "other steps: mise, nvim plugins, firmware report" {
  release 100 9
  run "$r/bin/update"
  assert_success
  run calls
  assert_line --index 0 --partial curl
  run bash -c "grep -nE '^(mise|nvim|fwupdmgr) ' '$STUBS/calls' | cut -d: -f2-"
  assert_output "mise upgrade --yes
nvim --headless +Lazy! update +qa
fwupdmgr get-updates"
}

@test "uncommitted lock files: refused before any step" {
  echo '{"x":1}' >lazyvim/.config/nvim/lazy-lock.json
  run "$r/bin/update"
  assert_failure
  assert_output --partial 'uncommitted changes in a lock file'
  assert_output --partial 'lazy-lock.json'
  [ -z "$(calls)" ]
}

@test "summary: changed lock files and their commits" {
  release 200 3
  echo 'echo "{\"plugin\":1}" >lazyvim/.config/nvim/lazy-lock.json' >"$STUBS/nvim.sh"
  run "$r/bin/update"
  assert_success
  assert_output --partial "git commit flake.lock -m 'build(nixos): flake update'"
  assert_output --partial "git commit lazyvim/.config/nvim/lazy-lock.json -m 'build(lazyvim): plugin update'"
}
