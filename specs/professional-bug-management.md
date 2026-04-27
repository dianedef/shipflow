---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipFlow
created: "2026-04-27"
created_at: "2026-04-27 12:44:52 UTC"
updated: "2026-04-27"
updated_at: "2026-04-27 17:37:26 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
user_story: "En tant qu'utilisatrice ShipFlow qui corrige des bugs avec des agents sur plusieurs sessions, je veux une gestion professionnelle des bugs avec index compact, dossier detaille par bug et preuves separees, afin de conserver une vraie tracabilite sans transformer TEST_LOG.md ou BUGS.md en fichiers ingerables."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sf-test/SKILL.md
  - skills/sf-test/README.md
  - skills/sf-fix/SKILL.md
  - skills/sf-verify/SKILL.md
  - skills/sf-ship/SKILL.md
  - skills/sf-help/SKILL.md
  - skills/sf-docs/SKILL.md
  - templates/artifacts/bug_record.md
  - tools/shipflow_metadata_lint.py
  - README.md
  - shipflow-spec-driven-workflow.md
  - CHANGELOG.md
  - site/src/content/skills/sf-test.md
  - site/src/content/skills/sf-fix.md
  - site/src/content/skills/sf-verify.md
  - site/src/content/skills/sf-ship.md
  - site/src/content/skills/sf-docs.md
depends_on:
  - artifact: "BUSINESS.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "PRODUCT.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "BRANDING.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "GUIDELINES.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "shipflow-spec-driven-workflow.md"
    artifact_version: "0.3.0"
    required_status: "draft"
supersedes: []
evidence:
  - "User feedback 2026-04-27: TEST_LOG.md alone will grow without bound if it stores full bug investigation detail."
  - "User feedback 2026-04-27: bug traceability must include how the bug happens and what was attempted to fix it."
  - "Repo investigation: sf-test currently writes TEST_LOG.md and BUGS.md, but has no per-bug dossier or evidence directory."
  - "Repo doctrine: trackers stay lightweight; durable decisions and evidence belong in dedicated artifacts."
  - "sf-ready 2026-04-27 found blocking gaps around lifecycle status, bug ID collisions, sf-ship ownership, sf-docs ownership, acceptance criteria, and evidence security."
next_step: "None"
---

# Spec: Professional Bug Management

## Title

Professional Bug Management

## Status

ready

## User Story

En tant qu'utilisatrice ShipFlow qui corrige des bugs avec des agents sur plusieurs sessions, je veux une gestion professionnelle des bugs avec index compact, dossier detaille par bug et preuves separees, afin de conserver une vraie tracabilite sans transformer `TEST_LOG.md` ou `BUGS.md` en fichiers ingerables.

## Minimal Behavior Contract

Quand un test manuel, une verification, un diagnostic navigateur, une correction ou une tentative de ship revele un bug, ShipFlow doit creer ou mettre a jour un bug identifiable par un ID stable, afficher une trace courte dans les index du projet, et conserver le detail complet dans un dossier dedie au bug. Les index doivent permettre de comprendre rapidement les bugs ouverts, bloques, a retester ou fermes; le dossier du bug doit contenir reproduction, attendu, observe, preuves redigees ou referencees, diagnostic, tentatives de correction, retests, statut et prochaine action. En cas d'information incomplete, le bug reste ouvert avec un statut explicite comme `needs-info` ou `needs-repro`, sans inventer les preuves manquantes ni fermer sur hypothese. L'edge case facile a rater est la preuve volumineuse ou sensible: elle doit etre redigee avant persistance et referencee par chemin, jamais collee brute dans `TEST_LOG.md`, `BUGS.md` ou le dossier bug.

## Success Behavior

- Preconditions: un projet utilise ShipFlow et peut contenir `TEST_LOG.md`, `BUGS.md`, `bugs/`, `test-evidence/`, des skills ShipFlow et des docs publiques de skills.
- Trigger: `sf-test` constate un echec, `sf-test --retest BUG-ID` reteste un bug, `sf-fix BUG-ID` lit ou corrige un bug, `sf-auth-debug` produit une preuve de bug, `sf-verify` detecte une regression actionable, ou `sf-ship` voit qu'un bug high/critical lie au scope bloque le ship.
- User/operator result: l'utilisatrice voit un identifiant stable `BUG-YYYY-MM-DD-NNN`, un `BUGS.md` compact, un dossier `bugs/BUG-ID.md`, les preuves sous `test-evidence/BUG-ID/` quand necessaire, un statut canonique et la prochaine commande claire.
- System effect: ShipFlow append ou met a jour les fichiers concernes sans supprimer l'historique existant; les gros logs, HAR, captures et dumps sont references par chemin apres redaction ou explicitement refuses si la redaction n'est pas prouvable.
- Success proof: ouvrir `BUGS.md` donne l'etat global en moins d'une minute; ouvrir `bugs/BUG-ID.md` donne assez de contexte pour qu'un agent frais reproduise, corrige, reteste ou refuse une fermeture dangereuse sans lire l'historique de conversation.
- Silent success: not allowed; toute creation, mise a jour, retest, blocage de ship ou fermeture de bug doit etre visible dans `BUGS.md`, dans le dossier bug ou dans le rapport final du skill.

## Error Behavior

- Expected failures: bug deja existant, reproduction incomplete, preuve trop volumineuse, preuve sensible non redigee, bug non reproductible, plusieurs bugs similaires, fichier non modifiable, evidence fournie sans chemin, collision d'ID, conflit entre `BUGS.md` et `bugs/`, correction tentee sans retest, ship demande avec bug high/critical ouvert.
- User/operator response: le rapport doit dire ce qui a ete trace, ce qui n'a pas ete trace, pourquoi, le statut canonique retenu, les preuves ignorees ou refusees, et la prochaine action concrete.
- System effect: aucun gros log inline; aucune duplication non controlee dans `TEST_LOG.md`; aucun bug marque `closed` sans retest ou exception `closed-without-retest`; aucune preuve brute connue comme sensible ne doit etre persistee; aucun ancien contexte ne doit etre supprime.
- Must never happen: ecraser l'historique d'un bug, fermer un bug sur simple hypothese, logguer des secrets ou donnees personnelles, coller un HAR/stacktrace massif dans un markdown central, creer deux bugs identiques sans lien, shipper un scope bloque par un bug high/critical sans note de risque explicite.
- Silent failure: not allowed; si un dossier bug, un index, une preuve ou une mise a jour de statut ne peut pas etre ecrit, le rapport final doit le dire et laisser le bug en etat non ferme.

## Problem

`sf-test` a deja la bonne intention: transformer un resultat de test en memoire projet durable. Mais le modele actuel melange trop de responsabilites. `TEST_LOG.md` risque de devenir un journal gigantesque si chaque echec contient reproduction, captures, logs, hypotheses, tentatives de fix et retests. `BUGS.md` risque aussi de devenir illisible si chaque bug y accumule tout son historique.

Le besoin reel est une gestion de bug professionnelle: index court pour piloter, dossier complet pour enqueter, preuves separees pour ne pas exploser la taille des fichiers markdown, et cycle de vie explicite entre detection, triage, correction, retest, verification, ship et cloture.

## Solution

Introduire une architecture de bug tracking ShipFlow en trois couches: `TEST_LOG.md` reste un journal compact des scenarios testes, `BUGS.md` devient un index compact des bugs, et `bugs/BUG-ID.md` devient le dossier complet du bug. Les preuves volumineuses vivent dans `test-evidence/BUG-ID/` quand elles sont redigees et utiles, ou restent en reference externe si elles ne doivent pas etre copiees. Les skills `sf-test`, `sf-fix`, `sf-verify`, `sf-ship`, `sf-docs` et les docs doivent appliquer la meme separation de responsabilites, les memes statuts et les memes regles de preuve.

## Scope In

- Definir la structure projet standard pour bugs: `BUGS.md`, `bugs/`, `test-evidence/`.
- Transformer `BUGS.md` en index compact plutot qu'en dossier complet.
- Creer un format de dossier bug individuel `bugs/BUG-ID.md`.
- Definir un cycle de vie canonique des statuts: `open`, `needs-info`, `needs-repro`, `in-diagnosis`, `fix-attempted`, `fixed-pending-verify`, `closed`, `closed-without-retest`, `duplicate`, `wontfix`.
- Definir les transitions autorisees, les transitions interdites et les conditions minimales de fermeture.
- Definir la generation d'ID et la resolution de collisions entre `BUGS.md`, `bugs/` et plusieurs agents.
- Ajouter un format d'historique de diagnostic, correction et retest dans chaque dossier bug.
- Mettre a jour `sf-test` pour ouvrir ou mettre a jour un dossier bug detaille quand un test echoue et pour append les retests dans le dossier.
- Mettre a jour `sf-fix` pour lire le dossier bug, append les diagnostics et tentatives de correction, et exiger un retest avant fermeture.
- Mettre a jour `sf-verify` pour detecter les bugs ouverts lies au scope et refuser une verification optimiste.
- Mettre a jour `sf-ship` pour avertir ou bloquer quand des bugs high/critical lies au scope restent ouverts.
- Mettre a jour `sf-docs` pour auditer et documenter le modele bug sans ajouter de frontmatter aux trackers operationnels.
- Documenter les limites de taille, la politique de preuves, la redaction et les surfaces publiques de skills.
- Ajouter les templates necessaires dans `templates/artifacts/`.

## Scope Out

- Construire une interface web de bug tracker.
- Synchroniser avec GitHub Issues, Linear, Jira ou un outil externe.
- Migrer automatiquement tous les anciens bugs de tous les projets.
- Stocker des captures binaires dans git sans decision explicite du projet.
- Remplacer les tests automatises par les dossiers bug.
- Transformer `TASKS.md`, `AUDIT_LOG.md` ou `PROJECTS.md` en bug tracker.
- Implementer un verrouillage distribue parfait entre plusieurs agents; la spec exige une resolution prudente de collision par relecture juste avant ecriture, pas un systeme de lock global.

## Constraints

- `TEST_LOG.md` et `BUGS.md` restent des trackers operationnels courts, sans frontmatter obligatoire.
- `bugs/BUG-ID.md` est un artefact durable ShipFlow et doit utiliser le frontmatter standard avec `artifact: bug_record`.
- `tools/shipflow_metadata_lint.py` doit accepter `artifact: bug_record` et peut linter `bugs/*.md` quand le chemin est fourni ou quand un dossier `bugs/` existe.
- Les preuves volumineuses ne doivent jamais etre collees inline dans les index.
- Les chemins de preuve doivent etre relatifs au projet quand possible et ne doivent pas traverser hors du repo via `..`.
- Les logs contenant secrets, tokens, cookies, emails prives, donnees personnelles, payloads sensibles, request headers, HAR ou screenshots doivent etre rediges avant d'etre references comme preuve persistante.
- Les skills ne doivent pas inventer reproduction, evidence, commit, tentative de correction ou resultat de retest.
- La fermeture `closed` exige un retest reussi. La fermeture `closed-without-retest` exige une justification visible, une raison non speculative et un risque residuel explicite.
- Les ecritures doivent etre additives: relire le fichier juste avant modification, append ou modifier la section cible, ne pas normaliser tout le fichier par confort.
- La doc publique ne doit pas promettre un bug tracker externe, une UI ou une garantie zero bug.

## Dependencies

- Runtime: markdown, YAML frontmatter pour `bugs/*.md`, conventions de nommage `BUG-YYYY-MM-DD-NNN`, relecture de fichiers avant ecriture.
- Document contracts: `PRODUCT.md` 1.1.0, `BUSINESS.md` 1.1.0, `BRANDING.md` 1.0.0, `GUIDELINES.md` 1.0.0, `shipflow-spec-driven-workflow.md` 0.3.0.
- Skill dependencies: `sf-test`, `sf-fix`, `sf-verify`, `sf-ship`, `sf-help`, `sf-docs`, and optionally `sf-auth-debug` when browser auth evidence is involved.
- Documentation surfaces: `README.md`, `skills/sf-test/README.md`, public skill content under `site/src/content/skills/`, and `CHANGELOG.md`.
- Metadata gaps: `BUGS.md` and `TEST_LOG.md` intentionally remain tracker files and should not be migrated to artifact frontmatter.
- Fresh external docs: fresh-docs not needed, because the change is local to ShipFlow markdown conventions, Python standard library linting, and skill instructions. No framework, SDK, service API, auth provider, build system, migration engine or external integration behavior determines this spec.

## Invariants

- `TEST_LOG.md` answers: what was tested, when, with what result, and which bug or next step followed.
- `BUGS.md` answers: what bugs are open, blocked, duplicate, closed, severity, owner/status if known, last tested date, and link to the detailed dossier.
- `bugs/BUG-ID.md` answers: how the bug reproduces, what evidence exists, what was tried, what changed, and how retests behaved.
- `test-evidence/BUG-ID/` stores only redacted external evidence files or redacted text dumps too large for the dossier.
- Every bug dossier must be usable by a fresh agent without reading the chat history.
- Existing `BUGS.md` content remains valid legacy content; new or retested bugs should use the new compact index plus dossier model.
- No skill may mark a bug `closed` unless the dossier contains a passing retest result or an explicit `closed-without-retest` exception.
- No skill may use UI visibility, optimistic wording or user intent as proof that sensitive evidence is safe to store.
- A ship or verification report may still proceed with partial risk only if it explicitly names the open bug state and does not claim closure.

Canonical status lifecycle:

| Status | Meaning | May enter when | May leave to |
|--------|---------|----------------|--------------|
| `open` | Actionable bug with enough context to investigate or fix. | New failed test, failed retest, verified regression, or manually captured bug. | `in-diagnosis`, `needs-info`, `needs-repro`, `fix-attempted`, `duplicate`, `wontfix` |
| `needs-info` | Bug exists but required context is missing. | Observed failure lacks environment, steps, expected result, or evidence. | `open`, `needs-repro`, `duplicate`, `wontfix` |
| `needs-repro` | Bug report lacks a safe or repeatable reproduction. | Failure is non-reproducible or destructive reproduction needs approval. | `open`, `duplicate`, `wontfix` |
| `in-diagnosis` | A skill is investigating the bug. | `sf-fix` or diagnostic flow starts from an open dossier. | `open`, `fix-attempted`, `needs-info`, `needs-repro` |
| `fix-attempted` | A concrete fix was attempted, but retest has not passed. | Fix attempt exists with files changed and validation command or reason validation was impossible. | `fixed-pending-verify`, `open`, `needs-info` |
| `fixed-pending-verify` | Retest passed enough to require final verification before closure. | Retest result passed and dossier links the fix attempt. | `closed`, `open`, `closed-without-retest` |
| `closed` | Bug is closed after passing retest or final verification. | Passing retest exists and no blocker remains. | `open` only if regression reappears with the same bug identity |
| `closed-without-retest` | Explicit exception closure with visible risk. | Retest is impossible or intentionally skipped with reason, approver if known, and risk note. | `open` if later reproduced |
| `duplicate` | Bug is represented by another bug ID. | Reproduction and observed behavior clearly match another bug. | `open` only if later proven distinct |
| `wontfix` | Known bug intentionally not fixed in this scope. | Product or operator decision says it is out of scope, obsolete, or acceptable. | `open` if decision changes |

Forbidden transitions:

- `open` directly to `closed` without a passing retest entry.
- `needs-info` or `needs-repro` to `closed` without becoming actionable or explicitly `wontfix`.
- `fix-attempted` directly to `closed` without `fixed-pending-verify` or explicit exception.
- Any status to `closed-without-retest` without reason, residual risk and operator-visible note.

Bug ID generation invariant:

- New IDs use `BUG-YYYY-MM-DD-NNN` in UTC date.
- Before assigning an ID, the skill must re-read `BUGS.md` and list `bugs/BUG-YYYY-MM-DD-*.md`, then pick the next numeric suffix greater than every suffix found in either place.
- If the chosen dossier file already exists immediately before writing, the skill must re-read and choose the next suffix instead of overwriting.
- If an existing open bug clearly matches, update and cross-link it rather than creating a new ID.
- If two similar bugs are not provably identical, create a separate ID and add `Related bugs`.

## Links & Consequences

- Upstream systems: `sf-test` creates bug records from failed manual tests; `sf-auth-debug` can attach browser-level evidence; `sf-verify` can surface regressions or open-bug blockers; `sf-fix` can capture bugs discovered during diagnosis.
- Downstream systems: `sf-fix` consumes bug dossiers; `sf-test --retest BUG-ID` appends retest history; `sf-verify` judges whether bug state blocks verification; `sf-ship` warns or blocks when linked high/critical bugs remain open.
- Cross-cutting checks: security for evidence redaction and path safety, documentation coherence for workflow docs and public skill pages, metadata linting for bug dossier frontmatter, and operational sanity for file growth.
- Regression impact: existing projects with simple `BUGS.md` should continue working; the new structure is additive and applies when new bugs are opened or retested.
- Public documentation impact: the website skill pages and README must not describe old `BUGS.md` behavior after the new dossier model lands.
- Operational consequence: no global registry in `/home/claude/shipflow_data`; bug records belong to the project repo where the behavior exists.

## Documentation Coherence

- `skills/sf-test/SKILL.md` must explain compact `TEST_LOG.md`, compact `BUGS.md`, per-bug dossiers, ID generation, status lifecycle, evidence storage, redaction, and retest behavior.
- `skills/sf-test/README.md` must explain the new three-layer model at a high level.
- `skills/sf-fix/SKILL.md` must treat bug dossiers as the primary input when a bug ID is provided and append diagnosis/fix attempts instead of relying on chat context.
- `skills/sf-verify/SKILL.md` must define how open bugs affect verification and closure.
- `skills/sf-ship/SKILL.md` must define how linked high/critical bugs affect quick/full shipping reports.
- `skills/sf-docs/SKILL.md` must include this bug model in documentation-coherence audits and preserve the tracker-vs-artifact distinction.
- `skills/sf-help/SKILL.md` must expose the professional bug loop and file roles.
- `templates/artifacts/bug_record.md` must define the per-bug dossier format.
- `README.md` and `shipflow-spec-driven-workflow.md` must mention the professional bug loop.
- `CHANGELOG.md` must record the new bug-management doctrine.
- `site/src/content/skills/sf-test.md`, `site/src/content/skills/sf-fix.md`, `site/src/content/skills/sf-verify.md`, `site/src/content/skills/sf-ship.md`, and `site/src/content/skills/sf-docs.md` must stay aligned if they describe bug, verification, shipping or documentation behavior.

## Edge Cases

- Same failure reported twice: update the existing open bug if reproduction and observed behavior clearly match; otherwise create a new bug and cross-link as related.
- ID collision: re-read both `BUGS.md` and `bugs/` immediately before writing; if the chosen ID now exists, increment and retry once. If still conflicting, stop and report the collision.
- `BUGS.md` references a missing dossier: keep index entry, set or report `needs-info`, and do not erase the index.
- Dossier exists without `BUGS.md` entry: add a compact index pointer if the dossier frontmatter is valid; otherwise report metadata gap.
- Failed retest after a claimed fix: keep status `open` or move back from `fixed-pending-verify`, append retest result, and preserve the failed fix attempt.
- Partial fix: record `partial` in the fix attempt and retest history; status remains `fix-attempted` or `open`, not `closed`.
- Non-reproducible bug: keep `needs-repro` or `needs-info`, with exact missing evidence.
- Sensitive logs: create a redacted evidence file and note what was redacted; never preserve raw secrets.
- Massive evidence: store as separate redacted file path or external reference, not inline.
- Evidence path outside repo: reject by default unless it is an explicit external reference and not copied.
- Production bug with destructive reproduction: record safe reproduction steps and require explicit approval for destructive retests.
- Bug caused by stale expected behavior: route to `sf-spec` or docs update instead of forcing a code fix.
- Multiple projects: bug artifacts belong to the project repo where the behavior exists, not global `shipflow_data`.
- Quick ship with open high/critical bug: report `blocked` or `partial-risk` and do not claim the user story is complete.

## Implementation Tasks

- [ ] Task 1: Add the bug dossier artifact template
  - File: `templates/artifacts/bug_record.md`
  - Action: Create a ShipFlow artifact template for `bugs/BUG-ID.md` with frontmatter, reproduction, expected, observed, evidence, diagnosis notes, fix attempts, retest history, related bugs/artifacts, status lifecycle notes, redaction status, and closure criteria.
  - User story link: Gives every bug a durable detailed home without bloating indexes.
  - Depends on: None
  - Validate with: `sed -n '1,280p' templates/artifacts/bug_record.md`
  - Notes: Include `artifact: bug_record`, canonical statuses, redaction guidance and no raw-secret rule.

- [ ] Task 2: Add bug record metadata lint support
  - File: `tools/shipflow_metadata_lint.py`
  - Action: Accept `artifact: bug_record`, require the bug-specific frontmatter fields needed by the template, and include `bugs/` in default targets only when that directory exists or when the path is explicitly passed.
  - User story link: Keeps detailed bug dossiers structured and reviewable by fresh agents.
  - Depends on: Task 1
  - Validate with: `SHIPFLOW_ROOT="${SHIPFLOW_ROOT:-/home/claude/shipflow}" "$SHIPFLOW_ROOT/tools/shipflow_metadata_lint.py" templates/artifacts/bug_record.md`
  - Notes: Do not lint `BUGS.md` or `TEST_LOG.md` as artifacts.

- [ ] Task 3: Define compact test and bug tracking doctrine in `sf-test`
  - File: `skills/sf-test/SKILL.md`
  - Action: Replace the current full `BUGS.md` append format with compact `BUGS.md` index rules, `bugs/BUG-ID.md` dossier rules, `test-evidence/BUG-ID/` rules, canonical statuses, ID generation, duplicate detection and evidence redaction.
  - User story link: Prevents `TEST_LOG.md` and `BUGS.md` from becoming unbounded investigation dumps.
  - Depends on: Tasks 1-2
  - Validate with: `rg -n "bug dossier|test-evidence|BUG-YYYY-MM-DD|needs-repro|closed-without-retest|redact|compact" skills/sf-test/SKILL.md`
  - Notes: Preserve the existing rule that results cannot be invented.

- [ ] Task 4: Update `sf-test` retest behavior
  - File: `skills/sf-test/SKILL.md`
  - Action: Specify that `--retest BUG-ID` reads `bugs/BUG-ID.md`, appends retest history there, writes only a short `TEST_LOG.md` pointer, and moves status only through allowed transitions.
  - User story link: Makes retests durable without duplicating full context in central trackers.
  - Depends on: Task 3
  - Validate with: `rg -n "--retest|Retest History|fixed-pending-verify|allowed transition|BUG-ID" skills/sf-test/SKILL.md`
  - Notes: A passing retest can move to `fixed-pending-verify`; closure still belongs to verification or an explicit final state.

- [ ] Task 5: Update `sf-fix` bug dossier intake
  - File: `skills/sf-fix/SKILL.md`
  - Action: When invoked with `BUG-ID` or a matching bug title, read `BUGS.md` and `bugs/BUG-ID.md`, reconstruct the bug story from the dossier, append diagnosis notes and fix attempts, and refuse closure without retest evidence.
  - User story link: Captures what was tried to correct the bug, including failed or partial attempts.
  - Depends on: Tasks 1, 3
  - Validate with: `rg -n "bug dossier|Fix Attempts|in-diagnosis|fix-attempted|fixed-pending-verify|closed-without-retest|BUG-ID" skills/sf-fix/SKILL.md`
  - Notes: If the bug has no reproduction, route to diagnostic or `sf-test` instead of guessing.

- [ ] Task 6: Update verification gate behavior
  - File: `skills/sf-verify/SKILL.md`
  - Action: Require `sf-verify` to inspect linked `BUGS.md` and `bugs/*.md` for the verified scope, report open high/critical bugs, and block optimistic closure when bug state contradicts the user story.
  - User story link: Prevents verification from claiming success while known core bugs remain unresolved.
  - Depends on: Task 5
  - Validate with: `rg -n "BUGS.md|bugs/|open bug|fixed-pending-verify|high|critical|blocks ship" skills/sf-verify/SKILL.md`
  - Notes: Verification may still report partial readiness if risk is explicit.

- [ ] Task 7: Update shipping gate behavior
  - File: `skills/sf-ship/SKILL.md`
  - Action: Add a pre-ship check for linked high/critical bug records in quick and full mode, and require shipping reports to state `blocked`, `partial-risk`, or `not assessed` instead of implying closure when such bugs remain open.
  - User story link: Prevents shipping from erasing bug traceability at the final step.
  - Depends on: Task 6
  - Validate with: `rg -n "BUGS.md|bugs/|high|critical|blocked|partial-risk|bug" skills/sf-ship/SKILL.md`
  - Notes: Do not make quick ship perform a heavy audit; require honest risk reporting.

- [ ] Task 8: Update documentation coherence skill
  - File: `skills/sf-docs/SKILL.md`
  - Action: Teach docs audit/update mode to recognize the professional bug model, verify docs mention `TEST_LOG.md`, compact `BUGS.md`, per-bug dossiers and evidence redaction, and preserve the rule that trackers do not need frontmatter.
  - User story link: Keeps the documentation layer aligned with the new workflow.
  - Depends on: Tasks 3-7
  - Validate with: `rg -n "BUGS.md|TEST_LOG.md|bug dossier|test-evidence|tracker" skills/sf-docs/SKILL.md`
  - Notes: This is documentation behavior only, not implementation of bug tracking itself.

- [ ] Task 9: Update help command coverage
  - File: `skills/sf-help/SKILL.md`
  - Action: Add the professional bug loop and the roles of `TEST_LOG.md`, `BUGS.md`, `bugs/BUG-ID.md`, and `test-evidence/BUG-ID/`.
  - User story link: A fresh user can discover the workflow without reading implementation skills.
  - Depends on: Tasks 3-8
  - Validate with: `rg -n "bug dossier|TEST_LOG.md|BUGS.md|test-evidence|sf-test --retest" skills/sf-help/SKILL.md`
  - Notes: Keep the help concise.

- [ ] Task 10: Update `sf-test` README
  - File: `skills/sf-test/README.md`
  - Action: Replace the two-artifact explanation with the three-layer model and mention redacted evidence directories.
  - User story link: Aligns user-facing skill documentation with the new durable traceability model.
  - Depends on: Tasks 3-4
  - Validate with: `rg -n "bug dossier|test-evidence|BUGS.md|TEST_LOG.md|redact" skills/sf-test/README.md`
  - Notes: Avoid promising external tracker sync.

- [ ] Task 11: Update workflow doctrine
  - File: `shipflow-spec-driven-workflow.md`
  - Action: Add a concise section explaining `sf-test -> bug dossier -> sf-fix -> sf-test --retest -> sf-verify -> sf-ship`, with file roles, status lifecycle summary and evidence size rules.
  - User story link: Makes the doctrine visible outside individual skills.
  - Depends on: Tasks 3-9
  - Validate with: `rg -n "Professional Bug|bug dossier|test-evidence|sf-test --retest|closed-without-retest" shipflow-spec-driven-workflow.md`
  - Notes: Keep this as workflow doctrine, not an exhaustive bug-tracker manual.

- [ ] Task 12: Update README
  - File: `README.md`
  - Action: Mention professional bug management in structured AI workflows and define the three file roles at a high level.
  - User story link: A fresh user understands that ShipFlow now preserves bug traceability.
  - Depends on: Task 11
  - Validate with: `rg -n "bug|BUGS.md|TEST_LOG.md|test-evidence|bugs/" README.md`
  - Notes: Keep public claims scoped; no zero-bug promise.

- [ ] Task 13: Update public `sf-test` skill page
  - File: `site/src/content/skills/sf-test.md`
  - Action: Align the public page with compact `TEST_LOG.md`, compact `BUGS.md`, per-bug dossiers and redacted evidence directories.
  - User story link: Prevents public docs from teaching the old bug model.
  - Depends on: Tasks 10-12
  - Validate with: `rg -n "bug dossier|test-evidence|BUGS.md|TEST_LOG.md" site/src/content/skills/sf-test.md`
  - Notes: Preserve existing content schema.

- [ ] Task 14: Update public related skill pages
  - File: `site/src/content/skills/sf-fix.md`
  - Action: Mention that `sf-fix BUG-ID` consumes per-bug dossiers and appends diagnosis/fix attempts.
  - User story link: Keeps the fix path aligned with the new bug memory model.
  - Depends on: Task 13
  - Validate with: `rg -n "BUG-ID|bug dossier|fix attempts|retest" site/src/content/skills/sf-fix.md`
  - Notes: Do not over-expand the page.

- [ ] Task 15: Update public verification skill page
  - File: `site/src/content/skills/sf-verify.md`
  - Action: Mention that verification checks linked open bug records when relevant.
  - User story link: Makes verification's role in bug closure clear.
  - Depends on: Task 14
  - Validate with: `rg -n "bug|BUGS.md|blocks|verification" site/src/content/skills/sf-verify.md`
  - Notes: Keep the wording high-level.

- [ ] Task 16: Update public shipping skill page
  - File: `site/src/content/skills/sf-ship.md`
  - Action: Mention that shipping reports must not hide linked high/critical bug risk.
  - User story link: Keeps final delivery aligned with bug traceability.
  - Depends on: Task 15
  - Validate with: `rg -n "bug|high|critical|risk|ship" site/src/content/skills/sf-ship.md`
  - Notes: Do not imply quick ship becomes full verification.

- [ ] Task 17: Update public docs skill page
  - File: `site/src/content/skills/sf-docs.md`
  - Action: Mention documentation-coherence checks for bug workflow docs when relevant.
  - User story link: Keeps docs audit/update aligned with feature behavior.
  - Depends on: Task 16
  - Validate with: `rg -n "bug|documentation coherence|BUGS.md|TEST_LOG.md" site/src/content/skills/sf-docs.md`
  - Notes: Preserve content schema.

- [ ] Task 18: Update changelog
  - File: `CHANGELOG.md`
  - Action: Add an Unreleased entry for professional bug management, per-bug dossiers, compact indexes, evidence directories, lifecycle statuses and gate updates.
  - User story link: Makes the workflow change discoverable in release history.
  - Depends on: Tasks 1-17
  - Validate with: `sed -n '1,80p' CHANGELOG.md`
  - Notes: Keep the changelog entry concise.

## Acceptance Criteria

- [ ] CA 1: Given a failed `sf-test` scenario, when the result is logged, then `TEST_LOG.md` contains a short scenario entry with a pointer to `BUG-ID` and `bugs/BUG-ID.md` contains the detailed reproduction, expected behavior, observed behavior, evidence, current status and next step.
- [ ] CA 2: Given a new bug is created, when `BUGS.md` and `bugs/` already contain bugs for the same UTC date, then the new ID uses a suffix greater than every existing suffix and does not overwrite an existing dossier.
- [ ] CA 3: Given the same failure is reported twice, when reproduction and observed behavior clearly match an open bug, then the existing bug is updated or cross-linked instead of creating an unlinked duplicate.
- [ ] CA 4: Given a bug with large console/network logs, HAR files or screenshots, when evidence is recorded, then markdown references a redacted file under `test-evidence/BUG-ID/` or an explicit external path instead of embedding the full log inline.
- [ ] CA 5: Given sensitive evidence is supplied, when it is attached, then the recorded artifact says whether redaction was applied and must not include secrets, cookies, tokens, private payloads, raw headers, private emails or production personal data.
- [ ] CA 6: Given `sf-fix BUG-ID`, when a fix is attempted, then `sf-fix` reads the bug dossier and appends a fix attempt with changed files, hypothesis, validation command, outcome and next retest command.
- [ ] CA 7: Given a fix attempt exists but no retest has passed, when closure is reported, then the status is not `closed`; it is `fix-attempted`, `fixed-pending-verify` after a passing retest, or `closed-without-retest` only with explicit reason and residual risk.
- [ ] CA 8: Given a retest still fails, when `sf-test --retest BUG-ID` records the result, then the bug remains or returns to `open` and the failed retest is appended without deleting prior fix attempts.
- [ ] CA 9: Given an existing legacy `BUGS.md`, when a new bug is created, then the legacy content is preserved and the new index entry stays compact with a link to the dossier.
- [ ] CA 10: Given `tools/shipflow_metadata_lint.py` is run on `templates/artifacts/bug_record.md`, then the template passes metadata lint with `artifact: bug_record`.
- [ ] CA 11: Given `sf-verify` checks a scope with linked open high/critical bugs, when the verification report is produced, then it states whether bug state blocks closure or leaves a partial-risk verdict.
- [ ] CA 12: Given `sf-ship` is invoked for a scope with linked open high/critical bugs, when the ship report is produced, then it does not claim product/user-story closure and explicitly reports `blocked`, `partial-risk` or `not assessed`.
- [ ] CA 13: Given docs are updated, when README, workflow docs, help, public skill pages and changelog are searched, then they no longer describe `BUGS.md` as the full bug dossier location.
- [ ] CA 14: Given a fresh agent opens only `BUGS.md` and `bugs/BUG-ID.md`, when asked to continue work, then it can identify current status, reproduction, attempted fixes, evidence, redaction state and next step without reading chat history.

## Test Strategy

- Unit: Add or update targeted metadata-linter coverage only if the repo already has a test harness for `tools/shipflow_metadata_lint.py`; otherwise validate by running the linter directly on the new template.
- Integration: Run metadata lint against `templates/artifacts/bug_record.md`; if sample fixtures are added, also lint a sample `bugs/BUG-ID.md`.
- Manual: Simulate a failed `sf-test` in a disposable project or fixture, verify compact `TEST_LOG.md`, compact `BUGS.md`, `bugs/BUG-ID.md`, redacted evidence references, then simulate `sf-fix BUG-ID`, `sf-test --retest BUG-ID`, `sf-verify`, and a quick `sf-ship` report with an open high/critical bug.
- Regression: Verify existing `sf-test` pass/blocked/not-run paths still keep `TEST_LOG.md` compact and do not create bug dossiers unnecessarily.
- Documentation: Run the `rg` validation commands from implementation tasks and verify public docs do not contradict the new three-layer model.

## Risks

- Security impact: yes, because bug evidence may include secrets, cookies, tokens, emails, screenshots, request payloads, HAR files, production data or other private data. Mitigation: require redaction before persistence, path safety checks, no raw inline evidence, and explicit redaction status in dossiers.
- Product/data/performance risk: medium, because unmanaged evidence directories can grow. Mitigation: store only paths or redacted minimal evidence by default, avoid binary capture unless explicit, and keep indexes compact.
- Workflow risk: medium, because adding too many files can feel bureaucratic. Mitigation: create detailed bug dossiers only for failed or actionable bugs, not for every passing test.
- Migration risk: low to medium, because legacy `BUGS.md` files may already contain details. Mitigation: leave old content valid and apply the new structure only to new or retested bugs unless a project explicitly requests migration.
- Consistency risk: medium, because several skills and public docs mention bug behavior. Mitigation: explicit tasks and acceptance criteria cover every linked surface.
- Concurrency risk: low to medium, because multiple agents could assign IDs. Mitigation: re-read `BUGS.md` and `bugs/` just before writing and retry on collision; stop on repeated conflict.

## Execution Notes

- Read first: `skills/sf-test/SKILL.md`, `skills/sf-fix/SKILL.md`, `skills/sf-verify/SKILL.md`, `skills/sf-ship/SKILL.md`, `skills/sf-docs/SKILL.md`, `templates/artifacts/spec.md`, `tools/shipflow_metadata_lint.py`.
- Implementation approach: create the template and metadata support first; then update the workflow skills in the order `sf-test`, `sf-fix`, `sf-verify`, `sf-ship`, `sf-docs`; then update help, README, workflow docs, public skill pages and changelog.
- Packages: do not add runtime packages. `tools/shipflow_metadata_lint.py` must remain Python standard library only.
- Patterns to follow: additive markdown edits, re-read before editing trackers, explicit status transitions, explicit evidence limits, no frontmatter for `TEST_LOG.md` or `BUGS.md`, ShipFlow-owned paths from `${SHIPFLOW_ROOT:-/home/claude/shipflow}`.
- Data flow: observation or failed test -> compact `TEST_LOG.md` entry -> compact `BUGS.md` index pointer -> detailed `bugs/BUG-ID.md` dossier -> optional redacted evidence under `test-evidence/BUG-ID/` -> fix attempt -> retest -> verify -> ship risk report.
- Abstractions to avoid: no global bug registry, no external issue tracker adapter, no UI, no central evidence database, no generated migration of all old bugs.
- Validate with: metadata lint for the new template, `rg` checks listed in tasks, manual dry-run against a fixture or temporary project, and final `tools/shipflow_metadata_lint.py specs/professional-bug-management.md templates/artifacts/bug_record.md` after implementation.
- Stop conditions: unclear status lifecycle change, uncertainty about storing sensitive evidence, conflict with an existing project-specific bug tracker, repeated ID collision, or any pressure to close a bug without retest or visible exception.

## Open Questions

None. The chosen defaults are: compact project indexes plus per-bug dossiers plus separate redacted evidence directories; UTC date IDs; no global registry; no external issue tracker sync; no UI; no historical migration unless explicitly requested later.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-04-27 12:44:52 UTC | sf-spec | GPT-5 Codex | Updated professional bug management spec after readiness gaps | draft saved | /sf-ready Professional Bug Management |
| 2026-04-27 14:37:31 UTC | sf-ready | GPT-5 Codex | Evaluated readiness gate for professional bug management | ready | /sf-start Professional Bug Management |
| 2026-04-27 14:59:24 UTC | sf-start | gpt-5.3-codex | Implemented bug dossier template, metadata linting, skill doctrine and docs; deferred changelog per sf-start rule | partial | /sf-verify Professional Bug Management |
| 2026-04-27 16:21:39 UTC | sf-verify | GPT-5 Codex | Verified tasks 1-17 and required validation commands; confirmed task 18 (`CHANGELOG.md`) remains intentionally deferred per sf-start rule | partial | /sf-end Professional Bug Management |
| 2026-04-27 16:48:22 UTC | sf-end | GPT-5 Codex | Closed professional bug management by adding changelog entry and marking trackers complete | closed | /sf-ship Professional Bug Management |
| 2026-04-27 17:04:30 UTC | sf-verify | GPT-5 Codex | Re-verified after sf-end; changelog complete, strict lifecycle smoke passed, metadata lint, Python compile, diff check and site build passed | verified | /sf-ship Professional Bug Management |
| 2026-04-27 17:37:26 UTC | sf-ship | GPT-5 Codex | Quick ship Professional Bug Management changes after verified chantier state | shipped | None |

## Current Chantier Flow

- `sf-spec`: done, draft spec updated with lifecycle, security, documentation and chantier tracking.
- `sf-ready`: ready on 2026-04-27 after structure, metadata, user story alignment, adversarial review, security review and documentation coherence checks.
- `sf-start`: implemented on 2026-04-27 for execution scope; task 18 (`CHANGELOG.md`) was intentionally handled by sf-end because sf-start must not update CHANGELOG.md.
- `sf-verify`: verified on 2026-04-27 after changelog completion, strict lifecycle smoke, metadata lint, Python compile, diff check and site build.
- `sf-end`: closed on 2026-04-27 after changelog and tracker closure.
- `sf-ship`: shipped on 2026-04-27.

Next step: None
