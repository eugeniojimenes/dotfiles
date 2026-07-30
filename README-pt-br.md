# Dotfiles

[![License](https://img.shields.io/badge/License-MIT-lightgray)](/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-lightblue)](/code_of_conduct.pt-br.md)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![en](https://img.shields.io/badge/lang-en-red.svg)](./README.md)
[![love](https://img.shields.io/badge/Build%20With-%F0%9F%96%A4-lightgreen)](https://eugeniojimenes.dev)

Um conjunto curado dos meus arquivos pessoais de configuração (dotfiles) para sistemas baseados em Arch, projetado para ser gerenciado com GNU Stow. Esta configuração atualmente tem como alvo um ambiente baseado em Omarchy, mas a maioria das partes funciona em qualquer instalação Arch.


## Índice
- [Início Rápido](#início-rápido)
- [Customizações do Omarchy](#customizações-do-omarchy)
  - [Atualizações do Omarchy escrevem dentro deste repositório](#atualizações-do-omarchy-escrevem-dentro-deste-repositório)
  - [Nota para a atualização ao Omarchy 4](#nota-para-a-atualização-ao-omarchy-4)
- [Pacotes necessários para estes dotfiles](#pacotes-necessários-para-estes-dotfiles)
- [Aplicar dotfiles com GNU Stow](#aplicar-dotfiles-com-gnu-stow)
  - [Sobre cada módulo](#sobre-cada-modulo)
  - [Desfazer Stow (remover symlinks)](#desfazer-stow-remover-symlinks)
- [Outras ferramentas e setups](#outras-ferramentas-e-setups)
  - [Lazygit e Lazydocker](#lazygit-e-lazydocker)
  - [Cedilha com layout de teclado dos EUA](#cedilha-com-layout-de-teclado-dos-eua)
- [Opcional: limpar plugins do Neovim](#opcional-limpar-plugins-do-neovim)
- [Licença](#licença)
- [Código de Conduta](#código-de-conduta)


## Início Rápido
Pré-requisitos:
- Distribuição baseada em Arch (ou Omarchy)
- `git` e `stow` instalados
- `yay` disponível, caso queira instalar pacotes do AUR

```sh
sudo pacman -S --needed git stow
# yay: https://github.com/Jguer/yay
```

Clone e acesse este repositório:
```sh
git clone https://github.com/eugeniojimenes/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

## Customizações do Omarchy
Eu uso Omarchy para preparar a máquina. Veja os documentos oficiais para começar:
- https://omarchy.org/
- https://manuals.omamix.org/2/the-omarchy-manual/50/getting-started

Customizações comuns que faço:

1) Remova apps/pacotes que não utilizo:
```sh
# Exemplo: remover gnome-keyring
omarchy-pkg-remove
# ou diretamente via yay:
yay -Rs gnome-keyring

# Exemplo: remover web apps incluídos (twitter, youtube, etc.)
omarchy-webapp-remove
```

2) Instale alguns pacotes extras:
```sh
# via helper do Omarchy
omarchy-pkg-install
# ou diretamente via yay:
yay -S google-chrome # rocm-smi-lib necessário para o btop ler GPU AMD
```

### Atualizações do Omarchy escrevem dentro deste repositório
Cada módulo aqui é aplicado pelo Stow no nível de *diretório* (`~/.config/hypr` → `~/dotfiles/hypr/.config/hypr`), e o Omarchy distribui mudanças de configuração rodando `sed -i` / `cp` sobre `~/.config/...` nas suas migrações. Essas escritas atravessam o symlink do diretório e caem nos **arquivos reais deste repositório**, então depois de um `omarchy-update` o `git status` pode mostrar mudanças que ninguém aqui fez. Revise o diff e mantenha o que fizer sentido — não descarte por reflexo.

O corolário: nunca aponte um arquivo dentro de um módulo do Stow para um caminho fora do repositório. As migrações do Omarchy são protegidas por `[[ -f ... ]]`, que é falso para um symlink quebrado, então a atualização é ignorada em silêncio e as duas máquinas divergem.

### Nota para a atualização ao Omarchy 4
O Omarchy 4 move o tema ativo de `~/.config/omarchy/current` para `~/.local/state/omarchy/current` (veja os comentários em `/usr/bin/omarchy-nvim-setup`). Estes arquivos fixam o caminho do 3.x e precisam do novo após a atualização:

| Arquivo | Linha |
|---|---|
| `hypr/.config/hypr/hyprland.conf` | `source = ~/.config/omarchy/current/theme/hyprland.conf` |
| `hypr/.config/hypr/hyprlock.conf` | `source = ...`, além de `path = ~/.config/omarchy/current/background` |
| `alacritty/.config/alacritty/alacritty.toml` | `general.import = [...]` |

O `source =` do Hyprland e o `general.import` do Alacritty não conseguem testar dois caminhos, então esses são edição manual. As próprias migrações do Omarchy podem reescrevê-los antes — veja a nota acima. O Neovim não precisa de nada: `lazyvim/.config/nvim/lua/plugins/theme.lua` já tenta os dois caminhos em tempo de execução.

## Pacotes necessários para estes dotfiles
```sh
## Bash customization and local bin (via mise):
sudo pacman -S usage # mise and starship packages is installed by omarchy
```

## Aplicar dotfiles com GNU Stow
O Stow gerencia symlinks deste repositório no seu $HOME. Eu costumo fazer backup de configurações existentes antes.

```sh
cd ~/dotfiles

# Faça backup de quaisquer configurações existentes (opcional, mas recomendado)

mv ~/.config/alacritty ~/.config/alacritty.bkp 2>/dev/null
mv ~/.bashrc ~/.bashrc.bkp 2>/dev/null
mv ~/.bash_profile ~/.bash_profile.bkp 2>/dev/null
mv ~/.config/starship.toml ~/.config/starship.toml.bkp 2>/dev/null
mv ~/.gitconfig ~/.gitconfig.bkp 2>/dev/null
mv ~/.config/hypr ~/.config/hypr.bkp 2>/dev/null
mv ~/.config/nvim ~/.config/nvim.bkp 2>/dev/null
mv ~/.config/mise ~/.config/mise.bkp 2>/dev/null
mv ~/.config/mpv ~/.config/mpv.bkp 2>/dev/null
mv ~/.claude ~/.claude.bkp 2>/dev/null

# Stow os módulos que você deseja
stow alacritty
stow bash
stow claude-code
stow git
stow hypr
stow lazyvim
stow mise
stow mpv
stow rubocop
stow steam
stow tmux
stow omp
stow opencode
```

### Desfazer Stow (remover symlinks)
Se desejar remover os symlinks criados pelo Stow (sem apagar seus arquivos), use `-D`:
```sh
# A partir da raiz do repositório
cd ~/dotfiles
stow -D lazyvim
stow -D hypr
# ...e assim por diante para qualquer módulo que você queira desanexar
```

### Sobre cada módulo:
1. **Alacritty**: configuração em `alacritty/.config/alacritty/`. Customiza fonte (JetBrainsMono Nerd Font), padding, keybindings e importa o tema atual do Omarchy.

2. **Bash** (customizado com Starship): configuração em `bash/`.
  Eu uso `bash` com o [starship](https://starship.rs/guide/).
  Observação: conforme mencionado em [Pacotes necessários para estes dotfiles](#pacotes-necessários-para-estes-dotfiles), garanta que `starship` esteja instalado.

3. **Claude Code**: configuração em `claude-code/.claude/`. Configuração global do Claude Code — inclui `CLAUDE.md` (instruções), skills customizadas (`skills/`) e memória persistente (`memory/`). Faça stow para colocar em `~/.claude/`.

4. **Git**: configuração em `git/`.
  Configuração geral:
  - habilita saída colorida,
  - define `develop` como branch padrão,
  - utiliza um template de mensagem de commit inspirado em Conventional Commits.

5. **Hyprland**: configuração em `hypr/.config/hypr/`.

6. **Neovim (LazyVim)**: configuração em `lazyvim/`. Após aplicar com o Stow:
  ```sh
  # Opcional: limpe todos os plugins/dados locais do Neovim antes da primeira execução
  rm -rf ~/.local/share/nvim
  rm -rf ~/.local/state/nvim
  # Depois de configurar o mise (descrito a seguir):
  gem install neovim # suporte ao ruby no Neovim
  yay -S tree-sitter-cli-git # pacote oficial tree-sitter-cli normalmente está desatualizado
  ```

  **Relação com a configuração do Neovim do Omarchy.** O Omarchy distribui sua própria configuração do LazyVim pelo pacote `omarchy-nvim` (`/usr/share/omarchy-nvim/config/`, replicada em `/etc/skel` para novos usuários). Como este repositório é dono de `~/.config/nvim`, o `omarchy-nvim-setup` não mexe nele. Por isso dois arquivos do Omarchy são **copiados** para cá como arquivos reais, e não como symlinks — apontar para fora do repositório torna a configuração irreproduzível em uma segunda máquina:

  - `lua/plugins/all-omarchy-themes.lua` — pré-carrega todos os colorschemes do Omarchy para que a troca de tema seja instantânea. O Omarchy nunca atualiza esse arquivo depois da instalação, então confira a defasagem de vez em quando:
    ```sh
    diff /usr/share/omarchy-nvim/config/lua/plugins/all-themes.lua \
         ~/dotfiles/lazyvim/.config/nvim/lua/plugins/all-omarchy-themes.lua
    ```
  - `plugin/after/transparency.lua` — remove o fundo dos grupos de destaque. O Omarchy altera esse arquivo no lugar por migrações, então ele pode aparecer no `git status` após uma atualização.

  O `lua/plugins/theme.lua` resolve o tema ativo em tempo de execução em vez de usar symlink, então o mesmo commit funciona no Omarchy 3.x e 4.x. Veja a [nota para a atualização ao Omarchy 4](#nota-para-a-atualização-ao-omarchy-4).

7. **mise** (gerenciador de versões de ferramentas): configuração em `mise/.config/mise/`.
  Este setup usa o [mise](https://mise.jdx.dev/getting-started.html) para gerenciar versões de ferramentas.

  - As ferramentas e versões globais estão definidas em ~/dotfiles/mise/.config/mise/config.toml.
  - Como mencionado em [Pacotes necessários para estes dotfiles](#pacotes-necessários-para-estes-dotfiles), garanta que `mise` e `usage` estejam instalados.

  ```sh
  # Instale as ferramentas declaradas
  mise install
  ```

8. **mpv**: configuração em `mpv/.config/mpv/`.

9. **RuboCop**: configuração em `rubocop/`. Config global do RuboCop (`rubocop/.rubocop.yml` → `~/.rubocop.yml`). Habilita os plugins `rubocop-performance`, `rubocop-rails` e `rubocop-rspec` e alguns cops extras.

10. **Steam**: configuração em `steam/`. Arquivos `.desktop` customizados para Steam e jogos, colocados em `~/.local/share/applications/`.

11. **tmux**: configuração em `tmux/`.
  Instale o tmux e o TPM, depois faça o stow:
  ```sh
  sudo pacman -S tmux
  mkdir -p ~/.config/tmux/plugins
  # Gerenciador de plugins
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

  # Faça o stow da configuração do tmux
  cd ~/dotfiles
  stow tmux
  ```

  **OBS:** Dentro do tmux, instale os plugins (tmux-resurrect, tmux-continuum, etc.) com `prefix + I` (com o meu prefix seria `CTRL+\ + I` ou `CTRL+b + I`)

12. **oh-my-pi (omp)**: configuração em `omp/.omp/`. Config do agente oh-my-pi — uma extensão TUI de mode-badge (`agent/extensions/`). Aplica em `~/.omp/`.

13. **OpenCode**: configuração em `opencode/.config/opencode/`. Config do OpenCode — modelo, plugins (ponytail, caveman), MCP context7 e ajustes da TUI. Aplica em `~/.config/opencode/`.

## Outras ferramentas e setups:

### Lazygit e Lazydocker
Eu uso lazygit e lazydocker para uma interface de terminal simples para git e docker. Essas ferramentas são instaladas por padrão com o Omarchy, mas se você precisar instalá-las manualmente:
```sh
sudo pacman -S lazygit lazydocker
```

Nota: se você mantém uma configuração pessoal do Lazygit, crie um symlink para `~/.config/lazygit/config.yml`. Este repositório não inclui um arquivo de configuração do Lazygit por padrão.

### Cedilha com layout de teclado dos EUA
Este é meu workaround pessoal para digitar "ç" em um layout de teclado Inglês ("*US, international with dead keys*"). Aplique com cautela e atente-se de que arquivos do sistema podem ser sobrescritos em atualizações.

1) Configure seu layout de teclado do sistema para: Inglês (EUA, internacional com teclas mortas).

Para Hyprland, edite `~/.config/hypr/hyprland.conf` ou `~/.config/hypr/input.conf`:
```conf
# Exemplo para layouts de teclado Brasileiro e dos EUA
input {
  kb_layout = br, us
  kb_variant = abnt2,intl
  kb_options = compose:caps,grp:alt_space_toggle
}
```

2) Edite os caches do GTK immodules (os caminhos variam por distro/versões):
```sh
sudo vim /usr/lib/gtk-3.0/3.0.0/immodules.cache
sudo vim /usr/lib/gtk-2.0/2.10.0/immodules.cache
```
Altere a linha:
```
"cedilla" "Cedilla" "gtk20" "/usr/share/locale" "az:ca:co:fr:gv:oc:pt:sq:tr:wa"
```
Para:
```
"cedilla" "Cedilla" "gtk20" "/usr/share/locale" "az:ca:co:fr:gv:oc:pt:sq:tr:wa:en"
```

3) Substitua "ć" por "ç" e "Ć" por "Ç" em `/usr/share/X11/locale/en_US.UTF-8/Compose`:
```sh
sudo cp /usr/share/X11/locale/en_US.UTF-8/Compose /usr/share/X11/locale/en_US.UTF-8/Compose.bak
sed 's/ć/ç/g' < /usr/share/X11/locale/en_US.UTF-8/Compose | sed 's/Ć/Ç/g' > Compose
sudo mv Compose /usr/share/X11/locale/en_US.UTF-8/Compose
```

4) Reinicie o computador.

## Opcional: limpar plugins do Neovim
Se deseja um início limpo no Neovim:
```sh
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
```

## Licença
Este projeto está disponível como código aberto sob a licença MIT. Veja [LICENSE](/LICENSE).


## Código de Conduta
Estou comprometido em fornecer um ambiente amigável, seguro e acolhedor para todos. Por favor, leia e respeite o [Código de Conduta](/code_of_conduct.pt-br.md).
