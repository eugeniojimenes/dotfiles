# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.


## Basic installation

Install these packages:
```bash
sudo pacman -S wget fd ripgrep xclip
```


For Neorg you need:
```bash
sudo pacman -S luarocks
```
and inside neovim execute:
```vim
:Neorg sync-parsers
```
## Spell Check and cohesion

To write my markdowns I use the ltex-ls LSP but for that you need to install java

```sh
sudo pacman -S openjdk-src
```

## My symbolic links

```sh
ln -s ~/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/lazyvim ~/.config/nvim
```
