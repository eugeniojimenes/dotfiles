# tmux

A config é um arquivo só, `tmux/.config/tmux/tmux.conf`.

## Plugins

Os plugins (tmux-sensible e tmux-resurrect) vêm do nixpkgs. O `nixos/common.nix` liga cada um em `/etc/tmux/plugins/`, e o fim do `tmux.conf` roda eles com `run-shell`. As versões ficam presas pelo `flake.lock` e só mudam com uma atualização do sistema. O TPM, usado antes, clonava cada plugin do repositório dele, e o `bin/update` puxava o último commit toda vez, sem espera nenhuma, de repositórios parados havia anos. Um plugin novo entra nos dois lugares.

O build do tmux-resurrect no nixpkgs é de 2022 e ainda salva em `~/.tmux/resurrect` por padrão, então o `tmux.conf` define `@resurrect-dir` como `~/.local/share/tmux/resurrect`, o caminho que as versões mais novas usam.

`~/.config/tmux` precisa ter só o `tmux.conf` para que o stow ligue a pasta inteira em vez do arquivo sozinho. Um link no nível do arquivo já se desconectou do repo uma vez sem ninguém perceber.

## Descrições dos atalhos

Todo atalho leva `-N "descrição"`. Esse texto é o que o `prefix + ?` mostra, via `tmux list-keys -N`. Um atalho adicionado sem `-N` aparece nessa lista como um comando cru do tmux.

## Salvando e restaurando sessões

A persistência vem só do tmux-resurrect, e ele roda à mão: `prefix + Ctrl-s` salva e `prefix + Ctrl-r` restaura. Nada salva num timer.

O tmux-continuum foi removido. Com a restauração automática desligada, o salvamento automático dele era prejudicial: um servidor vazio aberto depois de um reboot sobrescrevia o snapshot que você queria restaurar cinco minutos depois. Não o adicione de volta, e não adicione blocos `%if` que condicionam a config ao servidor em execução. Como nenhum servidor salva sem ser pedido, a ordem em que os servidores iniciam não importa mais.

`@resurrect-processes` está definido como `'false'`. Esse valor é um sentinela verificado por `restore_pane_processes_enabled()`, não uma lista de programas. Uma restauração reconstrói sessões, janelas, layouts, diretórios de trabalho e o conteúdo dos painéis, mas não reabre nenhum programa. Não há como restaurar só alguns programas: a opção soma a uma lista padrão embutida que já contém nvim, vim e htop, e nada remove entradas dela.

Snapshots antigos não precisam de limpeza. O `remove_old_backups()` do resurrect roda a cada salvamento, respeita `@resurrect-delete-backup-after` e sempre mantém os 5 arquivos mais novos.

## Servidores extras

Dois scripts iniciam servidores tmux próprios, e nenhum deles precisa de coordenação com o servidor principal porque nenhum salva sozinho.

- `sway/.config/sway/bin/tmux-launch` (`Super + Alt + Return`) se conecta ao servidor principal quando nenhum cliente está conectado a ele. Senão, abre um servidor independente no socket `iso-<pid>`.
- `sway/.config/sway/bin/sys-tools` (`Super + Shift + T`) roda o btop e o lazydocker no socket `sys-tools`. É um visualizador. Um hook `pane-exited` mata o servidor quando qualquer um dos dois programas sai, e `C-s` e `C-r` ficam sem atalho lá, então ele nunca salva por cima do snapshot principal.

## Quando o tmux 3.8 chegar

O nixpkgs travado traz o tmux 3.7b. Quando o `bin/update` passar para um nixpkgs com tmux 3.8 ou mais novo, o `nvd diff` mostra a versão nova, e o step estático `tmux-config`, que carrega o `tmux.conf` num servidor isolado, falha na hora se algum comando ou opção sumiu. O que mudar ou testar então:

- O `display-popup` não existe mais no 3.8, então o atalho `?` que mostra a lista de atalhos quebra. Painéis flutuantes e modais substituem os popups: `new-pane -O` abre um painel modal, e `-C` fecha com um clique fora.
- O `lazyvim/.config/nvim/lua/config/options.lua` desliga o `termsync` do Neovim dentro do tmux, porque o tmux 3.7 move o cursor durante uma atualização sincronizada e ele pisca linhas abaixo no explorer do Neovim. O tmux 3.8 corrige isso (commit `57a13664cc`), então o bloco pode sair.
- O 3.8 traz atalhos padrão que podem colidir com este config: `C-b g` para mover e redimensionar painéis flutuantes, `C-b T` para o título do painel, `C-b r` para um refresh, e `Tab` e `S-Tab` para o `switch-mode`.
- O 3.8 tem temas claro e escuro embutidos com cores padrão novas, o que pode mudar o visual da barra de status.
- O `switch-mode` é um seletor rápido de janelas e sessões que pode substituir os atalhos `choose-tree` em `w` e `s`.
