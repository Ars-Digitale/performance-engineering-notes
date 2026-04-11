## 1.8 – Performance au niveau des ressources

<a id="18-resource-level-performance"></a>

Ce chapitre investigue comment les ressources fondamentales du système se comportent sous charge et comment elles peuvent contraindre les performances.

On se concentre sur CPU, I/O, réseau et sur les modalités selon lesquelles des goulots d’étranglement peuvent émerger lorsque l’une des ressources se sature avant les autres.

Comprendre la performance au niveau des ressources est essentiel parce que la dégradation du système est souvent le résultat visible des limites des ressources plutôt que de la seule logique applicative.

## Table des matières

- [1.8.1 Comportement de la CPU](#181-cpu-behavior)
- [1.8.2 I/O et disque](#182-io-and-disk)
- [1.8.3 Comportement du réseau](#183-network-behavior)
- [1.8.4 Saturation des ressources et goulots d’étranglement](#184-resource-saturation-and-bottlenecks)

---

<a id="181-cpu-behavior"></a>
## 1.8.1 Comportement de la CPU

### Définition

La **CPU** est le composant responsable de l’exécution des instructions.

Les performances de la CPU sont déterminées non seulement par la rapidité avec laquelle les instructions sont exécutées, mais par la manière dont l’exécution est schedulée entre des charges de travail concurrentes.

Cette distinction est importante parce que la dégradation liée à la CPU est souvent causée par la pression de scheduling, la mise en file d’attente et les contentions, plutôt que seulement par le coût computationnel.

---

### Utilisation de la CPU vs saturation

L’**utilisation de la CPU** représente quelle part de la capacité de la CPU est utilisée.

Une utilisation élevée n’est pas nécessairement l’indice d’un problème éventuel.

La **saturation de la CPU** se vérifie lorsque :

- il y a plus de travail que la CPU ne peut en exécuter
- les threads sont prêts à exécuter mais ne peuvent pas être schedulés immédiatement

Distinction clé :

- **utilisation élevée** → la CPU est occupée  
- **saturation** → la CPU est surchargée  

Un système peut donc montrer une utilisation élevée de la CPU et continuer malgré tout à se comporter de manière acceptable, tant que le travail exécutable ne s’accumule pas plus vite que la CPU ne peut le traiter.

---

### Scheduling et run queue

Les threads n’exécutent pas de manière continue.

Ils sont schedulés par le système d’exploitation.

À tout moment :

- certains threads sont en **exécution**
- certains sont **en attente** d’exécuter (run queue)

Lorsque le nombre de threads exécutables dépasse le nombre de cœurs CPU disponibles :

- les threads s’accumulent dans la run queue
- les retards de scheduling augmentent

Cela impacte directement la latence (→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md)) et peut être investigué en utilisant les relations de concurrence (→ [1.2.1 Little’s Law (system-level concurrency)](./01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency)).

La run queue est donc un signal critique de pression de la CPU, parce qu’elle montre non seulement que la CPU est occupée, mais qu’il y a du travail qui est en attente d’être exécuté.

---

### Comportement observable (exemple)

Un système sous pression de la CPU montre un nombre croissant de threads exécutables.

```bash
$ vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 7  0      0  12000  45000 300000    0    0     2     1 1200 3000 90  8  2  0  0
 8  0      0  11000  45000 300000    0    0     1     2 1300 3200 92  6  2  0  0
```

Interprétation :

- run queue (`r`) élevée → threads en attente de la CPU  
- CPU idle (`id`) proche de zéro → aucune capacité disponible  
- utilisation de la CPU (`us + sy`) proche de la saturation  

Cela indique qu’il y a des threads prêts à exécuter mais qui ne peuvent pas être schedulés immédiatement par manque de cœurs disponibles (→ [1.6 Concurrency and parallelism](./01-06-concurrency-and-parallelism.md)).

Le point important est que la saturation de la CPU n’est pas définie seulement par des valeurs en pourcentage, mais par la présence de travail exécutable qui ne peut pas progresser immédiatement.

---

### Impact sur les performances

Lorsque la CPU devient saturée :

- les retards de scheduling augmentent
- le temps de réponse augmente
- le throughput peut se stabiliser ou diminuer

Cet effet est non linéaire (→ [1.5.3 Non-linear degradation](./01-05-system-behavior-under-load.md#153-non-linear-degradation)).

Avec l’augmentation de la saturation de la CPU, l’applicatif peut passer (progressivement) plus de temps à attendre d’être schedulé pour l’exécution plutôt qu’à accomplir un travail utile.

---

### Interaction avec la concurrence

La concurrence augmente le nombre de threads actifs.

Avec la croissance de la concurrence :

- plus de threads entrent en compétition pour la CPU
- la longueur de la run queue augmente
- l’overhead de scheduling augmente

Au-delà d’un certain point :

- ajouter des threads réduit les performances au lieu de les améliorer (→ [1.6 Concurrency and parallelism](./01-06-concurrency-and-parallelism.md)).

C’est la raison pour laquelle ajouter plus de travail concurrent ne produit pas toujours un meilleur throughput.

Si le temps CPU devient la ressource limitante, la concurrence se transforme en pression de scheduling.

---

### Implications pratiques

Pour raisonner sur le comportement de la CPU :

- distinguer utilisation et saturation
- observer les threads exécutables, pas seulement le %CPU
- corréler les métriques CPU avec la latence (→ [1.2 Core metrics and formulas](./01-02-core-metrics-and-formulas.md))

Les problèmes CPU ne concernent souvent pas la pure utilisation, mais la **contention pour l’exécution**.

Il est donc possible qu’un système apparaisse “pleinement occupé” sans être instable, ou bien qu’il apparaisse seulement modérément occupé tout en montrant déjà des retards de scheduling.

---

### Interprétation pratique

L’analyse de la CPU devrait se concentrer sur la capacité du système à suivre le rythme du travail exécutable.

Une CPU occupée n’est pas automatiquement un problème.

Une CPU saturée devient un problème lorsque les tâches exécutables s’accumulent, que la latence augmente et que le throughput ne scale plus avec la demande entrante.

---

### Idée clé

**Les performances de la CPU sont limitées par le scheduling**.

Lorsque les threads ne peuvent pas être schedulés immédiatement, la latence augmente même si le système apparaît pleinement utilisé.

---

<a id="182-io-and-disk"></a>
## 1.8.2 I/O et disque

### Définition

Les **opérations d’I/O** impliquent la lecture depuis ou l’écriture vers des dispositifs de stockage.

Contrairement aux opérations CPU, l’I/O est typiquement plus lent et souvent bloquant.

Cela signifie que beaucoup de problèmes de performance qui impliquent l’I/O sont dominés par le temps d’attente plutôt que par le calcul actif.

---

### Latence vs throughput

Les performances de l’I/O ont deux dimensions clés :

- **latence** → temps pour compléter une seule opération  
- **throughput** → nombre d’opérations par unité de temps  

Un throughput élevé ne garantit pas une faible latence.

Un système peut déplacer une grande quantité de données globale tandis que les requêtes individuelles expérimentent malgré tout des temps d’attente significatifs.

---

### Comportement bloquant

Beaucoup d’opérations d’I/O sont bloquantes :

- un thread démarre une opération
- il attend jusqu’à son achèvement

Pendant ce temps :

- le thread n’exécute pas de travail utile
- il peut maintenir des ressources (locks, connexions)

C’est l’une des raisons principales pour lesquelles les goulots d’étranglement d’I/O se propagent souvent en pression sur les thread pools, en mise en file d’attente et en réduction de la concurrence effective.

---

### Effets de mise en file d’attente

Lorsque plusieurs requêtes exécutent de l’I/O :

- les opérations se mettent en file au niveau du dispositif
- le temps d’attente augmente

Avec l’augmentation de la longueur de la file :

- la latence augmente
- la variabilité augmente (→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md))

Cela peut être exprimé comme un retard de mise en file d’attente (→ [1.2.3 Service time vs response time (queueing)](./01-02-core-metrics-and-formulas.md#123-service-time-vs-response-time-queueing)).

Le point important est que le coût de l’I/O n’est pas limité à la durée de l’opération en elle-même.

Il inclut aussi le temps passé à attendre que les opérations précédentes soient complétées.

---

### Comportement observable (exemple)

Un système sous pression d’I/O montre des temps d’attente croissants.

```bash
$ iostat -x 1
Device            r/s     w/s   await   %util
sda              120     80     35.0    95.0
sda              130     90     42.0    98.0
```

Interprétation :

- `await` élevé → les requêtes passent un temps significatif en attente  
- `%util` proche de 100% → le dispositif est saturé  
- latence croissante indique une accumulation de file  

Cela reflète des effets de mise en file d’attente (→ [1.2 Core metrics and formulas](./01-02-core-metrics-and-formulas.md)).

La valeur `await` croissante est particulièrement importante, parce qu’elle révèle souvent que le dispositif n’est pas simplement occupé, mais de plus en plus incapable d’absorber le travail entrant sans retard additionnel.

---

### Impact sur les performances

Lorsque l’I/O devient un goulot d’étranglement :

- la latence des requêtes augmente
- le throughput peut se dégrader
- les threads passent plus de temps à attendre qu’à exécuter

Cela peut réduire la capacité effective du système même lorsque l’utilisation de la CPU reste modérée.

Un système peut donc être limité par l’I/O sans apparaître limité par la CPU.

---

### Interaction avec la concurrence

Plus de requêtes concurrentes conduisent à :

- plus d’opérations d’I/O
- des files sur le dispositif plus longues
- une latence augmentée

Augmenter la concurrence n’améliore pas les performances si le dispositif est saturé (→ [1.6 Concurrency and parallelism](./01-06-concurrency-and-parallelism.md)).

Au-delà d’un certain point, une concurrence additionnelle augmente seulement l’attente et aggrave le temps de réponse.

---

### Implications pratiques

Pour raisonner sur le comportement de l’I/O :

- se concentrer sur la latence (`await`), pas seulement sur le throughput  
- identifier l’accumulation de file  
- corréler l’attente d’I/O avec la latence applicative (→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md))  

Les problèmes d’I/O sont souvent mal compris parce que le throughput peut rester acceptable tandis que la latence se dégrade significativement.

---

### Interprétation pratique

Les performances de l’I/O devraient être évaluées comme un système d’attente.

La question centrale n’est pas seulement combien d’opérations par seconde le dispositif peut supporter, mais pendant combien de temps les opérations attendent lorsque la charge de travail s’intensifie.

Un sous-système de stockage qui se comporte bien à faible concurrence peut se dégrader brutalement lorsque les requêtes commencent à s’accumuler.

---

### Idée clé

**Les performances de l’I/O sont dominées par le temps d’attente**.

Lorsque les files croissent, la latence augmente et la réactivité du système se dégrade.

---

<a id="183-network-behavior"></a>
## 1.8.3 Comportement du réseau

### Définition

Les performances du **réseau** sont déterminées par le transfert de données entre systèmes.

Elles dépendent à la fois de la latence et de la largeur de bande.

Dans les systèmes distribués, le comportement du réseau est souvent un contributeur principal au temps de réponse end-to-end, spécialement lorsque les requêtes traversent plusieurs services.

---

### Latence et round trip

La communication réseau requiert souvent des échanges multiples.

Chaque échange introduit :

- retard de transmission
- retard de propagation
- retard de traitement

Des round trips multiples amplifient la latence totale (→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md)).

Cela est particulièrement important dans les chaînes de requêtes dans lesquelles chaque appel de service dépend de la réponse du précédent.

Même de petits retards peuvent s’accumuler significativement à travers de multiples hops réseau.

---

### Limitations de largeur de bande

La largeur de bande définit la quantité de données qui peuvent être transférées par unité de temps.

Lorsque la largeur de bande est limitée :

- des payloads grands demandent plus de temps pour être transférés
- le throughput devient contraint

La largeur de bande compte donc surtout lorsque la quantité de données transférées devient suffisamment grande pour dominer le temps de communication.

La latence, au contraire, compte aussi pour des payloads petits lorsque beaucoup de round trips sont requis.

---

### Amplification sous charge

Avec l’augmentation de la charge :

- plus de requêtes sont envoyées sur le réseau
- la contention augmente
- des files peuvent se former dans les buffers

Cela conduit à :

- augmentation de la latence
- retards de paquets ou retransmissions (→ [1.5.5 Tail latency amplification](./01-05-system-behavior-under-load.md#155-tail-latency-amplification))

Sous charge, la variabilité du réseau devient particulièrement importante parce que des retards occasionnels peuvent influencer seulement une partie du trafic tout en dégradant malgré tout l’expérience utilisateur globale.

---

### Comportement observable (exemple)

Un système sous pression réseau montre une accumulation de connexions et de files.

```bash
$ ss -s
Total: 1200
TCP:   900 (estab 850, timewait 30)

Transport Total     IP        IPv6
*         1200      -         -
RAW       0         0         0
UDP       50        40        10
TCP       870       800       70
```

Interprétation :

- grand nombre de connexions établies → haute concurrence  
- accumulation de connexions peut indiquer un traitement lent ou des retards réseau  

Un nombre croissant de connexions ouvertes peut indiquer que les requêtes ne se complètent pas assez rapidement, soit parce que les services downstream sont lents, soit parce que le système n’est pas capable de traiter efficacement le travail réseau.

---

### Impact sur les performances

Les contraintes réseau conduisent à :

- augmentation du temps de réponse
- plus grande variabilité
- retards en cascade entre services

Dans les architectures distribuées, ces retards se propagent et s’amplifient souvent parce qu’une seule interaction réseau lente peut retarder de nombreuses opérations dépendantes.

---

### Interaction avec le design du système

Les systèmes distribués amplifient les effets du réseau :

- plusieurs services introduisent plusieurs hops réseau
- la latence s’accumule à travers les appels (→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md))

Un système avec beaucoup de frontières de service peut donc souffrir d’une latence induite par le réseau même lorsque chaque appel individuel apparaît relativement peu coûteux.

---

### Implications pratiques

Pour raisonner sur le comportement du réseau :

- considérer le nombre de round trips  
- observer les patterns de connexion  
- corréler l’activité réseau avec la latence  

Il est aussi important de distinguer entre :

- comportement limité par la largeur de bande
- comportement limité par la latence
- retard induit par les dépendances

Ce sont des problèmes corrélés mais non identiques.

---

### Interprétation pratique

Les performances du réseau ne concernent pas seulement la vitesse à laquelle les bytes se déplacent.

Elles concernent aussi la fréquence à laquelle les systèmes communiquent, combien de dépendances sont impliquées et comment les retards dans un composant influencent les autres.

Dans beaucoup d’architectures de services, réduire des round trips non nécessaires peut améliorer la latence plus efficacement qu’augmenter simplement la largeur de bande.

---

### Idée clé

**Les performances du réseau sont guidées par la latence et par les patterns de communication**.

Sous charge, de petits retards s’accumulent et impactent significativement le temps de réponse.

---

<a id="184-resource-saturation-and-bottlenecks"></a>
## 1.8.4 Saturation des ressources et goulots d’étranglement

### Définition

Un **goulot d’étranglement** (bottleneck) est la ressource qui limite les performances du système.

La saturation se vérifie lorsque cette ressource opère à pleine capacité ou dans des intervalles proches de sa capacité limite.

C’est le point auquel une charge de travail additionnelle ne se traduit plus par un throughput utile proportionnel.

---

### Identifier la ressource limitante

À tout moment, les performances du système sont contraintes par une ressource dominante :

- CPU
- I/O
- réseau
- mémoire (indirectement via GC → [1.7 Runtime and memory model](./01-07-runtime-and-memory-model.md))

Identifier cette ressource est essentiel.

Sans identifier la réelle ressource limitante, les efforts d’optimisation ciblent souvent les symptômes plutôt que les causes.

---

### Principe du goulot d’étranglement unique

Même dans les systèmes complexes :

- les performances sont typiquement limitées par une contrainte primaire

Améliorer des ressources non limitantes a peu d’effet.

Ce principe est l’une des raisons pour lesquelles la performance engineering doit rester orientée système.

Beaucoup de ressources peuvent apparaître actives, mais une seule, généralement, détermine la limite de capacité courante.

---

### Effets en cascade

Lorsqu’une ressource devient saturée :

- les files s’accumulent
- la latence augmente
- les composants upstream ralentissent

Cela peut se propager à travers le système (→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md)).

Un goulot d’étranglement local peut donc devenir un problème étendu à l’ensemble du système, puisque les retards se diffusent vers appelants, workers, pools et services dépendants.

---

### Interaction entre les ressources

Les ressources ne sont pas indépendantes :

- un I/O lent augmente le temps d’attente des threads → influence le scheduling de la CPU (→ [1.8.1 CPU behavior](#181-cpu-behavior))  
- les retards réseau augmentent la durée des requêtes → augmentent l’utilisation de la mémoire (→ [1.7 Runtime and memory model](./01-07-runtime-and-memory-model.md))  
- la saturation de la CPU retarde le traitement → augmente la taille des files (→ [1.2.1 Little’s Law (system-level concurrency)](./01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency))  

Cette interaction explique pourquoi les goulots d’étranglement se déplacent souvent ou apparaissent couplés avec la variation des conditions de charge de travail.

Le facteur limitant peut changer lorsqu’une partie du système est améliorée ou lorsque la composition de la charge de travail change.

---

### Patterns observables

Signes communs de goulots d’étranglement :

- CPU proche de la saturation avec run queue élevée  
- latence I/O en augmentation avec utilisation élevée du dispositif  
- retards réseau avec comptage de connexions croissant  

Ces patterns sont utiles parce qu’ils relient les symptômes au niveau du système avec des comportements spécifiques des ressources.

Ils aident à réduire l’ambiguïté diagnostique.

---

### Impact sur le comportement du système

Lorsqu’un goulot d’étranglement est atteint :

- le throughput cesse d’augmenter
- la latence croît rapidement
- le système devient instable sous charge supplémentaire

Cela correspond à :

- dégradation non linéaire (→ [1.5.3 Non-linear degradation](./01-05-system-behavior-under-load.md#153-non-linear-degradation))  
- effondrement du throughput (→ [1.5.4 Throughput collapse](./01-05-system-behavior-under-load.md#154-throughput-collapse))  

À ce stade, une demande additionnelle aggrave souvent la situation au lieu d’augmenter l’output utile.

---

### Implications pratiques

Pour analyser les performances :

- identifier la ressource saturée  
- corréler les métriques de ressource avec la latence  
- concentrer l’optimisation sur le facteur limitant  

Un diagnostic correct dépend donc de la compréhension non seulement de quelles ressources sont occupées, mais de laquelle d’entre elles est en train de déterminer actuellement le comportement de l’ensemble du système.

---

### Interprétation pratique

L’analyse des goulots d’étranglement est le pont entre observation et action.

Le but n’est pas simplement de collecter des métriques de CPU, d’I/O ou de réseau, mais de déterminer quelle ressource contraint le travail utile au point opérationnel courant.

Une fois cette ressource identifiée, l’optimisation devient significative.

---

### Idée clé

**Les performances du système sont limitées par son goulot d’étranglement**.

Comprendre quelle ressource est saturée est essentiel pour expliquer et améliorer le comportement sous charge.