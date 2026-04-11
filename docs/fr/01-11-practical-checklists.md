## 1.11 – Checklists pratiques

<a id="111-practical-checklists"></a>

Ce chapitre fournit des checklists pratiques pour préparer, exécuter et analyser des tests de performance.

À la différence des chapitres précédents, qui expliquent des concepts et des mécanismes, ce chapitre se concentre sur la discipline opérationnelle.

L’objectif est de réduire les erreurs évitables et d’assurer que les tests de performance produisent des résultats interprétables, fiables et utiles.

## Table des matières

- [1.11.1 Avant d’exécuter un test](#1111-before-running-a-test)
- [1.11.2 Pendant l’exécution du test](#1112-during-test-execution)
- [1.11.3 Après l’analyse du test](#1113-after-test-analysis)
- [1.11.4 Erreurs communes](#1114-common-pitfalls)

---

<a id="1111-before-running-a-test"></a>
## 1.11.1 Avant d’exécuter un test

### Objectifs

Définir clairement ce que le test entend valider.

Des objectifs typiques incluent :

- cibles de latence  
- objectifs de throughput  
- limites de capacité  

Un test sans objectif clair peut quand même générer des données, mais ces données seront difficiles à évaluer.

La première question devrait toujours être :

- qu’est-ce que ce test devrait prouver, valider ou révéler ?

---

### Définition de la charge de travail

Définir la charge de travail avec précision :

- taux de requêtes ou concurrence  
- mix de requêtes  
- durée  

(→ [1.4 Types of performance tests](./01-04-types-of-performance-tests.md))

La charge de travail doit être suffisamment spécifique pour être reproductible et suffisamment réaliste pour être significative.

Une charge de travail vague ou artificielle peut produire des résultats techniquement corrects mais opérationnellement non pertinents.

---

### Cohérence de l’environnement

S’assurer que :

- l’environnement de test soit stable  
- la configuration corresponde aux hypothèses de production  
- les dépendances externes soient contrôlées  

Si l’environnement change pendant le testing, l’interprétation devient incertaine.

Les résultats de performance sont comparables seulement si les conditions d’exécution restent suffisamment cohérentes.

Cela est particulièrement important lorsque l’on évalue :

- des changements de configuration
- des changements de code
- des changements infrastructurels

---

### Setup des métriques

Vérifier que toutes les métriques requises soient disponibles :

- percentiles de latence  
- throughput  
- utilisation des ressources  
- taux d’erreur  

(→ [1.2 Core metrics and formulas](./01-02-core-metrics-and-formulas.md))

Il est aussi utile de s’assurer que des signaux de support soient disponibles lorsqu’ils sont pertinents, comme :

- longueurs des files
- timing des dépendances
- activité GC
- états des threads ou des pools

Le test ne devrait pas commencer avant que la visibilité soit en place.

---

### Contrôles de préparation

Avant d’exécuter le test, confirmer que :

- le système cible soit dans l’état attendu
- le monitoring soit actif
- le générateur de charge de travail soit configuré correctement
- la durée du test soit appropriée pour l’objectif choisi
- les critères de succès et d’échec soient connus à l’avance

Cela évite un problème commun dans le performance testing : exécuter un test techniquement valide qui ensuite ne peut pas être interprété avec certitude.

---

### Interprétation pratique

La préparation fait partie du test.

La majorité des résultats peu fiables n’est pas causée par un comportement complexe du système, mais par une mauvaise préparation du test :

- objectifs peu clairs
- charge de travail non réaliste
- environnement incohérent
- métriques incomplètes

Un test bien préparé rend le diagnostic successif beaucoup plus facile.

---

### Idée clé

Un test est significatif seulement si les objectifs, la charge de travail et les mesures sont clairement définis.

---

<a id="1112-during-test-execution"></a>
## 1.11.2 Pendant l’exécution du test

### Monitoring

Observer le comportement du système en temps réel :

- évolution de la latence  
- stabilité du throughput  
- utilisation des ressources  

Le monitoring pendant l’exécution est important parce que certains problèmes sont visibles seulement pendant que le test est en cours d’exécution, spécialement :

- saturation soudaine
- mise en file d’attente inattendue
- récupération instable
- défaillances des dépendances

Attendre la fin du test peut cacher des comportements importants dépendants du temps.

---

### Contrôles de cohérence

S’assurer que :

- la charge de travail soit appliquée comme prévu  
- aucune perturbation externe n’influence le test  

Cela inclut vérifier que :

- le taux de requêtes prévu soit effectivement généré
- le mix d’opérations reste cohérent
- aucune activité non corrélée ne soit en train de distordre les résultats
- les échecs soient causés par les conditions de test plutôt que par du bruit externe

Une divergence entre charge de travail prévue et charge de travail réelle peut invalider l’interprétation entière.

---

### Signaux précoces

Observer :

- augmentation rapide de la latence  
- erreurs inattendues  
- saturation des ressources  

(→ [1.8 Resource-level performance](./01-08-resource-level-performance.md))

Ceux-ci sont souvent les premiers signaux que le système est en train de s’approcher d’une limite ou que la charge de travail est en train d’exposer un goulot d’étranglement non anticipé.

L’identification précoce est importante parce qu’elle permet à l’opérateur du test de :

- capturer des évidences pertinentes
- préserver un contexte utile
- éviter de perdre la partie la plus informative de l’exécution

---

### Observations à runtime

Pendant l’exécution, il est utile d’observer non seulement des valeurs absolues, mais aussi le changement dans le temps.

Exemples :

- latence en augmentation tandis que le throughput reste stable
- longueurs des files en croissance avant la saturation de la CPU
- erreurs qui apparaissent seulement après un seuil spécifique
- dégradation de p95/p99 avant que la moyenne change significativement

Ces patterns révèlent souvent plus que des snapshots isolés.

Ils aident à distinguer entre :

- instabilité transiente
- surcharge stable
- dégradation lente
- effondrement soudain

---

### Discipline d’intervention

Pendant un test, éviter de changer des paramètres à moins que le changement ne fasse partie du plan de test.

Une intervention non planifiée rend les résultats plus difficiles à interpréter parce qu’elle mélange des causes multiples dans la même fenêtre d’observation.

Si l’intervention devient nécessaire, elle devrait être :

- documentée
- marquée temporellement
- explicitement reliée au comportement observé

Cela préserve la valeur diagnostique de l’exécution.

---

### Interprétation pratique

L’exécution est la phase où la préparation théorique rencontre le comportement réel du système.

Un test bien conçu peut quand même devenir trompeur si l’opérateur ne confirme pas que :

- la charge de travail soit correcte
- l’environnement reste stable
- le système soit en train de se comporter comme prévu ou, chose importante, de manière inattendue comme le test entendait révéler

---

### Idée clé

L’exécution n’est pas passive.

Une observation continue est requise pour détecter précocement les anomalies.

---

<a id="1113-after-test-analysis"></a>
## 1.11.3 Après l’analyse du test

### Révision des données

Analyser les données recueillies :

- distribution de la latence  
- tendances de throughput  
- utilisation des ressources  

La révision des données devrait se concentrer non seulement sur les valeurs moyennes, mais aussi sur la forme du comportement dans le temps.

Par exemple :

- quand la dégradation a commencé
- si le throughput a scalé comme prévu
- si la latence en queue s’est élargie avant que les échecs apparaissent

Cela rend l’analyse plus diagnostique et moins descriptive.

---

### Corrélation

Mettre en relation les signaux :

- latence vs CPU  
- latence vs I/O  
- erreurs vs charge  

(→ [1.10 Diagnostics and analysis](./01-10-diagnostics-and-analysis.md))

La corrélation aide à identifier quelle ressource ou quel mécanisme soit le plus probablement associé à la dégradation observée.

Toutefois, la corrélation devrait être traitée comme un point de départ analytique, non comme une conclusion finale.

---

### Interprétation

Identifier :

- goulots d’étranglement  
- limites de scalabilité  
- patterns anormaux  

L’interprétation devrait répondre à des questions comme :

- qu’est-ce qui a changé en premier ?
- qu’est-ce qui s’est dégradé après ?
- quelle contrainte est devenue dominante ?
- la dégradation a-t-elle été graduelle, brusque ou dépendante du temps ?

C’est le point où les mesures brutes deviennent compréhension du système.

---

### Reporting

Résumer :

- comportement observé  
- problèmes identifiés  
- recommandations  

Un rapport utile fait plus qu’énumérer des nombres.

Il devrait expliquer :

- ce que le système était censé faire
- ce qu’il a effectivement fait
- où il s’est écarté des attentes
- quelle évidence supporte la conclusion

Cela rend les résultats utilisables pour engineering, operations et tests futurs.

---

### Orientation vers les étapes suivantes

Après l’analyse, définir ce qui devrait arriver ensuite.

Cela peut inclure :

- réexécuter le même test après modifications
- affiner le réalisme de la charge de travail
- recueillir un diagnostic plus profond
- isoler un goulot d’étranglement suspecté
- étendre vers des tests de stress, soak ou capacité

Sans une décision sur les étapes suivantes, l’analyse reste informative mais non utile opérationnellement.

---

### Interprétation pratique

L’analyse post-test est le point où la performance engineering devient prise de décision.

Le but n’est pas seulement de déclarer qu’une métrique a changé, mais d’expliquer :

- pourquoi le changement est important
- ce qu’il implique sur le système
- ce qui devrait être fait ensuite

---

### Idée clé

L’analyse transforme des données brutes en compréhension actionnable.

---

<a id="1114-common-pitfalls"></a>
## 1.11.4 Erreurs communes

### Mal interpréter les moyennes

- les moyennes cachent la latence en queue  
- les percentiles fournissent une vue plus claire  

(→ [1.2.7 Percentiles](./01-02-core-metrics-and-formulas.md#127-percentiles-p50-p95-p99))

Un système peut apparaître sain en moyenne tout en produisant des performances inacceptables pour une fraction significative des requêtes.

C’est l’une des erreurs les plus communes dans l’interprétation des tests.

---

### Ignorer le réalisme de la charge de travail

- des charges de travail non réalistes produisent des résultats trompeurs  
- les patterns de production doivent être approximés  

Une charge de travail synthétique peut être plus facile à générer, mais si elle ne reflète pas le réel mix de requêtes, la concurrence et le comportement des dépendances, les conclusions peuvent ne pas se transférer aux conditions de production.

Le réalisme ne requiert pas une reproduction parfaite, mais requiert une approximation crédible.

---

### Confondre symptôme et cause

- une CPU élevée n’est pas toujours le problème à la racine  
- la latence doit être analysée dans le contexte  

(→ [1.10 Diagnostics and analysis](./01-10-diagnostics-and-analysis.md))

Cette erreur conduit souvent à une optimisation inefficace.

Le symptôme visible peut être seulement la conséquence d’un mécanisme plus profond comme la mise en file d’attente, le blocking ou le ralentissement d’une dépendance.

---

### Négliger les goulots d’étranglement

- optimiser des ressources non limitantes a peu d’effet  
- le focus doit rester sur la contrainte dominante  

(→ [1.8 Resource-level performance](./01-08-resource-level-performance.md))

Ceci est une source fréquente d’effort gaspillé.

Un système peut contenir de nombreuses imperfections, mais seules certaines d’entre elles comptent au point opérationnel courant.

---

### Exécuter des tests sans critères d’acceptation

Un test est difficile à interpréter s’il n’existe pas de définition préalable de comportement acceptable.

Sans seuils explicites, il devient peu clair si le résultat signifie :

- succès
- échec
- dégradation
- risque acceptable

Les nombres de performance sont utiles seulement lorsqu’ils sont comparés à des attentes définies.

---

### Traiter un seul test comme définitif

Une seule exécution de test capture rarement le comportement complet d’un système.

Des exécutions différentes peuvent exposer :

- effets de warm-up
- variabilité des dépendances
- drift à long terme
- comportement de seuil sous des profils de charge différents

Une analyse de performance fiable requiert habituellement comparaison, répétition et validation.

---

### Ignorer la dimension temporelle

Certains problèmes n’apparaissent pas immédiatement.

Un test court peut manquer :

- croissance lente de la mémoire
- accumulation retardée des files
- dégradation graduelle des dépendances
- instabilité du runtime dans le temps

Pour cette raison la durée du test doit correspondre au type de comportement que l’on est en train d’évaluer.

---

### Interprétation pratique

La majorité des erreurs dans le performance testing n’est pas causée par de mauvais outils.

Elle est causée par :

- hypothèses faibles
- visibilité incomplète
- mauvaise interprétation
- manque de discipline méthodologique

Éviter ces erreurs est souvent plus précieux qu’ajouter davantage de détail de mesure.

---

### Idée clé

Des hypothèses incorrectes conduisent à des conclusions incorrectes.

Éviter les erreurs communes est essentiel pour une analyse de performance fiable.