# Dotfiles

[![License](https://img.shields.io/badge/License-MIT-lightgray)](/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-lightblue)](/code_of_conduct.pt-br.md)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![en](https://img.shields.io/badge/lang-en-red.svg)](./README.md)
[![love](https://img.shields.io/badge/Build%20With-%F0%9F%96%A4-lightgreen)](https://callmarx.github.io)

Um conjunto curado dos meus arquivos pessoais de configuração (dotfiles) para sistemas baseados em Arch, projetado para ser gerenciado com GNU Stow. Esta configuração atualmente tem como alvo um ambiente baseado em Omarchy, mas a maioria das partes funciona em qualquer instalação Arch.


## Índice
- [Início Rápido](#início-rápido)
- [Customizações do Omarchy](#customizações-do-omarchy)
- [Pacotes necessários para estes dotfiles](#pacotes-necessários-para-estes-dotfiles)
- [Aplicar dotfiles com GNU Stow](#aplicar-dotfiles-com-gnu-stow)
  - [Sobre cada módulo](#sobre-cada-modulo)
  - [Desfazer Stow (remover symlinks)](#desfazer-stow-remover-symlinks)
- [Outras ferramentas e setups](#outras-ferramentas-e-setups)
  - [Lazygit e Lazydocker](#lazygit-e-lazydocker)
  - [Notas Zettelkasten (zk)](#notas-zettelkasten-zk)
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
git clone https://github.com/callmarx/dotfiles.git ~/dotfiles
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
mv ~/.tmux.conf ~/.tmux.conf.bkp 2>/dev/null


# Stow os módulos que você deseja

stow alacritty
stow bash
stow git
stow hypr
stow lazyvim
stow mise
stow mpv
stow tmux
# Perfil isolado do Neovim (opcional)
# stow scratch-nvim
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
1. Neovim (LazyVim): a configuração está em `lazyvim/`. Após aplicar com o Stow:
  ```sh
  # Opcional: limpe todos os plugins/dados locais do Neovim antes da primeira execução
  rm -rf ~/.local/share/nvim/*
  ```

3. Hyprland: configuração em `./hypr/.config`.

4. mpv: configuração em `./mpv/.config/`.

5. tmux: configuração em `./tmux/`.
  Instale tmux e plugins:
  ```sh
  sudo pacman -S tmux
  mkdir -p ~/.tmux/plugins
  # Gerenciador de plugins
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  # Tema (versão fixada)
  git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.tmux/plugins/catppuccin

  # Então faça o stow da configuração do tmux (se ainda não fez)
  cd ~/dotfiles
  stow tmux
  ```

6. mise (gerenciador de versões de ferramentas): configuração em `./mise/.config/mise/`.
  Este setup usa o [mise](https://mise.jdx.dev/getting-started.html) para gerenciar versões de ferramentas.

  - As ferramentas e versões globais estão definidas em ~/dotfiles/mise/.config/mise/config.toml.
  - Como mencionado em [Pacotes necessários para este dotfiles](#pacotes-necessários-para-este-dotfiles), garanta que `mise` e `usage` estejam instalados.

  ```sh
  # Instale as ferramentas declaradas
  mise install
  ```

7. Bash (customizado com Starship): configuração em `./bash/`.
  Eu uso `bash` com o [starship](https://starship.rs/guide/).
  Observação: conforme mencionado em [Pacotes necessários para este dotfiles](#pacotes-necessários-para-este-dotfiles), garanta que `starship` esteja instalado.

8. Git: configuração em `./git/`.
  Configuração geral:
  - habilita saída colorida,
  - define `develop` como branch padrão,
  - utiliza um template de mensagem de commit inspirado em Conventional Commits.

8. (opcional) Scratch Neovim
  Um perfil de Neovim separado e isolado para testes ou demonstrações fica em `scratch-nvim/`.

  Para usar:
  1. use o stow para criar `~/.config/scratch-nvim`:
  ```sh
  cd ~/dotfiles
  stow scratch-nvim
  ```

  2. Use `NVIM_APPNAME` para executá-lo
  ```sh
  NVIM_APPNAME=scratch-nvim nvim
  ```

## Outras ferramentas e setups:

### Lazygit e Lazydocker
Eu uso lazygit e lazydocker para uma interface de terminal simples para git e docker. Essas ferramentas são instaladas por padrão com o Omarchy, mas se você precisar instalá-las manualmente:
```sh
sudo pacman -S lazygit lazydocker
```

Nota: se você mantém uma configuração pessoal do Lazygit, crie um symlink para `~/.config/lazygit/config.yml`. Este repositório não inclui um arquivo de configuração do Lazygit por padrão.

### Notas Zettelkasten (zk)
Eu uso [zk](https://github.com/zk-org/zk) para um sistema de notas no estilo Zettelkasten, frequentemente junto com o Neovim.

Instale:
```sh
sudo pacman -S zk bat
```

Recursos úteis:
- Documentação do diário: https://github.com/mickael-menu/zk/blob/main/docs/daily-journal.md
- Dicas para começar: https://github.com/zk-org/zk/blob/main/docs/tips/getting-started.md
- Vídeo que me ajudou: https://youtu.be/UzhZb7e4l4Y

### Cedilha com layout de teclado dos EUA
Este é meu workaround pessoal para digitar "ç" em um layout de teclado Inglês (EUA, internacional com teclas mortas). Aplique com cautela, pois arquivos do sistema podem ser sobrescritos por atualizações.

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
rm -rf ~/.local/share/nvim/*
```

## Licença
Este projeto está disponível como código aberto sob a licença MIT. Veja [LICENSE](/LICENSE).


## Código de Conduta
Estou comprometido em fornecer um ambiente amigável, seguro e acolhedor para todos. Por favor, leia e respeite o [Código de Conduta](/code_of_conduct.pt-br.md).
