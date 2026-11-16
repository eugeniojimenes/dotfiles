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
    nixfmt
    statix
    sway
    qt6.qtdeclarative
    quickshell
    jq
    stow
    gitleaks
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
      ]
      ''
        cp -r ${self} src && chmod -R u+w src && cd src
        patchShebangs . >/dev/null
        bats -r tests/unit
      '';
}
