---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipFlow
created: "2026-04-28"
created_at: "2026-04-28 10:00:00 UTC"
updated: "2026-04-28"
updated_at: "2026-04-28 10:00:00 UTC"
status: draft
source_skill: sf-spec
source_model: gpt-5.3-codex
scope: feature
owner: ShipFlow maintainer
user_story: "En tant qu'opérateur ShipFlow qui installe un serveur multi-utilisateurs, je veux choisir explicitement pour quels comptes la configuration d'agent doit être installée, afin d'éviter d'altérer des profils non concernés."
confidence: high
risk_level: low
security_impact: no
docs_impact: yes
linked_systems:
  - install.sh
  - config.sh
  - CLAUDE.md
  - README.md
  - local/README.md
  - CONTEXT.md
  - INSTALLATION-OWNERSHIP-SPEC.md
depends_on:
  - artifact: "INSTALLATION-OWNERSHIP-SPEC.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "README.md"
    artifact_version: "0.1.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "Current install.sh applies configuration to root and every /home/* user after system package setup."
  - "User request: avoid surprising per-user auto-configuration and ask install target explicitly."
next_step: "/sf-ready installation-user-targeting"
---

# Spec: Cible d'installation par utilisateur dans install.sh

> Note: cette spec est le detail ShipFlow du contrat racine
> `INSTALLATION-OWNERSHIP-SPEC.md`, qui separe les responsabilites
> entre `dotfiles` (tooling generique) et `ShipFlow` (IA/code actif).

## Title

Ciblage explicite des utilisateurs ciblés lors de l'installation

## Status

superseded by `specs/ai-agent-install-ownership-and-autonomous-permissions.md`