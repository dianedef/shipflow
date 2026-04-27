---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipFlow
created: "2026-04-27"
created_at: "2026-04-27 09:23:02 UTC"
updated: "2026-04-27"
updated_at: "2026-04-27 12:49:04 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
user_story: "En tant qu'utilisatrice ShipFlow qui lance plusieurs skills sur plusieurs chantiers, je veux que chaque spec se documente elle-meme avec les skills lancees, leur statut, leur modele et la prochaine etape, afin de savoir rapidement ou en est un chantier sans relire l'historique de conversation."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - specs/
  - templates/artifacts/spec.md
  - skills/*/SKILL.md
  - skills/sf-help/SKILL.md
  - shipflow-spec-driven-workflow.md
  - shipflow-metadata-migration-guide.md
  - README.md
depends_on:
  - artifact: "shipflow-spec-driven-workflow.md"
    artifact_version: "0.3.0"
    required_status: "draft"
  - artifact: "shipflow-metadata-migration-guide.md"
    artifact_version: "0.2.0"
    required_status: "draft"
  - artifact: "README.md"
    artifact_version: "unknown"
    required_status: "unknown"
supersedes: []
evidence:
  - "User decision 2026-04-27: the global registry should be the specs folder, not a separate tracker."
  - "User decision 2026-04-27: add the GPT model used to launch/create the spec in metadata."
- "User decision 2026-04-27: this concerns every skill, but every skill does not necessarily write into a spec."
- "User clarification 2026-04-27: this spec was created before the chantier registry tracker existed, so it should be migrated into the new registry shape and execution should continue."
  - "Repo investigation 2026-04-27: shipflow-spec-driven-workflow.md and shipflow-metadata-migration-guide.md currently have status draft."
  - "Repo investigation 2026-04-27: TASKS.md, AUDIT_LOG.md, and PROJECTS.md are operational trackers; specs are durable ShipFlow artifacts."
next_step: "None"
---

# Spec: Specs as Chantier Registry

## Title

Specs as Chantier Registry

## Status

ready

## User Story

En tant qu'utilisatrice ShipFlow qui lance plusieurs skills sur plusieurs chantiers, je veux que chaque spec se documente elle-meme avec les skills lancees, leur statut, leur modele et la prochaine etape, afin de savoir rapidement ou en est un chantier sans relire l'historique de conversation.

## Minimal Behavior Contract

Quand une skill travaille sur un chantier spec-first, elle doit lire la spec du chantier, ajouter ou mettre a jour une trace concise de son passage quand sa categorie l'exige, puis terminer son report avec un bloc standard `Chantier`. Ce bloc doit indiquer la skill courante, le chantier, le flux courant, ce qui reste a faire, la prochaine etape et un verdict qui repete la skill active quand le chantier est applicable. Si aucune spec ne correspond au chantier, la skill ne cree pas de registre parallele: elle indique `Chantier: non applicable` ou `Chantier: non trace`, explique pourquoi, puis oriente vers `sf-spec` ou vers une selection explicite de spec. Le cas facile a rater est celui d'une skill transverse, par exemple audit, docs, perf ou deps: elle concerne bien la doctrine globale, mais elle ne doit ecrire dans une spec que si son run est rattache a un chantier identifiable.

## Success Behavior

- Preconditions: un chantier spec-first possede un fichier dans `specs/` avec frontmatter ShipFlow, ou la skill est lancee dans un contexte qui permet d'identifier clairement cette spec.
- Trigger: n'importe quelle skill ShipFlow est lancee et produit un report final.
- User/operator result: le report final contient toujours un bloc `Chantier`, sauf justification explicite de non-applicabilite pour les skills purement informatives ou hors chantier.
- System effect: pour les categories obligatoires et conditionnelles applicables, la spec du chantier contient une section persistante `Skill Run History` et un resume courant `Current Chantier Flow`.
- Success proof: ouvrir la spec suffit pour voir les skills applicables lancees, l'heure UTC, le modele, le resultat et la prochaine etape; ouvrir `sf-help` ou la doc workflow suffit pour connaitre la matrice obligatoire, conditionnel, non-applicable.
- Silent success: not allowed; chaque passage de skill sur un chantier spec-first doit etre visible dans la spec ou explicitement signale comme non trace/non applicable dans le report.

## Error Behavior

- Expected failures: spec introuvable, plusieurs specs candidates, skill hors chantier, categorie non applicable, fichier de spec non modifiable, metadata manquante pendant migration, conflit entre statut courant et action demandee.
- User/operator response: le report doit nommer le probleme, dire si la trace a ete ecrite ou non, et donner la prochaine action concrete.
- System effect: aucune creation de registre global separe; aucune modification de `TASKS.md`, `AUDIT_LOG.md` ou `PROJECTS.md` pour ce suivi de flux.
- Must never happen: historique de skill invente, trace ecrite dans la mauvaise spec, statut `ready` ou `done` annonce sans preuve, perte de metadata existante, duplication incontrolee de sections, absence de bloc `Chantier` sans justification.
- Silent failure: not allowed; si la trace n'a pas pu etre ecrite, le report final doit le dire.

## Problem

ShipFlow contient deja beaucoup de skills et plusieurs trackers operationnels. Quand l'utilisatrice lance `sf-spec`, `sf-ready`, `sf-start`, `sf-verify` et d'autres skills dans plusieurs conversations, elle perd vite la vue du flux: quelle skill a deja tourne, dans quel modele, a quelle heure, avec quel resultat, et quelle est la suite.

Un registre global dedie resoudrait une partie du probleme, mais il ajouterait une source de verite supplementaire a maintenir. La decision produit est donc de faire du dossier `specs/` le registre global des chantiers. Toutes les skills doivent connaitre cette doctrine, mais toutes ne doivent pas forcement ecrire dans une spec: certaines tracent toujours, certaines tracent seulement quand un chantier est identifiable, et certaines justifient la non-applicabilite.

## Solution

Ajouter au schema de spec ShipFlow des metadata de modele (`source_model`, puis `run_model` dans l'historique) et une section persistante `Skill Run History`. Definir une matrice obligatoire, conditionnel, non-applicable pour tous les `skills/*/SKILL.md`. Adapter les skills selon leur categorie pour qu'elles finissent leurs reports avec un bloc standard `Chantier`; les skills applicables tracent leur passage dans la spec et les autres expliquent explicitement pourquoi elles ne tracent pas.

## Scope In

- Definir `specs/` comme registre global des chantiers spec-first.
- Ajouter les champs metadata de modele aux specs creees par `sf-spec`.
- Ajouter une section standard `Skill Run History` dans chaque spec de chantier.
- Ajouter un bloc final standard `Chantier` dans les reports de skills.
- Inventorier explicitement tous les `skills/*/SKILL.md` existants avant implementation.
- Classer toutes les skills en obligatoire, conditionnel ou non-applicable.
- Appliquer les instructions par categorie a toutes les skills, avec des edits individuels pour les lifecycle skills principales.
- Documenter la doctrine dans l'aide et la doc workflow.

## Scope Out

- Creer un nouveau fichier registre global distinct de `specs/`.
- Imposer une ecriture dans la spec aux runs hors chantier quand aucune spec ne porte le changement.
- Convertir `TASKS.md`, `AUDIT_LOG.md` ou `PROJECTS.md` en artefacts metadata.
- Reprendre retroactivement tout l'historique des anciennes conversations.
- Changer le systeme d'installation ou de decouverte des skills.
- Modifier les skills dans cette passe de correction de spec.

## Constraints

- `TASKS.md`, `AUDIT_LOG.md` et `PROJECTS.md` restent des trackers operationnels sans frontmatter obligatoire.
- La spec reste la source de verite du chantier uniquement pour les travaux spec-first.
- Le tracking doit etre lisible en markdown sans outil dedie.
- Les skills ne doivent pas inventer des etapes passees non prouvees par la spec, le report courant ou des fichiers existants.
- Les edits de spec doivent etre append-only ou cibles pour eviter d'effacer le contrat du chantier.
- Le modele doit etre trace avec la meilleure information disponible; si le runtime ne fournit pas l'identifiant exact, utiliser une valeur explicite comme `unknown`, `GPT-5 Codex` ou le nom fourni par l'operateur.
- Le bloc `Chantier` est obligatoire dans les reports de skills sauf si la skill est non interactive ou ne produit pas de report utilisateur; dans ce cas la non-applicabilite doit etre documentee dans la matrice.

## Dependencies

- Runtime: markdown, YAML frontmatter, skills ShipFlow existantes.
- Document contracts: `shipflow-spec-driven-workflow.md`, `shipflow-metadata-migration-guide.md`, `README.md`.
- Dependency status alignment: `shipflow-spec-driven-workflow.md` is currently `status: draft` with `artifact_version: "0.3.0"`; `shipflow-metadata-migration-guide.md` is currently `status: draft` with `artifact_version: "0.2.0"`; this spec therefore requires `draft` for both instead of incorrectly requiring `active`.
- Metadata debt: `README.md` has no ShipFlow frontmatter in the inspected state, so this spec records `artifact_version: "unknown"` and `required_status: "unknown"` rather than inventing an active status.
- Fresh external docs: fresh-docs not needed, because the change is local to ShipFlow markdown conventions and skill instructions.

## Invariants

- Une spec doit rester implementable par un agent frais sans relire l'historique de conversation.
- Le tracking de skill ne remplace pas les sections contractuelles: user story, behavior contract, tasks, acceptance criteria et risks restent obligatoires.
- Une skill hors chantier ne doit pas creer de fausse continuite spec-first.
- Le verdict final d'une skill applicable doit nommer la skill courante, par exemple `Verdict sf-ready: ready`.
- La prochaine etape doit etre une commande ShipFlow executable ou une phrase explicite disant qu'aucune action n'est requise.
- Chaque `skills/*/SKILL.md` doit etre couvert par l'inventaire et par la matrice, meme si son resultat est `non-applicable`.

## Links & Consequences

- Upstream systems: `sf-spec` cree les specs et doit initialiser les metadata et l'historique; `sf-ready` doit lire cet historique avant de statuer.
- Downstream systems: `sf-start`, `sf-verify`, `sf-end` et `sf-ship` doivent pouvoir afficher le flux du chantier depuis la spec.
- Cross-cutting skills: audits, docs, checks, fixes, migrations, content and research skills must emit a `Chantier` block when they report to the user, but only write to a spec when the active run is attached to a concrete chantier.
- Informational skills: status/help/resume/model/context style skills may be non-applicable for spec writes, but their reports must not obscure the chantier state when they are invoked inside a chantier flow.
- Compatibility: les specs existantes sans `Skill Run History` doivent rester valides pendant migration, mais les nouvelles specs doivent l'avoir.

## Documentation Coherence

- `templates/artifacts/spec.md` doit montrer les nouveaux champs `created_at`, `updated_at`, `source_model` et la section `Skill Run History`.
- `skills/sf-spec/SKILL.md` doit creer ces champs et cette section.
- `skills/sf-ready/SKILL.md`, `skills/sf-start/SKILL.md`, `skills/sf-verify/SKILL.md`, `skills/sf-end/SKILL.md` et `skills/sf-ship/SKILL.md` doivent decrire leur mise a jour obligatoire de l'historique quand une spec est presente.
- Toutes les autres `skills/*/SKILL.md` doivent etre inventoriees et classees pour savoir si elles appliquent le bloc final `Chantier` en obligatoire, conditionnel ou non-applicable.
- `skills/sf-help/SKILL.md` doit expliquer la doctrine: `specs/` est le registre global des chantiers spec-first.
- `README.md` ou `shipflow-spec-driven-workflow.md` doit documenter la lecture du flux depuis une spec.
- `CHANGELOG.md` doit mentionner la nouvelle tracabilite des chantiers.

## Edge Cases

- Une skill est lancee avec un titre qui matche plusieurs specs: elle doit demander ou choisir explicitement la spec la plus pertinente avec justification avant toute ecriture.
- Une skill est lancee hors spec-first: elle affiche `Chantier: non applicable` et ne modifie aucune spec.
- Une skill conditionnelle est lancee sur un chantier identifiable: elle doit appliquer le bloc `Chantier` et tracer selon la matrice.
- Une ancienne spec n'a pas `Skill Run History`: la premiere skill spec-driven ajoute la section sans modifier les anciennes decisions.
- Le modele exact n'est pas visible: la trace utilise `unknown` ou le nom runtime disponible, sans bloquer le chantier.
- `sf-ready` est lance deux fois: l'historique garde deux lignes avec heures et resultats distincts.
- `sf-start` implemente partiellement: la ligne d'historique doit dire `partial`, pas `done`.
- Une spec est en `ready` mais une execution revele un gap: `sf-start` ou `sf-verify` trace le gap et renvoie vers `sf-spec` ou `sf-ready`.

## Implementation Tasks

- [x] Task 1: Mettre a jour le template de spec
  - File: `templates/artifacts/spec.md`
  - Action: Ajouter `created_at`, `updated_at`, `source_model`, puis une section `Skill Run History` avec colonnes Date UTC, Skill, Model, Action, Result, Next step.
  - User story link: Permet aux nouvelles specs de s'auto-documenter des leur creation.
  - Depends on: None
  - Validate with: `rg -n "source_model|Skill Run History|created_at|updated_at" templates/artifacts/spec.md`
  - Notes: Garder un template lisible et compatible avec les specs existantes.

- [x] Task 2: Inventorier tous les fichiers de skills existants
  - File: `skills/*/SKILL.md`
  - Action: Lister tous les `skills/*/SKILL.md`, confirmer le nombre total, puis produire une matrice d'application couvrant chaque skill une seule fois avec categorie `obligatoire`, `conditionnel` ou `non-applicable`.
  - User story link: Garantit que le chantier concerne bien toutes les skills sans imposer une ecriture spec a toutes.
  - Depends on: Task 1
  - Validate with: `find skills -maxdepth 2 -name SKILL.md | sort`
  - Notes: L'inventaire inspecte le contenu des skills en lecture avant toute modification; aucune skill ne doit rester hors matrice.

- [x] Task 3: Documenter la matrice globale d'application
  - File: `skills/sf-help/SKILL.md`
  - Action: Ajouter la doctrine `specs/` comme registre global et publier la matrice issue de Task 2: obligatoire pour lifecycle spec-first, conditionnel pour skills rattachees a un chantier, non-applicable pour helpers purement informatifs ou sans report de chantier.
  - User story link: Donne a l'utilisatrice une regle unique pour savoir quelle skill trace quoi.
  - Depends on: Task 2
  - Validate with: `rg -n "registre global|specs/|obligatoire|conditionnel|non-applicable|Skill Run History" skills/sf-help/SKILL.md`
  - Notes: La matrice doit rester courte mais exhaustive; les listes de skills peuvent etre groupees par categorie.

- [x] Task 4: Adapter `sf-spec` pour initialiser la trace de chantier
  - File: `skills/sf-spec/SKILL.md`
  - Action: Exiger les metadata de modele dans le frontmatter et ajouter une premiere ligne `sf-spec` dans `Skill Run History` lors de l'enregistrement.
  - User story link: L'utilisatrice sait quand la spec a ete creee et avec quel modele.
  - Depends on: Tasks 1-3
  - Validate with: `rg -n "source_model|Skill Run History|created_at|updated_at|Verdict sf-spec|Chantier" skills/sf-spec/SKILL.md`
  - Notes: Ne pas demander un modele exact si l'environnement ne l'expose pas; imposer une valeur explicite.

- [x] Task 5: Adapter `sf-ready` pour lire et mettre a jour le flux
  - File: `skills/sf-ready/SKILL.md`
  - Action: Lire `Skill Run History`, ajouter une ligne `sf-ready`, et terminer le report par le bloc `Chantier` avec `Verdict sf-ready: ...`.
  - User story link: L'utilisatrice voit si la readiness gate a deja ete lancee et avec quel resultat.
  - Depends on: Tasks 3-4
  - Validate with: `rg -n "Skill Run History|Verdict sf-ready|Chantier" skills/sf-ready/SKILL.md`
  - Notes: Si la spec est not ready, `Next step` doit renvoyer vers `sf-spec` ou une correction precise.

- [x] Task 6: Adapter `sf-start` pour tracer execution et statut partiel
  - File: `skills/sf-start/SKILL.md`
  - Action: Quand une spec est utilisee, ajouter une ligne `sf-start` avec result `implemented`, `partial`, `blocked` ou `rerouted`, puis inclure `Verdict sf-start: ...` dans le bloc `Chantier`.
  - User story link: L'utilisatrice sait si l'implementation a commence ou reste a faire.
  - Depends on: Task 5
  - Validate with: `rg -n "Skill Run History|Verdict sf-start|partial|blocked|Chantier" skills/sf-start/SKILL.md`
  - Notes: Ne pas tracer dans une spec si l'execution directe n'est pas rattachee a un chantier.

- [x] Task 7: Adapter `sf-verify` pour tracer la verification
  - File: `skills/sf-verify/SKILL.md`
  - Action: Quand une spec de chantier est identifiee, ajouter une ligne `sf-verify` avec result `verified`, `not verified`, `partial` ou `blocked`, puis terminer par `Verdict sf-verify: ...`.
  - User story link: Le flux de chantier montre si la promesse utilisateur a ete verifiee.
  - Depends on: Task 6
  - Validate with: `rg -n "Verdict sf-verify|Skill Run History|Chantier|verified|blocked" skills/sf-verify/SKILL.md`
  - Notes: Cette task ne modifie que `sf-verify`; ne pas coupler avec cloture ou shipping.

- [x] Task 8: Adapter `sf-end` pour tracer la cloture de chantier
  - File: `skills/sf-end/SKILL.md`
  - Action: Quand une spec de chantier est identifiee, ajouter une ligne `sf-end` avec result `closed`, `deferred`, `blocked` ou `not applicable`, puis terminer par `Verdict sf-end: ...`.
  - User story link: Le flux de chantier montre si le travail a ete clos sans confondre cloture et shipping.
  - Depends on: Task 7
  - Validate with: `rg -n "Verdict sf-end|Skill Run History|Chantier|closed|deferred|blocked" skills/sf-end/SKILL.md`
  - Notes: Cette task ne modifie que `sf-end`.

- [x] Task 9: Adapter `sf-ship` pour tracer le shipping
  - File: `skills/sf-ship/SKILL.md`
  - Action: Quand une spec de chantier est identifiee, ajouter une ligne `sf-ship` avec result `shipped`, `not shipped`, `blocked` ou `skipped checks`, puis terminer par `Verdict sf-ship: ...`.
  - User story link: Le flux de chantier montre si la livraison a ete effectuee et avec quel niveau de verification.
  - Depends on: Task 8
  - Validate with: `rg -n "Verdict sf-ship|Skill Run History|Chantier|shipped|blocked" skills/sf-ship/SKILL.md`
  - Notes: Cette task ne modifie que `sf-ship`.

- [x] Task 10: Appliquer la doctrine aux skills conditionnelles par categorie
  - File: `skills/*/SKILL.md`
  - Action: Pour toutes les skills classees `conditionnel` dans Task 2, ajouter l'instruction de bloc final `Chantier` et la regle d'ecriture spec seulement quand un chantier unique est identifie; pour les skills `non-applicable`, documenter la justification de non-ecriture si elles produisent un report.
  - User story link: Toutes les skills sont couvertes sans bruit inutile dans les specs.
  - Depends on: Tasks 2-3
  - Validate with: `rg -n "Chantier|non applicable|Skill Run History" skills/*/SKILL.md`
  - Notes: Les lifecycle skills deja couvertes par Tasks 4-9 ne doivent pas etre reeditees en doublon ici; cette task applique les categories restantes.

- [x] Task 11: Documenter la doctrine dans le workflow public interne
  - File: `shipflow-spec-driven-workflow.md`
  - Action: Expliquer que `specs/` est le registre global des chantiers et que chaque spec garde son historique de skill runs; inclure la regle obligatoire, conditionnel, non-applicable.
  - User story link: Permet de retrouver la regle sans ouvrir les skills.
  - Depends on: Task 10
  - Validate with: `rg -n "Skill Run History|registre global des chantiers|specs/|conditionnel|non-applicable" shipflow-spec-driven-workflow.md`
  - Notes: Ne pas transformer la doc en manuel exhaustif.

- [x] Task 12: Ajouter une entree changelog
  - File: `CHANGELOG.md`
  - Action: Ajouter une entree concise sur l'auto-tracabilite des specs, le modele source et la matrice toutes skills.
  - User story link: Trace le changement de doctrine ShipFlow.
  - Depends on: Tasks 1-11
  - Validate with: `head -80 CHANGELOG.md`
  - Notes: Ne pas revendiquer l'implementation complete avant validation.

## Acceptance Criteria

- [ ] AC 1: Given une nouvelle spec creee par `sf-spec`, when elle est enregistree, then son frontmatter contient `source_model`, `created_at` et `updated_at`.
- [ ] AC 2: Given une nouvelle spec creee par `sf-spec`, when elle est ouverte, then elle contient une section `Skill Run History` avec une ligne initiale pour `sf-spec`.
- [ ] AC 3: Given l'implementation commence, when Task 2 est executee, then tous les fichiers retournes par `find skills -maxdepth 2 -name SKILL.md | sort` sont presents exactement une fois dans la matrice obligatoire/conditionnel/non-applicable.
- [ ] AC 4: Given une skill classee `obligatoire` est lancee sur une spec, when son report final est lu, then il contient un bloc `Chantier`, une ligne d'historique spec et `Verdict <skill>: ...`.
- [ ] AC 5: Given une skill classee `conditionnel` est lancee sur un chantier identifiable, when son report final est lu, then elle applique le bloc `Chantier` et trace selon la matrice.
- [ ] AC 6: Given une skill classee `conditionnel` est lancee hors chantier, when son report final est lu, then elle ne modifie aucune spec et indique `Chantier: non applicable` ou `Chantier: non trace` avec justification.
- [ ] AC 7: Given une skill classee `non-applicable` est lancee, when son report final est lu, then elle n'ecrit pas dans une spec et sa non-applicabilite est couverte par la matrice.
- [ ] AC 8: Given une spec existante sans historique, when `sf-ready` est lance dessus, then la skill ajoute ou demande l'ajout de `Skill Run History` sans effacer les sections contractuelles.
- [ ] AC 9: Given `sf-ready` a statue sur une spec, when le report final est lu, then il contient `Verdict sf-ready: ...` et un bloc `Chantier` avec la prochaine etape.
- [ ] AC 10: Given `sf-start` implemente seulement une partie du chantier, when il trace son passage, then le resultat est `partial` ou equivalent et la prochaine etape reste explicite.
- [ ] AC 11: Given l'utilisatrice veut savoir si `sf-ready`, `sf-start`, `sf-verify`, `sf-end` ou `sf-ship` a deja ete lance, when elle ouvre la spec du chantier, then l'information est visible sans relire la conversation.
- [ ] AC 12: Given `shipflow-spec-driven-workflow.md` and `shipflow-metadata-migration-guide.md` remain `status: draft`, when `/sf-ready` evaluates this spec, then `depends_on.required_status` matches `draft` and does not falsely require `active`.

## Test Strategy

- Unit: verifier par `rg` que les nouvelles instructions existent dans les skills et templates modifies.
- Inventory: verifier que le nombre de lignes de la matrice correspond au nombre de fichiers retournes par `find skills -maxdepth 2 -name SKILL.md | sort`.
- Integration: creer une spec de test, simuler les passages `sf-spec` puis `sf-ready`, et verifier que l'historique reste append-only et lisible.
- Category regression: lancer ou relire une skill obligatoire, une conditionnelle et une non-applicable pour confirmer que le bloc `Chantier` et l'ecriture spec suivent la matrice.
- Manual: ouvrir une spec reelle et confirmer que le bloc final de report indique la skill courante, le flux, les choses restantes et la prochaine etape.
- Regression: verifier que `TASKS.md`, `AUDIT_LOG.md` et `PROJECTS.md` ne recoivent pas de frontmatter ou de suivi de skill runs.

## Risks

- Security impact: none, because the change concerns local markdown metadata and skill reporting only.
- Product risk: trop de skills pourraient ecrire dans les specs et les rendre bruyantes; mitigation par matrice obligatoire/conditionnel/non-applicable.
- Data risk: une skill pourrait tracer dans la mauvaise spec si le matching est ambigu; mitigation par selection explicite ou stop condition.
- Maintenance risk: mettre a jour toutes les skills d'un coup peut creer des formulations incoherentes; mitigation par template de bloc final commun.
- Readiness risk: si la matrice n'inventorie pas tous les `skills/*/SKILL.md`, le chantier reste ambigu; mitigation par Task 2 et AC 3.

## Execution Notes

- Read first: `templates/artifacts/spec.md`, `skills/sf-spec/SKILL.md`, `skills/sf-ready/SKILL.md`, `skills/sf-start/SKILL.md`, `skills/sf-verify/SKILL.md`, `skills/sf-end/SKILL.md`, `skills/sf-ship/SKILL.md`.
- Then read: `skills/sf-help/SKILL.md`, `shipflow-spec-driven-workflow.md`, `shipflow-metadata-migration-guide.md`, `README.md`.
- Inventory command: `find skills -maxdepth 2 -name SKILL.md | sort`.
- Initial observed inventory on 2026-04-27: `skills/name/SKILL.md`, `skills/sf-audit-a11y/SKILL.md`, `skills/sf-audit-code/SKILL.md`, `skills/sf-audit-components/SKILL.md`, `skills/sf-audit-copy/SKILL.md`, `skills/sf-audit-copywriting/SKILL.md`, `skills/sf-audit-design-tokens/SKILL.md`, `skills/sf-audit-design/SKILL.md`, `skills/sf-audit-gtm/SKILL.md`, `skills/sf-audit-seo/SKILL.md`, `skills/sf-audit-translate/SKILL.md`, `skills/sf-audit/SKILL.md`, `skills/sf-auth-debug/SKILL.md`, `skills/sf-backlog/SKILL.md`, `skills/sf-changelog/SKILL.md`, `skills/sf-check/SKILL.md`, `skills/sf-context/SKILL.md`, `skills/sf-deps/SKILL.md`, `skills/sf-design-playground/SKILL.md`, `skills/sf-docs/SKILL.md`, `skills/sf-end/SKILL.md`, `skills/sf-enrich/SKILL.md`, `skills/sf-explore/SKILL.md`, `skills/sf-fix/SKILL.md`, `skills/sf-help/SKILL.md`, `skills/sf-init/SKILL.md`, `skills/sf-market-study/SKILL.md`, `skills/sf-migrate/SKILL.md`, `skills/sf-model/SKILL.md`, `skills/sf-perf/SKILL.md`, `skills/sf-priorities/SKILL.md`, `skills/sf-prod/SKILL.md`, `skills/sf-ready/SKILL.md`, `skills/sf-redact/SKILL.md`, `skills/sf-repurpose/SKILL.md`, `skills/sf-research/SKILL.md`, `skills/sf-resume/SKILL.md`, `skills/sf-review/SKILL.md`, `skills/sf-scaffold/SKILL.md`, `skills/sf-ship/SKILL.md`, `skills/sf-skills-refresh/SKILL.md`, `skills/sf-spec/SKILL.md`, `skills/sf-start/SKILL.md`, `skills/sf-status/SKILL.md`, `skills/sf-tasks/SKILL.md`, `skills/sf-test/SKILL.md`, `skills/sf-veille/SKILL.md`, `skills/sf-verify/SKILL.md`.
- Suggested baseline categories for Task 2: obligatoire: `sf-spec`, `sf-ready`, `sf-start`, `sf-verify`, `sf-end`, `sf-ship`; conditionnel: audit, docs, check, fix, deps, perf, migrate, scaffold, content, research, backlog/task/status-adjacent skills when tied to a concrete chantier; non-applicable: pure help/discovery/session utility runs unless a chantier is explicitly active.
- Implementation approach: start with the template and `sf-spec`, then update the spec-driven lifecycle skills one file at a time, then apply the category matrix to the remaining skills.
- Suggested final report block:

```text
## Chantier

Skill courante: sf-ready
Chantier: specs/[slug].md
Trace spec: ecrite | non ecrite | non applicable
Flux:
- sf-spec: done
- sf-ready: ready
- sf-start: not launched
- sf-verify: not launched
- sf-end: not launched
- sf-ship: not launched

Reste a faire:
- [item]

Prochaine etape:
- /sf-start [title]

Verdict sf-ready:
- ready
```

- Validate with: `rg -n "Skill Run History|source_model|Verdict sf-|Chantier|obligatoire|conditionnel|non-applicable" specs/specs-as-chantier-registry.md`.
- Stop conditions: if matching the correct spec is ambiguous, ask the user instead of writing a trace; if a skill is unrelated to a chantier, report non-applicable instead of creating a trace.

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-04-27 09:23:02 UTC | sf-spec | GPT-5 Codex | Created spec for specs-as-chantier-registry | draft | /sf-ready Specs as chantier registry |
| 2026-04-27 09:54:52 UTC | sf-ready | GPT-5 Codex | Readiness gate for specs-as-chantier-registry | not ready | /sf-spec Specs as chantier registry |
| 2026-04-27 10:19:20 UTC | sf-spec | GPT-5.5 high | Updated spec after readiness gaps: all-skills doctrine, inventory task, split lifecycle tasks, draft dependency alignment | draft updated | /sf-ready Specs as chantier registry |
| 2026-04-27 10:45:19 UTC | sf-ready | GPT-5 Codex | Readiness gate for specs-as-chantier-registry | ready | /sf-start Specs as chantier registry |
| 2026-04-27 12:25:09 UTC | sf-start | GPT-5 Codex | Implemented chantier registry doctrine across template, lifecycle skills, all-skills matrix, and workflow docs | partial | /sf-verify Specs as chantier registry |
| 2026-04-27 12:37:31 UTC | sf-start | GPT-5 Codex | Migrated this pre-registry spec into the chantier tracker shape and added changelog entry | implemented | /sf-verify Specs as chantier registry |
| 2026-04-27 12:38:10 UTC | sf-verify | GPT-5 Codex | Verified template, lifecycle skills, all-skills matrix, docs, changelog, metadata, and whitespace checks | verified | /sf-end Specs as chantier registry |
| 2026-04-27 12:42:21 UTC | sf-end | GPT-5 Codex | Closed chantier after verified implementation and tracker updates | closed | /sf-ship Specs as chantier registry |
| 2026-04-27 12:44:52 UTC | sf-repurpose | GPT-5 Codex | Repurposed chantier registry work into README and public website docs, FAQ, and lifecycle skill pages | docs updated | /sf-ship Specs as chantier registry |
| 2026-04-27 12:49:04 UTC | sf-ship | GPT-5 Codex | Shipped chantier registry implementation, docs, and website updates | shipped | None |

## Current Chantier Flow

- `sf-spec`: done, draft spec created; updated after readiness gaps on 2026-04-27 10:19:20 UTC.
- `sf-ready`: ready on 2026-04-27 10:45:19 UTC.
- `sf-start`: implemented on 2026-04-27 12:37:31 UTC; this pre-registry spec was migrated into the chantier tracker shape and the changelog entry was added.
- `sf-verify`: verified on 2026-04-27 12:38:10 UTC.
- `sf-end`: closed on 2026-04-27 12:42:21 UTC.
- `sf-ship`: shipped on 2026-04-27 12:49:04 UTC.

Next step: None
