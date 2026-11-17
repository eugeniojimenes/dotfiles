# Harness

Esta pasta guarda instruções para agentes de IA que trabalham neste repo. Se você não usa um agente de IA, pode ignorá-la, junto com `AGENTS.md`, `CLAUDE.md` e as pastas `.claude/`, `.agents/` e `.cursor/` na raiz do repo. Nada aqui muda o comportamento dos dotfiles.

O `AGENTS.md` na raiz do repo tem as regras que todo agente precisa em toda tarefa. Esta pasta acrescenta dois tipos de arquivo que só carregam quando importam:

- `rules/<área>.md`: regras para uma parte do repo. Cada arquivo declara no frontmatter os caminhos a que se aplica, e uma ferramenta que entende isso só carrega a regra quando o agente mexe num arquivo que bate com eles.
- `skills/<nome>/SKILL.md`: procedimentos passo a passo para tarefas recorrentes, com critérios de aceite e armadilhas conhecidas. O agente carrega uma skill quando a tarefa bate com a descrição dela. Uma skill pode ter uma pasta `references/` com exemplos.

As regras e skills são escritas em inglês, no estilo comprimido descrito no `AGENTS.md`. Os motivos por trás delas estão em [docs/](../docs/README.pt-br.md).

## Regras e skills atuais

| Regra | Vale para |
| --- | --- |
| `rules/nixos.md` | `nixos/**`, `flake.nix`, `flake.lock` |
| `rules/sway.md` | `sway/**` |
| `rules/tests.md` | `tests/**`, `docs/specs/**`, `bin/check` |
| `rules/writing.md` | todo arquivo `.md` |

| Skill | Uso |
| --- | --- |
| `nixos-change` | Mudar a config do sistema, fazer o build, comparar, passar o switch para o dono, conferir. |
| `new-host` | Adicionar uma máquina: pasta do host, entrada no flake, saídas do Sway, checklist manual. |
| `add-keybinding` | Adicionar um atalho do Sway com título e checagem de conflito. |
| `add-panel` | Adicionar um painel Quickshell seguindo o padrão dos painéis existentes. |
| `new-feature` | Entregar uma funcionalidade começando pela spec: critérios, testes, código, docs. |

## Qual ferramenta lê o quê

Os arquivos ficam só em `harness/`. Cada ferramenta os encontra por symlinks na pasta que ela já lê.

| Ferramenta | Instruções | Regras | Skills |
| --- | --- | --- | --- |
| Claude Code | `CLAUDE.md`, que importa o `AGENTS.md` | `.claude/rules` aponta para `harness/rules` e lê a chave `paths:` | `.claude/skills` aponta para `harness/skills` |
| Cursor | `AGENTS.md` | `.cursor/rules/<área>.mdc` aponta para cada arquivo de regra e lê as chaves `globs:` e `alwaysApply:` | lê `.claude/skills` e `.agents/skills` |
| Codex | `AGENTS.md` | nenhuma, só o `AGENTS.md` | `.agents/skills` aponta para `harness/skills` |
| OpenCode | `AGENTS.md` | nenhuma, só o `AGENTS.md` | lê `.claude/skills` e `.agents/skills` |

Observações sobre a tabela, conferidas na documentação de cada ferramenta em novembro de 2026:

- O Claude Code só lê `paths:` do frontmatter de uma regra e ignora as outras chaves. O Cursor lê `description`, `globs` (uma string separada por vírgulas) e `alwaysApply`. Por isso cada regra tem `paths:` e `globs:` com os mesmos padrões.
- O Cursor só carrega arquivos de regra com extensão `.mdc`, então `.cursor/rules/` tem um link `.mdc` por regra em vez de um link para a pasta inteira. A documentação do Cursor não diz se ele segue symlinks nessa pasta, e o Cursor não estava instalado aqui para testar.
- O Codex não tem arquivos de regra por caminho. As instruções dele vêm de arquivos `AGENTS.md`, um por pasta. O recurso "rules" dele controla quais comandos podem rodar, o que é outra coisa.
- O OpenCode também não tem regras por caminho. A opção `instructions` dele sempre carrega os arquivos listados. Ele acha as skills em `.claude/skills` e `.agents/skills` sem nenhum link extra.
- O Cursor e o OpenCode leem `.claude/skills` e `.agents/skills`, que apontam para os mesmos arquivos. O `opencode debug skill` lista cada skill uma vez só, vinda de `.agents/skills`. O Cursor pode listar uma skill duas vezes.
- Conferido aqui em novembro de 2026: uma sessão do Claude Code carrega o `AGENTS.md` pelo `CLAUDE.md`, enxerga as cinco skills e carrega `rules/sway.md` depois de ler um arquivo dentro de `sway/`.

## Adicionar uma regra

1. Escreva `harness/rules/<área>.md` com este frontmatter, listando os mesmos padrões nas duas chaves:
   ```yaml
   ---
   description: <uma linha>
   paths:
     - "<glob>"
   globs: <glob>, <glob>
   alwaysApply: false
   ---
   ```
2. Crie o link para o Cursor: `ln -s ../../harness/rules/<área>.md .cursor/rules/<área>.mdc`.
3. Adicione a regra na tabela acima e no `README.md`.

## Adicionar uma skill

1. Escreva `harness/skills/<nome>/SKILL.md` com `name` e `description` no frontmatter. A descrição diz o que a skill faz e quando usar, porque é com ela que o agente compara a tarefa. O corpo tem os passos, os critérios de aceite e as armadilhas.
2. Nenhum link é necessário: os links de pasta já cobrem skills novas.
3. Adicione a skill na tabela acima e no `README.md`.

Faça `git add` nos arquivos novos antes de rodar o `bin/check`, que também procura travessões neles.
