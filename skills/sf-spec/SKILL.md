---
name: sf-spec
description: Créer une spécification technique prête à implémenter — par conversation, investigation du code, et documentation structurée. Le chaînon entre sf-explore (réfléchir) et sf-start (coder).
argument-hint: [optional: description de ce qu'on veut construire]
---

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- CLAUDE.md (constraints): !`head -60 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Master TASKS.md: !`cat /home/claude/shipflow_data/TASKS.md 2>/dev/null | head -40 || echo "No master TASKS.md"`
- Local TASKS.md (if exists): !`cat TASKS.md 2>/dev/null | head -30 || echo "No local TASKS.md"`
- Project structure: !`find . -maxdepth 3 -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.astro" -o -name "*.vue" -o -name "*.py" -o -name "*.sh" \) 2>/dev/null | grep -v node_modules | grep -v .git | grep -v dist | sort | head -30`

## Your task

Créer une spec technique complète et prête à implémenter par conversation. Quatre étapes : comprendre, investiguer, spécifier, valider.

### Standard "Prêt à coder"

Une spec est prête UNIQUEMENT si :
- **Actionnable** : chaque tâche a un fichier cible et une action claire
- **Ordonnée** : les tâches sont triées par dépendance (fondations d'abord)
- **Testable** : les critères d'acceptation couvrent le happy path et les cas limites
- **Complète** : aucun "TBD" ou placeholder — tout le contexte est dans la spec
- **Autonome** : un agent frais peut implémenter sans lire l'historique de conversation

---

### Step 1 — Comprendre le besoin

**Si `$ARGUMENTS` est fourni**, l'utiliser comme point de départ.
**Sinon**, demander : "Qu'est-ce qu'on construit ?"

**Scan rapide d'orientation (< 30 secondes) :**
- Chercher des docs existantes (CLAUDE.md, README, docs/)
- Si l'utilisateur mentionne du code spécifique, scanner les fichiers concernés
- Repérer le stack technique, les patterns, la structure du projet

**Poser des questions informées** — pas des questions génériques, mais des questions ancrées dans ce qu'on a trouvé :
- "Le `AuthService` valide dans le controller — on suit ce pattern ou on crée un validateur dédié ?"
- "Je vois que les composants utilisent du state local — on reste là-dessus ou on passe au store global ?"

**Capturer et confirmer :**
- **Titre** : nom clair et concis
- **Problème** : qu'est-ce qu'on résout ?
- **Solution** : approche en 1-2 phrases
- **Scope in** : ce qui est inclus
- **Scope out** : ce qui est explicitement exclu

Demander confirmation avant de continuer.

---

### Step 2 — Investiguer le code

Explorer le codebase en profondeur pour ancrer la spec dans la réalité technique.

**Pour chaque fichier/zone pertinente :**
- Lire le code complet
- Identifier les patterns, conventions, style
- Noter les dépendances et imports
- Trouver les fichiers de test associés

**Capturer le contexte technique :**
- **Stack** : langages, frameworks, librairies
- **Patterns** : architecture, nommage, structure de fichiers
- **Fichiers à modifier/créer** : liste concrète
- **Patterns de test** : comment les tests sont structurés

**Si aucun code existant** (clean slate) :
- Identifier le dossier cible
- Scanner les dossiers parents pour le contexte architectural
- Documenter "Clean Slate confirmé" — pas de contraintes legacy

Résumer les trouvailles à l'utilisateur avant de continuer.

---

### Step 3 — Générer la spec

Produire la spécification complète.

**Tâches d'implémentation :**
```markdown
- [ ] Tâche N : Description claire de l'action
  - Fichier : `chemin/vers/fichier.ext`
  - Action : Modification spécifique à faire
  - Notes : Détails d'implémentation si nécessaire
```

Ordonnées par dépendance (fondations d'abord).

**Critères d'acceptation (Given/When/Then) :**
```markdown
- [ ] CA N : Given [précondition], when [action], then [résultat attendu]
```

Couvrir : happy path, erreurs, cas limites, intégrations.

**Sections complémentaires :**
- **Dépendances** : librairies, services, APIs nécessaires
- **Stratégie de test** : unit, intégration, tests manuels
- **Risques** : points sensibles identifiés (sécurité, perf, données)

---

### Step 4 — Valider avec l'utilisateur

Présenter la spec complète et demander une revue.

**Déclencheurs de revue adversariale (règle simple) :**
- Si **au moins un** signal ci-dessous est vrai, faire une revue adversariale avant validation finale :
  - plus d'un fichier à modifier
  - plus d'un domaine impacté (ex: UI + API, backend + data, auth + routing)
  - comportement métier non trivial
  - impact sécurité, données, auth, perf, migration, ou contrat API
  - cas limites probables ou déjà observés
  - au moins une phrase vague dans la spec ("optimiser", "gérer proprement", "adapter") sans critère testable

**Quand la revue adversariale peut rester légère :**
- bug local, comportement attendu évident, un seul fichier, pas d'impact transverse

**Afficher un résumé rapide :**
```
Spec : [titre]
─────────────────────────
Tâches : N à implémenter
Critères : M à vérifier
Fichiers : P à modifier
─────────────────────────
```

Puis afficher la spec complète.

**Utiliser AskUserQuestion :**
- Question : "La spec est prête ?"
- Options :
  - **C'est bon** — "Enregistrer et passer à l'implémentation"
  - **À modifier** — "J'ai des retours à intégrer"
  - **Revue adversariale** — "Critique la spec toi-même avant de valider" (recommandé)

**Si "À modifier"** : intégrer les retours, re-présenter, boucler.

**Si "Revue adversariale"** : prendre du recul et critiquer sa propre spec :
- Les tâches sont-elles vraiment ordonnées par dépendance ?
- Y a-t-il des cas limites non couverts dans les CA ?
- Un agent frais pourrait-il implémenter sans contexte supplémentaire ?
- Manque-t-il des fichiers à modifier ?
- Y a-t-il des formulations vagues sans test associé ?
- Présenter les trouvailles, corriger, re-présenter.

**Si "C'est bon"** : enregistrer la spec.

---

### Step 5 — Enregistrer

Sauvegarder la spec dans le projet :
- Écrire dans `specs/[slug].md` (créer le dossier `specs/` si nécessaire)
- Si un dossier `docs/` existe, écrire là-bas à la place

**Rapport final :**
```
Spec enregistrée : specs/[slug].md

Prochaine étape :
- Lancer /sf-start [titre] pour commencer l'implémentation
- Ou continuer à explorer avec /sf-explore
```

---

### Rules

- **Ne pas implémenter** — cette skill produit une spec, pas du code
- **Questions informées** — toujours scanner le code AVANT de poser des questions
- **Pas de TBD** — si quelque chose n'est pas clair, poser la question plutôt que laisser un placeholder
- **Autonome** — la spec doit contenir TOUT le contexte nécessaire pour implémenter
- **Pragmatique** — adapter la profondeur au scope (pas de spec de 50 tâches pour un bug fix)
- **Conversationnel** — c'est un dialogue, pas un formulaire. Suivre les fils intéressants.
