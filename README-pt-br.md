# Dotfiles

[![License](https://img.shields.io/badge/License-MIT-lightgray)](/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-lightblue)](/code_of_conduct.pt-br.md)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![en](https://img.shields.io/badge/lang-en-red.svg)](./README.md)
[![love](https://img.shields.io/badge/Build%20With-%F0%9F%96%A4-lightgreen)](https://eugeniojimenes.dev)

Meus arquivos pessoais de configuração (dotfiles) para NixOS com o compositor Sway. Configuração do sistema em `nixos/`, tudo dentro de `$HOME` gerenciado com GNU Stow.

## Sumário
- [Início rápido](#início-rápido)
- [Configuração do sistema (NixOS)](#configuração-do-sistema-nixos)
- [Aplicar os dotfiles com GNU Stow](#aplicar-os-dotfiles-com-gnu-stow)
  - [Sobre cada módulo](#sobre-cada-módulo)
- [Verificação](#verificação)
- [Cedilha com teclado US](#cedilha-com-teclado-us)
- [Licença](#licença)
- [Código de Conduta](#código-de-conduta)

## Início rápido
NixOS recém-instalado (instalador gráfico, sem desktop):
```sh
nix-shell -p git --run 'git clone https://github.com/eugeniojimenes/dotfiles.git ~/dotfiles'
```
Depois [Configuração do sistema](#configuração-do-sistema-nixos), depois [Stow](#aplicar-os-dotfiles-com-gnu-stow).

## Configuração do sistema (NixOS)
`nixos/configuration.nix` = pacotes, serviços, Sway, NVIDIA, login. Não é módulo do stow. `/etc/nixos/configuration.nix` importa ele junto com o `hardware-configuration.nix` da máquina:
```sh
echo '{ imports = [ ./hardware-configuration.nix /home/<user>/dotfiles/nixos/configuration.nix ]; }' |
  sudo tee /etc/nixos/configuration.nix
sudo nixos-rebuild boot && reboot
```
No dia a dia:
```sh
sudo nixos-rebuild switch            # depois de editar o configuration.nix
sudo nixos-rebuild switch --upgrade  # atualiza os pacotes pelo canal
sudo nixos-rebuild switch --rollback # volta para a geração anterior
```
Canais, sem flakes, sem home-manager: o estado do sistema fica no `configuration.nix`, a config do usuário nos módulos do stow abaixo. O arquivo é de um notebook (Intel + NVIDIA PRIME); usuário, hostname e endereços PCI das GPUs estão nele, ajuste antes de usar em outra máquina.

## Aplicar os dotfiles com GNU Stow
O Stow cria symlinks do repo para o `$HOME`. Antes, tire do lugar o que um módulo vai substituir (`~/.bashrc` num sistema novo).
```sh
cd ~/dotfiles
stow alacritty bash btop claude-code git lazyvim local-bin mise mpv omp opencode rubocop steam sway tmux
stow -D <módulo>   # remove os symlinks do módulo, os arquivos ficam no repo
```

### Sobre cada módulo:
1. **Alacritty**: `alacritty/.config/alacritty/`. Fonte JetBrainsMono Nerd Font, padding, atalhos, cores Catppuccin Mocha. Opacidade e tamanho do texto mudam na hora pelo menu do Sway e pelo painel de tela.

2. **Bash**: `bash/`. `.bashrc` carrega `~/.config/bash/{env,shell,aliases,init}` e o `inputrc`. Prompt do [starship](https://starship.rs/) (`bash/.config/starship.toml`).

3. **btop**: `btop/.config/btop/`. Tema Catppuccin Mocha, fundo transparente.

4. **Claude Code**: `claude-code/.claude/`. Config global do Claude Code: `CLAUDE.md` (instruções), skills (`skills/`), `statusline-command.sh`. Estado local da máquina (`settings.json`, `settings.local.json`, memória por projeto) fica fora do repo.

5. **Git**: `git/`. Saída colorida, `develop` como branch padrão, template de commit inspirado em Conventional Commits.

6. **Neovim (LazyVim)**: `lazyvim/`. Catppuccin Mocha com fundo transparente. Dentro do tmux ou por SSH, o yank também sai por OSC 52. Começar do zero: `rm -rf ~/.local/share/nvim ~/.local/state/nvim`.

7. **mise** (gerenciador de versões): `mise/.config/mise/`. Node, Python, Ruby, Rust, Go, uv e CLIs de agentes. Binários pré-compilados rodam no NixOS pelo `programs.nix-ld`.
  ```sh
  mise install
  ```

8. **mpv**: `mpv/.config/mpv/`. Interface = [uosc](https://github.com/tomasklaen/uosc), instalada pelo script dela, fora do git. Primeiro `stow mpv`, depois:
  ```sh
  curl -fsSL https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh | bash
  ```
  A uosc se atualiza pelo próprio menu (**Update uosc**). Notas em `mpv/.config/mpv/README.md`.

9. **RuboCop**: `rubocop/`. Config global (`~/.rubocop.yml`) com `rubocop-performance`, `rubocop-rails`, `rubocop-rspec`.

10. **Steam**: `steam/`. Atalhos de jogos em `~/.local/share/applications/`. Jogo na GPU NVIDIA: opção de lançamento `prime-run %command%`.

11. **Sway**: `sway/.config/sway/`. O desktop inteiro num diretório: config, waybar, mako, menu no fuzzel (`Super + Space`), calendário, painel de tela e tela de bloqueio em Quickshell, troca de papel de parede (`~/Pictures/Wallpapers`), capturas de tela, seletor de Wi-Fi, seletor de compartilhamento de tela (`sway/.config/xdg-desktop-portal-wlr/sway`). `Super + K` lista todos os atalhos. O `start` põe a GPU integrada primeiro, e a dedicada só cuida das saídas ligadas nela.

12. **tmux**: `tmux/`. Prefixo `Ctrl + \` (ou `Ctrl + b`), `prefix + ?` lista os atalhos. Gerenciador de plugins fora de `~/.config/tmux`:
  ```sh
  git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm
  ```
  Dentro do tmux, `prefix + I` instala os plugins. Snapshots são manuais: `prefix + Ctrl-s` salva, `prefix + Ctrl-r` restaura sessões, layouts e diretórios (nenhum programa é reaberto). `Super + Alt + Return` entra no servidor principal se ninguém estiver conectado, senão abre um independente. Sessões do Neovim: `<leader>qs`.

13. **oh-my-pi (omp)**: `omp/.omp/`. Config e uma extensão de badge de modo para o agente oh-my-pi.

14. **OpenCode**: `opencode/.config/opencode/`. Modelo, plugins, MCP do context7, config da TUI.

## Verificação
`dotfiles-doctor` confere estado do stow, comandos que vêm do `configuration.nix`, ferramentas do mise, plugins instalados e arquivos locais da máquina. Só lê por padrão e mostra o reparo de cada problema; `--fix` aplica os seguros.
```sh
dotfiles-doctor
dotfiles-doctor --fix
~/dotfiles/local-bin/.local/bin/dotfiles-doctor   # antes de dar stow no local-bin
```
Conflito do stow (arquivo real onde devia haver symlink) nunca é corrigido sozinho: compare com o repo antes.

## Cedilha com teclado US
O US internacional transforma `'` + `c` em ć. Override no fim do `~/.XCompose` (local da máquina, fora do repo):
```sh
cat >>~/.XCompose <<'XC'
include "%L"

# Cedilla on us/intl: dead_acute + c gives ç, not ć. Later definition wins over the system Compose above.
<dead_acute> <c> : "ç" ccedilla
<dead_acute> <C> : "Ç" Ccedilla
XC
```
Reinicie os apps. Conferir: `xkbcli compile-compose | grep '<dead_acute> <c>'` mostra ç. O teclado ABNT2 do notebook tem tecla própria de ç e não precisa disso.

## Licença
Código aberto sob a licença MIT. Veja [LICENSE](/LICENSE). Arquivos de terceiros e suas licenças: [THIRD-PARTY.md](/THIRD-PARTY.md).

## Código de Conduta
Estou comprometido em fornecer um ambiente amigável, seguro e acolhedor para todos. Por favor, leia e respeite o [Código de Conduta](/code_of_conduct.pt-br.md).
