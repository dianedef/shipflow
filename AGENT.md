---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "0.4.0"
project: "shipflow"
created: "2026-04-25"
updated: "2026-05-01"
status: draft
source_skill: manual
scope: "agent-entrypoint"
owner: "unknown"
confidence: "high"
risk_level: "low"
security_impact: "none"
docs_impact: "yes"
linked_systems: ["CLAUDE.md", "CONTEXT.md", "CONTEXT-FUNCTION-TREE.md", "CONTENT_MAP.md", "README.md", "docs/technical/", "docs/technical/code-docs-map.md", "skills/references/canonical-paths.md"]
depends_on: []
supersedes: []
evidence: ["Repository structure and active context docs", "CONTENT_MAP.md added as the content routing artifact", "Canonical path resolution added for ShipFlow-owned tools and references", "Technical documentation layer added for code-proximate agent routing"]
next_step: "/sf-docs update AGENT.md"
---

# AGENT

## Role

Ce fichier est le point d'entree rapide pour un agent qui arrive dans le repo. Il ne doit pas dupliquer toute la doc. Il doit diriger vers le bon contexte le plus vite possible.

## Read Order

1. Lire `CLAUDE.md` pour les contraintes du repo.
2. Lire `CONTEXT.md` pour la carte operative du projet.
3. Lire `CONTEXT-FUNCTION-TREE.md` si la tache touche les scripts Bash principaux ou `lib.sh`.
4. Lire `docs/technical/code-docs-map.md` si la tache touche du code, un outil, une skill, un template, le site public ou la documentation technique.
5. Lire `CONTENT_MAP.md` si la tache touche contenu, repurposing, blog, docs publiques, landing pages, FAQ ou cocons semantiques.
6. Lire `README.md` pour la vue d'ensemble publique et les workflows officiels.

## Route By Task

- Pour tout fichier interne ShipFlow, resoudre depuis `${SHIPFLOW_ROOT:-$HOME/shipflow}`. Cela inclut `skills/`, `skills/references/`, `templates/`, `tools/`, `shipflow-spec-driven-workflow.md` et `shipflow-metadata-migration-guide.md`. Le repo courant ne sert de racine que pour les artefacts et le code du projet audite ou modifie.
- Si la tache touche le CLI principal, commencer par `shipflow.sh`, `lib.sh`, puis `CONTEXT.md`.
- Si la tache touche le setup serveur ou Codex, lire `install.sh`, `config.sh`, puis `CONTEXT.md`.
- Si la tache touche les tunnels SSH locaux, lire `local/local.sh`, `local/dev-tunnel.sh`, puis `CONTEXT-FUNCTION-TREE.md`.
- Si la tache touche les skills, lire `README.md`, `shipflow-spec-driven-workflow.md`, puis les `skills/*/SKILL.md` concernes.
- Si la tache touche la metadata des docs, lire `$SHIPFLOW_ROOT/shipflow-metadata-migration-guide.md`, `$SHIPFLOW_ROOT/tools/shipflow_metadata_lint.py`, puis `$SHIPFLOW_ROOT/skills/sf-docs/SKILL.md`.
- Si la tache touche un code area mappe, lire `docs/technical/code-docs-map.md`, puis le doc primaire dans `docs/technical/`. `AGENT.md` reste canonique; `AGENTS.md` ne doit etre qu'un symlink de compatibilite vers `AGENT.md`.
- Si la tache touche contenu, repurposing, blog, docs publiques, landing pages ou cocons semantiques, lire `CONTENT_MAP.md`, puis `skills/sf-repurpose/SKILL.md` si la demande transforme une source en contenu.
- Si la tache touche produit, audience, priorites ou scope, lire `BUSINESS.md`, `PRODUCT.md`, puis `GTM.md` si la demande touche la promesse publique.
- Si la tache touche architecture ou conventions techniques, lire `ARCHITECTURE.md`, `GUIDELINES.md`, puis `CONTEXT.md`.

## Context Docs

- `CLAUDE.md`: contraintes techniques et patterns critiques.
- `CONTEXT.md`: architecture, entry points, flux, hotspots, invariants, ou modifier quoi.
- `CONTEXT-FUNCTION-TREE.md`: arbre de fonctions des scripts principaux.
- `CONTENT_MAP.md`: surfaces de contenu, pages piliers, cocons semantiques, destinations de repurposing.
- `shipflow-spec-driven-workflow.md`: doctrine de travail spec-first et artefacts.
- `shipflow-metadata-migration-guide.md`: doctrine de migration frontmatter.
- `docs/technical/README.md`: index interne des docs techniques proches du code.
- `docs/technical/code-docs-map.md`: map code -> docs, validations et triggers de mise a jour.
- `BUSINESS.md`: contrat business.
- `PRODUCT.md`: contrat produit.
- `BRANDING.md`: contrat de marque.
- `GTM.md`: contrat de promesse publique et de distribution.
- `ARCHITECTURE.md`: contrat de structure technique.
- `GUIDELINES.md`: conventions techniques et de contribution.

## Rules

- Ne pas lire tout le repo avant d'identifier la zone utile.
- Utiliser `CONTEXT.md` comme index, pas comme verite absolue.
- Si `CONTEXT.md` et le code divergent, le code gagne et la doc doit etre corrigee.
- Pour une tache locale, lire seulement la doc specialisee necessaire.
- Pour une tache ambigue ou transverse, lire `CONTEXT.md` avant de parcourir le code.
