# Dotfiles

[![License](https://img.shields.io/badge/License-MIT-lightgray)](/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-lightblue)](/code_of_conduct.pt-br.md)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![en](https://img.shields.io/badge/lang-en-red.svg)](./README.md)
[![love](https://img.shields.io/badge/Build%20With-%F0%9F%96%A4-lightgreen)](https://eugeniojimenes.dev)

Meus arquivos pessoais de configuração (dotfiles) para sistemas baseados em Arch, gerenciados com GNU Stow. Tem como alvo um ambiente baseado em Omarchy, mas a maioria das partes funciona em qualquer instalação Arch.


## Índice
- [Início Rápido](#início-rápido)
- [Customizações do Omarchy](#customizações-do-omarchy)
  - [Atualizações do Omarchy escrevem dentro deste repositório](#atualizações-do-omarchy-escrevem-dentro-deste-repositório)
  - [Nota para a atualização ao Omarchy 4](#nota-para-a-atualização-ao-omarchy-4)
- [Pacotes necessários para estes dotfiles](#pacotes-necessários-para-estes-dotfiles)
- [Aplicar dotfiles com GNU Stow](#aplicar-dotfiles-com-gnu-stow)
  - [Sobre cada módulo](#sobre-cada-módulo)
  - [Desfazer Stow (remover symlinks)](#desfazer-stow-remover-symlinks)
- [Verificação de saúde](#verificação-de-saúde)
- [Outras ferramentas e setups](#outras-ferramentas-e-setups)
  - [Lazygit e Lazydocker](#lazygit-e-lazydocker)
  - [Layout de teclado por máquina](#layout-de-teclado-por-máquina)
  - [Cedilha com layout de teclado dos EUA](#cedilha-com-layout-de-teclado-dos-eua)
- [Opcional: limpar plugins do Neovim](#opcional-limpar-plugins-do-neovim)
- [Licença](#licença)
- [Código de Conduta](#código-de-conduta)


## Início Rápido
Pré-requisitos:
- Distribuição baseada em Arch (ou Omarchy)
- `git` e `stow` instalados
- `yay`, caso queira pacotes do AUR

```sh
sudo pacman -S --needed git stow
```

Clone e acesse o repositório:
```sh
git clone https://github.com/eugeniojimenes/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

## Customizações do Omarchy
O Omarchy prepara a máquina. Documentos oficiais:
- https://omarchy.org/
- https://manuals.omamix.org/2/the-omarchy-manual/50/getting-started

Customizações comuns:

1) Remova apps/pacotes sem uso:
```sh
# Exemplo: remover gnome-keyring
omarchy-pkg-remove
# ou diretamente via yay:
yay -Rs gnome-keyring

# Exemplo: remover web apps incluídos (twitter, youtube, etc.)
omarchy-webapp-remove
```

2) Instale pacotes extras:
```sh
# via helper do Omarchy
omarchy-pkg-install
# ou diretamente via yay:
yay -S google-chrome
yay -S rocm-smi-lib # necessário para o btop ler a GPU AMD
```

### Atualizações do Omarchy escrevem dentro deste repositório
Cada módulo é aplicado pelo Stow no nível de *diretório* (`~/.config/hypr` → `~/dotfiles/hypr/.config/hypr`), e o Omarchy distribui mudanças de configuração rodando `sed -i` / `cp` sobre `~/.config/...` nas suas migrações. Essas escritas atravessam o symlink do diretório e caem nos **arquivos reais deste repositório**, então depois de um `omarchy-update` o `git status` pode mostrar mudanças que ninguém aqui fez. Revise o diff, mantenha o que fizer sentido. Nada de descarte por reflexo.

Corolário: nunca aponte um arquivo dentro de um módulo do Stow para um caminho fora do repositório. As migrações do Omarchy são protegidas por `[[ -f ... ]]`, que é falso para um symlink quebrado, então a atualização é ignorada em silêncio e as duas máquinas divergem.

### Nota para a atualização ao Omarchy 4
**O caminho do tema mudou.** O Omarchy 4 move o tema ativo de `~/.config/omarchy/current` para `~/.local/state/omarchy/current` (veja os comentários em `/usr/bin/omarchy-nvim-setup`). Estes arquivos fixam o caminho do 3.x e precisam do novo após a atualização:

| Arquivo | Linha |
|---|---|
| `alacritty/.config/alacritty/alacritty.toml` | `general.import = [...]` |

O `source =` do Hyprland e o `general.import` do Alacritty não conseguem testar dois caminhos, então esses são edição manual. As próprias migrações do Omarchy podem reescrevê-los antes, veja a nota acima. O Neovim não precisa de nada: `lazyvim/.config/nvim/lua/plugins/theme.lua` já tenta os dois caminhos em tempo de execução.

**A configuração do Hyprland virou Lua.** O Hyprland 0.56 carrega `~/.config/hypr/hyprland.lua` com preferência sobre o `hyprland.conf`, e a atualização do Quattro deixa arquivos `.lua` *de template, vazios* ao lado dos seus `.conf`, atravessando o symlink de diretório do Stow, direto neste repositório. Os `.conf` continuam ali sem efeito nenhum, então cada configuração pessoal de monitor/input/keybinding volta silenciosamente ao padrão do Omarchy. Este repositório já foi portado e os `.conf` mortos foram removidos; veja a seção do Hyprland abaixo.

**O terminal padrão virou o foot.** O Quattro instala `~/.local/share/applications/foot.desktop`, e sem um `~/.config/xdg-terminals.list` presente o `xdg-terminal-exec` escolhe ele em vez do Alacritty, então `SUPER + RETURN`, o launcher do tmux e todo `omarchy-launch-tui` abrem o foot com o tamanho de fonte dele. Correção:

```sh
omarchy-default-terminal alacritty
```

**O caminho do próprio Omarchy mudou.** `~/.local/share/omarchy` agora é um symlink para `/usr/share/omarchy`, e `OMARCHY_PATH` (definido a partir de `/etc/omarchy.conf` quando presente) é o valor a usar. O `bash/.bashrc` o resolve antes de carregar o rc do Omarchy.

## Pacotes necessários para estes dotfiles
```sh
## Customização do bash e bin local (via mise):
sudo pacman -S usage # mise e starship já vêm instalados pelo Omarchy

## Ferramentas usadas pelos módulos abaixo (tmux, Neovim, TUIs de git/docker):
sudo pacman -S tmux tree-sitter-cli lazygit lazydocker
```

## Aplicar dotfiles com GNU Stow
O Stow gerencia symlinks do repositório no seu $HOME. Faça backup das configurações existentes antes.

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
mv ~/.rubocop.yml ~/.rubocop.yml.bkp 2>/dev/null
mv ~/.claude ~/.claude.bkp 2>/dev/null
mv ~/.config/tmux ~/.config/tmux.bkp 2>/dev/null
mv ~/.config/opencode ~/.config/opencode.bkp 2>/dev/null
mv ~/.omp ~/.omp.bkp 2>/dev/null

# Stow os módulos que você deseja
stow alacritty
stow bash
stow claude-code
stow git
stow hypr
stow lazyvim
stow local-bin
stow mise
stow mpv
stow rubocop
stow steam
stow tmux
stow omp
stow opencode
```

### Desfazer Stow (remover symlinks)
Remova os symlinks do Stow sem apagar arquivos. Use `-D`:
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

3. **Claude Code**: configuração em `claude-code/.claude/`. Configuração global do Claude Code: `CLAUDE.md` (instruções), `settings.json`, skills customizadas (`skills/`) e `statusline-command.sh`. Faça stow para colocar em `~/.claude/`. Estado local da máquina (`settings.local.json`, memória por projeto) fica fora do repositório.

4. **Git**: configuração em `git/`.
  Config geral:
  - saída colorida,
  - `develop` como branch padrão,
  - template de mensagem de commit inspirado em Conventional Commits.

5. **Hyprland**: configuração em `hypr/.config/hypr/`. Os padrões do Omarchy nunca são editados. Desde o Omarchy 4 a configuração é em **Lua**: o `hyprland.lua` prepara o module path do Omarchy, faz `require` de `default.hypr.omarchy` (todos os padrões, vindos de `$OMARCHY_PATH/default/hypr/`) e então faz `require` dos arquivos locais, para que eles sobrescrevam.
  - Sobrescritas em Lua, carregadas depois dos padrões: `monitors.lua`, `input.lua`, `bindings.lua`, `looknfeel.lua`, `autostart.lua`.
  - O `input.lua` não define `kb_layout` nem `kb_variant`. O Omarchy tira os dois do `/etc/vconsole.conf`, veja [Layout de teclado por máquina](#layout-de-teclado-por-máquina).
  - Nenhum arquivo hyprlang independente. `hypridle.conf` e `hyprlock.conf` removidos: **o Omarchy 4 não instala nem `hypridle` nem `hyprlock`**, ociosidade e bloqueio agora são do `omarchy-shell`, então esses arquivos configuravam daemons que não existiam. `hyprsunset.conf` e `xdph.conf` removidos: o Omarchy 4 *fornece* os dois em `/usr/share/omarchy/config/hypr/`, cópias daqui idênticas byte a byte, não sobrescreviam nada.

  Coloque customizações apenas nesses arquivos. Nunca nos padrões do Omarchy.

  Duas APIs em jogo: `hl.*` é o Hyprland cru (`hl.config`, `hl.monitor`, `hl.env`, `hl.unbind`, `hl.dsp.*`) e `o.*` é o açúcar sintático do Omarchy (`o.bind`, `o.window`, `o.launch_on_start`), definido em `$OMARCHY_PATH/default/hypr/helpers.lua`. O `.luarc.json` aponta o lua-ls para `/usr/share/hypr/stubs`, para autocompletar.

  **Keybindings não sobrescrevem, eles se acumulam.** Carregar depois não substitui uma tecla que o Omarchy já reivindicou. Um segundo `o.bind` na mesma tecla apenas adiciona uma duplicata. Desfaça o bind antes:

  ```lua
  hl.unbind("SUPER + SHIFT + M")
  o.bind("SUPER + M", "Music", { omarchy = "spotify" })
  o.bind("SUPER + SHIFT + M", "Move workspace to next monitor", hl.dsp.workspace.move({ monitor = "+1" }))
  ```

  Prefira as tabelas de launcher `{ omarchy = "browser" }` / `{ tui = "btop" }` a fixar um executável, para que `omarchy default browser` continue sendo a única fonte de verdade. Liste tudo que está bindado no momento com `omarchy menu keybindings --print`.

6. **Neovim (LazyVim)**: configuração em `lazyvim/`. Após aplicar com o Stow:
  ```sh
  # Opcional: limpe todos os plugins/dados locais do Neovim antes da primeira execução
  rm -rf ~/.local/share/nvim
  rm -rf ~/.local/state/nvim
  # Depois de configurar o mise (descrito a seguir):
  gem install neovim # suporte ao ruby no Neovim
  sudo pacman -S tree-sitter-cli
  ```

  **Relação com a configuração do Neovim do Omarchy.** O Omarchy distribui sua própria configuração do LazyVim pelo pacote `omarchy-nvim` (`/usr/share/omarchy-nvim/config/`, replicada em `/etc/skel` para novos usuários). Como este repositório é dono de `~/.config/nvim`, o `omarchy-nvim-setup` não mexe nele. Por isso dois arquivos do Omarchy são **copiados** para cá como arquivos reais, e não como symlinks. Apontar para fora do repositório torna a configuração irreproduzível em uma segunda máquina:

  - `lua/plugins/all-omarchy-themes.lua`: pré-carrega todos os colorschemes do Omarchy para que a troca de tema seja instantânea. O Omarchy nunca atualiza esse arquivo depois da instalação, então confira a defasagem de vez em quando:
    ```sh
    diff /usr/share/omarchy-nvim/config/lua/plugins/all-themes.lua \
         ~/dotfiles/lazyvim/.config/nvim/lua/plugins/all-omarchy-themes.lua
    ```
  - `plugin/after/transparency.lua`: remove o fundo dos grupos de destaque. O Omarchy altera esse arquivo no lugar por migrações, então ele pode aparecer no `git status` após uma atualização.

  O `lua/plugins/theme.lua` resolve o tema ativo em tempo de execução em vez de usar symlink, então o mesmo commit funciona no Omarchy 3.x e 4.x. Veja a [nota para a atualização ao Omarchy 4](#nota-para-a-atualização-ao-omarchy-4).

7. **mise** (gerenciador de versões de ferramentas): configuração em `mise/.config/mise/`.
  Este setup usa o [mise](https://mise.jdx.dev/getting-started.html) para gerenciar versões de ferramentas.

  - As ferramentas e versões globais estão definidas em ~/dotfiles/mise/.config/mise/config.toml.
  - Como mencionado em [Pacotes necessários para estes dotfiles](#pacotes-necessários-para-estes-dotfiles), garanta que `mise` e `usage` estejam instalados.

  ```sh
  # Instale as ferramentas declaradas
  mise install
  ```

8. **mpv**: configuração em `mpv/.config/mpv/`. Interface = [uosc](https://github.com/tomasklaen/uosc).

  Só o `mpv.conf` é versionado. Árvore do uosc (`scripts/`, `fonts/`, o `script-opts/uosc.conf` dele)
  fica no gitignore, instalada e não vendorizada: ~18 MB, a maior parte binários pré-compilados sem
  checksum. `~/.config/mpv` = symlink de diretório para o repositório, então tudo abaixo escreve nos
  caminhos ignorados, nunca aparece no `git status`.

  Instalação. `stow mpv` antes: o instalador roda `mkdir -p ~/.config/mpv`, e um diretório real ali
  impede o symlink de diretório que o stow precisa.

  ```sh
  stow mpv
  curl -fsSL https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh | bash
  ```

  Atualização. O uosc se atualiza sozinho. Abra o menu dele no mpv (botão direito, ou tecla `menu`),
  escolha **Update uosc**. Roda o mesmo instalador com `MPV_CONFIG_DIR` em `~/.config/mpv`, então
  precisa de `curl` e `unzip`. A linha do curl acima faz o mesmo. Para criar um atalho:

  ```
  Ctrl+u script-binding uosc/update
  ```

  O Omarchy instala o mpv, torna ele o player de vídeo padrão, não fornece configuração de mpv, então
  nada aqui sobrescreve um padrão do Omarchy. Notas completas em `mpv/.config/mpv/README.md`.

9. **RuboCop**: configuração em `rubocop/`. Config global do RuboCop (`rubocop/.rubocop.yml` → `~/.rubocop.yml`). Habilita os plugins `rubocop-performance`, `rubocop-rails` e `rubocop-rspec` e alguns cops extras.

10. **Steam**: configuração em `steam/`. Arquivos `.desktop` customizados para Steam e jogos, colocados em `~/.local/share/applications/`.

11. **tmux**: configuração em `tmux/`.
  Instale o tmux e o TPM, depois faça o stow:
  ```sh
  sudo pacman -S tmux
  # Gerenciador de plugins. Atenção ao caminho: NÃO fica sob ~/.config/tmux
  git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm

  # Faça o stow da configuração do tmux
  cd ~/dotfiles
  stow tmux
  ```

  **OBS:** Dentro do tmux, instale os plugins (tmux-sensible, tmux-resurrect, etc.) com `prefix + I` (com o meu prefix seria `CTRL+\ + I` ou `CTRL+b + I`). Se estiver atualizando uma máquina que ainda tem o tmux-continuum instalado, remova-o com `prefix + ALT + u`.

  O TPM fica em `~/.local/share/tmux/plugins/` (definido via `TMUX_PLUGIN_MANAGER_PATH` no `tmux.conf`) para que `~/.config/tmux/` não contenha nada além do `tmux.conf`. Isso permite que o Stow crie o link do **diretório**, como em todos os outros módulos. Um link no nível de arquivo é substituído por uma cópia comum na próxima vez que uma migração do Omarchy rodar `sed -i` sobre `~/.config/tmux/tmux.conf`, que é exatamente como este módulo já divergiu do repositório em silêncio uma vez.

  Os snapshots são **manuais nas duas pontas**: `prefix + Ctrl-s` salva, `prefix + Ctrl-r` restaura. Não há timer. O tmux-continuum fornecia um e foi removido: com o auto-restore desligado, o auto-save só fazia estrago, porque o servidor vazio que você abre depois de um reboot sobrescreve o snapshot que você queria. Um restore reconstrói sessões, janelas, layouts de painel, o cwd de cada painel e o conteúdo dele, mas **não inicia nenhum programa** (`@resurrect-processes 'false'`), então nada reabre um editor que você já tinha deixado para trás.

  O `SUPER + ALT + RETURN` decide o que abrir perguntando se algum cliente está **conectado** ao servidor primário, e não se existe alguma sessão. Sem ninguém conectado, ele conecta ao primário, iniciando-o caso ainda não esteja rodando, então fechar todos os terminais e abrir um novo devolve você ao seu trabalho em vez de um servidor limpo. Com um já conectado, ele abre um servidor **independente**, no próprio socket, com a própria lista de sessões. O `SUPER + SHIFT + T` abre um terceiro no socket `sys-tools`, com btop e lazydocker em duas janelas; sair de qualquer um dos dois fecha o painel inteiro, e as teclas do resurrect ficam desvinculadas ali, então ele nunca salva por cima do seu snapshot de verdade. Nenhum deles precisa se coordenar e a ordem de início é irrelevante, porque nenhum servidor grava snapshot sem você mandar. Snapshots antigos não precisam de limpeza externa: o resurrect os poda sozinho a cada save, mantendo `@resurrect-delete-backup-after` dias e nunca menos que os 5 mais recentes.

  Buffers do Neovim **não** são restaurados pelo resurrect. O `@resurrect-strategy-nvim` só lê um `Session.vim` no cwd do painel, e o LazyVim guarda sessões com o persistence.nvim. Reabra-os com `<leader>qs`.

12. **oh-my-pi (omp)**: configuração em `omp/.omp/`. Config do agente oh-my-pi, uma extensão TUI de mode-badge (`agent/extensions/`). Aplica em `~/.omp/`.

13. **OpenCode**: configuração em `opencode/.config/opencode/`. Config do OpenCode: modelo, plugins (ponytail, caveman), MCP context7 e ajustes da TUI. Aplica em `~/.config/opencode/`.

## Verificação de saúde
`dotfiles-doctor` verifica uma instalação nova ou uma máquina existente depois do `omarchy update`. Só leitura por padrão, imprime o reparo exato de cada problema encontrado. `--fix` aplica os seguros.

```sh
dotfiles-doctor          # apenas relatório
dotfiles-doctor --fix    # aplica os reparos seguros
```

Em um clone novo o `local-bin` ainda não está stowed, então chame pelo caminho:
```sh
~/dotfiles/local-bin/.local/bin/dotfiles-doctor --fix
```

O que verifica:
- **stow**, por módulo. Três estados: linkado, ainda não linkado, ou **conflito**. Conflito significa que um arquivo real está onde deveria haver um symlink, que é o que uma migração do Omarchy deixa para trás (veja [Atualizações do Omarchy escrevem dentro deste repositório](#atualizações-do-omarchy-escrevem-dentro-deste-repositório)). Nunca corrigido automaticamente: o arquivo pode conter mudanças que valem a pena manter, então faça um diff contra o repo antes de apagar.
- **pacotes** de [Pacotes necessários](#pacotes-necessários-para-estes-dotfiles), via `pacman -Qq`.
- **mise**: `mise ls --missing`, mais os três pacotes de host do Neovim que os hooks `postinstall` do `config.toml` instalam (`gem`, `npm`, `pip`). Esses hooks falham em silêncio, então um runtime pode estar instalado sem o suporte a Neovim.
- **instalações externas** que nenhum gerenciador de pacotes controla: TPM e os plugins declarados no `tmux.conf`, uosc em `~/.config/mpv/scripts`, plugins do Neovim contados contra o `lazy-lock.json`.
- **input**: `kb_layout`/`kb_variant` ativos contra o `/etc/vconsole.conf`, protegendo o fallback não documentado do Omarchy no qual este repositório se apoia (veja [Layout de teclado por máquina](#layout-de-teclado-por-máquina)). Tolera o grupo `us,` que o Omarchy prefixa em layouts não latinos. Pulado quando o próprio `input.lua` define o layout, ou fora de uma sessão do Hyprland.
- **arquivos locais da máquina**, ausentes em uma máquina nova de propósito: `~/.claude/settings.json` (sinalizado se for um *symlink*, o que colocaria nomes de marketplaces do trabalho neste repo público), `~/.config/xdg-terminals.list` fixando o Alacritty, e a correção de cedilha no Compose que as atualizações do `libx11` revertem. A verificação da cedilha só roda quando `intl` aparece em qualquer posição da lista de variantes, então uma máquina só ABNT2 fica quieta, enquanto um notebook `br,us` continua sendo verificado: o grupo us dele alcança o `dead_acute` e precisa da correção.

Código de saída 1 quando algo falha, 0 quando está limpo. Não verifica higiene do repo (`git status`, migrações do Omarchy não commitadas); revise isso à mão.

A lista de módulos vem dos diretórios na raiz do repo, então um módulo novo é coberto sem editar o script.

## Outras ferramentas e setups:

### Lazygit e Lazydocker
Eu uso lazygit e lazydocker para uma interface de terminal simples para git e docker. Essas ferramentas são instaladas por padrão com o Omarchy, mas se você precisar instalá-las manualmente:
```sh
sudo pacman -S lazygit lazydocker
```

Nota: se você mantém uma configuração pessoal do Lazygit, crie um symlink para `~/.config/lazygit/config.yml`. Este repositório não inclui um arquivo de configuração do Lazygit por padrão.

### Layout de teclado por máquina
Desktop = US international with dead keys. Notebook = ABNT2. Um repositório só, sem ramificação.

Nada sobre o layout mora neste repositório. O `default/hypr/input.lua` do Omarchy lê o `/etc/vconsole.conf` e tira o `kb_layout` do `XKBLAYOUT` e o `kb_variant` do `XKBVARIANT`. Esse arquivo é configuração de sistema local da máquina, então cada máquina responde por si.

Configure uma vez por máquina e rode `hyprctl reload`:
```sh
# Desktop: US international with dead keys
sudo localectl set-x11-keymap us pc105+inet intl terminate:ctrl_alt_bksp

# Notebook: ABNT2 primeiro, US international em segundo
sudo localectl set-x11-keymap br,us pc105 ",intl" terminate:ctrl_alt_bksp
```

Passe os quatro argumentos. O `localectl` reescreve o bloco X11 inteiro, então omitir modelo ou opções limpa esses campos. Leia o `/etc/vconsole.conf` atual da máquina antes e leve o modelo e as opções dela, em vez de copiar os de outra máquina.

**O campo de variante do `br` fica vazio.** `abnt2` é um *modelo* XKB, não uma variante do `br`: o `xkbcli list` dá ao `br` apenas `nodeadkeys`, `dvorak`, `nativo`, `nativo-us`, `thinkpad`, `thinkpad_nodeadkeys`, `nativo-epo` e `rus`. O `br` base já *é* ABNT2, incluindo a 107ª tecla `<AB11>` (`slash`/`question`) e o ç dedicado no `<AC10>`. Escrever `abnt2,intl` compila sem erro e produz símbolos idênticos byte a byte, mudando só o rótulo do keymap para `pc_br(abnt2)_inet(evdev)`, ou seja, funciona documentando algo falso. Os modelos `abnt2` e `pc105` também compilam idênticos para o `br`, então não vale a pena mexer no modelo.

Por isso o `hypr/.config/hypr/input.lua` não define `kb_layout` nem `kb_variant`. Ele ainda define `kb_options`, que o Omarchy **não** lê do `XKBOPTIONS`. O padrão do Omarchy é `compose:caps,shift:both_capslock_cancel`, e ele só acrescenta um alternador de grupo para layouts não latinos. `br` é latino, então um notebook com `br,us` não ganha alternador nenhum a menos que este repositório adicione um. O `grp:alt_space_toggle` é inerte quando há um único layout, então um mesmo valor serve para as duas máquinas.

Para ver o que está ativo:
```sh
hyprctl getoption input:kb_layout
hyprctl getoption input:kb_variant
```

**Isto diverge do manual do Omarchy de propósito.** O [manual](https://omarchy.org/manual/keyboard-mouse-trackpad/) manda fixar o layout no `input.lua` (`kb_layout = "us,dk"`), acessível por *Setup > Input* no menu do Omarchy (`Super + Space`), e nunca cita vconsole nem `localectl`. Este repositório usa a rota do vconsole para que um único arquivo versionado sirva às duas máquinas. O fallback existe de verdade, o `default/hypr/input.lua` lê `vconsole.XKBLAYOUT or "us"`, mas é código do Omarchy e não a interface documentada dele, e esta versão é `4.0.0.alpha`. Se algum release remover essa leitura, o layout cai para `us` em silêncio. A [issue #6878](https://github.com/basecamp/omarchy/issues/6878) é essa mesma emenda falhando na prática: upgrades para o Quattro em que o vconsole tinha só `KEYMAP` e nenhum `XKBLAYOUT` perderam o layout inteiro. O `localectl set-x11-keymap` escreve as duas chaves, então estas máquinas ficam no estado bom que faltou a quem reportou.

### Cedilha com layout de teclado dos EUA
Workaround para digitar "ç" no layout Inglês ("*US, international with dead keys*"). Esse layout mapeia `'` + `c` para ć, e não para ç.

O layout em si não precisa de nada aqui, veja [Layout de teclado por máquina](#layout-de-teclado-por-máquina). Um arquivo para corrigir:

```sh
sudo cp /usr/share/X11/locale/en_US.UTF-8/Compose{,.bak}
sed 's/ć/ç/g; s/Ć/Ç/g' /usr/share/X11/locale/en_US.UTF-8/Compose.bak |
  sudo tee /usr/share/X11/locale/en_US.UTF-8/Compose >/dev/null
```

Saia da sessão e entre de novo.

**Como isso chega nos aplicativos.** Cadeia de Compose, cada arquivo incluindo o próximo:
```
~/.XCompose
  include "%H/.local/share/omarchy/default/xcompose"
    include "%L"  ->  /usr/share/X11/locale/en_US.UTF-8/Compose  (corrigido acima)
```
`%L` = o arquivo Compose da locale. O Omarchy já cria o `~/.XCompose` com esse include, então a correção alcança tudo. O fcitx5 roda por padrão no Omarchy e atende os clientes Wayland pelo frontend `waylandim`; os terminais leem a mesma tabela através do xkbcommon.

Para verificar sem digitar nada:
```sh
xkbcli compile-compose | grep '<dead_acute> <c>'
```
Corrigido, imprime `<dead_acute> <c> :  "ç" U0107`. O keysym continua `U0107`, que *é* o ć, porque o sed troca a string de saída e não o nome. Sem a correção, imprime "ć".

**O `libx11` é dono desse arquivo, então toda atualização o restaura e o ç quebra em silêncio.** O `dotfiles-doctor` detecta isso, usando como chave a divergência de SHA256 que o `pacman -Qkk libx11` reporta enquanto a correção está de pé.

**Passo antigo do `immodules.cache` do GTK removido.** Ele acrescentava `:en` na linha `cedilla` do `/usr/lib/gtk-3.0/3.0.0/immodules.cache`, mais um gêmeo em gtk-2.0. Nenhum dos dois faz nada hoje: o `GTK_IM_MODULE` não é definido no Omarchy, então os aplicativos GTK passam pelo text-input do Wayland até o fcitx5 e nunca carregam o `im-cedilla.so`, e o `/usr/lib/gtk-2.0/` não existe mais. Nenhum pacote é dono do `immodules.cache` também, então um rebuild do gtk3 descarta qualquer edição feita nele.

## Opcional: limpar plugins do Neovim
Início limpo no Neovim:
```sh
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
```

## Licença
Código aberto sob a licença MIT. Veja [LICENSE](/LICENSE).


## Código de Conduta
Estou comprometido em fornecer um ambiente amigável, seguro e acolhedor para todos. Por favor, leia e respeite o [Código de Conduta](/code_of_conduct.pt-br.md).
