---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipflow"
created: "2026-05-16"
updated: "2026-05-16"
status: draft
source_skill: sf-explore
scope: "skill instruction length and compaction strategy"
owner: "unknown"
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - "skills/"
  - "skills/references/"
  - "shipflow_data/technical/context.md"
  - "templates/artifacts/"
evidence:
  - "skills/*/SKILL.md total: 20155 lines"
  - "Long skills observed: sf-docs 941 lines, sf-audit-design 843 lines, sf-init 718 lines, sf-audit-code 653 lines, sf-audit-copywriting 641 lines, sf-verify 571 lines"
  - "Repeated sections observed: Canonical Paths, Chantier Tracking, Report Modes, Context blocks, development mode and documentation freshness gates"
depends_on:
  - "CLAUDE.md"
  - "shipflow_data/technical/context.md"
  - "skills/references/canonical-paths.md"
supersedes: []
next_step: "/sf-spec compact ShipFlow skill instructions"
---

# Exploration Report: Skill Instruction Compaction

## Starting Question

Est-ce que les skills ShipFlow sont trop longues, et est-ce qu'une version plus concise aiderait les LLM a mieux les suivre ?

## Context Read

- `CLAUDE.md` - contraintes repo, architecture et regles critiques.
- `shipflow_data/technical/context.md` - role central des skills dans le workflow ShipFlow.
- `skills/references/canonical-paths.md` - exemple de regle transverse deja factorisee.
- `skills/sf-start/SKILL.md` et `skills/sf-verify/SKILL.md` - exemples de skills longues avec beaucoup de garde-fous transverses.
- `skills/*/SKILL.md` - mesure globale de taille.

## Internet Research

- None. La question est locale au design des instructions ShipFlow.

## Problem Framing

La longueur n'est pas mauvaise en soi. Elle devient couteuse quand elle augmente la charge cognitive du modele, noie les priorites, duplique des regles entre skills, ou melange des contrats critiques avec des exemples stylistiques.

Le risque principal n'est pas seulement le cout token. C'est la dilution: plus une skill contient de couches, plus le modele peut suivre une instruction secondaire et oublier le comportement central.

## Option Space

### Option A: Garder les skills completes

- Summary: chaque skill reste autonome, avec tout son contexte.
- Pros: robuste en isolation; moins de dependances implicites; moins de risque qu'une reference manquante casse le comportement.
- Cons: repetition massive; prompts plus lourds; priorites moins nettes; maintenance lente.

### Option B: Compacter agressivement toutes les skills

- Summary: reduire chaque `SKILL.md` a une page courte.
- Pros: signal fort; moins de tokens; comportement central plus visible.
- Cons: risque de perdre des garde-fous acquis par experience; migrations difficiles; comportement moins fiable sur les cas limites.

### Option C: Compaction par couches

- Summary: garder dans chaque skill seulement l'intention, les interdits, le workflow local et les criteres de sortie; deplacer les regles transverses vers `skills/references/*`.
- Pros: moins de duplication; garde-fous critiques conserves; meilleure lisibilite; migration progressive possible.
- Cons: il faut une convention stricte de chargement des references; certaines skills doivent rester plus longues car elles portent un vrai contrat metier.

## Emerging Recommendation

Recommander Option C.

Compacter, oui, mais pas en supprimant de la substance. Le bon objectif est: chaque skill doit tenir comme une "fiche d'activation" claire, et charger des references partagees pour les politiques transverses.

Raccourcir une skill est utile si cela augmente la hierarchie du signal:

- role de la skill
- ce qu'elle doit faire
- ce qu'elle ne doit jamais faire
- quand charger quelles references
- comment conclure

## Non-Decisions

- Pas de seuil universel de lignes fixe.
- Pas de suppression immediate des garde-fous chantier, verification, metadata ou securite.
- Pas de rewrite complet des skills sans spec.

## Rejected Paths

- "Tout mettre dans AGENT.md" - rendrait l'entree globale trop lourde et moins actionnable.
- "Tout laisser dans chaque skill" - conserve la dette de repetition.
- "Compacter uniquement pour economiser des tokens" - objectif trop faible; la vraie cible est l'observance des instructions.

## Risks And Unknowns

- Une reference partagee trop longue peut recreer le meme probleme ailleurs.
- Une compaction trop aggressive peut supprimer des lecons operationnelles importantes.
- Il faut verifier runtime et symlinks apres modification de skills.
- Les skills lifecycle (`sf-start`, `sf-verify`, `sf-ready`, `sf-spec`) ont plus de contraintes et doivent etre migrees avec plus de prudence que les helpers.

## Redaction Review

- Reviewed: yes
- Sensitive inputs seen: none
- Redactions applied: none
- Notes: No secrets, tokens, cookies, private keys, customer data or sensitive logs were observed.

## Decision Inputs For Spec

- User story seed: En tant qu'utilisateur ShipFlow, je veux des skills plus concises et mieux factorisees pour que l'agent suive mieux les consignes importantes sans perdre les garde-fous critiques.
- Scope in seed: audit de longueur, classification des sections transverses, creation de references partagees, migration progressive d'un petit lot pilote.
- Scope out seed: suppression non controlee des politiques chantier, metadata, securite, verification ou reporting.
- Invariants/constraints seed: conserver la resolution canonique `$SHIPFLOW_ROOT`; conserver les trace categories et process roles; verifier la visibilite runtime des skills modifiees.
- Validation seed: diff lisible, `tools/shipflow_sync_skills.sh --check --all`, coherence check contre `skills/references/chantier-tracking.md`, comparaison avant/apres de quelques skills pilotes.

## Handoff

- Recommended next command: `/sf-spec compact ShipFlow skill instructions`
- Why this next step: la decision touche beaucoup de skills et des contrats transverses; elle merite une spec courte avant modification.

## Exploration Run History

| Date UTC | Prompt/Focus | Action | Result | Next step |
|----------|--------------|--------|--------|-----------|
| 2026-05-16 00:00:00 UTC | Skill length and LLM instruction quality | Read repo context, measured skill sizes, inspected representative long skills | Recommend layered compaction rather than aggressive shortening | `/sf-spec compact ShipFlow skill instructions` |
