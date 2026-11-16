{
  description = "NixOS + Sway dotfiles: one system per machine in nixos/hosts/";

  # Stable release branch (new release = edit here). flake.lock pins the revision; `nix flake update` moves it.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      # Attribute name = hostname, so `nixos-rebuild switch --flake ~/dotfiles` picks the right one by itself.
      nixosConfigurations.loc-nixos = nixpkgs.lib.nixosSystem {
        modules = [ ./nixos/hosts/loc-nixos ];
      };

      # Test layers, run by bin/check and CI. `nix flake check` also evaluates every nixosConfigurations toplevel
      # (unknown options, failed assertions) without building it: that is the eval layer, no check of its own.
      checks.x86_64-linux = import ./tests/checks.nix { inherit pkgs self; };

      # Same tools as the checks, for running one by hand: `nix develop`, then e.g. `bats -r tests/unit`.
      devShells.x86_64-linux.default = pkgs.mkShell {
        inputsFrom = builtins.attrValues self.checks.x86_64-linux;
      };

      formatter.x86_64-linux = pkgs.nixfmt-tree.override {
        settings.formatter.nixfmt.excludes = [ "nixos/hosts/*/hardware.nix" ];
      };
    };
}
