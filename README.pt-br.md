# Dotfiles

[![License](https://img.shields.io/badge/License-MIT-lightgray)](/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-lightblue)](/code_of_conduct.pt-br.md)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![en](https://img.shields.io/badge/lang-en-red.svg)](/README.md)
[![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](/README.pt-br.md)
[![love](https://img.shields.io/badge/Build%20With-%F0%9F%96%A4-lightgreen)](https://callmarx.github.io)

Finalmente eu "organizei" isso aqui!

```txt
          888d                888d       ~/dotfile 888d   888d
          888d                888d       888d"     888d   888d
          888d                888d      888d              888d
          888d                888d      888d       888d   888d
    ~/dotfiles   ~/dotfiles  ~/dotfiles ~/dotfiles 888d   888d   ~/dotfiles   ~/dotfiles
   888d"  888d  888d"  "888d  888d      888d       888d   888d  888d   888d   888d
  888d    888d  888d    888d  888d      888d       888d   888d  ~/.dotfiles   ~/dotfiles
   888d"  888d  888d"  "888d  888d"     888d       888d   888d  888d                888d
    ~/dotfiles   ~/dotfiles    888d"    888d       888d   888d   ~/.dotfiles  ~/dotfiles
```

## Git
O arquivo [.gitconfig](./.gitconfig) é bem pessoal e o meu não tem nada demais: habilito as cores
para comandos como o `$ git log`, defino a branch `develop` como a principal e uso um template de
mensagem commit descrito pelo [.gitmessage](./.gitmessage), inspirado no
[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

## Nerd Fonts
Pacote de fontes que utilizo no Tilix e no Neovim. Para instalar ou ver mais sobre acesse:
<https://github.com/ryanoasis/nerd-fonts>.

Para Arch Linux você pode usar este [pacote](https://aur.archlinux.org/packages/nerd-fonts-complete).

Atualmente estou usando o **FireCode Nerd Font Regular** e para Arch Linux é este
[pacote](https://archlinux.org/packages/community/any/ttf-firacode-nerd/).

## Oh My Zsh
Utilizo o *shell* `zsh` com gerenciador [*Oh My Zsh*](https://github.com/ohmyzsh/ohmyzsh). Para
utiliza-lo verifique se vc tem o `zsh` instalado no seu linux com:
```bash
$ zsh --version
```

O arquivo meu [.zshrc](./.zshrc) foi basicamente gerado pelo instalador do *Oh My Zsh*, apenas
incluí alguns plugins à mais. Para instalar execute:
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Uso o tema [Powerlevel10k](https://github.com/romkatv/powerlevel10k#oh-my-zsh) (**precisa do *Nerd
Fonts* instalado!**). Para incluí-lo no seu *Oh My Zsh*, execute:
```bash
$ git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```
E adicione `ZSH_THEME="powerlevel10k/powerlevel10k"` no seu `~/.zshrc` (já consta no que esta neste
repositório).

Para os plugins, instale [rvm](https://rvm.io/) e
[nvm](https://github.com/nvm-sh/nvm#installing-and-updating).

## Terminal Tilix
Para importar as configurações (**precisa do *Nerd Fonts* instalado!**) execute:
```bash
$ dconf dump /com/gexperts/Tilix/ < tilix.dconf
```

## Meu Neovim como IDE
Conjunto de plugins e configurações que utilizo no Neovim. Para organizar (e não deixar com um
único arquivo gigante) eu espalho minhas configurações em outros arquivos como pode ser visto em
[nvim/lua/user](./nvim/lua/user), mantendo o [init.lua](./nvim/init.lua) simples, apenas para
carregar os demais arquivos.

Pacotes que normalmente preciso instalar para obter um "bom" `:checkhealth`:
```sh
sudo pacman -S wget fd ripgrep xclip
npm install -g neovim
gem install neovim rubocop rubocop-packaging rubocop-performance rubocop-rails rubocop-rspec
```

Copie, altere e utilize á vontade. Sugestões e criticas (educadas) são bem vindas 🤓.

**OBS**: Para utilizar os ícones do [vim-devicons](https://github.com/ryanoasis/vim-devicons) é
preciso instalar o [Nerd Fonts](https://www.nerdfonts.com) e habilita-lo no *profile* do seu
terminal ou se for o Tilix pode usar minhas configurações como expliquei antes.

## My Zettelkasten notes
Depois de ler sobre esse método percebi que fiquei completamente desorganizado com minhas anotações
de trabalho e encontrei uma solução incrível para usar esse método com o Neovim graças ao
[Mickaël Menu](https://github.com/mickael-menu). Você pode ler mais sobre isso aqui:
<https://github.com/mickael-menu/zk>.

Esta também é uma boa desculpa para praticar meu inglês escrevendo algum tipo de diário pessoal,
como minha rotina diária, e este assistente de anotações pode ser configurado para esta finalidade
também, conforme descrito em sua documentação:
<https://github.com/ mickael-menu/zk/blob/main/docs/daily-journal.md>.

Isso também é pessoal, eu uso uma coleção de grupos no meu
[arquivo de configuração do zk](./zk/config.toml) que atendem às minhas necessidades, por exemplo.
Eu recomendo fortemente que você assista a este vídeo <https://youtu.be/UzhZb7e4l4Y>, que foi um
bom guia para mim, além da
[documentação do zk](https://github.com/zk-org/zk/blob/main/docs/tips/getting-started.md), é claro.

## Meus *symbolic links*

```sh
ln -s ~/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/zk ~/my-zk/.zk
```

# asdf

```sh
# Ruby
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby 2.7.1
asdf global ruby 2.7.1
# Python
asdf plugin add python
asdf install python 3.10.8
asdf global python 3.10.8
# Nodejs
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs latest
asdf global nodejs latest
# Golang
asdf plugin-add golang https://github.com/kennyp/asdf-golang.git
asdf install golang latest
asdf global golang latest
```

## Limpar instalação do nvim (plugins)
```sh
rm -rf ~/.local/share/nvim/*
```

## Licença
Este *dotfiles* está disponível como código aberto sob o MIT, consulte o arquivo [LICENSE](/LICENSE).

## Código de Conduta
Estou empenhado em fornecer um ambiente amigável, seguro e acolhedor para todos. Por favor, leia e
respeite o [código de conduta](/code_of_conduct.pt-br.md).
