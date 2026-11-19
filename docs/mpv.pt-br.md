# mpv

A interface do mpv é a [uosc](https://github.com/tomasklaen/uosc), do tomasklaen. O mpv e a uosc vêm do `nixos/common.nix`, e o módulo `mpv` guarda só a config do usuário.

## O que é rastreado

Só `mpv/.config/mpv/mpv.conf`, com três configurações: `vo=gpu`, `gpu-api=opengl` e `target-colorspace-hint=no`.

O `gpu-api=opengl` existe por causa das duas GPUs do notebook. A API padrão do mpv é o Vulkan, e o carregador do Vulkan inicia o driver de cada GPU que encontra, então cada abertura acordava a placa NVIDIA e levava cerca de 1,1 segundo até o primeiro quadro, 3 segundos quando a placa estava totalmente dormindo. Com OpenGL, o mpv desenha só na GPU Intel e abre em cerca de 0,17 segundo. O Vulkan só faria diferença com `vo=gpu-next` e shaders pesados, que não são usados aqui. Para tocar algo na placa NVIDIA mesmo assim, rode `prime-run mpv --gpu-api=vulkan <arquivo>`.

## A uosc do nixpkgs

O `nixos/common.nix` instala o mpv como `mpv.override { scripts = [ mpvScripts.uosc mpvScripts.mpris ]; }`. O script `mpris` coloca o mpv no MPRIS, então a barra, as teclas de mídia e o painel de som mostram e controlam o mpv como qualquer outro player. O wrapper passa o script da uosc para o mpv e aponta as fontes da uosc, então nada é instalado em `~/.config/mpv`. A versão segue o `flake.lock`: muda com o `bin/update`, com a mesma espera de 2 dias do resto do sistema, e volta atrás com uma geração do NixOS. O nixpkgs compila do código fonte o `ziggy`, o binário auxiliar da uosc, então nenhum binário pré-compilado sem checksum chega à máquina.

Antes disso, a uosc vinha do instalador dela, um `curl … | bash` a partir do HEAD do repo da uosc, que roda como o usuário o que estiver lá naquele momento e deixa a versão sem fixar. A versão do nixpkgs pode ficar um release atrás do upstream, que é o preço de fixar a versão.

Não use o instalador da uosc nem a entrada **Update uosc** do menu dela. Os dois gravam uma cópia em `~/.config/mpv/scripts`, e o mpv passa a carregar duas cópias da uosc. O `dotfiles-doctor` aponta essa cópia e mostra o comando que a remove. O `~/.config/mpv` é um link para dentro deste repo, então o `.gitignore` mantém essa cópia fora de um commit até ela ser removida.

## Configurações

A uosc roda com os padrões dela. Para mudar uma configuração, escreva `mpv/.config/mpv/script-opts/uosc.conf` só com as linhas que mudam e rastreie o arquivo.
