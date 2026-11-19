# NixOS

A configuração do sistema fica em `nixos/` e no `flake.nix` na raiz do repo. `nixos/` não é um módulo do stow: não tem conteúdo com prefixo de ponto, então o stow e o `dotfiles-doctor` o ignoram.

## Estrutura

O `flake.nix` define um `nixosConfigurations.<hostname>` por máquina. O nome do atributo é o hostname, então `sudo nixos-rebuild switch --flake ~/dotfiles` escolhe o sistema certo sozinho. O flake segue o branch `nixos-26.05`, e o `flake.lock` fixa a revisão exata do nixpkgs. O `bin/update` move o lock (veja [Atualizando](#atualizando)). Um segundo input, `nixpkgs-unstable`, fornece os poucos pacotes que o branch estável tem velhos demais, por enquanto só o mise: a 2026.5.12 do 26.05 quebra o `mise install` com uma entrada do `.tool-versions` listada em `disable_tools`, corrigido na 2026.6.4. O `bin/update` não move esse input; quem move é `nix flake update nixpkgs-unstable`. Ele sai na mudança para o 26.11.

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
- Uma cópia do `analog-input-internal-mic.conf` do PipeWire em `/etc/alsa-card-profile` que fixa o `Internal Mic Boost` em 0 dB. O arquivo original soma o boost ao volume do microfone, então 100% significava +60 dB de ganho e o microfone interno estourava só com o ruído do ambiente. Apps com ganho automático, como o Google Meet, levam o volume a 100%. Com o boost fixo, 100% é +30 dB vindos só do controle `Capture`. O PipeWire lê `/etc/alsa-card-profile` antes dos próprios arquivos, e o build falha se uma atualização do PipeWire renomear a seção, então a correção não para de funcionar sem aviso.

## Login

O greetd entra direto no Sway rodando `~/.config/sway/bin/start`. O disco é criptografado com LUKS, então a senha no boot já protege a máquina e uma segunda senha não acrescentaria nada. Ao sair do Sway aparece o tuigreet.

## Suporte do shell

`programs.fzf.keybindings` e o bash completion do NixOS substituem o que o módulo `bash` carregava de `/usr/share` no Arch.

`programs.nix-ld` deixa binários pré-compilados rodarem. O mise e o Mason baixam binários (Node, Python, Ruby, rustup, language servers) que esperam `/lib64/ld-linux-x86-64.so.2`. O `icu` entra no conjunto padrão de bibliotecas porque binários .NET, como o marksman do Mason, abortam sem `libicu`.

## Portals

Os portals vêm dos padrões do módulo Sway do NixOS: o `xdg-desktop-portal-wlr` cuida do compartilhamento de tela e das capturas de tela, e o `xdg-desktop-portal-gtk` cuida do resto, incluindo o seletor de arquivos. O seletor de compartilhamento de tela é definido em `xdg.portal.wlr.settings`, porque o módulo inicia o portal wlr com uma config gerada dessas settings e nunca lê `~/.config/xdg-desktop-portal-wlr`. O serviço de usuário do portal também recebe `/run/current-system/sw` no `PATH`, porque o dele tem pouco além de coreutils, grim e slurp, e o seletor precisa do fuzzel e do Quickshell.

O Nautilus como backend do FileChooser foi testado e abandonado. Na inicialização o portal ativa o Nautilus, e o Nautilus chama o portal de volta enquanto ainda está iniciando, então os dois ficam esperando um pelo outro por 25 segundos. Todo app GTK aberto nesse intervalo travava, e o waybar morria no login.

## Bluetooth

Nenhum agente de pareamento Bluetooth roda, porque o painel do Sway não registra um. Sem agente, o BlueZ deixa o adaptador sem bonding: o pareamento funciona mas nunca fica salvo, o `bluetoothctl info` mostra `Bonded: no` e o aparelho precisa parear de novo depois da primeira desconexão. `hardware.bluetooth.settings.General.AlwaysPairable = true` mantém o bonding ligado. Aparelhos que pedem PIN ou senha ainda precisam de um agente, que o `bluetoothctl` fornece.

## Endereço MAC do Wi-Fi

O NetworkManager conecta com um endereço MAC gerado por nome de rede (`wifi.macAddress = "stable-ssid"`) em vez do endereço real da placa. O roteador de casa continua vendo sempre o mesmo endereço, e cada outra rede vê um diferente, então visitas a lugares diferentes não podem ser ligadas pelo MAC. O MAC usado durante a busca de redes já é aleatório por padrão do NetworkManager.

O MAC vai em todo pacote pelo ar, então qualquer um por perto consegue registrá-lo sem entrar na rede, e o MAC por rede cobre isso. Mas ele é a única coisa que muda por rede. O DHCP ainda envia o hostname, `loc-nixos`, para toda rede, e o DHCPv6 envia um DUID feito a partir do machine ID, o mesmo em todo lugar, porque os padrões do NetworkManager foram mantidos. Uma rede que registra qualquer um dos dois consegue ligar as visitas, e este repo é público e cita o host. Redes com o mesmo nome em lugares diferentes, como eduroam ou uma rede de cafés, também recebem o mesmo MAC. Desligar os dois são três configurações do NetworkManager (`ipv4.dhcp-send-hostname` e `ipv6.dhcp-send-hostname` em false, `ipv6.dhcp-duid` em `stable-uuid`); o custo é que o roteador de casa lista o notebook pelo MAC em vez do nome.

## DNS

O DNS fica como a rede entrega: consultas em texto puro para o roteador em casa e para quem controla a rede em outros lugares. Essa rede vê todo domínio consultado e pode responder com um endereço falso, embora o HTTPS continue protegendo o conteúdo das conexões. Duas mudanças foram avaliadas em novembro de 2026 e ficaram para depois, porque o notebook raramente usa Wi-Fi público.

- DNS over TLS estrito: `services.resolved` com `DNSOverTLS=true` e um servidor fixo (Quad9 ou Cloudflare), ignorando o DNS do DHCP. Toda consulta vai cifrada e não pode ser alterada no caminho. Portais cativos de hotel e aeroporto param de abrir até desligar para aquela rede, uma VPN de trabalho com nomes internos precisa de `dns-over-tls=no` na conexão do NetworkManager, e a empresa do servidor vê as consultas no lugar da operadora.
- DNS over TLS oportunista: o mesmo com `DNSOverTLS=opportunistic`. Nada quebra, e as consultas ficam escondidas de quem só observa a rede, mas uma rede hostil pode bloquear o TLS e as consultas voltam para texto puro. O `omarchy-setup-dns cloudflare` do Omarchy faz isso (Cloudflare, Quad9 de reserva), e o padrão dele é o DNS da rede, como aqui.

Antes de qualquer uma, confira que o NetworkManager para de passar o DNS do DHCP para o resolved (`resolvectl status` lista só os servidores escolhidos), senão a mudança não protege nada.

## Hibernação

Só o notebook hiberna. O `nixos/hosts/loc-nixos/default.nix` acrescenta um swapfile de 16 GiB em `/var/lib/swapfile`, do mesmo tamanho da RAM, para que a memória cheia ainda caiba. Ele fica no root com LUKS, então a imagem da RAM gravada nele é cifrada como todo o resto do disco. O zram mantém prioridade 5 e o swapfile -2, então o swap do dia a dia continua indo primeiro para o zram.

O kernel encontra a imagem pelo `boot.resumeDevice`, que lê o dispositivo do root no `hardware.nix`, e pelo `resume_offset`, a posição física do primeiro bloco do swapfile nesse dispositivo. O offset vem de `sudo filefrag -v /var/lib/swapfile` (o `physical_offset` do extent 0) depois que o arquivo existe, então uma máquina nova é configurada em dois passos: um switch só com o swapfile, depois o offset e um `nixos-rebuild boot` com reboot. Recriar o swapfile, por exemplo com outro tamanho, muda a posição dele e exige um offset novo.

Fechar a tampa roda `suspend-then-hibernate`. Na bateria, o notebook hiberna depois de 2 horas suspenso (`HibernateDelaySec`), e na tomada continua suspenso (`HibernateOnACPower = false`). O atraso existe porque esta bateria tem um trip point ACPI: sem atraso, o systemd pula a estimativa de consumo e só hiberna quando o firmware acorda a máquina no trip point e marca o despertar como alarme de bateria, e o firmware deste notebook deixa essa marca em "Power Switch" depois de voltar do sono profundo, então sem o atraso a bateria acabaria em suspensão. System › Suspend no menu faz o mesmo, e System › Hibernate hiberna na hora; o menu só mostra essa entrada quando `/sys/power/resume` está definido, então o desktop sem swapfile não a oferece. O UPower hiberna com 4% de bateria em vez de desligar. Os 4% dão margem para uma leitura de bateria que desvia perto do fim conforme a bateria envelhece, e o aviso crítico passa para 7%, para continuar vindo alguns minutos antes. O swayidle trava a sessão antes de qualquer um deles. O driver open da NVIDIA preserva a memória de vídeo na hibernação sozinho (`UseKernelSuspendNotifiers=1`), sem o serviço `nvidia-hibernate`. A spec é [docs/specs/hibernation.md](specs/hibernation.md).

## Tema e cursor

O modo escuro é definido por padrões do dconf, que o `gsettings set` ainda pode sobrescrever. `color-scheme = "prefer-dark"` cobre GTK4, libadwaita e Chromium. O GTK3 ignora essa chave e precisa de um tema pelo nome. O GTK3 puro não vem com um tema `Adwaita-dark`, e um nome de tema desconhecido cai no Adwaita claro, e era por isso que o seletor de arquivos e outros apps GTK3 continuavam claros. O `adw-gtk3-dark` (do pacote `adw-gtk3`) deixa os apps GTK3 com a cara dos apps libadwaita.

O NixOS não define tema de cursor padrão, então o Sway desenhava os cursores antigos do núcleo do X11. O `adwaita-icon-theme` já estava na closure como dependência do GTK. Agora ele é instalado explicitamente e configurado tanto no Sway (`seat * xcursor_theme Adwaita 24`) quanto no dconf para o GTK.

## Gerações e coleta de lixo

Cada rebuild cria uma nova geração e uma nova entrada de boot, e é isso que torna o rollback possível: `sudo nixos-rebuild switch --rollback`, ou escolha uma entrada mais antiga no menu de boot. O systemd-boot mantém 10 entradas para a ESP de 1 GB não encher. O menu aparece por 1 segundo em vez de 5; apertar uma seta nesse segundo para a contagem. O menu não permite editar a linha de comando do kernel (`boot.loader.systemd-boot.editor = false`). Com isso liberado, acrescentar `init=/bin/sh` no menu dá um shell de root sem senha. A senha do LUKS continua protegendo os dados, mas a opção não custa nada, e um boot quebrado se resolve escolhendo uma entrada mais antiga.

Gerações antigas mantêm toda a closure delas no disco. O `nix.gc` roda toda semana e apaga gerações com mais de 30 dias. A deduplicação do store usa `nix.optimise.automatic`, que cria hard links entre arquivos idênticos num timer. O `auto-optimise-store` faria o mesmo durante cada build e deixaria cada build mais lento.

`system.stateVersion` fica na versão da primeira instalação. Ele fixa formatos de estado, como estrutura de banco de dados e caminhos, não versões de pacotes, então nunca é atualizado em upgrades.

## Atualizando

O `bin/update` roda uma etapa por fonte e para na primeira que falhar, então uma quebra aponta para uma fonte só: o sistema, as ferramentas do mise, os plugins do lazy.nvim e, por fim, uma verificação de firmware que só informa o que o `fwupdmgr` oferece. Ele nunca roda `sudo` e nunca faz commit. No final, e também quando uma etapa seguinte falha ou a execução é interrompida com Ctrl-C, mostra o comando que aplica o sistema e os arquivos de lock a commitar, o `flake.lock` como `build(nixos): flake update` e o `lazy-lock.json` como `build(lazyvim): plugin update`.

A etapa do sistema lê a lista de releases do canal do NixOS. Um release do canal passou pelos testes do Hydra e tem os pacotes no cache binário, o que um commit qualquer do branch não garante. O script usa o release mais novo publicado há pelo menos 2 dias. Num branch estável as mudanças são backports revisados, então a espera serve para dar tempo de regressões aparecerem. Um release mais novo pula a espera quando corrige um CVE com nota CVSS 7.0 ou mais nesta máquina: o vulnix analisa o sistema atual e o mais novo, e um CVE encontrado só no atual conta como corrigido quando o pacote faz parte do sistema em execução. A análise também cobre ferramentas usadas só para construir pacotes, que nunca chegam à máquina, então essas ficam de fora. O vulnix compara nomes e versões de pacotes com a base da NVD e gera falsos positivos, mas eles aparecem nos dois lados e se cancelam. A primeira execução baixa os dados da NVD, cerca de 400 MB. `bin/update --now` usa o release mais novo sem esperar. Um release já travado que é mais novo que o escolhido pela espera, pego com `--now` ou por um CVE, continua travado, então uma execução seguinte nunca volta para um mais velho. Quando uma análise do vulnix falha, a espera vale. Enquanto o `flake.lock` aponta para um release ainda não construído, uma falha ou um Ctrl-C o restaura.

Depois de travar o lock, o `bin/check` roda com os pacotes novos, então os painéis do Quickshell carregam com o Quickshell novo e o `sway -C` lê a config com o Sway novo antes de qualquer coisa ser aplicada. Uma falha restaura o `flake.lock`. Em seguida o sistema novo é construído e comparado com o que está rodando com `nvd diff`. Quando o kernel, os módulos dele ou o initrd mudaram, o script manda rodar `sudo nixos-rebuild boot` e reiniciar: um `switch` manteria o módulo antigo da NVIDIA carregado sob um driver de userspace novo, e os apps de GPU falham até o reboot. Caso contrário, manda rodar `sudo nixos-rebuild test`, que volta atrás no próximo boot, e o `switch` quando o sistema estiver funcionando.

O mise espera 7 dias por releases novos (`minimum_release_age` na config dele). As ferramentas dele são publicadas direto pelos mantenedores, e as CLIs de agente entre elas rodam com acesso ao shell e ao código, então recebem a espera mais longa contra ataques de supply chain. Análises de ataques de supply chain conhecidos mostraram que a maioria dos releases maliciosos foi retirada em menos de uma semana. O padrão embutido do mise é de 24 horas, então os 7 dias são definidos explicitamente.

## Fazendo uma mudança

Formate com `nixfmt` (o estilo oficial, RFC 166) e faça o lint com `statix check -i 'nixos/hosts/*/hardware.nix' .`. O statix quer um bloco por opção de nível superior (`services = { ... }`) e nenhuma chave repetida.

Faça o build antes de trocar:

```sh
nix build .#nixosConfigurations.loc-nixos.config.system.build.toplevel
nix store diff-closures /run/current-system ./result
```

Num refactor, o `diff-closures` não deve mostrar nada além do rótulo de versão. Depois, `sudo nixos-rebuild switch --flake ~/dotfiles` ativa o novo sistema. Mudanças no kernel, no initrd ou em drivers precisam de reboot para valer.
