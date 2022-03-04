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


## Terminal Tilix
Para importar as configurações (**precisa do *Nerd Fonts* instalado!**) execute:
```bash
$ dconf dump /com/gexperts/Tilix/ < tilix.dconf
```

## Meu Neovim como IDE
Conjunto de plugins e configurações que utilizo no Neovim. Para organizar (e não deixar o arquivo
principal gigante) eu coloco as configurações e atalhos de cada plugin (ou conjunto de plugins)
em arquivos separados, em [nvim/plugins](./nvim/plugins).

Copie, altere e utilize á vontade. Sugestões e criticas (educadas) são bem vindas 🤓.

**OBS**: Para utilizar os ícones do [vim-devicons](https://github.com/ryanoasis/vim-devicons) é
preciso instalar o [Nerd Fonts](https://www.nerdfonts.com) e habilita-lo no *profile* do seu
terminal ou se for o Tilix pode usar minhas configurações como expliquei antes.

## Licença
Licenciado sob MIT, consulte o arquivo [LICENSE](/LICENSE).

## Código de Conduta
Espera-se que todos que interagem nas bases de código deste projeto - lista de problemas/sugestões,
forum, email etc - sigam o [código de conduta](/code_of_conduct.md).
