# Conversation ShipFlow - questions contextuelles des skills

- Captured at: `2026-05-04 21:12:23 UTC`
- tmux session: `1`
- tmux source: `tab 10`
- tmux window index: `:10`
- tmux pane index: `.1`
- tmux window name: `node`

/home/ubuntu/home/ubuntu/home/ubuntu

      7 +updated: "2026-05-04"
      8 +status: active
      9 +source_skill: sf-skill-build
     10 +scope: skill-question-contract
     11 +owner: Diane
     12 +confidence: high
     13 +risk_level: medium
     14 +security_impact: none
     15 +docs_impact: yes
     16 +linked_systems:
     17 +  - skills/*/SKILL.md
     18 +  - skills/references/master-workflow-lifecycle.md
     19 +  - skills/references/entrypoint-routing.md
     20 +  - skills/references/reporting-contract.md
     21 +  - docs/technical/skill-runtime-and-lifecycle.md
     22 +  - shipflow-spec-driven-workflow.md
     23 +depends_on: []
     24 +supersedes: []
     25 +evidence:
     26 +  - "User request 2026-05-04: skill questions should be numbered, e
         xplain why, include helpful icons, and identify the recommended ans
         wer."
     27 +  - "User clarification 2026-05-04: a default is acceptable only wh
         en it is compatible with the current technical/product/editorial co
         ntext and current best practices."
     28 +next_review: "2026-06-04"
     29 +next_step: "/sf-verify shared question contract"
     30 +---
     31 +
     32 +# Question Contract
     33 +
     34 +## Purpose
     35 +
     36 +This reference defines how ShipFlow skills ask user-facing question
         s.
     37 +
     38 +The goal is to keep questions rare, useful, and easy to answer by n
         umber. A question is a decision brief: it tells the operator why th
         e decision matters, which answer ShipFlow recommends by default, an
         d why that answer is the most responsible choice.
     39 +
     40 +## Applies To
     41 +
     42 +Load this contract before any user-facing:
     43 +
     44 +- routing question
     45 +- clarification question
     46 +- product, persona, scope, or content-surface question
     47 +- security, data, permission, destructive, staging, closure, or shi
         p-risk question
     48 +- blocked-state recovery question
     49 +- selection question for project, file, URL, domain, check set, pac
         kage, market, or content source
     50 +
     51 +Do not use it for internal analysis, progress updates, final report
         s, or subagent instructions where the subagent is forbidden to ask
         the user.
     52 +
     53 +## Ask Threshold
     54 +
     55 +Ask only when the answer changes at least one material outcome:
     56 +
     57 +- owner skill, lifecycle path, or durable work item type
     58 +- user-visible behavior, product scope, audience, persona, or conte
         nt surface
     59 +- security, privacy, data retention, permissions, auth, tenant boun
         dary, money movement, or destructive behavior
     60 +- public claim, SEO target, brand promise, legal/compliance posture
         , or cost
     61 +- architecture, framework, dependency, provider, or runtime behavio
         r
     62 +- staging, deployment, release, closure, ship scope, or bug risk
     63 +- validation strategy when the wrong proof would create false confi
         dence
     64 +
     65 +Proceed without asking only when the default answer is all of these
         :
     66 +
     67 +- clear from the request and known project context
     68 +- low-risk and reversible
     69 +- inside the existing contract, spec, or accepted scope
     70 +- compatible with the current technical, product, and editorial con
         text
     71 +- aligned with current best practices for the affected stack, provi
         der, security posture, and user workflow
     72 +- verifiable with the evidence available in the current run
     73 +
     74 +If the obvious or requested option conflicts with project context,
         public/editorial claims, architecture, security posture, or current
          best practices, do not silently choose it. Either choose the safe
         compatible alternative when it is obvious and inside scope, or ask
         a numbered decision question that explains the conflict.
     75 +
     76 +Never ask broad "anything else?" questions.
     77 +
     78 +## Required Shape
     79 +
     80 +Every user-facing question must be answerable by number. Start each
          question with a numeric marker:
     81 +
     82 +```text
     83 +1. [icon] [decision title]
     84 +```
     85 +
     86 +Use the user's active language for labels and explanation. Stable c
         ommands, paths, IDs, and status values may stay literal.
     87 +
     88 +Each question must include:
     89 +
     90 +- decision title: the decision in plain language
     91 +- why: why the skill needs the answer now
     92 +- recommendation: the best default answer and why it is recommended
     93 +- options: 2-3 practical choices when useful, with number-prefixed
         labels
     94 +- answer instruction: tell the user they can answer with the number
     95 +
     96 +Use small icons only as scanning aids. Icons never replace the text
          label.
     97 +
     98 +## Plain-Text Format
     99 +
    100 +```text
    101 +1. 🧭 [Titre de décision]
    102 +Pourquoi: [ce qui est bloqué, contradictoire ou risqué]
    103 +Recommandé: [option] - [pourquoi c'est le meilleur défaut dans ce c
         ontexte]
    104 +
    105 +Options:
    106 +1. [Option recommandée] - [conséquence]
    107 +2. [Alternative] - [conséquence]
    108 +
    109 +Réponds avec le numéro, ou précise une autre option.
    110 +```
    111 +
    112 +For English users, use `Why`, `Recommended`, `Options`, and `Reply
         with the number`.
    113 +
    114 +## Recommendation Rules
    115 +
    116 +The recommended answer must be the most responsible default, not th
         e easiest path for the agent.
    117 +
    118 +Prefer recommendations that:
    119 +
    120 +- preserve user trust, data safety, and reversibility
    121 +- match the current spec, product contract, and repo conventions
    122 +- respect technical docs, `docs/technical/code-docs-map.md`, `CONTE
         NT_MAP.md`, editorial governance, and public claim boundaries when
         applicable
    123 +- follow current best practices for the stack, provider, security m
         odel, and deployment mode
    124 +- minimize cost or public exposure unless the user explicitly wants
          that tradeoff
    125 +- keep implementation scope small enough to verify
    126 +- avoid premature shipping when proof is missing
    127 +
    128 +Name the condition that would make another option better when that
         matters.

  └ skills/sf-build/SKILL.md (+1 -1)
     98
     99 -If the best-practice answer is clear, low-risk, reversible, and ins
         ide the existing contract, choose it and continue instead of asking
         . If the question is still necessary, make the recommended option f
         irst and explain why it is the most responsible default. Avoid jarg
         on; translate technical details into business consequences.
     99 +If the best-practice answer is clear, low-risk, reversible, inside
         the existing contract, compatible with the current technical/produc
         t/editorial context, aligned with current best practices, and verif
         iable in the current run, choose it and continue instead of asking.
          If the obvious or requested option conflicts with project context,
          public/editorial claims, architecture, security posture, or curren
         t best practices, surface the conflict and ask unless a safe compat
         ible alternative is obvious and inside scope. If the question is st
         ill necessary, make the recommended option first and explain why it
          is the most responsible default. Avoid jargon; translate technical
          details into business consequences.
    100

  └ skills/shipflow/SKILL.md (+1 -1)
    100
    101 -Ask only when the answer changes the route or safety posture. Forma
         t the prompt as one concise routing decision with why the route mat
         ters, the recommended route when there is a safe default, and pract
         ical options.
    101 +Ask only when the answer changes the route or safety posture. Forma
         t the prompt as one concise routing decision with why the route mat
         ters, the recommended route when there is a safe default, and pract
         ical options. A route is a safe default only when it fits the curre
         nt project context and does not conflict with current best practice
         s.
    102

────────────────────────────────────────────────────────────────────────────

• La règle est maintenant plus stricte : un défaut automatique doit aussi
  respecter le contexte technique/produit/éditorial et les bonnes pratiques
  actuelles. Je vérifie que le nouveau fichier existe encore, puis je lance
  le lint metadata sur les artefacts touchés.

• Ran test -f skills/references/question-contract.md && sed -n '1,145p'
  │ skills/references/question-contract.md
  └ ---
    artifact: technical_guidelines
    … +126 lines (ctrl + t to view transcript)
    Name the condition that would make another option better when that
    matters.

• Ran python3 tools/shipflow_metadata_lint.py skills/references/
  │ question-contract.md skills/references/master-workflow-lifecycle.md
  │ docs/technical/skill-runtime-and-lifecycle.md
  │ … +1 lines
  └ ShipFlow metadata lint passed: 4 file(s) checked.

• Ran git diff --stat -- skills/references/question-contract.md skills/
  │ references/master-workflow-lifecycle.md skills/sf-build/SKILL.md
  │ skills/shipflow/SKILL.md docs/technical/skill-runtime-and-lifecycle.md
  │ … +1 lines
  └  docs/technical/skill-runtime-and-lifecycle.md  | 22 ++++++++++++++++++
    ++--
    … +3 lines (ctrl + t to view transcript)
     skills/sf-build/SKILL.md                       |  2 +-
     4 files changed, 47 insertions(+), 10 deletions(-)

• Explored
  └ Search compatible with the current technical/product/editorial context|
           conflicts with project context|aligned with current best
practices|
           question-contract in question-contract.md

• Ran test -f skills/references/question-contract.md && echo
  │ question-contract-present && rg -n "project context|current best
  │ practices|technical/product/editorial" skills/references/
  │ … +1 lines
  └ question-contract-present
    27:  - "User clarification 2026-05-04: a default is acceptable only when
    … +10 lines (ctrl + t to view transcript)
    123:- follow current best practices for the stack, provider, security
    model, and deployment mode

• Ran git status --short | sed -n '1,120p'
  └  M README.md
     M docs/skill-launch-cheatsheet.md
    … +13 lines (ctrl + t to view transcript)
    ?? skills/shipflow/
    ?? specs/shipflow-primary-router-skill.md

────────────────────────────────────────────────────────────────────────────

• Oui, je l’ai durci.

  La règle améliorée est maintenant dans skills/references/question-
  contract.md:63 :

  > On ne procède sans question que si le défaut est clair, low-risk,
  > réversible, dans le contrat/scope, compatible avec le contexte
  > technique/produit/éditorial actuel, aligné avec les best practices
  > actuelles, et vérifiable.

  Et si l’option évidente ou demandée contredit le contexte projet, les
  claims publics/éditoriaux, l’architecture, la posture sécurité ou les best
  practices, la skill ne doit pas l’appliquer en silence : elle doit choisir
  l’alternative sûre évidente si elle existe, ou poser une question
  numérotée.

  J’ai aussi aligné :

  - skills/references/master-workflow-lifecycle.md:105
  - skills/sf-build/SKILL.md:99
  - docs/technical/skill-runtime-and-lifecycle.md:218
  - shipflow-spec-driven-workflow.md:268

  Validation passée : python3 tools/shipflow_metadata_lint.py ... sur les 4
  artefacts concernés.

─ Worked for 1m 34s ────────────────────────────────────────────────────────

• Fast mode set to off


› $sf-content explique cette notion importante dans notre doc et notre
  contenu public, la ou ca aura le plus d'impact.


⚠ Heads up, you have less than 25% of your 5h limit left. Run /status for a
  breakdown.

• J’utilise sf-content pour cette demande, parce qu’elle touche à la fois la
  doctrine interne et les surfaces publiques. Je vais d’abord repérer les
  surfaces à fort impact déjà déclarées, puis appliquer un contenu court et
  cohérent au lieu de disperser la notion partout.

• Explored
  └ Read SKILL.md (sf-content skill), canonical-paths.md, reporting-
contract.md

• Ran git status --short
  └  M README.md
     M docs/skill-launch-cheatsheet.md
    … +13 lines (ctrl + t to view transcript)
    ?? skills/shipflow/
    ?? specs/shipflow-primary-router-skill.md

• Ran sed -n '1,260p' CONTENT_MAP.md 2>/dev/null || true
  └ ---
    artifact: content_map
    … +144 lines (ctrl + t to view transcript)
    - [ ] No newsletter or social publishing repository surface is declared
    yet.

• Context compacted

────────────────────────────────────────────────────────────────────────────

• Je vais traiter ça comme une passe contenu ciblée avec sf-content:
  identifier les surfaces publiques/doc où ce principe influence le plus la
  compréhension, puis patcher uniquement ces endroits. Je vais d’abord
  relire les règles éditoriales et les pages concernées pour éviter
  d’ajouter une explication au mauvais niveau.

• Explored
  └ Read SKILL.md (sf-content skill), CONTENT_MAP.md, editorial-content-
         corpus.md

• Ran git status --short
  └  M README.md
     M docs/skill-launch-cheatsheet.md
    … +13 lines (ctrl + t to view transcript)
    ?? skills/shipflow/
    ?? specs/shipflow-primary-router-skill.md

────────────────────────────────────────────────────────────────────────────

• Le corpus confirme que les surfaces à fort impact sont la doctrine repo
  (README, workflow), la doc technique de lifecycle, et les pages publiques
  qui expliquent les skills et leurs modes. Je vais maintenant vérifier les
  gates éditoriaux et le contenu réel avant de patcher.

• Explored
  └ Read canonical-paths.md, README.md, public-surface-map.md, page-intent-
         map.md, astro-content-schema-policy.md, editorial-update-gate.md,
         claim-register.md, content.config.ts, reporting-
contract.md, question-
         contract.md
    Search question|decision|default|recommand|recommend|best practice|best-
           practice|prompt|clarif|router|scope in README.md
    Read README.md
    Search question|decision|default|recommand|recommend|best practice|
prompt|
           clarif|router|scope|safe in pages
    Read skill-runtime-and-lifecycle.md, shipflow-spec-driven-workflow.md,
         skill-modes.astro, index.astro, why-not-just-prompts.astro,
         shipflow.md, skill-launch-cheatsheet.md, README.md, BRANDING.md,
         PRODUCT.md, sf-build.md, SKILL.md (sf-build skill), master-
workflow-
         lifecycle.md
    List specs
    Search question|default|router|shipflow|skill in specs
    List templates
    Read shipflow-primary-router-skill.md, spec.md

────────────────────────────────────────────────────────────────────────────

• Le changement est public mais la claim reste dans une zone autorisée: on
  parle de réduction d’ambiguïté et de garde-fous, pas de garantie
  d’exactitude. Je vais faire une passe cohérente sur les surfaces déjà
  déclarées: doctrine repo, lifecycle technique, cheatsheet publique, hub
  skills, page shipflow, page sf-build, et la page “why not just prompts”.

• Updated Plan
  └ ✔ Repérer les surfaces de contenu à fort impact
    □ Patcher la doctrine interne et les références publiques
    □ Valider metadata, recherche ciblée et build site
    □ Rapporter le résultat et les limites de chantier

• Explored
  └ Read README.md, skill-runtime-and-lifecycle.md

────────────────────────────────────────────────────────────────────────────

• Je vais maintenant éditer les fichiers. La ligne directrice: documenter
  que “ne pas poser de question” est un privilège réservé aux défauts sûrs,
  réversibles, compatibles avec le contexte projet et les bonnes pratiques;
  sinon la skill doit poser une décision numérotée avec pourquoi et
  recommandation.

• Edited README.md (+11 -3)
      3  metadata_schema_version: "1.0"
      4 -artifact_version: "0.8.2"
      4 +artifact_version: "0.8.3"
      5  project: "shipflow"
        ⋮
     26    - skills/shipflow/SKILL.md
     27 +  - skills/references/question-contract.md
     28    - site/src/content/skills/shipflow.md
        ⋮
     45    - "Documented shipflow <instruction> as the recommended non-techn
         ical router before direct sf-* expert entrypoints."
     46 +  - "Documented the context-aware question/default rule for ShipFlo
         w skills."
     47  next_step: "/sf-docs audit README.md"
        ⋮
    276
    277 +### Question And Default Rule
    278 +
    279 +ShipFlow skills should not ask just because several choices exist.
         They proceed by default only when the answer is clear from the requ
         est and project context, low-risk, reversible, inside the accepted
         scope, compatible with the current technical/product/editorial cont
         ext, aligned with current best practices, and verifiable in the cur
         rent run.
    280 +
    281 +When one of those conditions is not true, the skill should turn the
          ambiguity into a decision brief: start with a number, optionally u
         se a small icon for scanning, explain why the question matters now,
          name the recommended answer, and explain why that recommendation i
         s the best default. If the obvious or requested path conflicts with
          the repo's contracts, public claims, architecture, security postur
         e, or current best practices, the skill must not silently choose it
         .
    282 +
    283  ShipFlow is now optimized for **one-pass execution**.
        ⋮
    295  | --- | --- | --- |
    288 -| Non-technical first command | `shipflow <instruction>` | Routes p
         ure conversation directly; routes real work to the right master or
         specialist skill; asks one numbered question when ambiguous. |
    296 +| Non-technical first command | `shipflow <instruction>` | Routes p
         ure conversation directly; routes real work to the right master or
         specialist skill; uses context-safe defaults and asks one numbered
         decision question when ambiguity changes route, risk, scope, or pro
         of. |
    297  | Non-trivial product, code, site, or docs work | `sf-build <story,
          bug, or goal>` | Plain task text is the story; use `report=agent`,
          `handoff`, `verbose`, or `full-report` only for detailed handoff e
         vidence. |
        ⋮
    355
    348 -`sf-build` follows the shared master delegation doctrine in `skills
         /references/master-delegation-semantics.md`: invocation authorizes
         bounded delegated sequential execution for the current chantier, sh
         ort natural-language confirmations continue that bounded sequential
          path after diagnosis by intent rather than exact keyword, and para
         llel agent execution requires ready non-overlapping `Execution Batc
         hes`. `sf-build` keeps user interaction focused on decisions and pr
         ogress; material questions are framed as business decision briefs w
         ith the root problem, business stakes, options, and a recommended b
         est-practice answer.
    356 +`sf-build` follows the shared master delegation doctrine in `skills
         /references/master-delegation-semantics.md`: invocation authorizes
         bounded delegated sequential execution for the current chantier, sh
         ort natural-language confirmations continue that bounded sequential
          path after diagnosis by intent rather than exact keyword, and para
         llel agent execution requires ready non-overlapping `Execution Batc
         hes`. `sf-build` keeps user interaction focused on decisions and pr
         ogress; material questions are framed as business decision briefs w
         ith the root problem, business stakes, options, and a recommended b
         est-practice answer. It skips the question only when the best defau
         lt is safe, reversible, compatible with the current project context
         , aligned with best practices, and verifiable.
    357

• Edited shipflow-spec-driven-workflow.md (+12 -1)
      3  metadata_schema_version: "1.0"
      4 -artifact_version: "0.14.2"
      4 +artifact_version: "0.14.3"
      5  project: ShipFlow
        ⋮
     31    - skills/references/master-workflow-lifecycle.md
     32 +  - skills/references/question-contract.md
     33  depends_on: []
        ⋮
     56    - "Updated on 2026-05-04 to document shipflow <instruction> as th
         e primary non-technical router with direct main-thread handoff to s
         elected skills."
     57 +  - "Updated on 2026-05-04 to document context-aware defaults and n
         umbered decision questions across skills."
     58  next_review: "unknown"
        ⋮
    269  - Master/orchestrator skills must load `skills/references/master-de
         legation-semantics.md` before choosing execution topology. The refe
         rence defines delegation, subagents, short approvals, degradation,
         and spec/batch-gated parallelism.
    270 +- User-facing questions follow `skills/references/question-contract
         .md`: ask only when the answer changes route, scope, risk, proof, c
         losure, ship posture, public claims, or technical/product/editorial
          direction.
    271  - `sf-build` planning questions should be decision briefs for busin
         ess operators: explain the root problem, business stakes, practical
          options, and the best-practice recommendation before asking for th
         e decision. A default can be chosen without asking only when it is
         clear, safe, reversible, compatible with the current technical/prod
         uct/editorial context, aligned with current best practices, and ver
         ifiable.
        ⋮
    281
    282 +## Question And Default Doctrine
    283 +
    284 +ShipFlow tries to reduce useless questions, not remove decisions. A
          skill can proceed by default only when the default is clear from t
         he request and known project context, low-risk, reversible, inside
         the current contract or accepted scope, compatible with the active
         technical/product/editorial context, aligned with current best prac
         tices for the affected stack or workflow, and verifiable during the
          run.
    285 +
    286 +If any of those conditions is false, the skill should ask a decisio
         n question instead of guessing. The question starts with a number,
         may use a small icon for scanning, explains why the answer is neede
         d now, names the recommended answer, and explains why that recommen
         dation is the safest or most coherent default.
    287 +
    288 +This matters most when the obvious or requested path contradicts th
         e repo's contracts, architecture, public/editorial claims, security
          posture, or current best practices. In that case, the skill either
          takes the obvious safe compatible alternative when it is inside sc
         ope, or asks the operator to choose with the conflict made explicit
         .
    289 +
    290  ## Report Modes

• Edited docs/technical/skill-runtime-and-lifecycle.md (+13 -2)
      3  metadata_schema_version: "1.0"
      4 -artifact_version: "1.10.0"
      4 +artifact_version: "1.10.1"
      5  project: ShipFlow
        ⋮
     30    - skills/references/master-workflow-lifecycle.md
     31 +  - skills/references/question-contract.md
     32    - specs/sf-build-autonomous-master-skill.md
        ⋮
     65    - "shipflow <instruction> documented as the primary non-technical
          router with direct main-thread handoff to selected skills."
     66 +  - "Question contract documented as the shared runtime rule for nu
         mbered questions and context-aware defaults."
     67  next_review: "2026-06-01"
        ⋮
     84  | `skills/references/master-workflow-lifecycle.md` | Shared master/
         orchestrator lifecycle skeleton and work item model | Load before m
         aster skills resolve intake, readiness, model/topology, validation,
          verification, closure, or ship/deploy routes |
     85 +| `skills/references/question-contract.md` | Shared user-facing que
         stion and default-selection contract | Load before routing, clarifi
         cation, product/scope, safety, blocked-state, or recovery-choice qu
         estions |
     86  | `skills/references/reporting-contract.md` | Shared final-report m
         ode contract | Default user reports are concise; detailed reports r
         equire explicit handoff mode |
        ⋮
    220  - Master/orchestrator skills load `skills/references/master-workflo
         w-lifecycle.md` before resolving lifecycle flow. The shared skeleto
         n is intake, work item resolution, readiness, model/topology routin
         g, owner-skill execution, validation/evidence, verification, post-v
         erify closure, and bounded ship/deploy/release routing.
    218 -- Skills should ask user-facing questions only when the answer chan
         ges route, scope, risk, validation, closure, or ship posture. Other
         wise they proceed by the best-practice default only when it is clea
         r, low-risk, reversible, compatible with the current technical/prod
         uct/editorial context, aligned with current best practices, and ver
         ifiable; conflicts with project context or best practices require a
          numbered decision question or an obvious safe alternative.
    221 +- Skills should ask user-facing questions only when the answer chan
         ges route, scope, risk, validation, closure, ship posture, public c
         laims, or technical/product/editorial direction. Otherwise they pro
         ceed by the best-practice default only when it is clear, low-risk,
         reversible, inside scope, compatible with the current technical/pro
         duct/editorial context, aligned with current best practices, and ve
         rifiable; conflicts with project context or best practices require
         a numbered decision question or an obvious safe alternative.
    222  - Bug work uses one Markdown bug file under `bugs/*.md` as the dura
         ble source of truth. `BUGS.md`, when present, is an optional compac
         t/generated/triage view and must not override the bug file.
        ⋮
    243  - `sf-build` planning questions are business decision briefs, not b
         are technical prompts: they name the problem root, business stakes,
          practical options, and recommended best-practice answer before ask
         ing for a decision.
    244 +
    245 +## Question Contract Runtime
    246 +
    247 +`skills/references/question-contract.md` is the runtime source for
         how skills ask. The contract is intentionally stricter than "ask wh
         en unsure": a question is required only when the answer changes a m
         aterial outcome, and a question is forbidden when the safe default
         is already clear, compatible with the current project context, alig
         ned with best practices, and verifiable.
    248 +
    249 +Every user-facing question must be answerable by number. The plain-
         text shape is: numbered title, optional small icon, why the decisio
         n is needed now, recommended answer with rationale, then two or thr
         ee practical options. This keeps the user in decision mode instead
         of forcing them to decode implementation detail.
    250 +
    251 +The important failure case is an apparently obvious path that confl
         icts with project contracts, public/editorial promises, architectur
         e, security posture, or current best practices. A skill must not si
         lently take that path. It either chooses the obvious safe compatibl
         e alternative when it remains inside scope, or asks a numbered deci
         sion question that names the conflict.
    252  - Audit skills still report findings first, but default user report
         s should summarize top findings, proof gaps, chantier potential, an
         d next action; full matrices and domain checklists belong in `repor
         t=agent`.

• Edited docs/skill-launch-cheatsheet.md (+11 -4)
     3  metadata_schema_version: "1.0"
     4 -artifact_version: "1.2.0"
     4 +artifact_version: "1.2.1"
     5  project: ShipFlow
       ⋮
    24    - artifact: "shipflow-spec-driven-workflow.md"
    25 -    artifact_version: "0.14.2"
    25 +    artifact_version: "0.14.3"
    26      required_status: draft
       ⋮
    33    - "shipflow <instruction> documented as the primary non-technical
        router with direct handoff to selected skills."
    34 +  - "Context-aware defaults and numbered decision questions document
        ed for skill launch behavior."
    35  next_step: "/sf-docs audit docs/skill-launch-cheatsheet.md"
       ⋮
    49
    50 +## Question Defaults
    51 +
    52 +Skills should not ask just because more than one path exists. They u
        se a default only when it is clear from the request and project cont
        ext, low-risk, reversible, inside scope, compatible with the current
         technical/product/editorial context, aligned with current best prac
        tices, and verifiable.
    53 +
    54 +When a decision changes route, scope, risk, public claim, validation
        , closure, or ship posture, the question should start with a number,
         explain why it matters, name the recommended answer, and explain wh
        y that answer is the best default. If the requested path conflicts w
        ith project context or best practices, the skill should expose the c
        onflict instead of silently choosing it.
    55 +
    56  ## Master Skills
       ⋮
    59  | --- | --- | --- |
    53 -| Non-technical first command | `shipflow <instruction>` | Routes pu
        re conversation directly; routes feature/code/docs to `sf-build`, ma
        intenance to `sf-maintain`, bugs to `sf-bug`, release/deploy/prod pr
        oof to `sf-deploy`, content to `sf-content`, skill maintenance to `s
        f-skill-build`, and obvious specialist audits to `sf-audit-*`. Asks
        one numbered question when ambiguous. |
    60 +| Non-technical first command | `shipflow <instruction>` | Routes pu
        re conversation directly; routes feature/code/docs to `sf-build`, ma
        intenance to `sf-maintain`, bugs to `sf-bug`, release/deploy/prod pr
        oof to `sf-deploy`, content to `sf-content`, skill maintenance to `s
        f-skill-build`, and obvious specialist audits to `sf-audit-*`. Uses
        a context-safe default when clear; asks one numbered decision questi
        on when ambiguity changes route, risk, scope, or proof. |
    61  | Non-trivial product, code, site, or docs work | `sf-build <story,
        bug, or goal>` | Plain task text is the story. Use `report=agent`, `
        handoff`, `verbose`, or `full-report` only for detailed handoff evid
        ence. |
       ⋮
    89  | --- | --- |
    83 -| `shipflow` | `<instruction>`; pure conversation direct answer; dir
        ect main-thread handoff to selected `sf-*` skill; one numbered clari
        fication question when ambiguous |
    90 +| `shipflow` | `<instruction>`; pure conversation direct answer; dir
        ect main-thread handoff to selected `sf-*` skill; context-safe defau
        lt when clear; one numbered clarification question with why and reco
        mmendation when ambiguous |
    91  | `sf-build` | `<story, bug, or goal>`; `report=agent`; `handoff`; `
        verbose`; `full-report` |

• Edited site/src/pages/skill-modes.astro (+14 -2)
     11      modes:
     12 -      "Answers pure conversation directly; routes feature/code/docs
          to sf-build, maintenance to sf-maintain, bugs to sf-bug, release/d
         eploy/prod proof to sf-deploy, content to sf-content, skill mainten
         ance to sf-skill-build, and obvious specialist audits to sf-audit-*
         . Asks one numbered question when ambiguous."
     12 +      "Answers pure conversation directly; routes feature/code/docs
          to sf-build, maintenance to sf-maintain, bugs to sf-bug, release/d
         eploy/prod proof to sf-deploy, content to sf-content, skill mainten
         ance to sf-skill-build, and obvious specialist audits to sf-audit-*
         . Uses a context-safe default when clear; asks one numbered decisio
         n question with why and recommendation when ambiguity changes route
         , risk, scope, or proof."
     13    },
        ⋮
    108              to the selected skill. Direct master skills still matte
         r when you
    109 -            already know the exact lifecycle you want handled.
    109 +            already know the exact lifecycle you want handled. It d
         oes not ask
    110 +            just because several routes exist; it asks when the def
         ault is not
    111 +            safe, contextual, best-practice-aligned, and verifiable
         .
    112            </p>
        ⋮
    222          </article>
    223 +
    224 +        <article class="doc-card">
    225 +          <h3>4. Decision question</h3>
    226 +          <p>
    227 +            When the safe default is not clear, the skill should as
         k a numbered
    228 +            question with the reason, the recommended answer, and p
         ractical
    229 +            options. If the requested path conflicts with project c
         ontext or
    230 +            best practices, that conflict should be visible.
    231 +          </p>
    232 +        </article>
    233        </div>

• Edited site/src/pages/skills/index.astro (+3 -0)
    86              `sf-content`, `sf-skill-build`, or an obvious audit spec
        ialist.
    87 +            It proceeds by default only when that route is clear, sa
        fe,
    88 +            compatible with project context, aligned with best pract
        ices, and
    89 +            verifiable; otherwise it asks one numbered decision ques
        tion.
    90            </p>

• Edited site/src/pages/why-not-just-prompts.astro (+10 -0)
    68          </article>
    69 +
    70 +        <article class="doc-card">
    71 +          <h3>It decides when to ask</h3>
    72 +          <p>
    73 +            A stronger prompt can still ask randomly or guess silent
        ly.
    74 +            ShipFlow makes that boundary explicit: use a default onl
        y when it
    75 +            fits the current project context and best practices; oth
        erwise ask
    76 +            a numbered question with why and a recommended answer.
    77 +          </p>
    78 +        </article>
    79        </div>

• Edited site/src/content/skills/shipflow.md (+11 -3)
    11  problem: "A user can lose momentum before work starts by having to c
        hoose between build, bug, maintenance, content, deploy, skill, and a
        udit workflows."
    12 -outcome: "You get one first command that either answers directly or
        routes the current thread to the right ShipFlow skill with one numbe
        red clarification question when needed."
    12 +outcome: "You get one first command that either answers directly, ro
        utes the current thread to the right ShipFlow skill, or asks one num
        bered decision question when the safe default is not clear."
    13  founder_angle: "The router keeps the first move simple. You describe
         the business or product need, and ShipFlow chooses whether the work
         is conversation, build, maintenance, bug, release, content, skill m
        aintenance, or audit."
       ⋮
    23    - "A direct main-thread handoff to the selected skill for real wor
        k"
    24 -  - "One numbered question when the route is ambiguous"
    24 +  - "A context-safe default when the route is clear, low-risk, compa
        tible with project context, aligned with best practices, and verifia
        ble"
    25 +  - "One numbered question with why and recommendation when the rout
        e is ambiguous"
    26    - "No hidden master-skill-in-subagent nesting"
       ⋮
    36    - "It does not replace the selected skill's lifecycle gates"
    36 -  - "It asks a numbered question with the reason and recommended rou
        te instead of guessing when routing is ambiguous"
    37 +  - "It asks a numbered question with the reason and recommended rou
        te instead of guessing when routing ambiguity changes scope, risk, p
        roof, or ship posture"
    38 +  - "It does not silently use a default that conflicts with project
        context, public claims, architecture, security posture, or best prac
        tices"
    39    - "It does not run master skills inside hidden subagents"
       ⋮
    60  takes over the main thread and owns its own delegated sequential exe
        cution.
    61 +
    62 +The important default is not "ask less." It is "ask only when the an
        swer
    63 +matters." If the safe route is clear, reversible, compatible with th
        e project,
    64 +aligned with best practices, and verifiable, `shipflow` should move.
         If the
    65 +route would change risk, scope, public claims, proof, or ship postur
        e, it should
    66 +ask a numbered question that explains why and names the recommended
        answer.

• Edited site/src/content/skills/sf-build.md (+9 -1)
    25    - "Implementation, verification, docs alignment, and closure routi
        ng"
    26 +  - "Context-aware defaults when the best path is clear, safe, rever
        sible, and verifiable"
    27    - "A concise user report with chantier status when a unique spec i
        s in scope"
       ⋮
    40    - "It does not skip safeguards; it reduces manual command-chaining
        "
    40 -  - "It asks a business-framed question when a decision changes beha
        vior, risk, permissions, security, or ship posture"
    41 +  - "It asks a numbered business-framed question when a decision cha
        nges behavior, risk, permissions, security, public claims, validatio
        n, or ship posture"
    42 +  - "It should not silently follow a requested path that conflicts w
        ith current project context or best practices"
    43    - "It should not ship unrelated dirty files without explicit user
        approval"
       ⋮
    63
    64 +`sf-build` should not ask for a decision when the responsible defaul
        t is already
    65 +clear. The default must still fit the current technical, product, an
        d editorial
    66 +context, follow current best practices, stay reversible enough for t
        he scope,
    67 +and be verifiable. When that is not true, the question should be num
        bered and
    68 +explain why the recommendation is the best default.
    69 +
    70  For a narrow command such as "run checks" or "open browser proof", c
        all the

• Explored
  └ Read faq.astro

• Edited site/src/pages/faq.astro (+4 -0)
    15    {
    16 +    q: "Why do skills sometimes ask a numbered question?",
    17 +    a: "Because a decision changes route, scope, risk, public claims
        , validation, closure, or ship posture. If the best default is clear
        , safe, compatible with the current project context, aligned with be
        st practices, and verifiable, the skill should proceed instead of as
        king."
    18 +  },
    19 +  {
    20      q: "Do ShipFlow skills work with both Codex and Claude Code?",

• Explored
  └ Read skill-runtime-and-lifecycle.md, README.md, shipflow-spec-driven-
         workflow.md, skill-launch-cheatsheet.md

• Edited docs/technical/skill-runtime-and-lifecycle.md (+1 -1)
    243  - `sf-build` planning questions are business decision briefs, not b
         are technical prompts: they name the problem root, business stakes,
          practical options, and recommended best-practice answer before ask
         ing for a decision.
    244 +- Audit skills still report findings first, but default user report
         s should summarize top findings, proof gaps, chantier potential, an
         d next action; full matrices and domain checklists belong in `repor
         t=agent`.
    245
        ⋮
    252  The important failure case is an apparently obvious path that confl
         icts with project contracts, public/editorial promises, architectur
         e, security posture, or current best practices. A skill must not si
         lently take that path. It either chooses the obvious safe compatibl
         e alternative when it remains inside scope, or asks a numbered deci
         sion question that names the conflict.
    252 -- Audit skills still report findings first, but default user report
         s should summarize top findings, proof gaps, chantier potential, an
         d next action; full matrices and domain checklists belong in `repor
         t=agent`.
    253

• Explored
  └ Read docs.astro

• Edited site/src/pages/docs.astro (+11 -0)
    87          <article class="doc-card">
    88 +          <h3>Defaults have to fit the context</h3>
    89 +          <p>
    90 +            ShipFlow skills do not ask just to be cautious, and they
         do not
    91 +            guess just to move faster. A default is acceptable only
        when it
    92 +            fits the current project context, best practices, and av
        ailable
    93 +            proof; otherwise the skill asks a numbered decision ques
        tion.
    94 +          </p>
    95 +          <a class="doc-action" href="/skill-modes">Open the launch
        cheatsheet</a>
    96 +        </article>
    97 +
    98 +        <article class="doc-card">
    99            <h3>Public content stays tied to product truth</h3>

────────────────────────────────────────────────────────────────────────────

• Les patches sont en place sur les surfaces publiques et doctrine. Je vais
  maintenant vérifier qu’on n’a pas cassé les métadonnées ni la collection
  Astro, puis je ferai un scan ciblé pour confirmer que la notion est bien
  présente aux bons endroits.

• Updated Plan
  └ ✔ Repérer les surfaces de contenu à fort impact
    ✔ Patcher la doctrine interne et les références publiques
    □ Valider metadata, recherche ciblée et build site
    □ Rapporter le résultat et les limites de chantier

• Explored
  └ Search Question And Default|Question Defaults|Question Contract Runtime|
           context-safe|numbered decision|best practices|question-contract|
           recommended answer in README.md

• Ran python3 tools/shipflow_metadata_lint.py README.md
  │ shipflow-spec-driven-workflow.md docs/skill-launch-cheatsheet.md docs/
  │ technical/skill-runtime-and-lifecycle.md
  └ ShipFlow metadata lint passed: 4 file(s) checked.

• Waited for background terminal · npm --prefix site run build

• Ran npm --prefix site run build
  └
    > shipflow-site@0.1.0 build
    … +97 lines (ctrl + t to view transcript)
    21:03:04 [build] 67 page(s) built in 2.91s
    21:03:04 [build] Complete!

• Ran git diff --check -- README.md shipflow-spec-driven-workflow.md docs/
  │ skill-launch-cheatsheet.md docs/technical/
  │ skill-runtime-and-lifecycle.md site/src/pages/docs.astro site/src/
  │ … +3 lines
  └ (no output)

• Ran git diff --stat -- README.md shipflow-spec-driven-workflow.md docs/
  │ skill-launch-cheatsheet.md docs/technical/
  │ skill-runtime-and-lifecycle.md site/src/pages/docs.astro site/src/
  │ … +3 lines
  └  README.md                                     | 26 ++++++++++++++++---
     docs/skill-launch-cheatsheet.md               | 18 +++++++++++---
    … +10 lines (ctrl + t to view transcript)
     site/src/pages/why-not-just-prompts.astro     | 10 ++++++++
     10 files changed, 169 insertions(+), 27 deletions(-)

• Ran git status --short
  └  M README.md
     M docs/skill-launch-cheatsheet.md
    … +17 lines (ctrl + t to view transcript)
    ?? skills/shipflow/
    ?? specs/shipflow-primary-router-skill.md

• Explored
  └ Search *sf-build* in skills
    List skills
    Search ^slug: \"(sf-build|shipflow)\"|^title: \"(sf-build|shipflow)\" in
           skills

• Updated Plan
  └ ✔ Repérer les surfaces de contenu à fort impact
    ✔ Patcher la doctrine interne et les références publiques
    ✔ Valider metadata, recherche ciblée et build site
    □ Rapporter le résultat et les limites de chantier

• Updated Plan
  └ ✔ Repérer les surfaces de contenu à fort impact
    ✔ Patcher la doctrine interne et les références publiques
    ✔ Valider metadata, recherche ciblée et build site
    ✔ Rapporter le résultat et les limites de chantier

────────────────────────────────────────────────────────────────────────────

• J’ai ajouté l’explication là où elle pèse le plus: doctrine repo,
  cheatsheet, doc technique, et contenu public.

  Modifié:

  - README.md:277: nouvelle règle “Question And Default Rule”.
  - shipflow-spec-driven-workflow.md:282: doctrine complète sur défauts
    contextuels et questions numérotées.
  - docs/technical/skill-runtime-and-lifecycle.md:246: runtime contract pour
    les skills.
  - docs/skill-launch-cheatsheet.md:50: règle de lancement et défauts.
  - Public site: /docs, /faq, /skill-modes, /skills, /why-not-just-prompts,
    plus les fiches shipflow et sf-build.

  Le message est maintenant clair: une skill ne pose pas de question si le
  bon défaut est clair, sûr, réversible, compatible avec le contexte
  technique/produit/éditorial, conforme aux best practices, et vérifiable.
  Sinon elle pose une question numérotée avec pourquoi, recommandation, et
  options.

  Validations:

  - python3 tools/shipflow_metadata_lint.py ... ✅
  - git diff --check ... ✅
  - npm --prefix site run build ✅, avec les warnings existants de duplicate
    content id sf-build / shipflow.

  Fresh docs: not needed, changement local de doctrine/contenu.

  ## Chantier

  non trace: demande contenu transverse sans spec unique identifiée.

  Flux: sf-content ✅ -> contenu public/docs ✅ -> validations ✅

─ Worked for 7m 49s ────────────────────────────────────────────────────────

⚠ Skipped loading 1 skill(s) due to invalid SKILL.md files.

⚠ /home/ubuntu/shipflow/skills/sf-build/SKILL.md: missing YAML frontmatter
  delimited by ---


› $tmux-capture-conversation a la racine shipflow


• J’utilise tmux-capture-conversation. Tu as explicitement donné la
  destination “racine ShipFlow”, donc je vais capturer le panneau tmux
  courant et écrire le Markdown directement sous /home/ubuntu/shipflow, avec
  un titre inféré depuis le contenu plutôt qu’un nom de fenêtre générique.

• Explored
  └ Read canonical-paths.md, capture_tmux_conversation.sh

• Ran SHIPFLOW_ROOT="${SHIPFLOW_ROOT:-$HOME/shipflow}" "$SHIPFLOW_ROOT/
  │ skills/tmux-capture-conversation/scripts/capture_tmux_conversation.sh"
  │ --destination /home/ubuntu/shipflow --dry-run
  └ Title: Conversation tmux - panneau courant - nvim
    Destination: /home/ubuntu/shipflow/
    … +3 lines (ctrl + t to view transcript)
    Neovim command: cd /home/ubuntu/shipflow && nvim
    conversation-tmux-panneau-courant-nvim.md

────────────────────────────────────────────────────────────────────────────

• Le dry-run montre un titre générique (nvim), donc je ne vais pas
  l’accepter tel quel. Je vais inspecter rapidement le texte capturé pour
  déduire un vrai titre; si le panneau n’est pas la conversation attendue,
  je te le dirai avant d’écrire.

• Ran tmux capture-pane -t 1:12.1 -p -S - | sed -n '1,120p'
  └      󰈔 [No Name]
      GIT STATUS for ~/dotfiles         ┃  1    ┃          󰭻 Avante
    … +48 lines (ctrl + t to view transcript)
     INSERT   ~/dotfiles  2                         AvanteInput    1:1
    Top

• Ran tmux list-windows -F '#{window_index}:#{window_name}:#{window_active}'
  └ 1:node:0
    2:node:0
    … +8 lines (ctrl + t to view transcript)
    11:nvim:0
    12:nvim:1

• Ran tmux capture-pane -t 1:12.1 -p -S - | tail -120
  └      󰈔 [No Name]
      GIT STATUS for ~/dotfiles         ┃  1    ┃          󰭻 Avante
    … +48 lines (ctrl + t to view transcript)
     INSERT   ~/dotfiles  2                         AvanteInput    1:1
    Top

────────────────────────────────────────────────────────────────────────────

• Le panneau actif n’est pas la conversation ShipFlow: c’est un nvim dans ~/
  dotfiles avec Avante, donc l’écriture à la racine ShipFlow serait
  probablement une mauvaise capture. Je vais chercher dans les fenêtres tmux
  visibles laquelle contient cette conversation avant de te demander un
  numéro.

• Ran tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}
  │ window=#{window_name} active=#{window_active}
  │ pane_current_command=#{pane_current_command} cwd=#{pane_current_path}'
  └ 0:1.1 window=bash active=1 pane_current_command=bash cwd=/home/ubuntu
    1:1.1 window=node active=0 pane_current_command=node cwd=/home/ubuntu/
    … +18 lines (ctrl + t to view transcript)
    1:12.1 window=nvim active=0 pane_current_command=nvim cwd=/home/ubuntu/
    dotfiles

• Ran for target in $(tmux list-panes -a -F
  │ '#{session_name}:#{window_index}.#{pane_index}'); do if tmux
  │ capture-pane -t "$target" -p -S - | rg -q 'tmux-capture-conversation|
  │ … +3 lines
  └ 1:10.1

• Ran tmux capture-pane -t 1:1.1 -p -S - | tail -80
  └ • Explored
      └ Search ### Step 3|### Phase|Fix|Report|Update|AUDIT_LOG|TASKS|
    … +76 lines (ctrl + t to view transcript)

      gpt-5.5 xhigh · ~/shipflow · Context 49% left · 5h 81% · weekly…

• Ran tmux capture-pane -t 1:2.1 -p -S - | tail -80
  └          arts with a number, may use a small icon for scanning, ex
             plains why the answer is needed now, names the recommende
    … +76 lines (ctrl + t to view transcript)

      gpt-5.5 xhigh fast · ~/shipflow · Context 14% left · 5h 15% · w…

• Ran tmux capture-pane -t 1:10.1 -p -S - | tail -80
  └ • Ran SHIPFLOW_ROOT="${SHIPFLOW_ROOT:-$HOME/shipflow}" "$SHIPFLOW_ROOT/
      │ skills/tmux-capture-conversation/scripts/
    … +77 lines (ctrl + t to view transcript)

      gpt-5.5 xhigh · ~/shipflow · Context 51% left · 5h 12% · weekly 15%

────────────────────────────────────────────────────────────────────────────

• J’ai trouvé la conversation ShipFlow dans 1:10.1, pas dans le panneau
  actif. Je vais donc capturer l’onglet 10 vers la racine /home/ubuntu/
  shipflow avec un titre explicite plutôt que le titre générique détecté.

◦ Working (1m 17s • esc to interrupt)


› Implement {feature}

  gpt-5.5 xhigh · ~/shipflow · Context 50% left · 5h 12% · weekly 15%

/home/ubuntu/home/ubuntu/home/ubuntu
