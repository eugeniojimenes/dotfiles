# English reference: AI-writing tells

Trigger phrases, repairs and examples for English text. Pattern IDs and strengths (strong/weak) match the catalog in `SKILL.md`, which holds the workflow; read it first.
Sources: Wikipedia "Signs of AI writing" (November 2026 revision), corpus studies (Kobak et al. 2025, Juzek & Ward 2025, Reinhart et al. 2025, Liang et al. 2024), and open-source de-slop skills (humanizer, stop-slop, no-ai-slop, avoid-ai-writing, unslop).

## Contents

- [A. Leftovers](#a-leftovers): A1 chatbot residue, A2 model disclaimers, A3 placeholders, A4 tool artifacts, A5 talking about the document
- [B. Staging](#b-staging): B1 negative parallelism, B2 forced triads, B3 kickers, B4 throat-clearing, B5 formulaic endings, B6 interpretive metadiscourse
- [C. Inflation](#c-inflation): C1 significance, C2 promotional tone, C3 participle tails, C4 vague attribution, C5 vague association, C6 copula avoidance, C7 over-attribution
- [D. Vocabulary and hedging](#d-vocabulary-and-hedging): D1 AI vocabulary (word lists), D2 stiff synonyms, D3 mechanical transitions, D4 synonym cycling, D5 hedge stacks
- [E. Formatting](#e-formatting): E1 em dashes, E2 bold, E3 Title Case, E4 emoji and arrows, E5 curly quotes, E6 stray Markdown
- [F. Rhythm](#f-rhythm): F1 uniform rhythm, F2 repeated openings
- [Signs of human writing to preserve](#signs-of-human-writing-to-preserve)
- [Ineffective indicators](#ineffective-indicators)

## A. Leftovers

### A1 Chatbot residue
- **Triggers:** "Certainly!", "Of course!", "Sure! Here's a", "Great question", "You're absolutely right!", "I'd be happy to", "Here is a ...", "Here's a template for", "I hope this helps", "Let me know if", "Would you like me to", "Is there anything else", "Feel free to", "more detailed breakdown", "Final important tip:", "Delete this section before submission", "check/verify ... before publishing", compliment sandwich ("Great suggestion! That said, ..."), customer-service tone ("I have carefully reviewed", "apologize for any inconvenience I may have caused").
- **Fix:** Delete the wrapper sentence. If it hides a real instruction for the reader, keep the instruction in plain words.
- **Example:**
  - Before: "Certainly! Here's the updated changelog entry. Version 2.3 fixes the login timeout on Safari. Let me know if you'd like any changes!"
  - After: "Version 2.3 fixes the login timeout on Safari."
- **Don't:** delete the greeting and sign-off of a real email or letter ("Hi Ana,", "Thanks, Bruno"). Only the chatbot's wrapper around the text goes.

### A2 Model disclaimers
- **Triggers:** "As an AI language model", "as a large language model", "As of my last knowledge update", "Up to my last training update", "I cannot offer medical advice, but I can", "I'm sorry, but I can't", "it's important to note that information may vary", "While specific details are limited/scarce", "not widely documented/available/disclosed", "in the provided sources", "in the search results", "based on available information", "maintains a low profile", "keeps personal details private". (Mid-2026 "corrective framing" lives under D5.)
- **Fix:** Delete. A disclaimer is often followed by a guess ("the area likely supports..."); that guess is speculation, so delete it too or list it under Needs the author.
- **Example:**
  - Before: "While details about the company's early years are not widely documented, it likely began as a small family workshop. In 1998 it opened its first factory in Leeds."
  - After: "In 1998 it opened its first factory in Leeds." (Needs the author: origin of the company.)
- **Don't:** remove a sourced statement that records are missing ("No birth record survives; the 1871 census lists him as 12"). That is a fact.

### A3 Placeholders
- **Triggers:** "[Your Name]", "[Company Name]", "[Describe ...]", "[link to ...]", "[Insert ...]", "[Year]", "(Add your channel URL here)", "(If available)", `INSERT_SOURCE_URL_30`, `INSERT_WEBSITE_URL_HERE`, `PASTE_YOUTUBE_VIDEO_URL_HERE`, `SOURCE_PUBLISHER`, `2025-XX-XX`, `https://example.com/source1`, `example.com/article`, "Example Source Title", `<!-- Add if available with citation -->`.
- **Fix:** Leave the placeholder where it is and list it under Needs the author. Never fill it with invented data.
- **Example:**
  - Before: "Please review the attached proposal [link to proposal] by Friday. Best regards, [Your Name]"
  - After: unchanged. Needs the author: proposal link, sender name.
- **Don't:** treat a bare `example.com` in docs that teach URL syntax, or boilerplate that a template ships with, as a tell.

### A4 Tool artifacts
- **Triggers (literal):** `:contentReference[oaicite:0]{index=0}`, `oai_citation`, `citeturn0search0`, `turn0image0`, `turn0news0`, `turn1file0`, `({"attribution":{"attributableIndex":"X-Y"}})`, source counts glued to words ("Wikipedia+1", "Microsoft Learn+3"), `[cite: 3]`, `[cite: 2, 6]`, `[span_1](start_span)`, `[span_1](end_span)`, stray `<mark>` tags, `<grok-card data-id=...>`, `grok_render_citation_card_json`, `【85†L261-269】`, `[attached_file:1]`, `[web:1]`, `ppl-ai-file-upload` URLs, `:::writing{variant="document" id="NNNNN"}`, `↩` around footnotes, a digit glued to a sentence end ("Demon Slayer.2"), a ```` ```wikitext ```` fence, URL parameters `utm_source=chatgpt.com`, `utm_source=openai`, `utm_source=copilot.com`, `referrer=grok.com`.
- **Fix:** Strip the artifact. In URLs remove only the tracking parameter (and a dangling `?` or `&`); keep the rest of the link. Keep the sentence the marker was attached to.
- **Example:**
  - Before: "The bridge opened in 1932.citeturn0search3 Photos: https://www.cityarchive.org/bridges?utm_source=chatgpt.com"
  - After: "The bridge opened in 1932. Photos: https://www.cityarchive.org/bridges"
- **Don't:** read `utm_source` as proof the prose is AI. It shows a chatbot found the link; people also use chatbots only to find sources.

### A5 Talking about the document
- **Triggers:** "In this article, we will explore", "In this section, we will discuss", "This guide walks you through", "Article explains what", "Helps to understand", "Let's dive in", "Let's break this down", "Let's take a closer look", "Below is a detailed overview", "the table below shows/compares", "as mentioned above", a first sentence that restates the heading, prose list in disguise ("The first takeaway is... The second takeaway is...").
- **Fix:** Delete the signpost and start with the content. Under "Pricing", the first sentence gives a price.
- **Example:**
  - Before: "## Installation / In this section, we'll walk through how to install the CLI. Let's dive in! Run `brew install foo`."
  - After: "## Installation / Run `brew install foo`."
- **Don't:** strip roadmaps where the genre expects them: theses, long specs, legal documents ("Section 3 describes the method").

## B. Staging

### B1 Negative parallelism
- **Triggers:** "not X, but Y", "not just X, but (also) Y", "not only X but also Y", "It's not X, it's Y", "This isn't X. It's Y." (split across sentences), "X isn't just Y; it's Z", "isn't about X, it's about Y", "doesn't just X; it Y", "Not because X. Because Y.", "The answer isn't X. It's Y.", "stops being X and starts being Y", "more than just a", "no X, no Y, just Z", "Not X. Not Y. Just Z.", "Rather than X, Y" and "Y rather than X" (frequent in mid-2026 output), trailing ", not X" ("should be encouraged, not belittled", "Collaboration, not confrontation"), clipped tails (", no guessing"). Press called it the hardest tic to shake; it outlived "delve" and the em dash.
- **Fix:** State Y. Drop X unless a reader really holds that belief and the text answers it. Two independent facts joined by "not only... but also" become a plain "and".
- **Example:**
  - Before: "The 4.0 update is not just a bug fix — it's a complete rethink of how sync works."
  - After: "The 4.0 update changes how sync works."
- **Don't:** cut a genuine correction or contrast that carries information ("The fee is not refundable, but it can be transferred"). Human "myths busted" writing uses the shape too, so one instance in a paragraph of facts is weak; repetition is the tell.

### B2 Forced triads
- **Triggers:** three adjectives in a row ("fast, reliable, and secure"), three parallel phrases or clauses, triplets in sentence after sentence, three-bullet lists where the content has two or four items, false ranges ("From innovation to implementation to cultural transformation"), triplet topics ("debate about authenticity, consent, and the psychological effects of..."). Stronger where people rarely bother with flourishes: emails, commit messages, chat, edit summaries.
- **Fix:** Keep the items the facts support and drop the padding, typically near-synonyms. If all three carry distinct information, keep the triad. Check the fact lock here: merging triads drops facts more often than any other edit.
- **Example:**
  - Before: "The database migration was smooth, efficient, and seamless."
  - After: "The database migration went smoothly."
- **Don't:** touch real lists that happen to have three members (three supported OS versions, three named authors).

### B3 Kickers and reveals
- **Triggers:** a one-line paragraph that delivers a punchline at the end of a section; "The result? ...", "The best part? ...", "The catch?", "The secret?"; colon reveals ("The best part: it learns."); "And that changes everything.", "And that's the point.", "And that's okay.", "Let that sink in.", "Full stop." / "Period.", "Make no mistake"; dramatic fragments ("He published this. Openly. In a book."), "every. single. day.", ALL CAPS emphasis; fake-profound closers ("In the end, code is a letter to our future selves."); grandiose stakes ("will define the next era of computing").
- **Fix:** Delete the kicker when it restates the paragraph. When a reveal hides a fact, put the fact in an ordinary sentence. Never polish it into a better metaphor.
- **Example:**
  - Before: "We moved the cache to the edge and cut p95 latency from 800 ms to 120 ms. The result? A faster product. And that changes everything."
  - After: "We moved the cache to the edge and cut p95 latency from 800 ms to 120 ms."
- **Don't:** flatten the author's own casual voice ("Worst. Service. Ever." in a review). And never produce new staccato while fixing.

### B4 Throat-clearing and faux insight
- **Triggers:** "Here's the thing", "Here's what/why", "Here's the kicker", "The truth is (simple)", "The uncomfortable truth is", "The reality is", "It turns out", "The real question is", "The real X is", "What most people miss", "What most people get wrong", "What nobody mentions is", "The part everyone misses", "At its core", "Let me be clear", "Can we talk about", "Honestly?", "Think of it as...", "Imagine a world where...", "In today's fast-paced world", "In today's digital age", "In a world where", "When it comes to", "One might wonder:", "Whether you're a beginner or an expert", "While X is true, Y is also important", "X is the language of Y", "X is a feature, not a bug", invented concept labels ("the supervision paradox", "the acceleration trap").
- **Fix:** Delete the run-up and start with the claim. Delete an invented label unless the text defines it and uses it again.
- **Example:**
  - Before: "Here's the thing: most onboarding programs fail for one simple reason. Nobody owns them."
  - After: "Most onboarding programs fail because nobody owns them."
- **Don't:** act on a lone "It turns out" or "When it comes to" in casual writing; these are everyday phrases. Act when they cluster.

### B5 Formulaic endings
- **Triggers:** "In conclusion", "In summary", "To sum up", "Overall,", "Ultimately,", "Taken together, these", "Despite its [praise], X faces several challenges", "Despite these challenges, X continues to thrive / provide a vital service", "Looking ahead, the", "The future of X lies in its ability to adapt", "the future looks bright", "the possibilities are endless", "continues to evolve", "positions it as", headings like "Challenges and Future Directions" or "Future Outlook", a recap paragraph that restates the points just made, a "Conclusion" heading on a short piece, a moralizing generic last line.
- **Fix:** Delete the recap and the vague optimism. If a challenges paragraph names specific problems, keep them as plain facts and drop the "Despite..." frame and the upbeat closer.
- **Example:**
  - Before: "Despite its rapid growth, Brookfield faces several challenges, including traffic congestion and a shortage of affordable housing. With ongoing initiatives, the town continues to thrive."
  - After: "Brookfield's growth has brought traffic congestion and a shortage of affordable housing."
- **Don't:** treat any mention of challenges as the tell; the sign is the rigid formula. Papers and reports have real conclusion sections; trim only the restating filler.

### B6 Interpretive metadiscourse
- **Triggers:** "This matters because", "Why this matters", "Why X matters", "This is important because", "This distinction matters / is important", "That last point deserves attention", "That last part matters more than it sounds", "It's worth noting/mentioning that", "It's important to note/remember that", sentence-initial "Notably,", "Importantly,", "Crucially,", "Interestingly,", "adds another layer", "What's next", "is especially helpful", "can help you". Graphite's 2026 study measured "this matters" at 116x and "why [X] matters" at 92x the human rate in Claude Opus 5.5 output.
- **Fix:** Delete the label, keep the reason, and attach the reason to the claim it supports.
- **Example:**
  - Before: "The API now returns 429 instead of 500 when rate-limited. This matters because clients can retry safely."
  - After: "The API now returns 429 instead of 500 when rate-limited, so clients can retry safely."
- **Don't:** rename a "Why this matters" section that a proposal template or the author chose on purpose.

## C. Inflation

### C1 Significance and legacy
- **Triggers:** stands/serves as, is a testament/reminder to, a crucial/pivotal/vital/significant/key role/moment, underscores/highlights its importance/significance, reflects broader, symbolizing its ongoing/enduring/lasting, contributing to the, setting the stage for, marking/shaping the, represents/marks a shift, marks a turning point, key turning point, evolving landscape, focal point, indelible mark, deeply rooted, forms part of the wider history of, was part of a broader movement, enduring legacy, transformative power; "has shaped conversations/discussions/debate about", "generated debate about", "prompted broader reflection on", "raising philosophical questions about", "contributed to wider discussions"; a hedging preamble followed by importance ("Though it saw only limited application, it contributes to the broader history of..."); in biology, generic ecosystem and conservation boilerplate.
- **Fix:** Delete the significance claim unless a source makes it, and keep the fact it was hung on. Where the text already has a specific fact, prefer it to the generic praise (Wikipedia's pair: "inventor of the first train-coupling device", not "a revolutionary titan of industry").
- **Example:**
  - Before: "The library opened in 1989, marking a pivotal moment in the town's cultural life and setting the stage for decades of community engagement."
  - After: "The library opened in 1989."
- **Don't:** cut sourced, concrete influence ("cited in 40 later rulings"). That is a fact.

### C2 Promotional tone
- **Triggers:** nestled (in/within), in the heart of, vibrant, rich (cultural heritage, history), boasts a, breathtaking, stunning, scenic, profound, renowned, groundbreaking, exemplifies, commitment to, natural beauty, diverse array, a fascinating glimpse into, worth visiting, seamless(ly), cutting-edge, state-of-the-art, world-class, unparalleled, transformative, "dependable, value-driven experiences", "a reliable partner", "thoughtfully designed". Wikipedia moved blatant puffery to its historical indicators (common 2023 to 2025, rarer since unless the user asks for it).
- **Fix:** Replace with the neutral fact or delete. "boasts a rooftop pool" becomes "has a rooftop pool".
- **Example:**
  - Before: "Nestled in the heart of downtown, the hotel boasts 120 rooms and a vibrant rooftop bar."
  - After: "The hotel is downtown and has 120 rooms and a rooftop bar."
- **Don't:** drain the selling out of copy that is meant to sell. On a product page, cut the stock phrases and keep the enthusiasm the author put there.

### C3 Shallow participle tails
- **Triggers:** a sentence-final ", highlighting/underscoring/emphasizing...", ", reflecting/symbolizing...", ", contributing to...", ", ensuring...", ", fostering/cultivating...", ", encompassing...", ", showcasing...", ", further enhancing its significance as...", ", demonstrating the ongoing relevance of...", ", creating a space where...", ", providing valuable insights into...", "aligns/resonates with". Reinhart et al. (PNAS 2025) measured present participial clauses at 2 to 5 times the human rate in instruction-tuned models (5.3x for GPT-4o). Retrieval-based models attach the analysis to a named source ("Roger Ebert highlighted the lasting influence") whether or not the source says it.
- **Fix:** Cut the tail. If it states a real consequence, give it its own clause with a subject and verb ("so", "which means").
- **Example:**
  - Before: "The team moved the billing service to Postgres 16 in March, ensuring long-term stability and underscoring its commitment to reliability."
  - After: "The team moved the billing service to Postgres 16 in March."
- **Don't:** cut a participle that carries a fact ("The storm hit the coast on Tuesday, cutting power to 40,000 homes").

### C4 Vague attribution
- **Triggers:** experts say/argue/agree, studies show, research suggests, industry reports, observers have cited, analysts note, some critics argue, critics have noted, is widely regarded as, is described in scholarship as, modern researchers treat, is of interest to researchers and conservationists, according to [nationality] sources (backed by one citation), "several sources/publications" when one or two are cited, "such as" before what is the full list, fake casual quotes ("what developers call 'good enough'").
- **Fix:** If a source is named nearby, attribute to it directly. Shrink "many reviewers" to the number actually cited. Otherwise keep the claim and list it under Needs the author; never invent the source.
- **Example:**
  - Before: "Tech publications such as TechRadar and Wired have praised the keyboard's build quality." (exactly those two cited)
  - After: "TechRadar and Wired praised the keyboard's build quality."
- **Don't:** flag hedged claims that carry citations ("several studies [3, 7, 12] report").

### C5 Vague association
- **Triggers:** associated with, is/was associated with, became associated with, particularly/widely associated with, associated principally with, in connection with, connected with/to, in association with, linked to, "sources identified X as being associated with leadership of Y". Wikipedia lists this among the most common signs of new AI text as of October 2026.
- **Fix:** Name the actual relation when the text gives it (worked at, founded, taught, played in, was used for). When the text never says what the relation is, flag it.
- **Example:**
  - Before: "Martins later became associated with music education in Porto, where he taught violin."
  - After: "Martins later taught violin in Porto."
- **Don't:** touch statistical or medical correlation, where "associated with" is the correct term ("smoking is associated with lung cancer").

### C6 Copula avoidance
- **Triggers:** serves as, stands as, functions as, operates as, acts as, represents a, marks the, holds the distinction of being, boasts/features/offers/maintains (meaning "has"), "refers to" in an opening sentence about a thing (as if the text were about the word), "began his career as" (for "was"), "ventured into politics as a candidate" (for "was a candidate"). One study found a drop of over 10% in "is" and "are" in 2023 academic writing.
- **Fix:** Use "is", "are", "has", "there are". Leave present perfect alone ("has been featured" is a different "has").
- **Example** (Wikipedia's textdiff, reversed back toward the human original):
  - Before: "Gallery 825 serves as LAAA's exhibition space for contemporary art. The gallery features four separate spaces."
  - After: "Gallery 825 is LAAA's exhibition space for contemporary art. It has four gallery spaces."
- **Don't:** replace "serves as" where the thing really takes on a role it doesn't have by nature ("the gym serves as a shelter during floods").

### C7 Over-attribution
- **Triggers:** "featured in", "cited/profiled in", "has been featured in X, Y, and other prominent media outlets", "independent coverage", "local/regional/national media outlets", "trade publications", "has been extensively documented across major national and regional media", "has been recognized by", "maintains an active/strong social media presence", "maintains a digital presence", "His personal website identifies him as", "His parliamentary biography records that", "Databases/records list X as", "is listed in", "his professional profile lists", an "Awards and recognition" heading.
- **Fix:** State the fact the source supports and keep the citation, without narrating the source. Delete a social-media-presence sentence unless it carries a fact.
- **Example:**
  - Before: "Her personal website identifies her as a former NASA engineer. Her work has been featured in Wired, Vogue, and other prominent media outlets."
  - After: "She is a former NASA engineer. Wired and Vogue have covered her work."
- **Don't:** strip the outlet list from a press kit or CV "Press" section, where listing outlets is the point. Drop only the inflation ("other prominent").

## D. Vocabulary and hedging

### D1 AI vocabulary
Weak unless clustered. Wikipedia: one or two of these words may be coincidence; an edit that uses many of them, many times, is one of the strongest tells. Rules for all tiers:
- Count only the figurative or inflated sense. `underscore` in code, landscape page orientation, a database key, delving in mining, an actual woven tapestry: all literal, all fine.
- A word being an AI favorite says nothing about its synonyms. Swapping "crucial" for "vital" fixes nothing; delete the word if it is filler.
- Lists decay. Writers and models react to publicity: in arXiv abstracts, delve fell 94% from its peak by 2026, meticulous 91%, intricate 85%, showcase 75%, pivotal 66%, underscore 62%, while harness was still rising (Ransomnews). Structural patterns (B, C) outlast vocabulary.

**(a) High confidence.** Wikipedia's list, each word corroborated by corpus studies (Kobak et al., Juzek & Ward, Liang et al.). Strength: highest within D1, still weak alone.

| Word (figurative use) | Plain option |
|---|---|
| delve (into) | look at, examine, or cut |
| tapestry (abstract) | mix, range, or cut |
| testament (to) | shows, or cut |
| underscore(s) (verb) | shows, or cut |
| highlight (verb), highlighting | shows, points out, or cut |
| emphasizing | says, or cut |
| showcase, showcasing | shows |
| pivotal, crucial, key (adj), vital | important, main, or cut |
| intricate, intricacies | complex, details |
| meticulous(ly) | careful(ly) |
| boasts | has |
| garner(ed) | got, won, drew |
| bolster(ed) | strengthened, supported |
| foster(ing) | encourage, build |
| vibrant | lively, or cut |
| enduring | lasting, or cut |
| interplay | interaction |
| landscape (abstract), realm | field, market, area |
| enhance | improve |
| align(s) with | matches, fits |
| valuable (insights) | useful, or cut |
| robust (figurative) | strong, or cut |
| Additionally (opening a sentence) | see D3 |

Also measured as overused, same strength: groundbreaking, advancements, surpass(es), comprehending, commendable (9.8x in peer reviews), notably, comprehensive, insights, elucidate, nuanced, noteworthy, invaluable, unparalleled, unveil, seamless. In narrative text, Reinhart et al. found fiction-flavored favorites: camaraderie, palpable, unspoken, fleeting, solace, unravel, amidst, grapple, pang, unease, cacophony, ignite. Grok overuses pseudo-scientific words: causal, empirical, correlate.

**(b) Newer, less certain (2025 to 2026).** Wikipedia's mid-2026 era list rests on a single review site; the Graphite figures come from a vendor study reported in the press. Most are everyday words. Strength: weakest tier; act only alongside structural tells.
- Wikipedia mid-2026 list: challenge, clearer, dependable, echoed, foster, leverage, matters ("this matters"), multifaceted, practical, prioritize, quietly ("quietly orchestrating"), steady, universally.
- Graphite (2026): "dependable" (26x in Claude Opus 5.5), "looking ahead, the", "can help you", "is especially helpful", unsourced superlatives ("the most powerful"); GPT-6 era hedges "not necessarily", "does not establish" (see D5).
- Magic adverbs: deeply, fundamentally, remarkably, arguably, truly, genuinely, inherently.
- Vague safe nouns: ecosystem, framework, dynamic, core, modern.

**(c) Business jargon and stock phrases.** Strength: medium. They are poor style whoever wrote them, so a plain-word edit is fine; report them as D1 only when they cluster.
- "navigate the complexities of", "navigating the landscape", "in today's fast-paced world", "in today's digital age", "ever-evolving landscape", "a complex tapestry"
- game-changer, paradigm shift, "at the end of the day", deep dive, "move the needle", "double down", "lean into", "circle back", "double-edged sword", "a beacon of", synergy
- unlock (potential), elevate, embark (on a journey), harness (the power of), supercharge, empower, streamline, paramount, transformative, cutting-edge

- **Example:**
  - Before: "This report delves into the intricate interplay between pricing and churn, offering valuable insights for a rapidly evolving landscape."
  - After: "This report looks at how pricing affects churn."
- **Don't:** edit protected mentions ("the word *delve*"), names, or a single "crucial" in an otherwise plain paragraph.

### D2 Stiff synonyms
- **Triggers:** utilize (use), commence (start), facilitate (help), endeavor (try), attempt (try), authored (wrote), relocated (moved), passed away (died), prior to (before), obtain (get), possess (have), assist (help), demonstrate (show), individuals (people), leverage as a verb (use).
- **Fix:** Use the plain word. These are clarity edits: report them, but on their own they are weak evidence of AI.
- **Example:**
  - Before: "Users can utilize the export feature prior to commencing the migration."
  - After: "Users can use the export feature before starting the migration."
- **Don't:** cut "in order to", "the fact that", "as a result of", "all of the": Wikipedia lists isolated wordiness like this as more common in human text. Keep terms of art ("CPU utilization") and register-appropriate euphemism ("passed away" in a condolence note).

### D3 Mechanical transitions
- **Triggers:** sentence-initial Additionally, Moreover, Furthermore, Notably, Consequently, Subsequently, Conversely, In addition, Ultimately, "That said,", "With that said,", "On the other hand", opening sentence after sentence.
- **Fix:** Delete most of them; sentence order already carries the link. Keep one where the logic needs it (contrast, cause), in the plainest form ("But", "So", "Also").
- **Example:**
  - Before: "The plugin supports Vim keybindings. Additionally, it syncs settings across machines. Moreover, it is free."
  - After: "The plugin supports Vim keybindings and syncs settings across machines. It is free."
- **Don't:** remove a lone "However" or "Additionally" (Wikipedia lists isolated transitions as an ineffective indicator), and don't swap "Moreover" for "Plus".

### D4 Synonym cycling
- **Triggers:** one referent renamed in sentence after sentence ("the tool... the platform... the solution..."; "the constraints of socialist realism... the confines of state-imposed artistic norms... the constraints imposed by the Soviet regime"). Older models had a repetition penalty that produced this.
- **Fix:** Pick one name (the one the document defines or uses first) and keep it, with "it" where the reference is clear.
- **Example:**
  - Before: "Install the agent on each host. Once running, the daemon reports metrics every minute. If the service crashes, systemd restarts the process."
  - After: "Install the agent on each host. Once running, the agent reports metrics every minute. If it crashes, systemd restarts it."
- **Don't:** merge names that may be different things (in technical text, the "collector" may be a separate component), or "fix" variation in an otherwise clean text: many non-native writers were taught to avoid repetition.

### D5 Hedge stacks and corrective framing
- **Triggers:** "it's important to note/remember that", "it is crucial to differentiate", "may potentially", "could possibly", "might perhaps", "may vary", "It's understandable that"; mid-2026 corrective framing: "should be treated as X rather than Y", "should be distinguished from", "does not (by itself) establish", "does not necessarily", "not necessarily", "Although the figure should not be treated as an exact census"; less reliable: "should not be confused with".
- **Fix:** Keep one hedge that expresses real uncertainty, at the author's strength. Cut instructions to the reader about how to read a source; if the source's limits matter, say what the source is ("The chronicle, written 200 years later, gives 10,000 soldiers").
- **Example:**
  - Before: "It's important to note that results may potentially vary depending on hardware."
  - After: "Results may vary with hardware."
- **Don't:** turn "may" into "will", or strip hedges a scientific, medical or legal text needs. Models differ (GPT-6 era hedges more, recent Claude hedges less and inflates more), so never add hedges either.

## E. Formatting

### E1 Em dashes
- **Triggers:** "—" spaced or unspaced; a spaced " – " en dash used as a dash; "--" used as a dash in prose. Typical shapes: dash before a contrast ("— not because..."), dash reveal ("— and that's the point"), paired dashes around an aside.
- **Fix:** Apply the rule in `SKILL.md` step 3: comma for a light aside, parentheses for a true aside, colon before an explanation or list, period when the halves are separate thoughts. Vary the replacements.
- **Example:**
  - Before: "The fix was simple — we pinned the dependency — and the build went green. One thing still slowed us down — flaky tests."
  - After: "The fix was simple (we pinned the dependency), and the build went green. One thing still slowed us down: flaky tests."
- **Don't:** touch en dashes in ranges (1990–2000, pp. 12–18) or dashes in protected zones. As evidence the dash is now weak (OpenAI cut it in November 2025, Wikipedia moved it to historical indicators); the skill removes it as a house rule. Replacing every dash with a colon creates a new tic, and Wikipedia notes text with nothing but commas and periods is becoming a sign of its own.

### E2 Bold overuse and bold-label bullets
- **Triggers:** bold scattered through prose on terms that are not being defined ("**debt financing**", "**private equity firms**"), every instance of a phrase bolded, bolded dates and figures, "key takeaways" bold; inline-header lists ("- **Speed:** It is fast.", "1. **Historical Context:** ..."), including the variant with no punctuation after the label ("**Durability** Unlike roasted meats..."); `**` showing as literal asterisks.
- **Fix:** Unbold emphasis that is not a defined term or UI label. For label bullets, keep the list and drop the bold, or fold the label into the sentence. Every fact in every bullet survives.
- **Example:**
  - Before: "- **Performance:** Queries run 3x faster. / - **Security:** Tokens now expire after 15 minutes."
  - After: "- Queries run 3x faster. / - Tokens now expire after 15 minutes."
- **Don't:** change glossaries, API parameter lists, or documents that use bold labels on purpose throughout.

### E3 Title Case headings
- **Triggers:** every main word capitalized in section headings ("Impact of Technology and Digitalization", "Challenges and Future Directions", "Key Takeaways", "Let's Connect!"); related heading quirks: an "X and Y" heading formula, a top heading that repeats the document title, skipped heading levels, a heading that holds only subheadings.
- **Fix:** In English, change case only when the document's convention is sentence case or it mixes both. Keep proper nouns capitalized.
- **Example:**
  - Before: "## Getting Started With The CLI" (other headings in sentence case)
  - After: "## Getting started with the CLI"
- **Don't:** touch a document that uses title case consistently: AP, Chicago headline style and many product docs use it on purpose.

### E4 Emoji and arrows
- **Triggers:** emoji opening headings or bullets ("🚀 Getting Started", "✅ Done", "🧠 Cognitive Dissonance Pattern:", "📬 Let's Connect!"); Pangram measured ✅ at 167x, ✔️ 64x and 🚀 26x the human rate. Arrows and symbols in prose ("Input → Processing → Output", "≈", "⚠", box-drawing "─"); a `---` rule between every section.
- **Fix:** Remove decorative emoji. Spell arrows out ("then", "to", "becomes", "leads to").
- **Example:**
  - Before: "🚀 Deploy flow: build → test → ship ✅"
  - After: "Deploy flow: build, then test, then ship."
- **Don't:** strip emoji that carry tone in chat or social posts (humans use 😊 and ❤️ more than models do), or arrows in diagrams, code and UI paths ("Settings → Privacy").

### E5 Curly quotes mixed with straight
- **Triggers:** “ ” or ‘ ’ alongside " and ' in the same text; curly apostrophes in some contractions and straight ones in others.
- **Fix:** Normalize to whatever the document mostly uses. Never change quotes inside code.
- **Example:**
  - Before: `He said “ship it,” but the PR said "wait" and the bot’s comment didn't help.`
  - After: `He said "ship it," but the PR said "wait" and the bot's comment didn't help.`
- **Don't:** treat consistent curly quotes as a tell. Word, macOS and iOS insert them by default, typeset text uses them, and Claude and Gemini rarely produce them.

### E6 Markdown in the wrong context
- **Triggers:** `**bold**`, `## Heading`, `[text](url)`, `---` breaks, `*` bullets, or a ```` ```wikitext ```` fence in a context that won't render them: plain-text email, SMS, a form field, a commit message body, wiki markup.
- **Fix:** Convert to the target format. Remove the asterisks, turn headings into a plain line (or drop them), write links as the bare URL.
- **Example:**
  - Before (plain-text email): "**Next steps:** review the plan at [the doc](https://docs.acme.io/plan)."
  - After: "Next steps: review the plan at https://docs.acme.io/plan."
- **Don't:** strip Markdown where it renders (README, PR description, Slack, GitHub, Obsidian). Markdown alone is a weak sign; developers write it all day.

## F. Rhythm

### F1 Uniform rhythm
- **Triggers:** every paragraph the same length and shape (claim, elaboration, kicker); sentence after sentence of 15 to 20 words; in newer models, short sentences held in an 8 to 20 word band with heavy use of commas and periods. Graphite's Druck: humans write some very short and some very long sentences; models stay uniform.
- **Fix:** Light touch, only where other edits already touch: join two short related sentences, or split one overloaded sentence. Never rewrite a passage for rhythm alone.
- **Example:**
  - Before: "The service handles auth. It issues tokens for clients. It also refreshes expired sessions. It logs every login attempt."
  - After: "The service handles auth. It issues client tokens and refreshes expired sessions, and it logs every login attempt."
- **Don't:** chop sentences into fragments for punch; that staccato is the recognizable "humanizer voice". Over-polishing makes human text more uniform, so back off when in doubt.

### F2 Repeated openings
- **Triggers:** several paragraphs or bullets opening the same way ("This...", "By...", "With its...", "It also...", "Whether you're..."); anaphora ("We build. We ship. We learn."); every paragraph opening with a transition (see D3).
- **Fix:** Rephrase one or two openers to break the run; change nothing else.
- **Example:**
  - Before: "This release adds dark mode. This change also fixes the export bug. This update requires Node 20."
  - After: "This release adds dark mode and fixes the export bug. It requires Node 20."
- **Don't:** break parallel step lists ("Run... Open... Click..."); in instructions, parallel openings are the convention.

## Signs of human writing to preserve

Wikipedia lists constructions that are measurably more common in human text, because models default to a "formal, neutral" register and avoid them. A de-AI edit should move toward these. Sanding text into sterile prose is over-correction.
- Plain "is" and "has": "there is a", "it has a".
- Plain verbs: wrote, moved, used, tried, died (over authored, relocated, utilized, attempted, passed away).
- Superlatives and definite statements: "one of the best", "is the only", "was the first". Keep them when sourced. (Graphite reports recent Claude models overusing superlatives like "the most powerful"; an unsourced one goes under Needs the author.)
- Qualifiers and intensifiers: very, perhaps, tends to.
- Occasional wordiness: "as a result of", "in order to", "all of the", "a part of", "the fact that".
- Specific, unusual facts. Models regress toward generic praise; the specific detail is what a human editor keeps.
- Agentless passive. GPT-4o uses it at about half the human rate (Reinhart et al.), so a passive sentence is no reason to edit.
- The author's own voice: humor, bluntness, digressions, real uncertainty ("I think", "maybe"), casual register, anger at full strength.

## Ineffective indicators

Wikipedia and the research name these as poor evidence of AI, sometimes evidence of the opposite. Do not "fix" them:
- Perfect grammar. Many people are skilled writers.
- Formal, academic or "fancy" prose in general. Only specific words are tells.
- "Bland" or "robotic" feel without the specific traits listed above.
- Mixed casual and formal registers, or prose that sounds both clinical and emotional (technical writers, young writers, neurodivergent writers, several authors on one page).
- Transition words in isolation.
- Passive voice (see above).
- Missing citations, Markdown in technical contexts, curly quotes, or a single em dash, each on its own.
- Detector scores. Detectors flag non-native writers at high rates (61% of TOEFL essays misclassified as AI in Liang et al. 2023) and are unreliable in general. Never edit toward a score.
