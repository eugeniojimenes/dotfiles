# Repo público

Este repo é público no GitHub, com um espelho no GitLab. Dois tipos de conteúdo nunca podem chegar nele.

## Sem segredos

Nenhum token, chave de API, senha, chave SSH ou GPG privada, ou qualquer outra credencial pessoal, em nenhum arquivo. Quando uma config precisa de um segredo, por exemplo por uma variável de ambiente, ela referencia a variável pelo nome e o valor é definido fora do repo. Os valores ficam no repo privado `~/.private`, criptografados com age. Este repo só dá o nome desse lugar e nunca descreve o que tem nele.

## Sem detalhes do empregador

Esta regra cobre o nome da empresa, nomes de ferramentas e repos internos, caminhos internos, nomes de engines e serviços, e nomes de marketplaces. Ela vale para comentários de código, docs, arquivos de agentes, skills e exemplos.

Um comentário que explica por que um contorno existe não precisa de nome próprio. "Uma CLI do trabalho chama `asdf` direto no código" carrega o mesmo raciocínio que um comentário com o nome da ferramenta.

Alguns arquivos ficam fora porque ferramentas gravam detalhes do trabalho neles:

- `/.claude/` na raiz do repo é ignorado, menos os links do harness `.claude/rules` e `.claude/skills`. O Claude Code grava `settings.local.json` ali para este projeto, e as entradas de permissão dele citam ferramentas do trabalho pelo nome.
- `claude-code/.claude/` ignora tudo menos os arquivos que o módulo entrega. Veja [claude-code.pt-br.md](claude-code.pt-br.md), que também explica por que o `settings.json` não é mais rastreado.
- A identidade git do trabalho vem de um arquivo em `~/.private`, veja [git.pt-br.md](git.pt-br.md).

## Buscas

Duas buscas procuram vazamentos.

`bin/check terms` faz grep em todo arquivo e caminho rastreado pelos termos de `~/.private/forbidden-terms`, uma lista guardada criptografada no repo privado e nunca commitada aqui. Ele mostra só `file:line` para cada ocorrência num arquivo, e para uma ocorrência num caminho só o número da linha dele em `git ls-files`, então o termo em si nunca aparece num log. `bin/check terms --cached` varre a versão em stage em vez da árvore de trabalho, e `bin/check terms --message FILE` varre uma mensagem de commit. Quando a lista não existe, como no CI ou num clone novo, a busca é pulada com um aviso e não falha.

O `gitleaks` procura segredos. `bin/check static` (local e no CI) varre a árvore inteira com `gitleaks dir`, e o hook de pre-commit varre as mudanças em stage com `gitleaks git --staged`. Os valores aparecem mascarados na saída.

O hook de pre-commit em `.githooks/pre-commit` roda as duas buscas nas mudanças em stage antes de cada commit e recusa o commit quando encontra algo. O hook commit-msg em `.githooks/commit-msg` roda a busca de termos na mensagem do commit, que também é pública. O hook pre-push em `.githooks/pre-push` roda as duas buscas em cada commit prestes a ser enviado (mensagem, caminhos e linhas adicionadas), porque um rebase ou squash cria commits sem rodar os outros dois. O git só roda o hook depois que o clone aponta para ele, então ative uma vez por clone com `git config core.hooksPath .githooks`. `dotfiles-doctor --fix` faz o mesmo. O hook roda só localmente. O comportamento dele está listado em [specs/pre-commit.md](specs/pre-commit.md).

Quando o hook recusa um commit porque uma ferramenta escreveu num arquivo linkado pelo stow, como um instalador que adiciona um bloco no `~/.bashrc`, reverta esse arquivo com `git checkout <file>`. Nos outros casos, remova o valor e guarde ele fora do repo. Pular o hook com `git commit --no-verify` é possível, mas só com aprovação explícita do dono para aquele commit.

### O que as buscas não pegam

- O gitleaks só encontra segredos que batem com as regras dele: formatos de token conhecidos e strings de alta entropia atribuídas a nomes como `key` ou `token`. Uma senha simples ou um formato de token incomum pode passar.
- A busca de termos só encontra os termos da lista. Um nome interno novo precisa entrar na lista antes de a busca saber dele.
- A busca de termos não roda no CI nem numa máquina onde o `~/.private` está bloqueado. O `dotfiles-doctor` avisa quando a lista não existe.
- O hook não roda quando não está ativado no clone, nem quando um commit usa `--no-verify`.
- O hook commit-msg verifica as mensagens de commit só contra os termos. O gitleaks não varre as mensagens.

## Reescrita do histórico de agosto de 2026

Em 2026-08-20 o nome do empregador e nomes de ferramentas internas foram encontrados em 7 commits na ponta do `develop`, de dois dias antes. Eles foram removidos com `git filter-repo --replace-text`, junto com `--invert-paths --path claude-code/.claude/settings.json`, e enviados com force push para os dois remotes. Todo commit a partir de `a5c3a3a` ganhou um SHA novo. Os 250 commits anteriores não foram tocados.

Se acontecer de novo, faça um backup antes, depois reescreva só o `develop` e faça o force push:

```sh
git bundle create ~/dotfiles-backup.bundle --all
git filter-repo --force --refs develop --replace-text expressions.txt
git push --force-with-lease origin develop
```

`--refs develop` mantém a reescrita longe das outras branches, e também impede o filter-repo de remover o remote `origin`. O `origin` tem duas URLs de push, o GitHub e o espelho no GitLab, e as duas precisam do force push.

Um force push sozinho não apaga nada. Os commits antigos continuam acessíveis pelo SHA no GitHub até o GitHub rodar a coleta de lixo. Quando o vazamento importa, peça ao GitHub Support para limpar as visualizações em cache.
