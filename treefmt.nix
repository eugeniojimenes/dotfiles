# `nix fmt` formats the whole repo: Nix, shell, Lua, TOML, CSS/JSON/YAML/JS. `bin/check static` (step format) fails
# when it would change a file.
# Shell style comes from .editorconfig. Generated or tool-written files are left alone.
{ pkgs }:
pkgs.treefmt.withConfig {
  settings = {
    tree-root-file = "flake.nix";
    on-unmatched = "debug";

    formatter = {
      nixfmt = {
        command = "${pkgs.nixfmt}/bin/nixfmt";
        includes = [ "*.nix" ];
        # nixos-generate-config output, committed verbatim.
        excludes = [ "nixos/hosts/*/hardware.nix" ];
      };

      # Most scripts have no extension: shfmt -f keeps the paths it sees as shell (shebang or extension).
      shfmt = {
        command = pkgs.writeShellScript "shfmt-detected" ''
          mapfile -t files < <(${pkgs.shfmt}/bin/shfmt -f "$@")
          ((''${#files[@]} == 0)) || exec ${pkgs.shfmt}/bin/shfmt -w "''${files[@]}"
        '';
        includes = [ "*" ];
      };

      stylua = {
        command = "${pkgs.stylua}/bin/stylua";
        options = [
          "--config-path"
          "lazyvim/.config/nvim/stylua.toml"
        ];
        includes = [ "*.lua" ];
      };

      taplo = {
        command = "${pkgs.taplo}/bin/taplo";
        options = [ "format" ];
        includes = [ "*.toml" ];
      };

      # CSS, JSON, YAML, the opencode plugins. Width and indent from .editorconfig. Not the panels' .js files
      # (`.pragma library` is QML, not JS) and not files a tool rewrites (lazy-lock.json, lazyvim.json).
      prettier = {
        command = "${pkgs.prettier}/bin/prettier";
        options = [ "--write" ];
        includes = [
          "*.css"
          "*.json"
          "*.yml"
          "*.mjs"
          "*.tsx"
        ];
        excludes = [
          "lazyvim/.config/nvim/lazy-lock.json"
          "lazyvim/.config/nvim/lazyvim.json"
        ];
      };

      # waybar.jsonc: prettier's JSONC default adds trailing commas, which waybar's parser and `jq` refuse.
      prettier-jsonc = {
        command = "${pkgs.prettier}/bin/prettier";
        options = [
          "--write"
          "--trailing-comma"
          "none"
        ];
        includes = [ "*.jsonc" ];
      };
    };
  };
}
