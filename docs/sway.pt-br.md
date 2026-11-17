# Sway

O desktop inteiro fica numa pasta só, `sway/.config/sway/`, que o stow liga em `~/.config/sway/`. Todo app é iniciado com um caminho explícito para dentro dessa pasta, então os locais padrão `~/.config/<app>` nunca são lidos.

## Estrutura

- `config` define as variáveis, depois roda `include config.d/*` e depois `include hosts/$(hostname)`.
- `config.d/` é a config dividida por assunto em partes numeradas (`10-look`, `20-input`, `30-apps` e assim por diante). Elas carregam em ordem de nome, e as variáveis do `config` precisam vir primeiro.
- `hosts/<hostname>` tem as linhas `output` daquela máquina. Carrega por último para poder sobrescrever as partes compartilhadas, e um arquivo ausente é pulado. Veja [machines.pt-br.md](machines.pt-br.md).
- `bin/` tem os scripts que os atalhos, o waybar e o menu rodam.
- `apps/` tem as configs do waybar, fuzzel, swaylock e wiremix.
- `panels/` guarda os painéis Quickshell e a tela de bloqueio. Cada um tem um arquivo de entrada no topo (`wifi.qml`, `bluetooth.qml`, `sound.qml`, `display.qml`, `calendar.qml`, `lock.qml`) e um diretório com o mesmo nome com os seus scripts e a sua lógica (`toggle`, `flow.mjs`, `display/ctl`, `lock/lock`).
- `panels/common/` guarda o que os painéis compartilham: `PanelShell.qml`, `Theme.qml`, `AdvancedLink.qml` e `Chip.qml`, o botão pequeno usado pelos painéis.

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

## Gravação de tela

O `bin/record` grava uma região (`Ctrl + Print`) ou a tela em foco (`Ctrl + Shift + Print`) num MP4 em `~/Videos`. O menu Capture tem as mesmas duas opções. O vídeo não tem áudio. Enquanto grava, uma caixinha no canto inferior direito mostra o tempo decorrido, e as notificações ficam escondidas, como num compartilhamento de tela. O Sway não tem como deixar uma janela ou notificação fora da captura, então a caixa aparece no vídeo quando a área gravada inclui aquele canto, e uma notificação também apareceria. Apertar a tecla de novo, escolher qualquer entrada de gravação, ou clicar na caixa ou no ícone vermelho da barra para a gravação. O wf-recorder codifica com x264 na CPU. Ele só codifica os quadros que mudaram, então a carga fica baixa, e o notebook não tem driver VA-API instalado para a GPU Intel. A spec é [docs/specs/screen-recording.md](specs/screen-recording.md).

## Notificações

As notificações vêm do `panels/notifications.qml`, um processo Quickshell que assume o serviço de notificações do freedesktop e desenha os popups no canto superior direito do monitor em foco. Ele substituiu o mako para que as notificações possam ser guardadas com hora e ações para uma central de notificações. Diferente dos outros painéis, ele fica sempre rodando: o `config.d/90-autostart` o inicia pelo `panels/notifications/run`, que o inicia de novo se ele cair. O mako não está mais instalado, porque o arquivo de serviço D-Bus dele deixaria o D-Bus iniciá-lo sempre que o daemon do Quickshell estivesse fora, e os dois disputariam o mesmo nome de serviço.

Clique esquerdo executa a ação padrão da notificação, clique direito a dispensa, e as outras ações aparecem como botões. Um popup fica 5 segundos, a não ser que quem enviou peça outro tempo, e um crítico fica até receber um clique. Popups que chegam juntos formam um baralho: o mais novo na frente e os mais antigos atrás, com a borda de cima aparecendo, então dá para ver quantos são e a cor das bordas sem ocupar toda a lateral direita da tela. Com o ponteiro sobre o baralho ele se abre em lista, e nada some até o ponteiro sair. Não perturbe, compartilhamento da tela inteira e gravação de tela ligam cada um um modo que esconde os popups. São modos separados, então terminar um compartilhamento nunca desliga um Não perturbe ligado à mão. Durante um compartilhamento ou uma gravação, um card ocupa o lugar dos popups e diz só quantas notificações chegaram e por que estão escondidas, sem nome de app nem texto, para você saber que algo chegou sem mostrar o quê. Uma crítica mantém o card na tela com borda vermelha até receber um clique. O Não perturbe não mostra nada. Navegadores Chromium como o Brave já escondem as próprias notificações web enquanto compartilham a tela, mas as notificações de outros apps, como o app do Slack, apareciam. O `bin/dnd` troca os modos pelo IPC do Quickshell, e os modos ligados ficam salvos em `$XDG_RUNTIME_DIR`, então sobrevivem a um reinício do daemon.

O sino na barra fica cinza quando está tudo quieto, azul com o número de notificações que chegaram desde a última vez que a central foi aberta, amarelo no Não perturbe e vermelho enquanto um compartilhamento ou gravação esconde os popups. Um clique nele, `Super + Ctrl + ,` ou Notifications no menu abre a central de notificações: todas as notificações da sessão, da mais nova para a mais antiga, com hora e ações. Um clique numa entrada executa a ação padrão, o x a dispensa e Clear dispensa todas. A central também tem o botão do Não perturbe, e um clique do meio no sino faz o mesmo. A central vive dentro do daemon, porque só ele guarda as notificações e ainda consegue executar as ações delas. Ela usa o mesmo `PanelShell` dos outros painéis com `keepAlive` ligado, então fechar esconde a janela em vez de encerrar o processo. As regras ficam em `panels/notifications/notify.mjs`. A spec é [docs/specs/notifications.md](specs/notifications.md).

## Avisos de bateria

O UPower (`nixos/common.nix`) acompanha a bateria e desliga a máquina em 2%. A ação padrão dele é hybrid sleep, que precisa de um dispositivo de swap, e esta máquina só tem zram. O `poweralertd`, iniciado em `config.d/90-autostart`, transforma os níveis do UPower em notificações: baixa em 20%, crítica em 5%. Ele também manda uma notificação a cada mudança de estado da carga, como ligar o carregador. O daemon de notificações nunca mostra essas, e mostra os avisos com borda vermelha até receberem um clique, inclusive enquanto o Não perturbe, um compartilhamento de tela ou uma gravação esconde todo o resto.

## Agente polkit

O `polkit-gnome-authentication-agent-1`, iniciado em `config.d/90-autostart`, mostra a janela de senha quando um app pede ao polkit uma ação de administrador, como formatar um disco no GNOME Disks ou abrir uma pasta como administrador no Nautilus. Sem um agente na sessão essas ações falham na hora. O NixOS guarda o agente no diretório `libexec/` do pacote, então o `nixos/common.nix` adiciona `/libexec` em `environment.pathsToLink` e o Sway o inicia a partir de `/run/current-system/sw/libexec`.

## Ficar acordado, luz noturna e perfil de energia

Os três ficam no menu Toggle, e cada um aparece na barra. O `bin/idle` (`Super + Ctrl + I`) impede o bloqueio e o apagar da tela por inatividade. Ele reinicia o swayidle sem os timeouts em vez de parar o processo, então suspender ou fechar a tampa continua bloqueando a sessão antes. Um ícone de xícara aparece na barra enquanto ele está ligado. O `bin/nightlight` (`Super + Ctrl + N`) deixa a tela mais quente, em 4000 K, com o gammastep até você desligar, e mostra um ícone de lua. Não há horário automático. O ícone do perfil de energia é o módulo `power-profiles-daemon` da própria waybar: uma folha verde para power-saver, um coração com batimento cinza para balanced e um raio laranja para performance. Um clique alterna entre eles, e Toggle › Power profile escolhe um direto. Neste Lenovo LOQ, o `Fn + Q` muda o modo do próprio firmware num ciclo de quiet, balanced e performance, que o kernel mostra como `low-power`, `balanced` e `balanced-performance`. O power-profiles-daemon 0.30 não tem perfil para `balanced-performance`, então nesse passo o ícone fica em balanced, e nos outros dois ele acompanha uns 2 segundos depois. O perfil performance do próprio daemon é o `performance` do kernel, que nesta máquina corresponde ao modo extreme da BIOS. Um clique no ícone da bateria abre o painel de energia, que também mostra o tempo restante, o consumo, a saúde da bateria e o limite de carga. O limite de carga é o charge threshold do UPower, que neste Lenovo é o conservation mode. O polkit deixa o usuário ativo mudar isso sem senha. A spec é [docs/specs/power-panel.md](specs/power-panel.md). As specs são [docs/specs/stay-awake.md](specs/stay-awake.md) e [docs/specs/night-light.md](specs/night-light.md).

## Histórico do clipboard e emoji

O `bin/clipboard`, iniciado em `config.d/90-autostart`, guarda cada cópia com o cliphist. `Super + V` lista as cópias no fuzzel, da mais nova para a mais antiga, e a escolhida volta para o clipboard. O histórico fica em `$XDG_RUNTIME_DIR`, que está na memória, então some ao sair da sessão e nunca vai para o disco. System › Clear clipboard history esvazia antes disso, por exemplo depois de copiar uma senha à mão. Cópias que um gerenciador de senhas marca como sensíveis nunca são guardadas. `Super + .` abre o `bin/emoji`, uma lista no fuzzel com os emojis do Unicode, buscados pelo nome em inglês. O escolhido é digitado na janela em foco com o wtype e também fica no clipboard. A lista é o `emoji-test.txt` do pacote `unicode-emoji`, que o `nixos/common.nix` linka em `/run/current-system/sw/share/unicode`. As specs são [docs/specs/clipboard-history.md](specs/clipboard-history.md) e [docs/specs/emoji-picker.md](specs/emoji-picker.md).

## Painéis

Os painéis são janelas Quickshell. Cada painel tem um script `toggle` que mata o painel em execução ou inicia um novo, então um clique no ícone dele no waybar ou na entrada do menu abre e fecha o painel. Enquanto um painel está aberto, um scanner ou listener roda; quando ele fecha, nada continua rodando.

Um painel é uma `PanelWindow` transparente de tela cheia na camada overlay, com foco exclusivo do teclado. Esc fecha o painel, e um clique fora do card visível também.

O foco exclusivo do teclado não acompanha a troca de workspace. Trocar de workspace pelo teclado ou por um clique em outra saída deixaria todas as janelas sem entrada até o painel fechar. Por isso cada painel escuta os eventos de workspace do Sway pelo `I3IpcListener` e se fecha quando o foco muda, como faria um popup. O Sway também pula o próprio reposicionamento do mouse enquanto uma layer surface segura o teclado, então quando a troca vai para outra saída o painel move o cursor para o centro do novo workspace antes de sair.

Tudo isso fica uma vez só em `common/PanelShell.qml`, e todo painel, menos a tela de bloqueio, é um `PanelShell` com o seu próprio card. O Quickshell só carrega arquivos do diretório do arquivo de entrada que ele roda, e por isso todo arquivo de entrada fica no topo de `panels/` e importa dali o `"common"` e os arquivos do seu `<nome>/`. Um import que sai desse diretório passa no qmllint mas falha no Quickshell, então o `bin/check static` também inicia cada painel num Sway headless (passo `panels-load`). Um painel grande se divide em arquivos de componente no seu próprio diretório `<nome>/`, como o daemon de notificações faz com os popups e a central. Esses arquivos importam `"../common"`, que continua dentro de `panels/` e funciona. A forma `import qs.common` do próprio Quickshell também funciona ali, mas o qmllint não consegue resolvê-la, então o repo mantém imports relativos. O `common/Theme.qml` guarda as cores e a fonte, e o `common/AdvancedLink.qml` é o link do rodapé que abre a TUI completa do painel num terminal flutuante. Uma correção no comportamento compartilhado vai ali, e chega a todos os painéis de uma vez.

## Opacidade e tamanho do texto do terminal

A opacidade do Alacritty é definida na hora pelo `bin/opacity`, via `alacritty msg config`. O tamanho do texto é definido pelo `display/ctl`, que edita `alacritty/.config/alacritty/alacritty.toml` no lugar. A edição aparece no `git status`. Faça commit para manter o novo tamanho como padrão, ou faça checkout do arquivo para descartar.
