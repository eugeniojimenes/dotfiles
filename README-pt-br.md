# Dotfiles

[![License](https://img.shields.io/badge/License-MIT-lightgray)](/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-lightblue)](/code_of_conduct.pt-br.md)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![en](https://img.shields.io/badge/lang-en-red.svg)](./README.md)
[![love](https://img.shields.io/badge/Build%20With-%F0%9F%96%A4-lightgreen)](https://eugeniojimenes.dev)

Minha configuração pessoal para NixOS com o compositor Sway. O sistema em si (pacotes, serviços, login, uma configuração por máquina) é um flake do Nix. Tudo dentro de `$HOME` vem de módulos do GNU Stow, que criam os links dos arquivos no lugar certo.

## Sumário
- [O que tem aqui](#o-que-tem-aqui)
- [Instalar numa máquina nova](#instalar-numa-máquina-nova)
- [Usar como base para o seu](#usar-como-base-para-o-seu)
- [Uso no dia a dia](#uso-no-dia-a-dia)
- [Módulos](#módulos)
- [Verificação](#verificação)
- [Testes](#testes)
- [Cedilha com teclado US](#cedilha-com-teclado-us)
- [Documentação](#documentação)
- [Licença](#licença)
- [Código de Conduta](#código-de-conduta)

## O que tem aqui
- `flake.nix` e `nixos/` guardam a configuração do sistema. O `nixos/common.nix` vale para todas as máquinas, e `nixos/hosts/<hostname>/` guarda o que só aquela máquina precisa. Não há home-manager.
- Toda pasta da raiz com conteúdo que começa com ponto é um módulo do stow. O stow espelha a árvore do módulo dentro de `$HOME`, então `sway/.config/sway/config` vira `~/.config/sway/config`. A lista está em [Módulos](#módulos).
- `bin/check` e `tests/` rodam os testes. `docs/` explica como cada parte funciona e por quê.
- `AGENTS.md`, `CLAUDE.md`, `harness/` e as pastas `.claude/`, `.agents/` e `.cursor/` guardam instruções para agentes de IA. Se você não usa um, pode ignorá-los.

## Instalar numa máquina nova
1. Instale o NixOS com o instalador gráfico, sem desktop. Crie o usuário com o nome que está no `nixos/common.nix`, ou troque esse nome antes, como explicado em [Usar como base para o seu](#usar-como-base-para-o-seu).

2. Clone o repo:
   ```sh
   nix-shell -p git --run 'git clone https://github.com/eugeniojimenes/dotfiles.git ~/dotfiles'
   ```

3. Prepare o host. Uma reinstalação cria UUIDs de disco novos, então até uma máquina que já tem sua pasta em `nixos/hosts/` precisa gerar a config de hardware de novo. Uma máquina nova também precisa de um `default.nix`, de uma entrada no `flake.nix` e de um arquivo de saídas do Sway. O [docs/machines.pt-br.md](docs/machines.pt-br.md) explica cada um.
   ```sh
   cd ~/dotfiles
   mkdir -p nixos/hosts/<hostname>
   nixos-generate-config --show-hardware-config > nixos/hosts/<hostname>/hardware.nix
   # só máquina nova: escrever nixos/hosts/<hostname>/default.nix (a partir de hosts/loc-nixos),
   # adicionar no flake.nix e escrever sway/.config/sway/hosts/<hostname>
   git add nixos flake.nix sway   # flake só enxerga arquivos que o git rastreia
   ```

4. Crie os links dos dotfiles antes do primeiro rebuild. O gerenciador de login inicia o Sway pelo `~/.config/sway/bin/start`, e esse arquivo só existe depois do stow do módulo `sway`. Tire do lugar qualquer arquivo que um módulo vá substituir (`~/.bashrc` num sistema novo). Crie também as pastas compartilhadas: sem elas o stow transforma `~/.local/share` inteira num link para o módulo `steam`, e todo app passa a gravar seus dados dentro do repo.
   ```sh
   mkdir -p ~/.local/share ~/.local/bin ~/.claude
   nix-shell -p stow --run 'stow alacritty bash btop claude-code git lazyvim local-bin mise mpv opencode rubocop steam sway tmux'
   ```

5. Faça o build do sistema e reinicie nele. Depois do reboot o greetd entra direto no Sway. A senha do disco no boot já protege a máquina, então não há uma segunda senha.
   ```sh
   sudo nixos-rebuild boot --flake ~/dotfiles#<hostname>
   reboot
   ```

6. Instale o que fica fora do Nix: as linguagens e CLIs do mise. Abra o Neovim uma vez para o lazy.nvim instalar os plugins dele. Os plugins do tmux vêm com o sistema.
   ```sh
   mise install
   ```

7. Ative o hook de pre-commit, que recusa commits com um segredo ou um termo proibido: `git config core.hooksPath .githooks`.

8. Com um teclado US internacional, configure a cedilha como explicado em [Cedilha com teclado US](#cedilha-com-teclado-us).

9. Este passo é só para o dono do repo. Destrave o repo privado com `~/.private/private unlock`. Um fork pula este passo. Os arquivos deste repo que apontam para lá são todos opcionais.

10. Rode o `dotfiles-doctor` para conferir o resultado. Ele lista o que ainda falta, e `dotfiles-doctor --fix` aplica os reparos seguros.

## Usar como base para o seu
A configuração é pessoal, então um fork precisa de algumas mudanças antes da instalação acima.

- O nome de usuário `callmarx` é definido uma vez só, como `user` no topo do `nixos/common.nix`. Use o nome que você escolheu no instalador, porque mudar ali cria um usuário novo em vez de renomear o existente.
- Escreva sua própria pasta de host em vez de reaproveitar `nixos/hosts/loc-nixos/`. Essa tem os IDs de barramento do NVIDIA PRIME e configurações da Intel para um notebook específico.
- Fuso horário e layout do console estão no `nixos/common.nix`. Os layouts de teclado estão em `sway/.config/sway/config.d/20-input`: todo teclado é US internacional por padrão, e o arquivo de host `sway/.config/sway/hosts/<hostname>` dá o layout brasileiro a um teclado ABNT2 embutido, identificado pelo nome.
- Troque a seção `[user]` do `git/.gitconfig`. O include da identidade do trabalho aponta para um arquivo que fica no meu repo privado, e o git ignora o include quando o arquivo não existe.
- A lista de pacotes do `nixos/common.nix` é a minha. Tire o que você não usa.
- O módulo `claude-code` guarda minhas instruções globais do Claude Code, que incluem feedback de inglês para quem fala português. Deixe ele fora do comando `stow` ou troque o conteúdo.
- Use a URL do seu fork no passo do clone.

A busca de termos do `bin/check` e do hook precisa de uma lista do meu repo privado. Sem ela a busca é pulada, então um fork não precisa fazer nada ali.

## Uso no dia a dia
```sh
sudo nixos-rebuild switch --flake ~/dotfiles                       # depois de editar o nixos/, escolhe o host pelo hostname
bin/update                                                         # atualiza tudo, depois rode o comando que ele mostra
sudo nixos-rebuild switch --rollback                               # volta para a geração anterior
stow <module>                                                      # liga um módulo, a partir de ~/dotfiles
stow -D <module>                                                   # remove os links, os arquivos ficam no repo
```
Um arquivo novo em `nixos/` precisa de `git add` antes que o rebuild o enxergue. As gerações anteriores também aparecem no menu de boot.

O `bin/update` (também em System › Update no menu do Sway) atualiza o sistema, as ferramentas do mise e os plugins do Neovim, e lista as atualizações de firmware. Os plugins do tmux vêm do nixpkgs junto com o sistema. O sistema usa o release mais novo do NixOS com pelo menos 2 dias, ou um mais novo quando ele corrige um CVE sério nesta máquina, e é testado, construído e comparado antes de você aplicá-lo com o comando mostrado no final. O mise só instala releases com pelo menos 7 dias. O [docs/nixos.pt-br.md](docs/nixos.pt-br.md#atualizando) explica o porquê.

No Sway, `Super + Space` abre o menu e `Super + K` lista todos os atalhos. No tmux, `prefix + ?` lista os atalhos.

## Módulos
- **Alacritty** (`alacritty/.config/alacritty/`): o terminal, com a fonte JetBrainsMono Nerd Font, padding, atalhos e cores Catppuccin Mocha. Opacidade e tamanho do texto mudam na hora pelo menu do Sway e pelo painel de tela.

- **Bash** (`bash/`): o `.bashrc` carrega `~/.config/bash/{env,shell,aliases,init}` e o `inputrc`. O prompt é o [starship](https://starship.rs/), configurado em `bash/.config/starship.toml`.

- **btop** (`btop/.config/btop/`): tema Catppuccin Mocha com fundo transparente.

- **Claude Code** (`claude-code/.claude/`): minha config global do Claude Code, com as instruções em `CLAUDE.md`, skills próprias em `skills/` e o script da status line. Estado local da máquina, como `settings.json`, `settings.local.json` e a memória por projeto, fica fora do repo. O [docs/claude-code.pt-br.md](docs/claude-code.pt-br.md) explica por quê.

- **Git** (`git/`): saída colorida, `develop` como branch padrão e um template de mensagem de commit baseado em Conventional Commits. O [docs/git.pt-br.md](docs/git.pt-br.md) trata da identidade do trabalho.

- **Neovim** (`lazyvim/`): uma configuração LazyVim com Catppuccin Mocha e fundo transparente. Dentro do tmux ou por SSH, todo yank também vai para a área de transferência do sistema por OSC 52. Para começar do zero, apague `~/.local/share/nvim` e `~/.local/state/nvim`.

- **local-bin** (`local-bin/.local/bin/`): scripts pessoais no `PATH`. O `dotfiles-doctor` é a [verificação](#verificação). O `asdf` é um shim pequeno que repassa para o mise, porque uma CLI do trabalho chama `asdf` direto. O stow liga esse módulo arquivo por arquivo, porque `~/.local/bin` também guarda arquivos que não pertencem ao repo, como os shims do mise.

- **mise** (`mise/.config/mise/`): o gerenciador de versões de Node, Python, Ruby, Rust, Go, uv e das CLIs de agentes. Os binários pré-compilados deles rodam no NixOS pelo `programs.nix-ld`.

- **mpv** (`mpv/.config/mpv/`): o player de vídeo, com a interface [uosc](https://github.com/tomasklaen/uosc). A uosc vem do nixpkgs pelo wrapper do mpv, fixada pelo `flake.lock`. O [docs/mpv.pt-br.md](docs/mpv.pt-br.md) tem os detalhes.

- **OpenCode** (`opencode/.config/opencode/`): modelo, plugins, o servidor MCP do context7 e a config da TUI.

- **RuboCop** (`rubocop/`): o `~/.rubocop.yml` global, com `rubocop-performance`, `rubocop-rails` e `rubocop-rspec`.

- **Steam** (`steam/`): atalhos de jogos em `~/.local/share/applications/`. Para rodar um jogo na GPU NVIDIA, use a opção de lançamento `prime-run %command%`.

- **Sway** (`sway/.config/sway/`): o desktop inteiro numa pasta. Tem a config do Sway, waybar (com a música que toca), um menu no Quickshell que busca apps e configurações juntos, um daemon de notificações no Quickshell, os painéis Quickshell de calendário, tela, som (com um card de mídia), energia, rede (cabo e Wi-Fi) e Bluetooth, a tela de bloqueio, a troca de papel de parede de `~/Pictures/Wallpapers`, capturas e gravação de tela, modo acordado, luz noturna, troca de perfil de energia, histórico do clipboard, seletor de emoji e o seletor de compartilhamento de tela (`bin/share-picker`, ligado ao portal no `nixos/common.nix`). A config fica dividida por assunto em `config.d/`, os scripts em `bin/` e as configs dos apps em `apps/`. O `bin/start` põe a GPU integrada primeiro, e a NVIDIA só cuida das saídas ligadas nela. O [docs/sway.pt-br.md](docs/sway.pt-br.md) tem os detalhes.

- **tmux** (`tmux/`): o prefixo é `Ctrl + \` (ou `Ctrl + b`). Os snapshots são manuais: `prefix + Ctrl-s` salva e `prefix + Ctrl-r` restaura sessões, layouts e diretórios, sem reabrir programas. `Super + Alt + Return` entra no servidor principal quando ninguém está conectado nele, e senão abre um servidor independente. As sessões do Neovim ficam em `<leader>qs`. O [docs/tmux.pt-br.md](docs/tmux.pt-br.md) tem os detalhes.

## Verificação
O `dotfiles-doctor` confere o estado do stow, os comandos que o `nixos/common.nix` deve fornecer, as ferramentas do mise, os plugins instalados e os arquivos locais da máquina. Por padrão ele só lê e mostra o reparo de cada problema. `--fix` aplica os seguros.
```sh
dotfiles-doctor
dotfiles-doctor --fix
~/dotfiles/local-bin/.local/bin/dotfiles-doctor   # antes do stow do local-bin
```
Um conflito do stow (um arquivo real onde devia haver um symlink) nunca é corrigido sozinho. Compare o arquivo com o repo antes. O [docs/dotfiles-doctor.pt-br.md](docs/dotfiles-doctor.pt-br.md) descreve cada checagem.

## Testes
O `bin/check` roda as camadas de teste pelos checks do flake. As ferramentas vêm do nixpkgs fixado, então nada precisa ser instalado. Rode antes de cada commit. O flake só enxerga arquivos rastreados, então faça `git add` nos arquivos novos antes.
```sh
bin/check           # tudo: static, unit, eval de cada host, depois a busca de termos do empregador
bin/check static    # formatação (nix fmt não mudaria nada), shellcheck, statix, sway -C por host, qmllint, painéis carregados num Sway headless, JSON do waybar, config do tmux carregado pelo tmux travado, caminhos do Sway, a paleta de cores e o formato dos textos dos painéis, varredura de em-dash, pares de docs, todo critério de spec ligado a um teste que existe, frontmatter válido nas regras e skills de agente, stow simulado, gitleaks
bin/check unit      # testes bats em tests/unit/, scripts rodam contra comandos stub
bin/check terms     # só local: arquivos e caminhos rastreados contra a lista de termos em ~/.private, pulado quando está trancado
nix develop         # shell com as mesmas ferramentas, para rodar uma delas na mão
nix fmt             # formata o repo: Nix, shell, Lua, TOML, CSS, JSON, YAML, JS (treefmt.nix, estilo no .editorconfig)
```
O CI do GitLab roda `nix flake check -L` em todo push para `sway` e `develop`. Isso cobre todas as camadas menos `terms`. Os testes de hardware e de sessão ao vivo estão em [tests/manual.md](tests/manual.md). Quando itens passam, `bin/manual-pass "<item>"...` registra em `tests/manual-passes.toml`, que guarda a última passada de cada item por máquina com a máquina e as versões de software em que passou (`-n` mostra o resultado antes, `--with` acrescenta os periféricos usados, ou `agent-driven` quando um agente rodou o teste), e as specs das funcionalidades, que dizem o que cada teste cobre, estão em [docs/specs/](docs/specs/README.md) (só em inglês).

O hook de pre-commit em `.githooks/` recusa o commit quando um arquivo ou caminho em stage tem um termo proibido (`bin/check terms --cached`) ou as mudanças em stage têm um segredo (`gitleaks git --staged`). O hook commit-msg ao lado faz a mesma busca de termos na mensagem do commit, e o hook pre-push roda as duas buscas em cada commit prestes a ser enviado, então commits reescritos por um rebase ou squash também são verificados. Ele mostra `arquivo:linha` e nunca o valor. O git só roda o hook depois que o clone aponta para ele, então ative em cada clone com `git config core.hooksPath .githooks` (o `dotfiles-doctor --fix` faz o mesmo). O hook roda só na máquina local, e o CI roda as mesmas buscas pelo `bin/check`, menos `terms`. Para pular uma vez, use `git commit --no-verify`. O [docs/public-repo.pt-br.md](docs/public-repo.pt-br.md) lista o que cada busca deixa passar.

## Cedilha com teclado US
O layout US internacional transforma `'` seguido de `c` em ć. Para ter ç, acrescente um override no fim do `~/.XCompose`, que é local da máquina e fica fora do repo:
```sh
cat >>~/.XCompose <<'XC'
include "%L"

# Cedilla on us/intl: dead_acute + c gives ç, not ć. Later definition wins over the system Compose above.
<dead_acute> <c> : "ç" ccedilla
<dead_acute> <C> : "Ç" Ccedilla
XC
```
Reinicie os apps para pegar a mudança. Para conferir, `xkbcli compile-compose | grep '<dead_acute> <c>'` deve mostrar ç. Apps Chromium e Electron (Brave, Slack) ignoram o `~/.XCompose` e compõem com uma tabela embutida que dá ć, então recebem as teclas pelo fcitx5, um método de entrada que compõe com a mesma biblioteca e lê esse arquivo. O `nixos/common.nix` instala ele com uma config só de teclado em `/etc/xdg/fcitx5`, e o Sway inicia ele. O teclado ABNT2 do notebook tem tecla própria de ç e não precisa disso.

## Documentação
O [docs/](docs/README.pt-br.md) explica como cada parte funciona e por quê: NixOS, máquinas, Sway, tmux, git, as regras do repo público, Claude Code, dotfiles-doctor e mpv. Cada página também tem uma versão em inglês.

## Licença
Código aberto sob a licença MIT. Veja [LICENSE](/LICENSE). Os arquivos de terceiros e suas licenças estão listados em [THIRD-PARTY.md](/THIRD-PARTY.md).

## Código de Conduta
Estou comprometido em oferecer um ambiente amigável, seguro e acolhedor para todos. Por favor, leia e respeite o [Código de Conduta](/code_of_conduct.pt-br.md).
