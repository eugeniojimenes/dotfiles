# Git

`git/.gitconfig` define saída colorida, `develop` como branch padrão e um template de mensagem de commit (`git/.gitmessage`) baseado em Conventional Commits.

## Identidade do trabalho

A identidade do trabalho é incluída de forma condicional por `[includeIf "gitdir:~/*-workspace/"]` no fim do `.gitconfig`. O padrão é um glob para casar com a pasta do checkout do trabalho sem dar o nome do empregador, o que um caminho literal faria.

O include aponta para `~/.gitconfig-work`, um symlink para o repo privado `~/.private` (payload `gitwork`, ciphertext `gitconfig-work.age`). O email do trabalho nunca chega neste repo.

Um destino ausente não é erro: o git pula um include cujo caminho não existe. Numa máquina onde o `~/.private` não está desbloqueado, o git cai na seção `[user]` pessoal. O `settings.json` no módulo do Claude Code segue o mesmo raciocínio, veja [claude-code.pt-br.md](claude-code.pt-br.md).

## Hook de pre-commit

`.githooks/pre-commit` recusa um commit que publicaria um segredo ou um termo proibido. Veja [public-repo.pt-br.md](public-repo.pt-br.md).
