# Brazilian Portuguese reference

Pattern IDs and strengths match the catalog in `SKILL.md`; this file adds pt-BR triggers, fixes and examples. pt.wikipedia's "Sinais de texto gerado por inteligência artificial" is a translation of the English page (its phrase boxes say "traduzidas do inglês"), so native pt-BR triggers here come mostly from pt-BR press lists, the Enem study and the open-source "humanizar" skill.

Source tags: `[wiki]` = pt.wikipedia, translated from en. `[imprensa]` = Exame, Gazeta do Povo, Fast Company Brasil, Canaltech, Sabbatini (IAEdPraxis). `[Enem]` = Barbosa, Caiado, Bezerra 2025 (peer-reviewed, ChatGPT redações). `[humanizar]` = fabricioctelles "humanizar" skill: reasoned, not measured. No pt-BR corpus frequency study was found; English frequency findings do not transfer automatically to Portuguese.

Contents: [A. Leftovers](#a-leftovers) · [B. Staging](#b-staging) · [C. Inflation](#c-inflation) · [D. Vocabulary and hedging](#d-vocabulary-and-hedging) · [E. Formatting](#e-formatting) · [F. Rhythm](#f-rhythm) · [pt-BR-only patterns](#pt-br-only-patterns) · [Travessão](#travessão) · [Não corrigir](#não-corrigir)

## A. Leftovers

### A1 Resíduo de chatbot
- **Gatilhos**: "Claro! Aqui está o texto sobre o tema", "Certamente!", "Ótima pergunta!", "Você tem toda a razão!", "Espero ter ajudado!", "Espero que isto ajude", "Fique à vontade para perguntar mais!", "Me avise se...", "Quer que eu explique...?", "Posso ajudar com mais alguma coisa?" `[wiki]` `[imprensa]`. "Espero que esta mensagem o encontre bem" = calque of "I hope this message finds you well" `[imprensa]`.
- **Fix**: delete.
- **Exemplo** (e-mail corporativo):
  - Antes: "Claro! Aqui está uma versão do e-mail: Prezada Marina, espero que esta mensagem a encontre bem. Segue o relatório de vendas de outubro. Espero ter ajudado! Quer que eu deixe o tom mais formal?"
  - Depois: "Prezada Marina, segue o relatório de vendas de outubro."
- **Don't**: remove closing courtesies of a real e-mail ("Estou à disposição", "Qualquer dúvida, é só chamar", "Atenciosamente"). Those address the recipient, not the chatbot user.

### A2 Ressalvas de modelo
- **Gatilhos**: "Até minha última atualização de conhecimento", "Como modelo de linguagem de IA", "como grande modelo de linguagem", "Não posso oferecer aconselhamento médico, mas posso...", "Sinto muito, mas não posso", "Não tenho acesso a dados em tempo real", "as informações podem variar" `[wiki]`.
- **Fix**: delete. If the disclaimer hides a real gap (date of the data), list it under Needs the author.
- **Exemplo** (artigo de saúde):
  - Antes: "Até minha última atualização, a vacina estava disponível apenas para maiores de 60 anos. É importante lembrar que as informações podem variar."
  - Depois: "A vacina estava disponível apenas para maiores de 60 anos." Needs the author: "a partir de quando?"
- **Don't**: cut a disclaimer the author wrote for readers ("Este conteúdo não substitui consulta médica").

### A3 Placeholders
- **Gatilhos**: "[Seu Nome]", "[Nome da Empresa]", "[inserir dado]", "XX de XXXX", "2025-XX-XX", "R$ X mil", "[DADO OU EXEMPLO REAL NECESSÁRIO]", links para example.com.
- **Fix**: flag under Needs the author, leave the placeholder visible.
- **Exemplo** (bio):
  - Antes: "Com mais de [X] anos de experiência, [Nome] lidera a área de dados da [Empresa]."
  - Depois: unchanged. Needs the author: X, Nome, Empresa.
- **Don't**: fill with plausible data.

### A4 Artefatos de ferramenta
- **Gatilhos**: language-independent, same list as `SKILL.md` A4 (`oaicite`, `turn0search0`, `[cite: 3]`, `【4†L1-L5】`, `utm_source=chatgpt.com`).
- **Fix**: strip the artifact or the tracking parameter, keep the URL and the sentence.
- **Exemplo** (relatório):
  - Antes: "A evasão caiu no segundo semestre [cite: 3]. Fonte: https://exemplo.org/relatorio?utm_source=chatgpt.com"
  - Depois: "A evasão caiu no segundo semestre. Fonte: https://exemplo.org/relatorio"
- **Don't**: touch other query parameters; they may be needed.

### A5 Falar do próprio documento
- **Gatilhos**: "Neste artigo, vamos explorar", "Nesta seção, discutiremos" `[wiki]`, "Vamos mergulhar nesse assunto:", "Vamos destrinchar:" `[humanizar]`, "Vamos dar uma olhada mais de perto" `[imprensa]` (vendor source), "Ao longo deste texto, você vai entender", "A tabela abaixo mostra", first sentence repeating the heading.
- **Fix**: delete; start on the content.
- **Exemplo** (doc técnica, under heading "Configurar o cache"):
  - Antes: "Nesta seção, vamos explorar como configurar o cache. Vamos mergulhar nesse assunto! O arquivo fica em `config/cache.yml`."
  - Depois: "O arquivo fica em `config/cache.yml`."
- **Don't**: cut structural signposting in theses, TCCs and long manuals ("No capítulo 3, apresenta-se o método"). Genre convention.

## B. Staging

### B1 Paralelismo negativo
- **Gatilhos**: "não é apenas X, mas também Y", "não se trata de X, mas de Y", "não se trata apenas de X, mas de Y" `[imprensa]`, "mais do que X, é Y", "é mais do que um X, é um Y", "vai muito além de", "transcende o simples X" `[humanizar]`, "Não é sobre X, é sobre Y" `[imprensa]`, "Y em vez de X", "em vez de simplesmente" `[wiki]`. Split form, from real posts `[imprensa]`: "Não era narrativa política. Era aviso." Trailing form: "O país precisa de pacificação, não de vingança."
- **Fix**: state Y directly. Drop X unless someone actually claimed it.
- **Exemplo** (post LinkedIn):
  - Antes: "Liderança não é sobre cargo. É sobre exemplo. Mais do que gerir tarefas, um bom gestor inspira pessoas."
  - Depois: "Um bom gestor lidera pelo exemplo e inspira a equipe, além de gerir tarefas."
- **Don't**: rewrite a contrast that corrects a stated fact ("O prazo não é dia 10, é dia 12.").

### B2 Tríades forçadas
- **Gatilhos**: three adjectives in a row ("um ambiente dinâmico, colaborativo e inovador"), stock triads ("clareza, concisão e coerência" `[humanizar]`, "resiliência, riqueza cultural e beleza natural" `[wiki]`), three parallel short sentences, three bullets where the content has two or four.
- **Fix**: keep the items the content supports, drop the near-duplicates.
- **Exemplo** (release notes):
  - Antes: "A nova versão é mais rápida, mais estável e mais confiável."
  - Depois: "A nova versão é mais rápida e mais estável."
- **Don't**: shorten a real list of three (três requisitos do edital). After merging, check every fact survived.

### B3 Kickers e revelações
- **Gatilhos**: "O resultado? …", "O segredo? …", "E aqui mora o perigo:" `[humanizar]`, "E isso muda tudo.", "Simples assim.", "As possibilidades são infinitas.", one-line punchline paragraph, moralizing closer: "O silêncio também é uma escolha. E a neutralidade, diante do mal, nunca foi virtude." `[imprensa]`
- **Fix**: fold into the previous sentence or delete.
- **Exemplo** (blog de engenharia):
  - Antes: "Migramos o banco para o PostgreSQL 16. O resultado? Consultas 40% mais rápidas. E isso muda tudo."
  - Depois: "Migramos o banco para o PostgreSQL 16, e as consultas ficaram 40% mais rápidas."
- **Don't**: flatten a crônica or opinion column that uses closing lines deliberately; cut only the stock ones.

### B4 Pigarro e falso insight
- **Gatilhos**: "Em um mundo cada vez mais...", "No mundo atual, cada vez mais..." `[imprensa]`, "No cenário atual...", "Na contemporaneidade...", "Em meio a um cenário de...", "É inegável que..." `[humanizar]`, "Eis a questão:", "A grande sacada é:", "Sendo honesto aqui...", "Imagine um mundo onde..." `[humanizar]`, "A verdade é que", "O que pouca gente percebe é que".
- **Fix**: delete the frame, start on the claim.
- **Exemplo** (post LinkedIn):
  - Antes: "Em um mundo cada vez mais conectado, a cibersegurança deixou de ser opcional. A grande sacada é: a maioria dos ataques começa por um e-mail."
  - Depois: "A cibersegurança deixou de ser opcional. A maioria dos ataques começa por um e-mail."
- **Don't**: treat these as strong in a redação; see P7.

### B5 Fechos formulaicos
- **Gatilhos**: "Em suma", "Em síntese", "Em resumo", "Em conclusão", "Concluindo", "Diante do exposto", "De modo geral" `[wiki]` `[imprensa]`; "Apesar dos desafios", "Apesar desses desafios, X continua a prosperar" `[wiki]`; "desafios e oportunidades", "rumo a um futuro", "O futuro é promissor" `[humanizar]`; "É por isso que X é tão importante" `[imprensa]`.
- **Fix**: delete recap paragraphs that only repeat. Keep any new fact, without the marker.
- **Exemplo** (artigo sobre cidade):
  - Antes: "Apesar dos desafios de mobilidade, Campinas continua a prosperar e se consolida como polo tecnológico. Em suma, o futuro da cidade é promissor."
  - Depois: "Campinas é um polo tecnológico, apesar dos problemas de mobilidade."
- **Don't**: cut "Diante do exposto" in a petição or the conclusion of a redação or TCC. Genre-required.

### B6 Metadiscurso interpretativo
- **Gatilhos**: "Isso importa porque", "Por que isso importa?", "Isso importa.", "acrescenta outra camada" (from TabNews, translated English n-grams, unverified for pt), "Essa distinção é importante", "Esse ponto merece atenção" `[wiki]`.
- **Fix**: delete the signpost; the reason after it stands alone.
- **Exemplo** (doc técnica):
  - Antes: "O token expira em 15 minutos. Por que isso importa? Porque requisições longas podem falhar no meio."
  - Depois: "O token expira em 15 minutos, então requisições longas podem falhar no meio."
- **Don't**: rename a README section like "Por que usar X". Normal heading.

## C. Inflation

### C1 Importância e legado
- **Gatilhos**: "representa um marco", "um marco na história de", "desempenha um papel crucial/fundamental/vital/decisivo", "deixou uma marca indelével", "moldando o futuro de", "preparando o terreno para", "ponto de inflexão", "ponto de virada decisivo", "é um testemunho de", "serve como um lembrete", "legado duradouro", "profundamente enraizado", "reflete tendências mais amplas" `[wiki]` `[humanizar]`.
- **Fix**: replace with the concrete fact; cut when there is none.
- **Exemplo** (artigo histórico):
  - Antes: "Inaugurada em 1922, a estação representa um marco na história ferroviária paulista e deixou uma marca indelével na identidade do bairro."
  - Depois: "A estação foi inaugurada em 1922."
- **Don't**: cut significance backed by a fact in the text ("foi a primeira estação eletrificada do estado").

### C2 Tom promocional
- **Gatilhos**: "aninhado no coração de", "no coração de", "vibrante", "rica herança cultural", "ostenta", "de tirar o fôlego", "gama diversificada", "beleza natural", "renomado", "compromisso com" `[wiki]`; corporate: "potencializar resultados e impulsionar o crescimento" `[imprensa]`.
- **Fix**: neutral verb, plain fact ("tem", "fica em").
- **Exemplo** (guia de turismo):
  - Antes: "Aninhada no coração da Serra da Mantiqueira, Gonçalves ostenta paisagens de tirar o fôlego e uma vibrante cena gastronômica."
  - Depois: "Gonçalves fica na Serra da Mantiqueira e é conhecida pela paisagem e pela gastronomia."
- **Don't**: neutralize ad copy or a landing page. There, remove only the stock phrases and keep the selling.

### C3 Gerúndio conclusivo
- **Gatilhos**: sentence-final gerund clause after a comma: ", destacando a importância de", ", evidenciando que", ", contribuindo para", ", reforçando a necessidade de", ", consolidando a posição de", ", refletindo", ", simbolizando" `[wiki]` (pt form of the en "-ing" tail) `[humanizar]`.
- **Fix**: delete the tail. If it holds a real fact, make it its own sentence with a subject.
- **Exemplo** (release de imprensa):
  - Antes: "A empresa abriu 200 vagas em Recife, reforçando seu compromisso com o Nordeste e contribuindo para o desenvolvimento regional."
  - Depois: "A empresa abriu 200 vagas em Recife."
- **Don't**: touch gerunds with real manner or simultaneity ("trabalhou como garçom, pagando a faculdade"). Different from gerundismo (P1).

### C4 Atribuição vaga
- **Gatilhos**: "especialistas apontam", "segundo especialistas", "estudos indicam/apontam que", "pesquisas mostram", "relatórios do setor", "observadores citaram", "alguns críticos argumentam", "várias fontes" for one source `[wiki]` `[humanizar]`.
- **Fix**: keep the claim, list it under Needs the author. If the text names the source elsewhere, attribute to it.
- **Exemplo** (artigo):
  - Antes: "Especialistas apontam que o trabalho remoto aumenta a produtividade."
  - Depois: unchanged. Needs the author: "quais especialistas ou estudo?"
- **Don't**: delete the claim or invent a source.

### C5 Associação vaga
- **Gatilhos**: "associado a", "ligado a", "em conexão com", "conectado a", "em associação com", "esteve ligado a" `[wiki]`.
- **Fix**: the concrete relation, when the text gives it.
- **Exemplo** (bio, `[wiki]`):
  - Antes: "A professora Maria da Silva esteve ligada ao ensino de ciências na Universidade Exemplo."
  - Depois: "A professora Maria da Silva ensinou ciências na Universidade Exemplo."
- **Don't**: guess a relation the text doesn't state; flag it. Technical senses stay ("associado da cooperativa", "fator associado a maior risco").

### C6 Evitação de "ser" e "ter"
- **Gatilhos**: "constitui", "configura-se como", "serve como", "figura como", "atua como", "funciona como", "ergue-se como", "representa", "dispõe de", "conta com", "apresenta"/"oferece" where "tem" fits, "refere-se a" in a first sentence `[wiki]` `[humanizar]`.
- **Fix**: "é", "são", "tem", "há".
- **Exemplo** (doc técnica):
  - Antes: "O módulo `auth` configura-se como a camada de segurança da API e dispõe de três estratégias de login."
  - Depois: "O módulo `auth` é a camada de segurança da API e tem três estratégias de login."
- **Don't**: change terms of art ("constitui crime") or literal uses ("o galpão serve como depósito").

### C7 Excesso de credenciais
- **Gatilhos**: "reconhecido por diversos veículos", "foi destaque em veículos como", "mantém presença ativa nas redes sociais", "conta com milhares de seguidores", a "Prêmios e reconhecimento" list with every mention `[wiki]`.
- **Fix**: keep the named outlets; drop the framing and the social-media line unless it carries a fact.
- **Exemplo** (bio):
  - Antes: "Reconhecida por diversos veículos, como Exame e Valor Econômico, Ana mantém uma presença ativa nas redes sociais, onde compartilha insights sobre liderança."
  - Depois: "Ana apareceu na Exame e no Valor Econômico e escreve sobre liderança nas redes sociais."
- **Don't**: trim a press kit or speaker bio, where listing coverage is the point.

## D. Vocabulary and hedging

### D1 Vocabulário de IA (weak unless clustered)
- **Gatilhos** `[humanizar]` `[imprensa]` `[wiki]` (wiki entries are glosses of English words, unverified for pt):
  - Adjetivos: crucial, fundamental, robusto, multifacetado, holístico, disruptivo, escalável, dinâmico, inovador, transformador, envolvente, fascinante, poderoso, meticuloso, vibrante, inegável, abrangente.
  - Substantivos: cenário, panorama, ecossistema, jornada, sinergia, catalisador, paradigma, pilar, insight, "rica tapeçaria".
  - Verbos: mergulhar em, desbloquear, potencializar, alavancar, impulsionar, navegar [complexidades], orquestrar, fomentar, aprimorar.
  - Frases: "um testemunho de", "cenário em constante evolução", "serve como um lembrete", "X é a moeda de Y", "o paradoxo da X".
  - Advérbios: indubitavelmente, exponencialmente, notavelmente, absolutamente, incrivelmente.
- A pt-BR blog claims "crucial" carries heavy weight in ChatGPT output even when asked to avoid it: UNVERIFIED.
- **Fix**: plain word or delete. Never swap one list word for another ("crucial" for "vital").
- **Exemplo** (comunicado interno):
  - Antes: "Nossa jornada de transformação digital alavanca sinergias robustas para potencializar o ecossistema de parceiros."
  - Depois: "A transformação digital deve facilitar o trabalho com os parceiros." Needs the author: what concretely changes.
- **Don't**: replace technical senses: "direito fundamental", "ecossistema" in biology, "estimador robusto", "arquitetura escalável".

### D2 Sinônimos rígidos
- **Gatilhos**: "utilizar" (usar), "realizar" for any action ("realizar uma reunião/análise/compra"), "efetuar", "possuir" (ter), "visando", "veio a falecer" (morreu), "realocou-se" (mudou-se), "empreendeu uma tentativa" (tentou), "foi autor de" (escreveu) `[wiki]`. See C6 for "constitui", "configura-se como".
- **Fix**: the plain verb.
- **Exemplo** (e-mail de suporte):
  - Antes: "Realizamos a análise dos dados e efetuamos a correção, visando possibilitar a utilização do sistema."
  - Depois: "Analisamos os dados e corrigimos o erro para liberar o uso do sistema."
- **Don't**: rewrite fixed formulas in contracts and official documents ("efetuar o pagamento").

### D3 Transições mecânicas
- **Gatilhos** at sentence start, one after another: "Além disso", "Ademais", "Nesse sentido", "Dessa forma", "Desse modo", "Diante disso", "Por outro lado", "Sendo assim", "Nessa perspectiva", "À vista disso", "Por conseguinte", "Consequentemente" `[imprensa]` `[humanizar]`. Archaic ones: P2.
- **Fix**: delete where the relation is obvious; keep the one that carries real logic (contrast, cause).
- **Exemplo** (artigo de produto):
  - Antes: "O app ganhou modo offline. Além disso, a sincronização ficou mais rápida. Nesse sentido, o consumo de bateria caiu. Dessa forma, a avaliação na loja subiu."
  - Depois: "O app ganhou modo offline, a sincronização ficou mais rápida e o consumo de bateria caiu. Com isso, a avaliação na loja subiu."
- **Don't**: touch a lone "Além disso". In redações these are taught cohesion: see P7.

### D4 Ciclo de sinônimos
- **Gatilhos**: one referent renamed by generic nouns each sentence: "a ferramenta", "a solução", "a plataforma" `[humanizar]`.
- **Fix**: one name, a pronoun, or the null subject Portuguese allows.
- **Exemplo** (página de produto):
  - Antes: "O Jira centraliza as tarefas do time. A plataforma também gera relatórios, e a solução se integra ao Slack."
  - Depois: "O Jira centraliza as tarefas do time, gera relatórios e se integra ao Slack."
- **Don't**: undo journalistic variation with real descriptors ("o presidente", "o ex-ministro"); act only on generic category nouns.

### D5 Ressalvas empilhadas e burocráticas
- **Gatilhos**: "Vale ressaltar que", "Vale destacar que", "É importante destacar que", "É importante notar/observar que", "É fundamental destacar que", "Cabe destacar", "Cumpre salientar que", "Convém mencionar que", "Faz-se necessário" `[imprensa]` `[humanizar]`; stacked hedges: "pode potencialmente", "pode vir a", "em certa medida", "não necessariamente"; corrective framing: "deve ser entendido como X, e não como Y".
- **Fix**: delete the frame. Keep one hedge if the uncertainty is real.
- **Exemplo** (relatório técnico):
  - Antes: "Vale ressaltar que a mudança pode potencialmente impactar, em certa medida, o tempo de resposta."
  - Depois: "A mudança pode afetar o tempo de resposta."
- **Don't**: remove a single real qualifier ("os dados são preliminares").

## E. Formatting

### E1 Travessão
See [Travessão](#travessão).

### E2 Negrito e listas com rótulo em negrito
- **Gatilhos**: "**Agilidade:** O processo ficou mais rápido.", bold sprinkled on keywords in prose.
- **Fix**: keep the list, drop the bold. In pt-BR the word after a colon is lowercase unless it is a proper noun or a quotation.
- **Exemplo** (apresentação de resultados):
  - Antes: "- **Agilidade:** O processo ficou mais rápido."
  - Depois: "- Agilidade: o processo ficou mais rápido."
- **Don't**: unbold defined terms, or a document that uses the style consistently.

### E3 Title Case em títulos (strong in pt-BR)
- **Gatilhos**: every major word capitalized in a heading `[wiki]` `[humanizar]`.
- **Fix**: sentence case: first word and proper nouns only. Unlike English, this is the pt-BR norm, so fix regardless of the document's mix.
- **Exemplo** (doc técnica):
  - Antes: "## Como Configurar o Ambiente de Desenvolvimento no Linux"
  - Depois: "## Como configurar o ambiente de desenvolvimento no Linux"
- **Don't**: change titles of works, product names or brands; they are protected.

### E4 Emoji e setas decorativas
- **Gatilhos**: "🚀 Resultados", "✅" as bullets, "👉" before a link, "→" in prose `[imprensa]`.
- **Fix**: delete; use a plain bullet or word.
- **Exemplo** (post LinkedIn):
  - Antes: "🚀 Lançamos o novo painel! 👉 Confira no link."
  - Depois: "Lançamos o novo painel. Confira no link."
- **Don't**: strip emoji from WhatsApp messages or posts where the author uses them in their own register.

### E5 Aspas misturadas
- **Gatilhos**: curly “ ” mixed with straight " ".
- **Fix**: normalize to what the document mostly uses. Period placement: P9.
- **Exemplo**: Antes: “prazo” e "escopo". Depois: "prazo" e "escopo" (document uses straight quotes).
- **Don't**: convert « » in pt-PT text. Variant, not a tell.

### E6 Markdown fora de contexto
- **Gatilhos**: `**`, `##` in a plain e-mail or chat message. WhatsApp renders `*negrito*` and `_itálico_`, not `**negrito**`.
- **Fix**: remove the syntax, or convert to the target's own markup.
- **Exemplo** (mensagem de WhatsApp):
  - Antes: "**Atenção:** reunião amanhã às 9h."
  - Depois: "*Atenção:* reunião amanhã às 9h."
- **Don't**: touch Markdown files, READMEs or chat tools that render it.

## F. Rhythm

### F1 Ritmo uniforme
- **Gatilhos**: paragraphs of the same size, predictable subject-verb-object sentences, each paragraph closing on an effect line `[imprensa]`.
- **Fix**: vary length only in sentences already being edited, usually by joining two.
- **Exemplo**: Antes: "O sistema caiu às 14h. A equipe identificou a causa. O serviço voltou às 15h." Depois: "O sistema caiu às 14h e voltou às 15h, depois que a equipe identificou a causa."
- **Don't**: restructure untouched paragraphs or chop sentences for "punch".

### F2 Mesma abertura repetida
- **Gatilhos**: paragraphs opening with the same construction. ChatGPT redações opened development paragraphs with "Em primeiro lugar" and "Além disso" in the same slots across texts `[Enem]`.
- **Fix**: rephrase one or two openings, or drop the connective.
- **Exemplo** (proposta comercial):
  - Antes: "Com o novo painel, o gestor acompanha as metas. Com o novo relatório, o time vê o funil. Com a nova API, os dados chegam ao ERP."
  - Depois: "Com o novo painel, o gestor acompanha as metas. O relatório mostra o funil ao time, e a API leva os dados ao ERP."
- **Don't**: break deliberate parallelism in bullets or anaphora used as rhetoric.

## pt-BR-only patterns

Not in the English catalog. Each maps to the nearest `SKILL.md` ID for reporting ("P3 → D2"). All `[humanizar]` unless tagged otherwise: reasoned, not measured. Most are also common human habits (telemarketing, bureaucracy, corporate jargon), so treat as weak unless clustered or noted.

### P1 Gerundismo (→ D2, weak)
- **Gatilhos**: "vou estar enviando", "estaremos realizando", "vamos estar verificando", "vou estar te passando".
- **Fix**: simple future or present: "vou enviar", "envio", "vamos verificar".
- **Exemplo** (e-mail de atendimento):
  - Antes: "Vou estar encaminhando sua solicitação ao setor responsável e estaremos retornando em até 48 horas."
  - Depois: "Vou encaminhar sua solicitação ao setor responsável e retornamos em até 48 horas."
- **Don't**: change a real progressive ("amanhã às 10h vou estar viajando" = in progress at that time).

### P2 Conectivos arcaicos fora de contexto (→ D3)
- **Gatilhos**: "outrossim", "destarte", "ademais", "não obstante", "doravante", "nesse diapasão", "mister se faz", "em última análise", "no bojo de".
- **Fix**: "além disso" or nothing, "portanto", "mas", "a partir de agora", "é preciso".
- **Exemplo** (post de blog):
  - Antes: "Destarte, mister se faz revisar o processo de onboarding."
  - Depois: "Por isso, é preciso revisar o processo de onboarding."
- **Don't**: touch petições and legal writing, where these are normal.

### P3 Formalidade deslocada e oficialês (→ D2)
- **Gatilhos**: "No que tange a", "No tocante a", "Tendo em vista que", "Haja vista que", "O referido", "O supracitado", "Venho por meio deste", "Segue em anexo para os devidos fins", "Solicito a gentileza de", "a nível de", "no âmbito de", "sob a ótica de", "à luz de".
- **Fix**: say it directly: "sobre", "como", "segue o anexo", "por favor".
- **Exemplo** (mensagem no Slack):
  - Antes: "Venho por meio deste informar que, no que tange ao deploy de sexta, o referido procedimento foi adiado."
  - Depois: "O deploy de sexta foi adiado."
- **Don't**: rewrite ofícios, requerimentos or petições; oficialês is their register.

### P4 "Haver/existir" hipercorreto (→ D2, weak)
- **Gatilhos**: "existem", "há" in casual text where Brazilian usage is existential "tem".
- **Fix**: "tem", only when the rest of the text is informal.
- **Exemplo** (mensagem no grupo do time):
  - Antes: "Pessoal, existem duas vagas no estacionamento hoje, quem precisar avisa aí."
  - Depois: "Pessoal, tem duas vagas no estacionamento hoje, quem precisar avisa aí."
- **Don't**: push "tem" into formal writing. "Há" is standard written pt-BR.

### P5 Colocação pronominal artificial (→ D2)
- **Gatilhos**: ênclise or mesóclise where Brazilians use próclise: "Permite-nos afirmar", "Apresento-lhe", "Dar-se-á", "Far-se-á", "Informo-lhe".
- **Fix**: "nos permite", "apresento a você", future with "vai"/"será".
- **Exemplo** (anúncio de produto):
  - Antes: "O novo recurso permite-nos acompanhar pedidos em tempo real, e dar-se-á acesso a todos os clientes em março."
  - Depois: "O novo recurso nos permite acompanhar pedidos em tempo real, e todos os clientes terão acesso em março."
- **Don't**: change ênclise at sentence start ("Trata-se de", "Diz-se que"), standard in written pt-BR, or legal text that uses mesóclise.

### P6 Calques do inglês (→ D1)
- **Gatilhos**: "endereçar um problema" (to address), "no final do dia" (at the end of the day), "Com isso dito" (with that said, also `[imprensa]`), "em termos de", "performar", "correr um experimento", "fazer sentido" overused, "baseado em" with no subject ("Baseado nos dados, a decisão foi..."), "Espero que esta mensagem o encontre bem" (A1).
- **Fix**: "resolver/tratar", "no fim das contas" or delete, "Dito isso", rephrase "em termos de", "ter bom desempenho", "rodar/fazer um experimento".
- **Exemplo** (e-mail de time):
  - Antes: "Com isso dito, precisamos endereçar o problema de performance, porque no final do dia o que importa é a experiência do usuário."
  - Depois: "Dito isso, precisamos resolver o problema de performance, porque o que importa é a experiência do usuário."
- **Don't**: translate naturalized loanwords ("performance", "feedback" stay). Tech and corporate writers use these calques themselves; act when clustered, follow a writing sample if given.

### P7 Aberturas e coesão estilo Enem (→ B4, F2)
- **Gatilhos**: "Em um mundo cada vez mais...", "No cenário atual...", "Na contemporaneidade...", "É inegável que...", "Diante do exposto...", "Em meio a um cenário de..." `[humanizar]`; paragraph sequence "Em primeiro lugar", "Além disso", "Diante desse cenário", "Em conclusão" `[Enem]`.
- **Fix**: outside essays, delete the frame. In a redação or academic essay, act only on mechanical repetition.
- **Exemplo** (blog de finanças):
  - Antes: "Na contemporaneidade, é inegável que a educação financeira se tornou indispensável."
  - Depois: "A educação financeira se tornou indispensável."
- **Don't**: strip these from a student essay just for being there; schools teach them (see [Não corrigir](#não-corrigir)).

### P8 Vírgula de Oxford (→ E5)
- **Gatilhos**: comma before the "e"/"ou" that closes a simple list.
- **Fix**: remove the comma.
- **Exemplo** (ementa de curso):
  - Antes: "O curso cobre SQL, Python, e estatística."
  - Depois: "O curso cobre SQL, Python e estatística."
- **Don't**: remove a comma before "e" joining clauses with different subjects ("Ele saiu, e a reunião continuou"), in polissíndeto, or with adversative "e".

### P9 Ponto dentro de aspas parciais (→ E5)
- **Gatilhos**: American period inside a partial quotation that closes the sentence.
- **Fix**: period outside. Inside only when the whole sentence is the quotation.
- **Exemplo** (notícia):
  - Antes: O diretor chamou o resultado de "histórico."
  - Depois: O diretor chamou o resultado de "histórico".
- **Don't**: move punctuation that belongs to a fully quoted sentence.

### P10 Title Case em títulos (→ E3)
Covered under E3. Strong in pt-BR.

### P11 Passiva analítica em série (→ D2)
- **Gatilhos**: "foi realizado por", "foi constatado que", "foi verificado que", "foi feita uma análise", chained.
- **Fix**: active voice with the agent, when the text names it.
- **Exemplo** (relatório de produto):
  - Antes: "Foi realizada uma análise pela equipe de dados e foi constatado que o churn foi impulsionado pelo aumento de preço."
  - Depois: "A equipe de dados fez uma análise e constatou que o aumento de preço elevou o churn."
- **Don't**: change a single passive, or one with unknown or irrelevant agent (methods section). Passive alone is a clarity edit, not a de-AI one: GPT-4o underuses agentless passive (Reinhart et al. 2025).

### P12 Ressalva com preâmbulo (→ C1)
- **Gatilhos**: minimize, then inflate: "Embora pareça um conceito simples, X representa um dos pilares mais fundamentais de..."
- **Fix**: drop both halves; state what X is or does.
- **Exemplo** (doc técnica):
  - Antes: "Embora pareça um conceito simples, o versionamento semântico representa um dos pilares mais fundamentais da manutenção de bibliotecas."
  - Depois: "O versionamento semântico indica, pelo número da versão, se uma atualização quebra compatibilidade." Only if the text explains this nearby; otherwise cut to the claim the text supports.
- **Don't**: invent the explanation.

## Travessão

The skill removes every em dash (user preference, not an authorship claim: the travessão is centuries-old Portuguese norm, `[imprensa]`). Exceptions:
- **Dialogue in fiction**: the line-initial travessão and the one setting off the narrator's tag in the same line. "— Vamos embora — disse ela." stays as written.
- Protected zones, numeric ranges with en dash (1990–2000), the hyphen (hífen) in compounds.

A spaced hyphen used as a pause (" - ") counts as a dash. Pick the replacement by the dash's job and vary them:
- Vírgula, light aside. Antes: "O relatório — entregue ontem — já foi aprovado." Depois: "O relatório, entregue ontem, já foi aprovado."
- Parênteses, true aside or acronym. Antes: "A Lei Geral de Proteção de Dados — a LGPD — entrou em vigor em 2020." Depois: "A Lei Geral de Proteção de Dados (LGPD) entrou em vigor em 2020."
- Dois-pontos, explanation follows. Antes: "O problema era simples — faltava memória no servidor." Depois: "O problema era simples: faltava memória no servidor."
- Ponto, two separate thoughts. Antes: "A equipe entregou no prazo — o cliente, porém, mudou o escopo na semana seguinte." Depois: "A equipe entregou no prazo. O cliente, porém, mudou o escopo na semana seguinte."

Lowercase after the colon (E2). Don't turn every dash into a colon.

## Não corrigir

- **Naturalized anglicisms**: feedback, deploy, churn, onboarding, performance, pull request, stakeholder. Translating them ("retroalimentação", "rotatividade de clientes", "partes interessadas") is purism and plants a new tell `[humanizar]`.
- **School and academic cohesion**: "Em primeiro lugar", "Além disso", "Diante desse cenário", "Em conclusão" are taught as correct cohesion for the redação do Enem, which is also what ChatGPT imitates `[Enem]`. In student and academic essays they are weak signals: act only on mechanical repetition (every paragraph opening the same way), not presence.
- **Formal genres**: petições, pareceres, contratos, ofícios, artigos acadêmicos and TCCs are legitimately formal. Archaic connectives, oficialês, mesóclise and "Diante do exposto" belong there.
- **Variants**: pt-PT, African Portuguese and regional Brazilian usage are not AI signs `[wiki]`. Keep the text's variant; never "Brazilianize" a pt-PT passage.
- **Polish is not evidence**: perfect grammar, formal register, a mix of formal and casual, "robotic" flatness, a lone connective, a lone list word `[wiki]`. Writing errors in on purpose to "look human" is the wrong fix `[imprensa]`.
- **Detectors**: Portuguese AI detectors show high false-positive rates and low sensitivity (Candido et al., IFAL). Never edit toward a detector score.
