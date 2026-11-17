# Máquinas

Hoje o repo atende o notebook `loc-nixos`. Um desktop com GPU AMD e dois monitores entra depois e ainda não tem hostname. Tudo o que vale para uma só máquina vai nos arquivos dela, nunca nos compartilhados.

## O que é por máquina

- `nixos/hosts/<hostname>/default.nix`: o hostname, o driver da GPU e suas opções (bus IDs do NVIDIA PRIME, `i915` no initrd, `services.xserver.videoDrivers`) e serviços ligados ao fabricante da CPU, como o `thermald`, que é para CPUs Intel.
- `nixos/hosts/<hostname>/hardware.nix`: a config de hardware gerada, commitada sem alterações.
- `flake.nix`: uma linha `nixosConfigurations.<hostname>` por máquina.
- `sway/.config/sway/hosts/<hostname>`: as linhas `output` daquela máquina. O Sway inclui esse arquivo depois de `config.d/*`, então ele pode sobrescrever qualquer coisa lá, e uma máquina sem o arquivo roda só com as partes compartilhadas.
- `tests/manual.md`: uma seção de verificações de hardware por máquina.

As saídas são identificadas por `"make model serial"`, como mostra o `swaymsg -t get_outputs -p`, nunca pelo nome do conector. Nomes de conector como `eDP-1` mudam conforme a ordem em que os drivers carregam: a tela do notebook era `eDP-2` no Arch e é `eDP-1` aqui.

## Itens só do notebook para rever no desktop

Estes ficam em arquivos compartilhados hoje e só importam no notebook. Verifique cada um quando o desktop chegar.

- `sway/.config/sway/panels/display/reinit` é o hook pós-suspensão para monitores externos na NVIDIA. Não faz mal em outro hardware.
- A ordem das GPUs em `sway/.config/sway/bin/start` não faz nada numa máquina com uma GPU só.
- O bloco `input` do touchpad não faz nada numa máquina sem touchpad.
- As ferramentas de monitoramento de GPU AMD (`amdgpu_top`, `rocm-smi`) vão no arquivo de host do desktop.

## Adicionando uma máquina

Instale primeiro o NixOS puro. Depois, dentro do clone, crie `nixos/hosts/<hostname>/` e grave nela a config de hardware da máquina com `nixos-generate-config --show-hardware-config > nixos/hosts/<hostname>/hardware.nix`. Escreva o `default.nix` usando o arquivo do notebook como modelo e deixe de fora as partes de NVIDIA, PRIME, `i915` e `thermald`, a menos que a máquina nova tenha esse hardware. Adicione uma entrada `nixosConfigurations.<hostname>` no `flake.nix`.

Em seguida, escreva `sway/.config/sway/hosts/<hostname>` com as linhas `output` da máquina, adicione uma seção para ela em `tests/manual.md` e rode `git add` em cada arquivo novo, já que o flake só enxerga arquivos rastreados. Faça o build e instale com `sudo nixos-rebuild boot --flake ~/dotfiles#<hostname>` e reinicie. Depois do reboot o hostname bate e o `nixos-rebuild switch --flake ~/dotfiles` simples funciona.

Se a máquina precisar de uma linha de saída de monitor antes de o Sway ter rodado nela, inicie o Sway uma vez sem o arquivo de host, leia os nomes no `swaymsg -t get_outputs -p` e adicione depois.

Agentes de IA que trabalham neste repo têm uma skill `new-host` em `harness/skills/` que segue os mesmos passos.
