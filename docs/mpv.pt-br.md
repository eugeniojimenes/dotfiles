# mpv

A interface do mpv é a [uosc](https://github.com/tomasklaen/uosc), do tomasklaen. O mpv em si vem do `nixos/common.nix`. O pacote dele não traz config de usuário, então o módulo `mpv` guarda tudo o que existe.

## O que é rastreado

Só `mpv/.config/mpv/mpv.conf`, com duas configurações: `vo=gpu` e `target-colorspace-hint=no`.

## O que não é rastreado

`scripts/`, `fonts/`, `script-opts/` e `.uosc-backup/` estão no `.gitignore`.

A árvore da uosc tem cerca de 18 MB, e cerca de 17 MB disso são três binários `ziggy` pré-compilados para Linux, macOS e Windows. Eles vêm sem checksum e sem procedência, o que tira eles de um repo público. Dois dos três nunca rodam nesta máquina, de qualquer forma.

`script-opts/uosc.conf` também fica de fora. A cópia rastreada não tinha nenhuma personalização, só o padrão do upstream de uma versão atrás, então rastrear ela só congelava um padrão velho. Volte a rastrear se algum dia uma configuração mudar.

`.uosc-backup/` é a pasta temporária do instalador. Ela é removida quando a instalação dá certo e fica para trás quando falha.

## Instalar a uosc numa máquina nova

Primeiro rode o stow do módulo, depois o instalador. O instalador roda `mkdir -p ~/.config/mpv`, e uma pasta real ali bloqueia o symlink de pasta que o stow precisa. Quando o stow roda primeiro, `~/.config/mpv` já é um symlink para o repo, então tudo o que o instalador grava cai nos caminhos ignorados acima e fica fora do git.

```sh
stow mpv
curl -fsSL https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh | bash
```

O instalador grava `scripts/uosc`, `fonts/uosc_icons.otf`, `fonts/uosc_textures.ttf` e um `script-opts/uosc.conf` atual. Ele só baixa esse arquivo conf quando ele não existe, então uma cópia rastreada ganharia do padrão novo.

O nixpkgs tem `mpvScripts.uosc`, que poderia ser adicionado por um wrapper do mpv no `nixos/common.nix`. Ele não é usado aqui porque o instalador mantém a uosc junto desta config e ela se atualiza sozinha.

## Atualizar a uosc

A uosc se atualiza sozinha. Abra o menu dela no mpv (clique direito, ou a tecla `menu`) e escolha **Update uosc**. O `main.lua` liga a atualização a `script-binding uosc/update`, então um atalho de teclado também funciona:

```
Ctrl+u script-binding uosc/update
```

O atualizador roda o mesmo `installers/unix.sh` que uma instalação nova usa, com `MPV_CONFIG_DIR` apontando para a pasta de config do mpv. Ele precisa de `curl` e `unzip` no `PATH`, e a linha do `curl` acima faz a mesma coisa. Reinicie o mpv depois.

Tudo o que a atualização grava cai em caminhos ignorados, então nunca aparece no `git status`. O upstream avisa que o atualizador automático não funciona no macOS, o que não importa aqui.

A versão em uso é o `uosc_version` no topo de `scripts/uosc/main.lua`, ou a mensagem de script `uosc-version`.

Como o instalador só baixa `script-opts/uosc.conf` quando ele não existe, a cópia local nunca é atualizada. Para pegar os padrões novos depois de uma atualização grande, apague o arquivo e rode o instalador de novo.
