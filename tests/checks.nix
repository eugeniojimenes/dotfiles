# Flake checks, one per test layer. `self` = the flake source: git-tracked files only.
{ pkgs, self }:
let
  check =
    name: tools: script:
    pkgs.runCommand name { nativeBuildInputs = tools; } ''
      ${script}
      touch $out
    '';
in
{
  # Read-only, straight on the source in the store.
  static = check "static" (with pkgs; [
    shellcheck
    statix
    sway
    tmux
    qt6.qtdeclarative
    quickshell
    jq
    yq-go
    stow
    gitleaks
    self.formatter.x86_64-linux # treefmt.nix: step format
  ]) "cd ${self} && bash tests/static.sh";

  # Writable copy with patched shebangs: the build sandbox has no /usr/bin/env.
  unit =
    check "unit"
      [
        (pkgs.bats.withLibraries (p: [
          p.bats-support
          p.bats-assert
        ]))
        pkgs.jq
        # bin/manual-pass reads tests/manual-passes.toml.
        pkgs.yq-go
        # qmltestrunner: panel logic kept in ES modules (bluetooth/flow.mjs), run offscreen.
        pkgs.qt6.qtdeclarative
        # Hook tests: real git and gitleaks in a temp repo.
        pkgs.git
        pkgs.gitleaks
      ]
      ''
        cp -r ${self} src && chmod -R u+w src && cd src
        patchShebangs . >/dev/null
        bats -r tests/unit
      '';
}
