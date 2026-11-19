# dotfiles-doctor

`local-bin/.local/bin/dotfiles-doctor` é uma verificação de saúde para uma máquina que usa este repo. Por padrão ele só lê e mostra o reparo de cada problema que encontra. `dotfiles-doctor --fix` aplica os reparos que são seguros de aplicar automaticamente. O comportamento e os testes estão listados em [specs/dotfiles-doctor.md](specs/dotfiles-doctor.md).

A raiz do repo é encontrada com `readlink -f "$0"`, então o script funciona tanto linkado pelo stow quanto rodado direto de um clone novo (`~/dotfiles/local-bin/.local/bin/dotfiles-doctor`).

## O que ele verifica

- O estado do stow de cada módulo. A lista de módulos é toda pasta de primeiro nível com conteúdo começando com ponto, então um módulo novo entra na verificação sem editar o script. Pastas pai compartilhadas, como `~/.local/share`, precisam ser pastas reais, não links para dentro do repo.
- Os comandos que o `nixos/common.nix` deveria fornecer. Se um deles falta, o sistema não foi reconstruído desde que o comando foi adicionado.
- O hook de pre-commit: `core.hooksPath` precisa ser `.githooks`. O `--fix` configura isso.
- A lista de termos proibidos. Quando `~/.private/forbidden-terms` não existe, ele mostra um aviso, porque `bin/check terms` e o hook pulam a busca de termos nesse caso. Ele nunca mostra o conteúdo da lista.
- As ferramentas do mise: toda ferramenta declarada na config do mise está instalada.
- Instalações externas: os plugins do tmux que o `nixos/common.nix` liga em `/etc/tmux/plugins`, os plugins do lazy.nvim. Também a uosc: ela precisa estar no wrapper do mpv, e uma segunda cópia em `~/.config/mpv/scripts`, deixada pelo instalador antigo, é apontada e nunca apagada.
- Arquivos locais da máquina: `~/.claude/settings.json`, o app padrão para imagens e o mapeamento da cedilha.

## Lendo a saída do stow

O stow não tem comando de status. O script roda `stow -n -v <module>` e lê três sinais, conferidos no stow 2.4.1. Nenhum deles é documentado.

- Código de saída 0 e nenhuma saída: o módulo está linkado.
- Código de saída 0 e linhas `LINK:`: o módulo não está linkado.
- Código de saída 1 e `WARNING! ... conflicts`: existe um arquivo real onde deveria estar um symlink.

Conflitos nunca são corrigidos automaticamente, porque o arquivo real pode ter mudanças que valem a pena guardar. Compare com o repo antes.

## Visualizador de imagens

Imagens precisam abrir no `imv-dir.desktop`. Ele vem com o `imv` e abre o arquivo clicado junto com a pasta dele, então próximo e anterior funcionam. O padrão é definido em `~/.config/mimeapps.list` com `xdg-mime default`. O `mimeapps.list` em si não é rastreado, porque os apps reescrevem esse arquivo o tempo todo.

## Cedilha

Com o layout US internacional, `'` seguido de `c` produz ć em vez de ç. A verificação compila a tabela Compose com `xkbcli compile-compose` e espera que `<dead_acute> <c>` resulte em ç.

A correção é uma sobrescrita no fim do `~/.XCompose` local da máquina. Esse arquivo começa com `include "%L"`, que puxa a tabela Compose do sistema, e uma definição posterior vence uma anterior. O README-pt-br.md tem as linhas exatas.

O script guarda a saída do `xkbcli` antes de rodar `grep -q` sobre ela. Se o `grep -q` lesse o pipe direto, a saída antecipada dele mandaria SIGPIPE para o `xkbcli`, e com `pipefail` ligado o pipeline indicaria falha mesmo quando encontra o padrão.

A verificação só roda quando a config do Sway define `xkb_variant intl`. O teclado ABNT2 embutido do notebook tem uma tecla ç de verdade, e só um teclado externo US internacional chega no `dead_acute`. A verificação só reporta. O reparo edita um arquivo fora do repo, então o `--fix` não mexe nele.
