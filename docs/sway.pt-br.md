# Sway

O desktop inteiro fica numa pasta só, `sway/.config/sway/`, que o stow liga em `~/.config/sway/`. Todo app é iniciado com um caminho explícito para dentro dessa pasta, então os locais padrão `~/.config/<app>` nunca são lidos.

## Estrutura

- `config` define as variáveis, depois roda `include config.d/*` e depois `include hosts/$(hostname)`.
- `config.d/` é a config dividida por assunto em partes numeradas (`10-look`, `20-input`, `30-apps` e assim por diante). Elas carregam em ordem de nome, e as variáveis do `config` precisam vir primeiro.
- `hosts/<hostname>` tem as linhas `output` daquela máquina. Carrega por último para poder sobrescrever as partes compartilhadas, e um arquivo ausente é pulado. Veja [machines.pt-br.md](machines.pt-br.md).
- `bin/` tem os scripts que os atalhos, o waybar e o menu rodam.
- `apps/` tem as configs do waybar, mako, fuzzel, swaylock e wiremix.
- `bluetooth/`, `calendar/`, `display/`, `lock/`, `sound/` e `wifi/` são painéis Quickshell.
- `common/` guarda o que os painéis compartilham: `PanelShell.qml`, `Theme.qml` e `AdvancedLink.qml`.

Um arquivo fica fora dessa pasta: `sway/.config/xdg-desktop-portal-wlr/sway`, a config do seletor de compartilhamento de tela.

`/etc/sway/config.d` não é incluído. O `bin/session-env` importa ele mesmo o ambiente da sessão (`DISPLAY`, `WAYLAND_DISPLAY`, `SWAYSOCK`, `XDG_CURRENT_DESKTOP`) para o systemd e o D-Bus, e depois reinicia o `xdg-desktop-portal` para ele pegar a config de portal do Sway e o compartilhamento de tela funcionar.

## Scripts

Scripts bash começam com `#!/usr/bin/env bash` porque o NixOS não tem `/bin/bash`. Scripts POSIX usam `#!/bin/sh`, que o NixOS oferece. O menu lê arquivos `.desktop` de `XDG_DATA_DIRS` em vez de `/usr/share`, já que o NixOS os guarda no store e nas pastas de profile.

## Títulos dos atalhos

Todo atalho tem um comentário `#: <título>` na linha de cima. O `bin/keybindings` (`Super + K`) lê primeiro o `config` e depois `config.d/*`, e mostra esse título para cada atalho. Um atalho sem título mostra o comando cru. Os atalhos de workspace ganham títulos gerados. Escolher uma linha da lista executa o atalho, então a cola também serve como lançador.

## Ordem das GPUs na inicialização

O greetd roda o `bin/start` (o caminho fica em `nixos/common.nix`). O script define `WLR_DRM_DEVICES` com a GPU integrada primeiro. O wlroots renderiza no primeiro dispositivo dessa lista. Sem isso, ele escolhia a placa NVIDIA, e todo frame da tela embutida, que é ligada à iGPU, atravessava entre as GPUs por cópias na CPU: uso alto de CPU e ventoinha girando. A placa NVIDIA continua na lista, em segundo, porque as portas HDMI e DP são ligadas a ela. Sem ela os monitores externos ficam apagados. Numa máquina com uma GPU só, a ordem não faz nada.

## Retorno da suspensão e monitores externos

O `display/reinit` roda depois de voltar da suspensão. Com o driver proprietário da NVIDIA, o Sway mantém as saídas externas marcadas como ativas depois de uma suspensão enquanto a tela continua preta. Desativar e reativar cada saída externa força um novo modeset. Isso ainda é necessário com o suporte de suspensão da NVIDIA ativado: em 2026-11-12 o monitor externo ficou preto sem o hook.

## Painéis

Os painéis são janelas Quickshell. Cada painel tem um script `toggle` que mata o painel em execução ou inicia um novo, então um clique no ícone dele no waybar ou na entrada do menu abre e fecha o painel. Enquanto um painel está aberto, um scanner ou listener roda; quando ele fecha, nada continua rodando.

Um painel é uma `PanelWindow` transparente de tela cheia na camada overlay, com foco exclusivo do teclado. Esc fecha o painel, e um clique fora do card visível também.

O foco exclusivo do teclado não acompanha a troca de workspace. Trocar de workspace pelo teclado ou por um clique em outra saída deixaria todas as janelas sem entrada até o painel fechar. Por isso cada painel escuta os eventos de workspace do Sway pelo `I3IpcListener` e se fecha quando o foco muda, como faria um popup. O Sway também pula o próprio reposicionamento do mouse enquanto uma layer surface segura o teclado, então quando a troca vai para outra saída o painel move o cursor para o centro do novo workspace antes de sair.

Tudo isso fica uma vez só em `common/PanelShell.qml`, e todo painel, menos a tela de bloqueio, é um `PanelShell` com o seu próprio card. O Quickshell só carrega arquivos do diretório do painel que ele roda, então cada diretório de painel tem um symlink `common` para `../common` e importa `"common"`. Um `import "../common"` simples passa no qmllint mas falha no Quickshell, e por isso o `bin/check static` também inicia cada painel num Sway headless (passo `panels-load`). O `common/Theme.qml` guarda as cores e a fonte, e o `common/AdvancedLink.qml` é o link do rodapé que abre a TUI completa do painel num terminal flutuante. Uma correção no comportamento compartilhado vai ali, e chega a todos os painéis de uma vez.

## Opacidade e tamanho do texto do terminal

A opacidade do Alacritty é definida na hora pelo `bin/opacity`, via `alacritty msg config`. O tamanho do texto é definido pelo `display/ctl`, que edita `alacritty/.config/alacritty/alacritty.toml` no lugar. A edição aparece no `git status`. Faça commit para manter o novo tamanho como padrão, ou faça checkout do arquivo para descartar.
