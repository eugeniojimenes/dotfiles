# Módulo do Claude Code

O módulo `claude-code` guarda minha configuração global do Claude Code. O stow coloca ele em `~/.claude/`. É uma coisa diferente dos arquivos de projeto na raiz do repo (`AGENTS.md`, `CLAUDE.md`, `.claude/`, `harness/`), que só valem para sessões dentro deste repo.

## Conteúdo

- `claude-code/.claude/CLAUDE.md`: instruções globais, principalmente feedback para o aprendizado de inglês.
- `claude-code/.claude/skills/`: skills próprias.
- `claude-code/.claude/statusline-command.sh`: a status line.

Os arquivos em `claude-code/.claude/` são texto de prompt, não documentação. As skills usam o travessão como separador de lista que o modelo lê, e reescrever esse texto mudaria o comportamento do modelo. Eles ficam como estão e ficam fora da varredura de travessões.

## Link arquivo por arquivo

O stow linka este módulo arquivo por arquivo em vez de linkar a pasta inteira, porque `~/.claude/` já guarda estado de execução que não é rastreado: `plugins/`, `projects/`, `ide/`, `settings.local.json`. Esse estado fica fora do repo porque o stow nunca linka a pasta em si. Nenhuma entrada do `.gitignore` faz esse trabalho.

O Claude Code também trata `claude-code/.claude/` como pasta de configurações de projeto quando uma sessão começa em qualquer lugar dentro de `claude-code/`, e grava o `settings.json` dele ali. Por isso o `.gitignore` ignora tudo nessa pasta, menos os arquivos que o módulo entrega. O Claude Code também sincroniza as skills da conta do claude.ai em `skills/synced/`, que é ignorada pelo mesmo motivo.

## Por que o settings.json não é rastreado

O `settings.json` era rastreado aqui. Ele foi removido porque as duas chaves que o Claude Code grava nele vazavam detalhes do trabalho para este repo público. `extraKnownMarketplaces` guarda URLs git internas. `enabledPlugins` dá o nome de cada plugin junto com o marketplace dele, então um marketplace do trabalho aparece pelo nome. A segunda é fácil de passar batido, já que cada valor parece um booleano inofensivo. O histórico do repo foi reescrito para remover o arquivo, veja [public-repo.pt-br.md](public-repo.pt-br.md).

Agora o arquivo é local da máquina, um arquivo real em `~/.claude/settings.json` e não um symlink para este módulo. Uma cópia criptografada fica no repo privado `~/.private` (`claude-settings.json.age`), então ela sobrevive a uma reinstalação da máquina. `~/.private/private unlock` descriptografa o arquivo direto no caminho em uso. Rode isso antes de registrar os marketplaces de novo com `claude plugin marketplace add <url>`. O registro em si continua local da máquina, em `~/.claude/plugins/known_marketplaces.json`.

Configurações que não carregam nada privado (modelo, status line, opções da TUI) poderiam ir para um arquivo rastreado no futuro, se um dia houver motivo. Hoje um arquivo basta.

O `dotfiles-doctor` aponta `~/.claude/settings.json` quando ele é um symlink ou não existe.
