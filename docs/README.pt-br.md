# Docs

Como as partes deste repo funcionam e por que estão configuradas assim. Instalação e uso no dia a dia estão no [README](../README-pt-br.md). Cada página tem uma versão em inglês ao lado (`<página>.md`).

- [nixos.pt-br.md](nixos.pt-br.md): estrutura do flake, o host do notebook, login, portals, pareamento Bluetooth, tema, gerações e coleta de lixo.
- [machines.pt-br.md](machines.pt-br.md): o que é configurado por máquina e como adicionar uma nova.
- [sway.pt-br.md](sway.pt-br.md): a estrutura da pasta do Sway, títulos dos atalhos, ordem das GPUs, retorno da suspensão, painéis Quickshell.
- [tmux.pt-br.md](tmux.pt-br.md): plugins do nixpkgs, descrições dos atalhos, snapshots manuais, servidores extras, o que mudar quando o tmux 3.8 chegar.
- [git.pt-br.md](git.pt-br.md): identidade de trabalho condicional.
- [public-repo.pt-br.md](public-repo.pt-br.md): sem segredos, sem detalhes do empregador, varreduras de vazamento, a reescrita de histórico de 2026.
- [claude-code.pt-br.md](claude-code.pt-br.md): o módulo global do Claude Code e por que o `settings.json` não é rastreado.
- [dotfiles-doctor.pt-br.md](dotfiles-doctor.pt-br.md): o que o health check verifica e como ele lê o stow.
- [mpv.pt-br.md](mpv.pt-br.md): a uosc do nixpkgs, e por que não o instalador dela.
- [specs/](specs/README.md): specs das funcionalidades e os testes que as cobrem (só em inglês).

Screenshots e GIFs ficam no repo separado [dotfiles-media](https://github.com/eugeniojimenes/dotfiles-media), assim versões antigas nunca aumentam o tamanho deste repo. O `docs/media.json` lista cada um com o texto alternativo e os arquivos que ele mostra.

As instruções para agentes de IA estão em [AGENTS.md](../AGENTS.md) e [harness/](../harness/README.pt-br.md).
