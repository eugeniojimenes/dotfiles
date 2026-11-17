# tmux

A config é um arquivo só, `tmux/.config/tmux/tmux.conf`.

## Gerenciador de plugins

O TPM fica em `~/.local/share/tmux/plugins/tpm`, não dentro de `~/.config/tmux`. `~/.config/tmux` precisa ter só o `tmux.conf` para que o stow ligue a pasta inteira em vez do arquivo sozinho. Um link no nível do arquivo já se desconectou do repo uma vez sem ninguém perceber. O caminho é definido por `TMUX_PLUGIN_MANAGER_PATH` no fim do `tmux.conf`. Depois do stow, instale os plugins de dentro do tmux com `prefix + I`.

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
