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

}
