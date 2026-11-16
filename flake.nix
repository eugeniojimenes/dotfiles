{
  description = "NixOS + Sway dotfiles: one system per machine in nixos/hosts/";

  # Stable release branch (new release = edit here). flake.lock pins the revision; `nix flake update` moves it.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    {
      # Attribute name = hostname, so `nixos-rebuild switch --flake ~/dotfiles` picks the right one by itself.
      nixosConfigurations.loc-nixos = nixpkgs.lib.nixosSystem {
        modules = [ ./nixos/hosts/loc-nixos ];
      };
    };
}
