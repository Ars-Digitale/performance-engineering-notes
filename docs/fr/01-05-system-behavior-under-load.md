# 1.5 – Comportement du système sous charge

<a id="15-system-behavior-under-load"></a>

Ce chapitre analyse le comportement des systèmes à mesure que la charge de travail (workload) augmente et à l’approche de leurs limites de capacité.

Il se concentre sur les principaux mécanismes pouvant causer une dégradation sous charge, y compris **saturation**, **mise en file**, **perte de throughput** et **amplification de la tail latency**.

Ces concepts sont centraux dans la performance engineering puisqu’ils analysent pourquoi les systèmes peuvent paraître stables à faible charge et devenir instables à proximité de leurs limites de capacité.

## Table des matières

- [1.5.1 Charge vs capacité](#151-load-vs-capacity)
- [1.5.2 Saturation et mise en file](#152-saturation-and-queueing)
- [1.5.3 Dégradation non linéaire](#153-non-linear-degradation)
- [1.5.4 Effondrement du throughput](#154-throughput-collapse)
- [1.5.5 Amplification de la tail latency](#155-tail-latency-amplification)

---

<a id="151-load-vs-capacity"></a>
## 1.5.1 Charge vs capacité

### Définition

Un système fonctionne sous une charge de travail, mais possède une capacité bien définie.

- **Charge** : la quantité de travail appliquée au système (ex. requêtes par seconde, utilisateurs concurrents)
- **Capacité** : la quantité maximale de travail que le système peut gérer tout en restant stable

Comprendre la relation entre charge et capacité est fondamental en performance engineering.

Elle définit l’enveloppe opérationnelle du système et détermine quand le comportement est prévisible et quand la dégradation commence.

---

### Comportement du système

À faible charge :

- les ressources sont sous-utilisées
- le temps de réponse est stable
- le throughput augmente linéairement avec la charge

À mesure que la charge augmente :

- l’utilisation des ressources croît
- la contention commence à apparaître
- le temps de réponse augmente

Lorsque la charge s’approche de la capacité :

- des files se forment
- la latence augmente rapidement
- le comportement du système devient moins prévisible

Cette transition est l’un des aspects les plus importants de l’analyse des performances.

Un système passe rarement directement de « stable » à « problématique ».
  
Il traverse généralement une région d’instabilité croissante et d’efficacité réduite.

---

### La capacité n’est pas une valeur fixe

La capacité est souvent comprise à tort comme un ensemble restreint de valeurs.

En réalité, elle dépend de :

- composition du workload (cas d’usage et distribution)
- configuration des ressources (CPU, mémoire, pools)
- état du système (cold vs warm, effets du cache)
- dépendances externes (bases de données, services)

Un système peut gérer :

- 100 req/s pour des requêtes simples
- mais seulement 20 req/s pour des requêtes complexes

La capacité est donc toujours contextuelle.

Elle doit être comprise en relation avec un workload spécifique, un environnement spécifique et des critères d’acceptation.

---

### Capacité effective

La capacité doit être définie sous des contraintes bien précises.

Critères typiques :

- latence dans des limites acceptables (ex. p95)
- taux d’erreur sous le seuil
- utilisation stable des ressources

La charge maximale qui satisfait ces conditions est la **capacité effective**.

C’est cette capacité qui compte du point de vue opérationnel.

Un maximum théorique qui produit une latence inacceptable ou de l’instabilité n’est pas utile dans la pratique.

---

### Implication pratique

La capacité ne peut pas être supposée a priori.

Elle doit être :

- mesurée sous un workload réaliste
- validée par des tests
- surveillée dans le temps

Augmenter la charge au-delà de la capacité effective conduit à :

- dégradation rapide
- comportement instable
- rupture potentielle du système

Cela peut aussi réduire la capacité du système à récupérer rapidement après une surcharge.

---

### Lien avec les concepts précédents

La relation entre charge, latence et concurrence est formalisée par :

→ [1.2.1 Loi de Little](01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency)

À mesure que la charge augmente :

- la concurrence augmente
- le temps d’attente croît
- le temps de réponse se dégrade

Cette relation constitue l’un des fondements permettant de comprendre le comportement sous charge.

---

### Interprétation pratique

Charge et capacité ne devraient jamais être traitées comme des étiquettes abstraites.

Elles déterminent :

- si le système fonctionne avec de la headroom
- s’il est probable que de la mise en file (queueing) apparaisse
- quelle marge existe avant que l’instabilité apparaisse

En performance engineering, savoir qu’un système « fonctionne » n’est pas suffisant.

Ce qui compte, c’est de savoir dans quelles conditions de charge il reste stable et à quel point il est proche de sa capacité effective.

---

### Idée clé

Un système ne se casse pas lorsqu’il atteint sa capacité.

Il commence à se dégrader avant ce point.

L’objectif de la performance engineering est d’identifier :

- où se trouvent les limites de capacité
- comment le système se comporte à leur proximité
- quelle marge est requise

--- 

<a id="152-saturation-and-queueing"></a>
## 1.5.2 Saturation et mise en file

### Définition

La **saturation** se produit lorsqu’une ressource est occupée la majeure partie du temps ou tout le temps.

La **mise en file** (queueing) se produit lorsque le travail entrant ne peut pas être traité immédiatement et doit être placé en attente : en file.

Ces deux phénomènes sont étroitement corrélés.

Ils figurent parmi les mécanismes les plus importants à la base de la dégradation des performances dans les systèmes réels.

---

### Saturation de la ressource

Une ressource devient saturée lorsque :

- son utilisation s’approche de la limite
- elle a peu ou pas de temps d’inactivité

Exemples typiques :

- CPU proche de 100%
- thread pool entièrement occupé
- connection pool épuisé

À ce stade :

- les nouvelles requêtes ne peuvent pas être traitées immédiatement
- elles doivent attendre

La saturation ne signifie pas nécessairement qu’il y a problème.

Elle signifie que le système a perdu sa marge de traitement et n’est plus en mesure d’absorber du travail supplémentaire sans délai.

---

### Formation de la file

Lorsque les requêtes de travail arrivent plus vite qu’elles ne peuvent être traitées :

- une file se forme
- le temps d’attente augmente

Cela affecte le temps de réponse :

- le temps de service reste le même
- le temps d’attente croît

→ [1.2.3 Temps de service vs temps de réponse](01-02-core-metrics-and-formulas.md#123-service-time-vs-response-time-queueing)

La mise en file est donc la conséquence visible d’une capacité de traitement insuffisante sur une ressource donnée.

---

### Effet non linéaire

La mise en file ne croît pas linéairement.

À mesure que l’utilisation augmente :

- le temps d’attente croît lentement au début
- puis augmente rapidement
- enfin il domine le temps de réponse

De petites augmentations de charge peuvent provoquer de grandes augmentations de latence.

Cela explique pourquoi les systèmes paraissent souvent stables pendant longtemps puis se dégradent brusquement à proximité du seuil de saturation.

---

### Lien avec l’utilisation

L’utilisation joue un rôle central :

→ [1.2.2 Loi dutilisation](01-02-core-metrics-and-formulas.md#122-utilization-law-resource-level-busy-time)

Lorsque l’utilisation s’approche de sa limite :

- la probabilité d’attente augmente
- les files croissent
- la latence devient instable

Le point important n’est pas qu’une ressource soit « occupée », mais que lorsqu’elle est occupée de façon persistante, le travail entrant commence à s’accumuler.

---

### Implications pratiques

La mise en file est souvent la cause principale de la dégradation des performances.

Les symptômes incluent :

- augmentation soudaine du temps de réponse
- tail latency élevée (p95, p99)
- files croissantes (threads, connexions, requêtes)

Même si :

- le CPU n’est pas complètement saturé
- la latence moyenne paraît acceptable

la mise en file peut néanmoins être la source dominante du retard.

Cela est particulièrement courant dans les systèmes avec des pools partagés, des opérations bloquantes ou des goulets d’étranglement au niveau des dépendances.

---

### Exemple

Un système traite des requêtes avec :

- temps de service = 10 ms

À faible charge :

- les requêtes sont traitées immédiatement
- temps de réponse ≈ 10 ms

À mesure que la charge augmente :

- les requêtes commencent à attendre
- le temps de réponse devient :

  10 ms (service) + temps d’attente

À forte charge :

- le temps d’attente domine
- le temps de réponse augmente rapidement

Cet exemple vise à illustrer pourquoi la croissance de la latence sous charge est souvent davantage causée par l’attente que par le travail lui-même.

---

### Interprétation pratique

La saturation est la condition.

La mise en file (queueing) est la conséquence.

Le système ne ralentit pas parce que chaque requête exige davantage de calcul, mais parce que davantage de requêtes sont en concurrence pour les mêmes ressources limitées.

Cette distinction est essentielle :

- optimiser le temps de service peut aider
- mais réduire la mise en file est souvent encore plus important

---

### Idée clé

La saturation ne casse pas immédiatement le système.

Elle introduit de la mise en file.

La mise en file augmente le temps d’attente.

Le temps d’attente domine le temps de réponse.

C’est le mécanisme principal à la base de la dégradation des performances sous charge.

---

<a id="153-non-linear-degradation"></a>
## 1.5.3 Dégradation non linéaire

### Définition

Les performances du système ne se dégradent pas linéairement à mesure que la charge augmente.

Au contraire, la dégradation suit une évolution non linéaire, en particulier à proximité des limites de capacité.

Cela signifie que la relation entre charge et temps de réponse est souvent d’abord régulière, puis fortement instable près de la saturation.

---

### Comportement linéaire vs non linéaire

À charge faible ou modérée :

- le throughput augmente proportionnellement à la charge
- la latence reste relativement stable

Dans cette région, le système paraît prévisible.

---

Lorsque la charge s’approche de la capacité :

- de petites augmentations de charge produisent de grandes augmentations de latence
- la variabilité augmente
- le comportement devient instable

Cela marque la transition vers la dégradation non linéaire.

Le système ne se comporte plus de manière proportionnelle à la demande.

Il commence à réagir de manière disproportionnée au travail supplémentaire.

---

### Cause racine

La dégradation non linéaire est principalement causée par :

- effets de mise en file (→ [1.5.2 Saturation et mise en file](#152-saturation-and-queueing))
- utilisation élevée des ressources
- contention entre requêtes

À mesure que l’utilisation augmente :

- le temps d’attente croît de manière disproportionnée
- le temps de réponse est dominé par les délais plutôt que par le service

Cela explique pourquoi la dégradation s’accélère souvent brusquement au lieu de croître progressivement.

---

### Effets observables

Les symptômes typiques incluent :

- augmentation rapide de la latence p95 et p99
- élargissement de l’écart entre latence moyenne et tail latency
- augmentation de la variance dans les temps de réponse
- erreurs intermittentes ou timeouts

Ces effets apparaissent souvent soudainement.

Le système peut sembler sain juste avant d’entrer dans une région de grave instabilité.

---

### Intuition trompeuse

Il est courant de supposer :

- « Si le système gère 80 req/s, il devrait gérer 100 req/s avec une latence légèrement plus élevée »

En réalité :

- les performances peuvent rester stables jusqu’à un certain point
- puis se dégrader brutalement au-delà de ce point

Il n’existe souvent pas de transition graduelle.

Cela constitue l’une des erreurs les plus fréquentes dans le capacity planning et dans les attentes de performance.

---

### Exemple

Un système se comporte comme suit :

- jusqu’à 70 req/s → latence stable (~100 ms)
- à 80 req/s → la latence augmente à 150 ms
- à 90 req/s → la latence monte à 400 ms
- à 100 req/s → le système devient instable

La dégradation n’est pas proportionnelle à la charge.

Les derniers incréments de charge ont un effet beaucoup plus important que les précédents.

---

### Implication pratique

Le capacity planning doit tenir compte du comportement non linéaire.

Faire fonctionner un système près de ses limites conduit à :

- latence imprévisible
- performances instables
- mauvaise expérience utilisateur

Les systèmes devraient fonctionner avec une marge de sécurité raisonnable en dessous de la capacité.

Cette marge n’est pas optionnelle.

C’est elle qui permet au système d’absorber la variabilité normale sans entrer dans un comportement instable.

---

### Lien avec les concepts précédents

La dégradation non linéaire est l’effet visible de :

- utilisation croissante (→ [1.2.2 Loi dutilisation](01-02-core-metrics-and-formulas.md#122-utilization-law-resource-level-busy-time))
- mise en file croissante (→ [1.5.2 Saturation et mise en file](#152-saturation-and-queueing))

Elle est donc une conséquence au niveau système de mécanismes déjà introduits dans les sections précédentes.

---

### Interprétation pratique

La dégradation non linéaire explique pourquoi les systèmes ne devraient pas être exploités trop près de leur maximum théorique.

Une marge opérationnelle adéquate peut faire la différence entre :

- performances stables
- dégradation imprévisible

Cela explique aussi pourquoi la seule utilisation moyenne des ressources est souvent trompeuse dans l’évaluation de la sécurité en production.

---

### Idée clé

La dégradation des performances n’est pas graduelle.

Elle s’accélère à mesure que le système s’approche de ses propres limites.

Comprendre cette non-linéarité est essentiel pour éviter d’exploiter des systèmes trop près de leurs limites de capacité.

---

<a id="154-throughput-collapse"></a>
## 1.5.4 Effondrement du throughput

### Définition

L’**effondrement du throughput** se produit lorsque l’augmentation de la charge n’augmente plus le throughput et peut même le réduire.

Au lieu de scaler avec la demande, le système devient moins efficace à mesure que la charge augmente.

C’est l’un des signes les plus clairs que le système fonctionne au-delà de sa propre capacité effective.

---

### Comportement attendu vs effondrement

Dans des conditions normales :

- l’augmentation de la charge augmente le throughput
- jusqu’à ce que le système s’approche des limites de capacité

Cependant, au-delà d’un certain point :

- le throughput cesse d’augmenter
- peut se stabiliser ou diminuer
- la latence augmente significativement

C’est ce qu’on appelle l’effondrement du throughput.

Davantage de travail entrant ne se traduit pas par autant de travail achevé.

---

### Causes racines

L’effondrement du throughput est typiquement causé par :

- mise en file excessive
- contention sur des ressources partagées
- thrashing des ressources (CPU, mémoire, I/O)
- amplification des retries
- scheduling ou locking inefficients

Lorsque le système entre en surcharge :

- davantage de temps est dépensé à gérer la contention qu’à effectuer du travail utile
- la capacité de traitement effective diminue

C’est la raison clé pour laquelle une demande plus élevée peut produire un output plus faible.

---

### Contribution de la mise en file

Lorsque les files croissent :

- les requêtes attendent plus longtemps
- les ressources du système restent occupées
- les nouvelles requêtes ajoutent de la pression sans augmenter le travail achevé

La mise en file peut donc :

- augmenter la latence
- réduire le throughput effectif

Cela est particulièrement visible lorsque le système passe de plus en plus de temps à gérer l’arriéré au lieu de faire de réels progrès.

---

### Contention et thrashing

À forte charge :

- les threads sont en concurrence pour des ressources partagées
- les locks deviennent des hotspots
- le context switching augmente
- la localité du cache se dégrade

Dans des cas extrêmes :

- le système passe plus de temps à coordonner qu’à traiter

Cela conduit à une réduction du throughput.

Le système reste actif, mais son activité devient de plus en plus improductive.

---

### Amplification des retries

Les défaillances sous charge déclenchent souvent des retries.

Cela crée une charge supplémentaire :

- les requêtes ayant échoué sont retentées
- davantage de travail est généré
- la pression augmente encore

Cette boucle de rétroaction peut :

- accélérer l’effondrement
- rendre la récupération difficile

Le comportement des retries n’est donc pas seulement une réponse aux symptômes, mais aussi une cause fréquente de l’aggravation de la surcharge.

---

### Effets observables

Les symptômes typiques incluent :

- throughput qui se stabilise ou diminue malgré l’augmentation de la charge
- forte augmentation de la latence
- augmentation des taux d’erreur (timeouts, 5xx)
- comportement instable ou oscillant

À ce stade, le système peut paraître occupé mais il ne scale plus de manière utile.

---

### Exemple

Un système se comporte comme suit :

- 50 req/s → 50 req/s de throughput
- 80 req/s → 80 req/s de throughput
- 100 req/s → 90 req/s de throughput
- 120 req/s → 70 req/s de throughput

L’augmentation de la charge réduit le throughput effectif.

C’est un indicateur direct du fait que la surcharge est en train « d’endommager » le travail utile.

---

### Implication pratique

L’effondrement du throughput indique que le système fonctionne au-delà de sa propre capacité effective.

À ce point :

- ajouter davantage de charge aggrave les performances
- le système peut devenir instable

La mitigation exige :

- réduire la charge
- supprimer les goulets d’étranglement
- améliorer l’efficacité des ressources

Dans de nombreux cas, la première action corrective n’est pas l’optimisation mais la protection : rate limiting, admission control ou contrôle des retries.

---

### Lien avec les concepts précédents

L’effondrement du throughput est le résultat de :

- dégradation non linéaire (→ [3.5.3 Dégradation non linéaire](#353-non-linear-degradation))
- saturation et mise en file (→ [3.5.2 Saturation et mise en file](#352-saturation-and-queueing))

Il peut donc être compris comme un stade avancé du comportement en surcharge.

---

### Interprétation pratique

Un système ne traite pas toujours davantage de travail lorsqu’on lui en applique davantage.

À un certain point, le travail supplémentaire devient destructeur plutôt que productif.

Reconnaître cette transition est essentiel en performance engineering, parce qu’elle marque la différence entre charge élevée et surcharge.

---

### Idée clé

Au-delà d’un certain point, la charge supplémentaire réduit la capacité du système à traiter les requêtes.

Comprendre l’effondrement du throughput est essentiel pour éviter des conditions de surcharge.

---

<a id="155-tail-latency-amplification"></a>
## 1.5.5 Amplification de la tail latency

### Définition

L’**amplification de la tail latency** se réfère à l’augmentation disproportionnée des temps de réponse à haut percentile (ex. p95, p99) sous charge.

Alors que la latence moyenne peut paraître acceptable, un sous-ensemble de requêtes devient significativement plus lent.

Cet effet constitue l’un des indicateurs les plus importants d’une expérience utilisateur dégradée et d’une instabilité cachée.

---

### Percentiles vs moyenne

La latence moyenne masque la variabilité.

Les percentiles révèlent la distribution :

- p50 représente la requête typique
- p95 et p99 représentent les requêtes les plus lentes

Sous charge :

- la latence moyenne peut augmenter modérément
- la tail latency peut augmenter drastiquement

→ [1.2.7 Percentiles](01-02-core-metrics-and-formulas.md#127-percentiles-p50-p95-p99)

Pour cette raison, les seules moyennes ne suffisent pas pour évaluer la qualité réelle des performances.

---

### Causes racines

L’amplification de la tail latency est principalement pilotée par :

- retards de mise en file
- contention sur des ressources partagées
- distribution hétérogène du workload
- variabilité des dépendances (ex. base de données, services externes)

Même de petits retards dans certains composants peuvent :

- se propager à travers le système
- amplifier la latence end-to-end

La tail latency est donc souvent un effet émergent, pas seulement local.

---

### Effet dans les systèmes distribués

Dans les systèmes comportant plusieurs composants :

- une requête dépend souvent de plusieurs services
- la latence globale dépend du composant le plus lent

À mesure que le nombre de dépendances augmente :

- la probabilité d’une requête lente augmente
- la tail latency devient plus marquée

C’est l’une des raisons pour lesquelles la tail latency est particulièrement importante dans les architectures distribuées.

---

### Sous charge

À mesure que la charge augmente :

- les files croissent
- la contention augmente
- la variabilité s’élargit

Cela conduit à :

- un élargissement de l’écart entre moyenne et p95/p99
- des temps de réponse imprévisibles pour un sous-ensemble d’utilisateurs

Le système peut donc paraître globalement stable tout en produisant malgré tout une expérience inacceptable pour une fraction significative des requêtes.

---

### Effets observables

Les symptômes typiques incluent :

- latence moyenne stable avec p95/p99 dégradés
- réponses lentes intermittentes
- timeouts qui n’affectent qu’une fraction des requêtes

Cela peut être trompeur :

- le système paraît « globalement correct »
- mais l’expérience utilisateur est dégradée

Cela explique pourquoi les métriques de queue sont essentielles dans le performance testing et dans la surveillance en production.

---

### Exemple

Un système montre :

- latence moyenne = 120 ms
- latence p95 = 180 ms (acceptable)
- latence p99 = 1200 ms (problématique)

La majorité des requêtes est rapide, mais un petit pourcentage est très lent.

Dans de nombreux systèmes orientés utilisateur, ce petit pourcentage suffit à créer une insatisfaction visible ou des violations des SLO.

---

### Implication pratique

L’évaluation des performances doit prendre en compte la **tail latency**.

S’appuyer sur les moyennes peut :

- masquer des problèmes critiques
- sous-estimer l’impact sur les utilisateurs

Les systèmes devraient être conçus et testés pour :

- contrôler le comportement de queue
- limiter la variabilité sous charge

Cela est particulièrement important pour les systèmes distribués, les API et les applications interactives.

---

### Lien avec les concepts précédents

L’amplification de la tail latency est une conséquence de :

- mise en file (→ [1.5.2 Saturation et mise en file](#152-saturation-and-queueing))
- dégradation non linéaire (→ [1.5.3 Dégradation non linéaire](#153-non-linear-degradation))
- interactions et dépendances système

Elle est donc l’une des manifestations les plus visibles du stress du système sous charge.

---

### Interprétation pratique

Les performances ne sont pas définies par la requête moyenne.

Elles sont définies par la prévisibilité des temps de réponse, en particulier pour les requêtes les plus lentes.

Un système avec une latence moyenne acceptable mais un comportement p95/p99 médiocre n’est pas réellement stable du point de vue utilisateur ou opérationnel.

---

### Idée clé

Les performances ne sont pas définies par la requête moyenne.

Elles sont définies par la manière dont le système se comporte pour les requêtes les plus lentes.

Contrôler la tail latency est essentiel pour des systèmes prévisibles et fiables.