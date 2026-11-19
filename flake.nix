{
  description = "NixOS + Sway dotfiles: one system per machine in nixos/hosts/";

  # Stable release branch (new release = edit here). flake.lock pins the revision; `nix flake update` moves it.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  # Recipes only, for packages the stable branch has too old: built against stable, so no second glibc and toolchain in
  # the closure. Only mise now: 26.05 ships 2026.5.12, whose `mise install` errors on a `disable_tools` entry it does
  # not know (fixed in 2026.6.4). Drop with the 26.11 move. bin/update does not move this input:
  # `nix flake update nixpkgs-unstable` does.
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
    }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      # Attribute name = hostname, so `nixos-rebuild switch --flake ~/dotfiles` picks the right one by itself.
      nixosConfigurations.loc-nixos = nixpkgs.lib.nixosSystem {
        modules = [ ./nixos/hosts/loc-nixos ];
        specialArgs = { inherit nixpkgs-unstable; };
      };

      # Test layers, run by bin/check and CI. `nix flake check` also evaluates every nixosConfigurations toplevel
      # (unknown options, failed assertions) without building it: that is the eval layer, no check of its own.
      checks.x86_64-linux = import ./tests/checks.nix { inherit pkgs self; };

      # Same tools as the checks, for running one by hand: `nix develop`, then e.g. `bats -r tests/unit`.
      devShells.x86_64-linux.default = pkgs.mkShell {
        inputsFrom = builtins.attrValues self.checks.x86_64-linux;
      };

      # `nix fmt`: nixfmt, shfmt, stylua, taplo over the repo (treefmt.nix).
      formatter.x86_64-linux = import ./treefmt.nix { inherit pkgs; };
    };
}
