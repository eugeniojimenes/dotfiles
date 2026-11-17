# NixOS

A configuração do sistema fica em `nixos/` e no `flake.nix` na raiz do repo. `nixos/` não é um módulo do stow: não tem conteúdo com prefixo de ponto, então o stow e o `dotfiles-doctor` o ignoram.

## Estrutura

O `flake.nix` define um `nixosConfigurations.<hostname>` por máquina. O nome do atributo é o hostname, então `sudo nixos-rebuild switch --flake ~/dotfiles` escolhe o sistema certo sozinho. O flake segue o branch `nixos-26.05`, e o `flake.lock` fixa a revisão exata do nixpkgs. `nix flake update` move o lock para a revisão mais nova desse branch.

`nixos/common.nix` tem tudo o que todas as máquinas compartilham: pacotes, serviços, Sway, login. `nixos/hosts/<hostname>/default.nix` tem o que uma máquina precisa e importa `../../common.nix` e `./hardware.nix`. `/etc/nixos` não é usado.

`hardware.nix` é a saída do `nixos-generate-config` daquela máquina, commitada sem alterações. Contém UUIDs de disco e módulos do kernel, nenhum segredo. Gere de novo em vez de editar à mão. Ele também fica fora do `nixfmt` e do `statix`, para que o arquivo continue exatamente como a ferramenta escreveu.

Um flake só enxerga arquivos que o git rastreia. Um arquivo novo precisa de `git add` antes de qualquer comando `nix` ler o flake, senão o build falha como se o arquivo não existisse.

Não há home-manager. Pacotes e serviços do sistema ficam em `nixos/`, e a configuração do usuário passa pelos módulos do stow.

## Notebook (loc-nixos)

O notebook é um Lenovo LOQ com gráficos Intel UHD e uma GPU RTX 3050 Laptop. O arquivo do host define:

- O módulo de kernel aberto da NVIDIA (a arquitetura Ampere suporta) com PRIME offload. A Intel renderiza o desktop e a placa NVIDIA roda os programas iniciados com `prime-run`. O comando mantém o nome do Arch (`offloadCmdMainProgram = "prime-run"`), então as opções de lançamento do Steam vieram sem mudança.
- `hardware.nvidia.powerManagement.enable` para a suspensão.
- `i915` no initrd. Os nomes de conector (`eDP-1`, `DP-1`, `HDMI-A-1` e assim por diante) vêm de um contador único compartilhado pelas duas GPUs, na ordem em que os drivers carregam. Sem essa linha, uma corrida entre os dois drivers às vezes renomeava a tela embutida. Carregar o `i915` primeiro fixa a ordem em todo boot e, como efeito colateral, o prompt do LUKS aparece na resolução nativa.
- `services.xserver.videoDrivers = [ "nvidia" ]` e `thermald` (gerenciamento térmico de CPU Intel).

## Login

O greetd entra direto no Sway rodando `~/.config/sway/bin/start`. O disco é criptografado com LUKS, então a senha no boot já protege a máquina e uma segunda senha não acrescentaria nada. Ao sair do Sway aparece o tuigreet.

## Suporte do shell

`programs.fzf.keybindings` e o bash completion do NixOS substituem o que o módulo `bash` carregava de `/usr/share` no Arch.

`programs.nix-ld` deixa binários pré-compilados rodarem. O mise e o Mason baixam binários (Node, Python, Ruby, rustup, language servers) que esperam `/lib64/ld-linux-x86-64.so.2`. O `icu` entra no conjunto padrão de bibliotecas porque binários .NET, como o marksman do Mason, abortam sem `libicu`.

## Portals

Os portals vêm dos padrões do módulo Sway do NixOS: o `xdg-desktop-portal-wlr` cuida do compartilhamento de tela e das capturas de tela, e o `xdg-desktop-portal-gtk` cuida do resto, incluindo o seletor de arquivos.

O Nautilus como backend do FileChooser foi testado e abandonado. Na inicialização o portal ativa o Nautilus, e o Nautilus chama o portal de volta enquanto ainda está iniciando, então os dois ficam esperando um pelo outro por 25 segundos. Todo app GTK aberto nesse intervalo travava, e o waybar morria no login.

## Tema e cursor

O modo escuro é definido por padrões do dconf, que o `gsettings set` ainda pode sobrescrever. `color-scheme = "prefer-dark"` cobre GTK4, libadwaita e Chromium. O GTK3 ignora essa chave e precisa de um tema pelo nome. O GTK3 puro não vem com um tema `Adwaita-dark`, e um nome de tema desconhecido cai no Adwaita claro, e era por isso que o seletor de arquivos e outros apps GTK3 continuavam claros. O `adw-gtk3-dark` (do pacote `adw-gtk3`) deixa os apps GTK3 com a cara dos apps libadwaita.

O NixOS não define tema de cursor padrão, então o Sway desenhava os cursores antigos do núcleo do X11. O `adwaita-icon-theme` já estava na closure como dependência do GTK. Agora ele é instalado explicitamente e configurado tanto no Sway (`seat * xcursor_theme Adwaita 24`) quanto no dconf para o GTK.

## Gerações e coleta de lixo

Cada rebuild cria uma nova geração e uma nova entrada de boot, e é isso que torna o rollback possível: `sudo nixos-rebuild switch --rollback`, ou escolha uma entrada mais antiga no menu de boot. O systemd-boot mantém 10 entradas para a ESP de 1 GB não encher.

Gerações antigas mantêm toda a closure delas no disco. O `nix.gc` roda toda semana e apaga gerações com mais de 30 dias. A deduplicação do store usa `nix.optimise.automatic`, que cria hard links entre arquivos idênticos num timer. O `auto-optimise-store` faria o mesmo durante cada build e deixaria cada build mais lento.

`system.stateVersion` fica na versão da primeira instalação. Ele fixa formatos de estado, como estrutura de banco de dados e caminhos, não versões de pacotes, então nunca é atualizado em upgrades.

## Fazendo uma mudança

Formate com `nixfmt` (o estilo oficial, RFC 166) e faça o lint com `statix check -i nixos/hosts/*/hardware.nix .`. O statix quer um bloco por opção de nível superior (`services = { ... }`) e nenhuma chave repetida.

Faça o build antes de trocar:

```sh
nix build .#nixosConfigurations.loc-nixos.config.system.build.toplevel
nix store diff-closures /run/current-system ./result
```

Num refactor, o `diff-closures` não deve mostrar nada além do rótulo de versão. Depois, `sudo nixos-rebuild switch --flake ~/dotfiles` ativa o novo sistema. Mudanças no kernel, no initrd ou em drivers precisam de reboot para valer.
