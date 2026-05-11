---
artifact: veille_concurrents_inspirations
project: shipflow
created: "2026-05-11"
updated: "2026-05-11"
status: reviewed
source_skill: sf-veille
scope: "inspirations techniques pour ShipFlow CLI, serveur et skills"
confidence: medium
---

# Concurrents et inspirations — ShipFlow

## Lecture projet

ShipFlow gère l'environnement serveur, PM2, Caddy, Flox, les skills et la mémoire opérationnelle. Les liens utiles sont ceux qui améliorent la validation d'agents, le monitoring, le tunnel, la documentation et les rapports actionnables.

## Liens prioritaires

| Lien | Type | Score | Usage concret |
|---|---:|:---:|---|
| [Spec27](https://betalist.com/startups/spec27) | Inspiration skills / validation | 9/10 | Très pertinent pour transformer les specs ShipFlow en tests d'agents: critères d'acceptation, cas limites, non-régression. |
| [frp](https://github.com/fatedier/frp) | Inspiration infra | 8/10 | Benchmark technique pour tunnels rapides entre serveur, machine locale et apps en dev. À comparer au modèle Caddy/DuckDNS/SSH actuel. |
| [DiffHook](https://betalist.com/startups/diffhook) | Inspiration monitoring | 7/10 | Pattern de surveillance de pages, docs, dépendances ou changements concurrents déclenchant une tâche ShipFlow. |
| [MemoryPlugin](https://betalist.com/startups/memoryplugin) | Inspiration mémoire agent | 7/10 | Intéressant pour cadrer la mémoire cross-skills sans fuite de contexte ni dérive. |
| [Web-Analytics.ai](https://web-analytics.ai/) | Inspiration reporting | 7/10 | Format de rapports hebdo en langage clair pour `sf-status`, `sf-review` ou dashboard ShipFlow App. |
| [Airbin](https://betalist.com/startups/airbin) | Inspiration workspace | 6/10 | Workspace privé de fichiers + recherche: proche d'une interface lisible sur `shipflow_data`. |

## À surveiller

| Lien | Type | Score | Pourquoi |
|---|---:|:---:|---|
| [VenturOS](https://betalist.com/startups/venturos) | Inspiration pilotage | 6/10 | Comparable à un OS exécutif; utile pour priorités, reviews et décisions. |
| [BundleUp](https://betalist.com/startups/bundleup) | Inspiration intégrations | 5/10 | Peut inspirer une couche unifiée pour GitHub, Vercel, Supabase, Convex, analytics. |
| [Impulse AI](https://betalist.com/startups/impulse-ai) | Inspiration déploiement IA | 5/10 | À surveiller si ShipFlow orchestre des déploiements modèles/agents. |

## Question

- Veux-tu que `frp` soit creusé comme alternative réelle de tunnel ShipFlow, ou seulement noté comme benchmark technique ?
