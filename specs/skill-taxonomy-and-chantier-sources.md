---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipFlow
created: "2026-04-27"
created_at: "2026-04-27 19:34:21 UTC"
updated: "2026-04-27"
updated_at: "2026-04-27 19:59:25 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
user_story: "En tant qu'utilisatrice ShipFlow qui lance des skills d'audit, diagnostic, verification et pilotage, je veux que chaque skill sache si elle peut etre source d'un chantier et comment formaliser la suite, afin que les travaux importants ne restent pas bloques dans un simple rapport de conversation."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/chantier-tracking.md
  - skills/sf-help/SKILL.md
  - skills/*/SKILL.md
  - specs/
  - templates/artifacts/spec.md
  - shipflow-spec-driven-workflow.md
depends_on:
  - artifact: "specs/specs-as-chantier-registry.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "templates/artifacts/spec.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "User decision 2026-04-27: focus only on internal taxonomy and chantier process; public website taxonomy is out of scope for now."
  - "User problem 2026-04-27: audit and diagnostic skills can produce important follow-up work that remains trapped in the conversation."
  - "Repo investigation 2026-04-27: current chantier doctrine only supports obligatoire, conditionnel, and non-applicable spec tracing."
  - "Repo investigation 2026-04-27: sf-deps, sf-perf, sf-audit, sf-check, sf-test, sf-prod, sf-migrate, and sf-auth-debug are currently conditionnel but can originate new chantiers."
next_step: "None"
---

# Spec: Skill Taxonomy and Chantier Sources

## Title

Skill Taxonomy and Chantier Sources

## Status

ready

## User Story

En tant qu'utilisatrice ShipFlow qui lance des skills d'audit, diagnostic, verification et pilotage, je veux que chaque skill sache si elle peut etre source d'un chantier et comment formaliser la suite, afin que les travaux importants ne restent pas bloques dans un simple rapport de conversation.

## Minimal Behavior Contract

Quand une skill ShipFlow termine un travail qui revele plus qu'une action immediate, elle doit determiner si son resultat est un chantier potentiel, l'indiquer explicitement dans son rapport final, et orienter vers une spec durable quand le travail necessite de la reflexion, des decisions, plusieurs etapes, ou une verification ulterieure. Si un chantier existe deja, la skill continue a tracer selon la doctrine actuelle; si aucun chantier unique n'existe mais que le rapport revele un vrai travail a suivre, elle ne doit pas ecrire au hasard dans une spec existante, mais produire un bloc `Chantier potentiel` avec titre propose, raison, severite, scope, evidence et prochaine commande `/sf-spec ...`. Le cas facile a rater est une skill `conditionnel` comme `sf-deps` ou `sf-perf`: elle ne peut pas tracer dans une spec ambigue, mais elle peut et doit recommander la creation d'un chantier quand ses findings depassent un simple fix direct.

## Success Behavior

- Preconditions: ShipFlow possede deja une doctrine de chantier dans `skills/references/chantier-tracking.md`, une matrice `obligatoire/conditionnel/non-applicable`, et des `SKILL.md` avec blocs `Chantier Tracking`.
- Trigger: une skill produit un audit, un diagnostic, une verification, une revue, ou un rapport qui contient des actions futures non triviales.
- User/operator result: le rapport final dit clairement si la skill est `source-de-chantier`, si un chantier potentiel existe, et quelle prochaine commande lancer.
- System effect: la doctrine de chantier contient une taxonomie interne augmentee; les skills concernees contiennent une instruction standard de detection de chantier potentiel; `sf-help` documente les categories.
- Success proof: lancer ou relire `sf-deps`, `sf-perf`, `sf-audit`, `sf-check` ou `sf-prod` montre un format standard qui ne laisse plus les findings critiques seulement dans la conversation.
- Silent success: not allowed; une skill source qui revele un chantier potentiel doit le dire explicitement dans le rapport.

## Error Behavior

- Expected failures: plusieurs specs candidates, aucun chantier existant, findings trop faibles pour justifier une spec, rapport incomplet, seuil de severite ambigu, skill helper non concernee.
- User/operator response: le rapport final doit dire `Chantier potentiel: oui`, `non`, ou `incertain`, avec une raison concrete et une prochaine action.
- System effect: aucune ecriture speculative dans une spec existante; aucune creation automatique de spec sans passage par `sf-spec`.
- Must never happen: rattacher un audit a la mauvaise spec, ouvrir un chantier pour chaque micro-finding, laisser un P0/P1 sans prochaine etape, confondre taxonomie publique du site et taxonomie interne du process, creer un registre parallele hors `specs/`.
- Silent failure: not allowed; si une skill source ne peut pas evaluer le chantier potentiel, elle doit indiquer la preuve manquante.

## Problem

La doctrine actuelle resout la tracabilite d'un chantier deja identifie, mais pas l'amont du probleme: beaucoup de skills decouvrent elles-memes le chantier. Un audit de dependencies, performance, code, SEO, auth ou prod peut produire des dizaines de findings. Sans mecanisme explicite, le rapport reste dans la conversation, puis l'utilisateur doit relancer manuellement `sf-spec` en reconstituant le contexte.

Cela rend le systeme incoherent: `sf-spec` sait creer un chantier, les lifecycle skills savent le suivre, mais les skills qui decouvrent le travail n'ont pas de responsabilite claire pour transformer un signal en chantier potentiel.

## Solution

Etendre la doctrine avec une seconde taxonomie interne: la categorie de tracing reste `obligatoire`, `conditionnel`, `non-applicable`, mais chaque skill recoit aussi une capacite de lifecycle, dont `source-de-chantier`. Les skills sources appliquent un seuil standard et terminent leurs rapports avec un bloc `Chantier potentiel`; quand le seuil est atteint, elles recommandent une commande `/sf-spec` pre-remplie et fournissent les elements minimaux a copier dans la future spec.

## Scope In

- Definir la taxonomie interne des skills pour le process chantier.
- Ajouter le concept `source-de-chantier` sans remplacer `obligatoire/conditionnel/non-applicable`.
- Definir les seuils qui transforment un rapport en chantier potentiel.
- Definir un bloc final standard `Chantier potentiel`.
- Classer les skills existantes entre `source-de-chantier`, `support-de-chantier`, `lifecycle`, `pilotage`, et `helper`.
- Mettre a jour `skills/references/chantier-tracking.md`.
- Mettre a jour `skills/sf-help/SKILL.md`.
- Mettre a jour les `SKILL.md` des principales sources de chantier.
- Garder `specs/` comme registre unique des chantiers.

## Scope Out

- Taxonomie commerciale ou marketing pour le site public ShipFlow.
- Design de page web, cards, filtres ou navigation de site.
- Creation automatique d'une spec depuis une skill source sans passer par `sf-spec`.
- Retroconversion de tous les anciens rapports de conversation en specs.
- Changement du format `TASKS.md`, `AUDIT_LOG.md` ou `PROJECTS.md`.
- Refonte complete du systeme de skills ou de marketplace.

## Constraints

- La taxonomie publique future peut differer de la taxonomie interne; cette spec ne doit pas figer le site.
- `source-de-chantier` est une capacite de process, pas une categorie exclusive: une skill peut etre `conditionnel` pour le tracing et `source-de-chantier` pour l'intake.
- Les skills ne doivent pas ecrire dans une spec ambigue.
- Les skills sources ne doivent pas noyer l'utilisateur avec une spec pour chaque finding mineur.
- Le seuil doit favoriser la tracabilite des travaux qui demandent de la reflexion, des decisions, plusieurs etapes, ou une validation.
- Les rapports doivent rester lisibles et actionnables.

## Dependencies

- Runtime: markdown, YAML frontmatter, instructions de skills ShipFlow.
- Document contracts: `specs/specs-as-chantier-registry.md`, `skills/references/chantier-tracking.md`, `templates/artifacts/spec.md`.
- Metadata gaps: `skills/references/chantier-tracking.md` est encore `status: draft`; cette spec depend de sa forme actuelle et devra le mettre a jour.
- Fresh external docs: fresh-docs not needed, because the change is local to ShipFlow process and markdown skill instructions.

## Invariants

- `specs/` reste le registre global des chantiers.
- Une skill source ne cree pas de spec directement; elle recommande `sf-spec` avec assez de contexte.
- Une skill conditionnelle attachee a un chantier unique continue a tracer dans ce chantier.
- Une skill conditionnelle sans chantier unique ne trace pas dans une spec existante au hasard.
- La matrice actuelle de tracing reste valide mais devient insuffisante seule.
- Un agent frais doit pouvoir comprendre depuis la doctrine si une skill peut creer un chantier potentiel.

## Links & Consequences

- Upstream systems: `sf-spec` reste l'entree de creation durable; les sources lui fournissent titre, raison, evidence, scope et next step.
- Downstream systems: `sf-ready`, `sf-start`, `sf-verify`, `sf-end`, `sf-ship` continuent le cycle apres creation de la spec.
- Cross-cutting checks: audits, deps, perf, tests, prod, migrations et debug auth doivent evaluer le potentiel chantier a la fin du rapport.
- Operational trackers: `TASKS.md` et `AUDIT_LOG.md` peuvent rester utiles pour les audits, mais ne remplacent pas le chantier quand une vraie decision/spec est necessaire.
- Documentation impact: `sf-help` et `shipflow-spec-driven-workflow.md` doivent expliquer les deux axes: tracing category et process role.

## Documentation Coherence

- `skills/references/chantier-tracking.md` doit documenter `Trace category` et `Process role` comme deux champs separes.
- `skills/sf-help/SKILL.md` doit afficher une matrice lisible des roles internes.
- `skills/sf-spec/SKILL.md` doit accepter une entree provenant d'une skill source et reprendre son contexte sans le perdre.
- Les skills sources doivent inclure le bloc `Chantier potentiel`.
- `shipflow-spec-driven-workflow.md` doit expliquer le flux: source skill -> chantier potentiel -> `sf-spec` -> `sf-ready` -> `sf-start`.
- `CHANGELOG.md` doit mentionner l'ajout du role `source-de-chantier`.

## Edge Cases

- Un audit trouve un seul fix trivial: `Chantier potentiel: non`, prochaine etape directe possible.
- Un audit trouve plusieurs P2 mais aucun P0/P1: `Chantier potentiel: oui` si les corrections touchent plusieurs fichiers ou demandent arbitrage.
- `sf-deps` trouve des vulnerabilites critiques mais deux specs actives existent: ne pas ecrire dans une spec; recommander une nouvelle spec ou demander selection explicite.
- `sf-prod` revele une panne: chantier potentiel incident, meme si aucune spec n'existait.
- `sf-check` echoue sur une erreur locale mono-fichier: pas forcement chantier; orienter vers fix direct.
- `sf-test` revele un bug critique avec dossier bug: peut etre source d'un chantier bug si la correction depasse la retouche directe.
- `sf-backlog` capture une idee vague: pilotage, pas source automatique, sauf si l'utilisateur demande explicitement de cadrer en spec.
- Une skill helper comme `sf-context` ne doit pas devenir source seulement parce qu'elle lit du contexte.

## Implementation Tasks

- [x] Task 1: Etendre la doctrine chantier avec deux axes de classification
  - File: `skills/references/chantier-tracking.md`
  - Action: Ajouter la distinction `Trace category` (`obligatoire`, `conditionnel`, `non-applicable`) et `Process role` (`lifecycle`, `source-de-chantier`, `support-de-chantier`, `pilotage`, `helper`).
  - User story link: Evite de confondre "peut ecrire dans une spec existante" et "peut reveler un chantier a creer".
  - Depends on: None
  - Validate with: `rg -n "source-de-chantier|Process role|Trace category|Chantier potentiel" skills/references/chantier-tracking.md`
  - Notes: Garder la compatibilite avec les instructions existantes.

- [x] Task 2: Definir le seuil standard de chantier potentiel
  - File: `skills/references/chantier-tracking.md`
  - Action: Documenter les criteres: P0/P1, plusieurs fichiers ou domaines, decision produit/technique, migration, risque secu/data/prod, besoin de validation, travail impossible a finir en un fix direct.
  - User story link: Les skills sources savent quand recommander une spec.
  - Depends on: Task 1
  - Validate with: `rg -n "seuil|P0|P1|plusieurs fichiers|decision|validation" skills/references/chantier-tracking.md`
  - Notes: Le seuil doit aussi dire quand ne pas creer de chantier.

- [x] Task 3: Definir le bloc standard `Chantier potentiel`
  - File: `skills/references/chantier-tracking.md`
  - Action: Ajouter un format final avec `Chantier potentiel`, `Titre propose`, `Raison`, `Severite`, `Scope`, `Evidence`, `Spec recommandee`, `Prochaine etape`.
  - User story link: Les findings importants deviennent actionnables sans relire toute la conversation.
  - Depends on: Task 2
  - Validate with: `rg -n "Titre propose|Spec recommandee|Prochaine etape|Evidence" skills/references/chantier-tracking.md`
  - Notes: Le bloc doit coexister avec le bloc `Chantier`.

- [x] Task 4: Produire la matrice interne des roles pour toutes les skills
  - File: `skills/sf-help/SKILL.md`
  - Action: Ajouter une matrice `Skill | Trace category | Process role | Source threshold`.
  - User story link: Donne une vue coherente des 46 skills sans imposer une logique unique a toutes.
  - Depends on: Tasks 1-3
  - Validate with: `rg -n "Process role|source-de-chantier|support-de-chantier|pilotage|helper" skills/sf-help/SKILL.md`
  - Notes: Inclure `continue` ou documenter explicitement son statut manquant si la skill reste hors matrice actuelle.

- [x] Task 5: Mettre a jour `sf-spec` pour consommer un rapport source
  - File: `skills/sf-spec/SKILL.md`
  - Action: Ajouter l'instruction: si l'entree contient un bloc `Chantier potentiel`, reprendre titre, evidence, scope, severite et next step dans la spec.
  - User story link: La transition rapport -> spec ne perd pas le contexte.
  - Depends on: Task 3
  - Validate with: `rg -n "Chantier potentiel|Titre propose|Evidence|source-de-chantier" skills/sf-spec/SKILL.md`
  - Notes: `sf-spec` reste la seule skill qui cree la spec durable.

- [x] Task 6: Mettre a jour les sources audit et diagnostic prioritaires
  - File: `skills/sf-deps/SKILL.md`, `skills/sf-perf/SKILL.md`, `skills/sf-audit/SKILL.md`, `skills/sf-audit-code/SKILL.md`, `skills/sf-audit-design/SKILL.md`, `skills/sf-audit-a11y/SKILL.md`, `skills/sf-audit-components/SKILL.md`, `skills/sf-audit-seo/SKILL.md`, `skills/sf-audit-gtm/SKILL.md`, `skills/sf-audit-copy/SKILL.md`, `skills/sf-audit-copywriting/SKILL.md`, `skills/sf-audit-translate/SKILL.md`, `skills/sf-audit-design-tokens/SKILL.md`
  - Action: Ajouter `Process role: source-de-chantier` et le bloc `Chantier potentiel` dans les instructions de rapport.
  - User story link: Les audits ne laissent plus leurs corrections majeures dans la conversation.
  - Depends on: Tasks 1-4
  - Validate with: `rg -n "source-de-chantier|Chantier potentiel" skills/sf-deps/SKILL.md skills/sf-perf/SKILL.md skills/sf-audit*/SKILL.md`
  - Notes: Les sous-audits peuvent proposer un chantier specialise; `sf-audit` peut proposer un chantier transversal.

- [x] Task 7: Mettre a jour les sources incident, verification et migration
  - File: `skills/sf-auth-debug/SKILL.md`, `skills/sf-prod/SKILL.md`, `skills/sf-check/SKILL.md`, `skills/sf-test/SKILL.md`, `skills/sf-migrate/SKILL.md`, `skills/sf-fix/SKILL.md`
  - Action: Ajouter le role source quand les resultats depassent le fix direct; documenter les seuils spec-first.
  - User story link: Les bugs, incidents, migrations et echecs de validation deviennent des chantiers quand le risque le justifie.
  - Depends on: Tasks 1-4
  - Validate with: `rg -n "source-de-chantier|Chantier potentiel|spec-first" skills/sf-auth-debug/SKILL.md skills/sf-prod/SKILL.md skills/sf-check/SKILL.md skills/sf-test/SKILL.md skills/sf-migrate/SKILL.md skills/sf-fix/SKILL.md`
  - Notes: Garder la possibilite de correction directe pour les problemes locaux.

- [x] Task 8: Classer les skills de contenu, recherche et pilotage
  - File: `skills/sf-market-study/SKILL.md`, `skills/sf-veille/SKILL.md`, `skills/sf-research/SKILL.md`, `skills/sf-docs/SKILL.md`, `skills/sf-enrich/SKILL.md`, `skills/sf-redact/SKILL.md`, `skills/sf-repurpose/SKILL.md`, `skills/sf-review/SKILL.md`, `skills/sf-priorities/SKILL.md`, `skills/sf-backlog/SKILL.md`, `skills/sf-tasks/SKILL.md`
  - Action: Assigner `source-de-chantier`, `support-de-chantier`, ou `pilotage` selon le role; ajouter le bloc seulement aux vraies sources.
  - User story link: Les rapports strategiques ou contenus peuvent ouvrir un chantier quand il y a une vraie suite a formaliser.
  - Depends on: Tasks 1-4
  - Validate with: `rg -n "Process role|source-de-chantier|support-de-chantier|pilotage|Chantier potentiel" skills/sf-market-study/SKILL.md skills/sf-veille/SKILL.md skills/sf-research/SKILL.md skills/sf-docs/SKILL.md skills/sf-enrich/SKILL.md skills/sf-redact/SKILL.md skills/sf-repurpose/SKILL.md skills/sf-review/SKILL.md skills/sf-priorities/SKILL.md skills/sf-backlog/SKILL.md skills/sf-tasks/SKILL.md`
  - Notes: Eviter de transformer chaque idee de backlog en chantier.

- [x] Task 9: Documenter les helpers et lifecycle non sources
  - File: `skills/sf-context/SKILL.md`, `skills/sf-model/SKILL.md`, `skills/sf-help/SKILL.md`, `skills/sf-status/SKILL.md`, `skills/sf-resume/SKILL.md`, `skills/sf-explore/SKILL.md`, `skills/name/SKILL.md`, `skills/continue/SKILL.md`, `skills/sf-ready/SKILL.md`, `skills/sf-start/SKILL.md`, `skills/sf-verify/SKILL.md`, `skills/sf-end/SKILL.md`, `skills/sf-ship/SKILL.md`
  - Action: Confirmer leur role `helper` ou `lifecycle`, et documenter quand ils doivent router vers une source ou vers `sf-spec` au lieu de devenir source eux-memes.
  - User story link: Les skills ne se sentent plus perdues apres execution: chacune connait sa responsabilite.
  - Depends on: Task 4
  - Validate with: `rg -n "Process role|helper|lifecycle|source-de-chantier" skills/sf-context/SKILL.md skills/sf-model/SKILL.md skills/sf-help/SKILL.md skills/sf-status/SKILL.md skills/sf-resume/SKILL.md skills/sf-explore/SKILL.md skills/name/SKILL.md skills/continue/SKILL.md skills/sf-ready/SKILL.md skills/sf-start/SKILL.md skills/sf-verify/SKILL.md skills/sf-end/SKILL.md skills/sf-ship/SKILL.md`
  - Notes: `continue` avait une categorie chantier manquante pendant l'investigation; il faut la normaliser ou l'exclure explicitement.

- [x] Task 10: Mettre a jour le workflow spec-driven
  - File: `shipflow-spec-driven-workflow.md`
  - Action: Ajouter le flux `source skill -> Chantier potentiel -> sf-spec -> sf-ready -> sf-start -> sf-verify -> sf-end/sf-ship`.
  - User story link: Rend le processus transmissible a un agent frais.
  - Depends on: Tasks 1-9
  - Validate with: `rg -n "Chantier potentiel|source skill|source-de-chantier|sf-spec" shipflow-spec-driven-workflow.md`
  - Notes: Ne pas inclure la taxonomie du site public.

- [x] Task 11: Ajouter la validation de coherence
  - File: `skills/sf-verify/SKILL.md`
  - Action: Ajouter un check de coherence: toute skill modifiee doit avoir `Trace category` et `Process role`; les sources doivent avoir le bloc `Chantier potentiel`.
  - User story link: Evite les regressions quand de nouvelles skills sont ajoutees.
  - Depends on: Tasks 1-10
  - Validate with: `rg -n "Trace category|Process role|Chantier potentiel" skills/sf-verify/SKILL.md`
  - Notes: Si un script de lint metadata existe ou devient necessaire, le proposer comme suivi, pas comme precondition.

- [x] Task 12: Ajouter l'entree changelog
  - File: `CHANGELOG.md`
  - Action: Documenter l'ajout de la taxonomie interne et du role `source-de-chantier`.
  - User story link: Garde une trace du changement de processus ShipFlow.
  - Depends on: Tasks 1-11
  - Validate with: `rg -n "source-de-chantier|Chantier potentiel|skill taxonomy" CHANGELOG.md`
  - Notes: Entree courte, orientee process.

## Acceptance Criteria

- [x] AC 1: Given une skill existante, when on lit sa section chantier, then elle expose ou herite clairement d'une `Trace category` et d'un `Process role`.
- [x] AC 2: Given `sf-deps` trouve des vulnerabilites critiques sans chantier unique, when son rapport final est produit, then il ne modifie aucune spec existante et affiche `Chantier potentiel: oui` avec une commande `/sf-spec`.
- [x] AC 3: Given `sf-perf` trouve seulement une optimisation mineure locale, when son rapport final est produit, then il peut afficher `Chantier potentiel: non` avec raison.
- [x] AC 4: Given `sf-audit` trouve plusieurs problemes P1/P2 transverses, when son rapport final est produit, then il propose un titre de chantier transversal et les evidences principales.
- [x] AC 5: Given une skill source est lancee dans un chantier unique existant, when elle termine, then elle conserve le bloc `Chantier` existant et peut ajouter `Chantier potentiel: non` si le travail reste dans le chantier courant.
- [x] AC 6: Given `sf-spec` recoit un bloc `Chantier potentiel`, when elle cree la spec, then elle reprend le titre, la raison, le scope, la severite et les evidences dans la nouvelle spec.
- [x] AC 7: Given une skill helper comme `sf-context`, when elle est lancee, then elle ne se declare pas source et ne propose pas de chantier hors demande explicite.
- [x] AC 8: Given une nouvelle skill est ajoutee plus tard, when `sf-verify` ou la checklist de coherence est appliquee, then l'absence de `Trace category` ou `Process role` est signalee.

## Test Strategy

- Unit: None, because this is a markdown/process change unless a lint script is added later.
- Integration: Run `rg` validations from the implementation tasks across modified skills and docs.
- Manual: Review one lifecycle skill, one source skill, one support/pilotage skill, and one helper skill to confirm the final reports have the expected routing.
- Regression: Re-run `/sf-ready Skill taxonomy and chantier sources` before implementation, then `/sf-verify` after changes.

## Risks

- Security impact: none, because this is process metadata and reporting. Indirectly, better source detection should improve security follow-up for deps/auth/prod findings.
- Product/data/performance risk: medium process risk; too many source prompts could create noise. Mitigation: threshold requires severity, multi-step work, decision, risk, or validation need.
- Maintenance risk: 46 skills can drift. Mitigation: add both `Trace category` and `Process role` to the standard skill header and verify them.

## Execution Notes

- Read first: `skills/references/chantier-tracking.md`, `skills/sf-help/SKILL.md`, `specs/specs-as-chantier-registry.md`, `templates/artifacts/spec.md`.
- Then inspect representative sources: `skills/sf-deps/SKILL.md`, `skills/sf-perf/SKILL.md`, `skills/sf-audit/SKILL.md`, `skills/sf-check/SKILL.md`, `skills/sf-prod/SKILL.md`.
- Suggested taxonomy baseline:
  - `lifecycle`: `sf-spec`, `sf-ready`, `sf-start`, `sf-verify`, `sf-end`, `sf-ship`.
  - `source-de-chantier`: `sf-deps`, `sf-perf`, all audits, `sf-auth-debug`, `sf-prod`, `sf-check`, `sf-test`, `sf-migrate`, `sf-fix`, `sf-market-study`, `sf-veille`, maybe `sf-research` when it produces implementation decisions.
  - `support-de-chantier`: `sf-docs`, `sf-enrich`, `sf-redact`, `sf-repurpose`, `sf-scaffold`, `sf-changelog`, `sf-design-playground`, `sf-skills-refresh`.
  - `pilotage`: `sf-tasks`, `sf-backlog`, `sf-priorities`, `sf-review`, maybe `continue`.
  - `helper`: `sf-context`, `sf-model`, `sf-help`, `sf-status`, `sf-resume`, `sf-explore`, `name`.
- Validate with: `for f in skills/*/SKILL.md; do skill=$(basename "$(dirname "$f")"); printf "%s\t" "$skill"; rg -n "Category:|Process role:|source-de-chantier|Chantier potentiel" "$f"; done`
- Stop conditions: if adding `Process role` to every skill creates too much duplication, centralize the matrix in `chantier-tracking.md` and require each skill to reference it; if a skill's role is ambiguous, classify conservatively as `support-de-chantier` until usage proves it should be a source.

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-04-27 19:34:21 UTC | sf-spec | GPT-5 Codex | Created spec for skill taxonomy and chantier sources | draft | /sf-ready Skill taxonomy and chantier sources |
| 2026-04-27 19:36:56 UTC | sf-ready | GPT-5 Codex | Evaluated readiness for skill taxonomy and chantier sources | ready | /sf-start Skill taxonomy and chantier sources |
| 2026-04-27 19:37:42 UTC | sf-ready | GPT-5 Codex | Re-evaluated readiness for skill taxonomy and chantier sources | ready | /sf-start Skill taxonomy and chantier sources |
| 2026-04-27 19:47:42 UTC | sf-start | GPT-5 Codex | Implemented skill taxonomy and chantier source instructions; left changelog entry to end/ship flow | partial | /sf-verify Skill taxonomy and chantier sources |
| 2026-04-27 19:51:36 UTC | sf-verify | GPT-5 Codex | Verified skill taxonomy and chantier sources; fixed changelog and spec metadata gap during verification | verified | /sf-end Skill taxonomy and chantier sources |
| 2026-04-27 19:53:05 UTC | sf-end | GPT-5 Codex | Closed skill taxonomy and chantier sources after verified implementation | closed | /sf-ship Skill taxonomy and chantier sources |
| 2026-04-27 19:59:25 UTC | sf-ship | GPT-5 Codex | Shipped skill taxonomy and chantier source changes | shipped | None |

## Current Chantier Flow

- `sf-spec`: done, draft spec created.
- `sf-ready`: ready.
- `sf-start`: implemented; taxonomy, source intake, docs, verification hooks, and changelog are complete.
- `sf-verify`: verified.
- `sf-end`: closed.
- `sf-ship`: shipped.

Next step: None
