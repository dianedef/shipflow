  Pour travail non trivial
  sf-explore -> sf-spec -> revue adversariale de la spec -> sf-start ->
  implémentation -> sf-verify -> sf-end

  Le point clé : sf-start ne devrait plus être le moment où on découvre le
  problème. Il devrait être le moment où on engage une implémentation déjà
  clarifiée.

  Ce que je changerais dans le flow

  1. sf-explore devient l’étape optionnelle de désembrouillage.
     Pour idée floue, refactor risqué, feature transverse, bug mal compris.
     Objectif : faire émerger les vraies questions avant la spec.
  2. sf-spec devient la porte d’entrée par défaut pour tout scope medium+.
     Pas juste une doc technique, mais un contrat d’implémentation.
     Si la spec n’est pas autonome, on ne code pas.
  3. sf-start devient un “execution kickoff”.
     Il ne planifie plus à partir d’une vague intention.
     Il charge une spec existante, vérifie qu’elle est exploitable, puis prépare
     les fichiers cibles et le plan d’exécution.
  4. sf-verify vérifie contre la spec, pas seulement contre le diff.
     Aujourd’hui il contrôle surtout “est-ce propre / cohérent / safe ?”.
     Il devrait aussi répondre à : “est-ce que ce qui a été livré correspond          exactement au contrat ?”
  5. sf-end doit fermer la boucle avec traçabilité.
     Il devrait résumer :

  - ce qui a été livré de la spec
  - ce qui reste hors scope
  - quelles décisions ont changé pendant l’implémentation
