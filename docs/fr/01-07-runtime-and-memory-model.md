## 1.7 – Runtime et modèle mémoire

<a id="17-runtime-and-memory-model"></a>

Ce chapitre explique comment les "managed runtime" organisent la mémoire, allouent les objets, récupèrent la mémoire qui n’est plus utilisée et se comportent dans une situation de mémoire "sous pression".

On se concentre sur les mécanismes de runtime et de mémoire qui influencent directement la latence, la stabilité et le throughput sous charge.

Comprendre ces mécanismes est essentiel parce que de nombreux problèmes de performance ne sont pas causés seulement par des limites de CPU ou d’I/O, mais par la manière dont la mémoire est allouée, maintenue et récupérée dans le temps.

## Table des matières

- [1.7.1 Structure de la mémoire (heap, stack)](#171-memory-structure-heap-stack)
- [1.7.2 Allocation et cycle de vie des objets](#172-allocation-and-object-lifecycle)
- [1.7.3 Garbage collection (conceptuelle)](#173-garbage-collection-conceptual)
- [1.7.4 Pression mémoire et performance](#174-memory-pressure-and-performance)

---

<a id="171-memory-structure-heap-stack"></a>
## 1.7.1 Structure de la mémoire (heap, stack)

### Modèles de gestion de la mémoire

Des systèmes différents utilisent des stratégies de gestion de la mémoire différentes.

Deux approches communes sont :

- **gestion manuelle de la mémoire**  
  La mémoire est allouée et libérée explicitement par le programmeur (ex. C, C++)

- **mémoire gérée**  
  La mémoire est allouée automatiquement et récupérée par le runtime (ex. Java, .NET)

Ce guide se concentre sur les **systèmes à mémoire gérée**, où :

- les objets sont alloués dynamiquement
- la mémoire est récupérée automatiquement par un ou plusieurs threads dédiés des machines virtuelles respectives (garbage collection)

Cette distinction est importante parce que le comportement des performances change significativement selon que le cycle de vie de la mémoire est contrôlé directement par le programmeur ou indirectement par le runtime.

---

### Définition

La mémoire est organisée en différentes régions avec des rôles bien distincts.

Les deux zones les plus importantes pour le discours sur les performances sont :

- **heap**
- **stack**

Ces deux régions supportent des aspects différents de l’exécution du programme et ont des implications de performance très différentes.

---

### Heap

Le heap est une zone de mémoire partagée utilisée pour l’allocation dynamique.

Dans les runtimes gérés (comme Java) :

- les objets sont alloués sur le heap
- la mémoire est gérée par le runtime
- la garbage collection récupère les objets non utilisés

Implications :

- l’utilisation de la mémoire croît avec le taux d’allocation
- la garbage collection impacte les performances
- l’accès partagé peut introduire de la contention

Le heap n’est donc pas seulement une zone de stockage, mais une section centrale par rapport au comportement du runtime sous charge.

---

### Stack

Chaque thread a son propre stack.

Le stack mémorise :

- les appels de méthode (call frame)
- les variables locales
- les valeurs intermédiaires

Caractéristiques :

- privé pour chaque thread
- croît et diminue pendant l’exécution
- typiquement beaucoup plus petit que le heap

Puisque le stack est privé au thread, l’accès est simple et efficace, mais le nombre de threads influe directement sur l’utilisation totale de la mémoire du stack.

---

### Heap vs stack

| Aspect            | Heap                         | Stack                        |
|------------------|------------------------------|------------------------------|
| Scope            | Partagé entre threads        | Privé par thread             |
| Allocation       | Dynamique (objets)           | Automatique (appels méthode) |
| Durée            | Gérée par le runtime         | Liée à l’exécution méthode   |
| Performance      | Plus complexe                | Très rapide                  |
| Impact mémoire   | Global                       | Par thread                   |

---

### Interaction avec les threads

Chaque thread :

- a son propre stack
- partage le heap

Cela crée un modèle dans lequel :

- l’exécution est isolée par thread (stack)
- les données sont partagées entre threads (heap)

Cette interaction est une source de :

- contention (objets partagés)
- overhead de coordination

Cela explique aussi pourquoi la concurrence et le comportement au niveau de la mémoire sont étroitement corrélés dans les systèmes gérés par le runtime.

---

### Implications sur les performances

Heap :

- allocation excessive → augmentation de l’activité GC
- heap grand → cycles de garbage collection plus longs
- accès partagé → contention potentielle

Stack :

- beaucoup de threads → plus grande utilisation totale de la mémoire (un stack par thread)
- chaînes d’appels profondes → augmentation de l’utilisation du stack
- stack overflow → échec dans des cas extrêmes

Ces implications deviennent particulièrement importantes lorsque le système est sous charge soutenue ou à haute concurrence.

---

### Interprétation pratique

Heap et stack ne sont pas seulement des détails d’implémentation.

Ils influencent :

- la manière dont les données sont partagées
- la manière dont le travail est exécuté
- la manière dont la mémoire croît sous concurrence
- l’endroit où apparaît l’overhead du runtime

Un système avec beaucoup de threads et des allocations fréquentes stresse les deux régions de manière différente : le stack à travers le nombre de threads et la profondeur des appels, le heap à travers la création et la rétention des objets.

---

### Idée clé

Le heap mémorise des données partagées.

Le stack supporte l’exécution.

Les performances dépendent de la manière dont ces deux éléments interagissent sous charge.

---

### Lien avec les concepts précédents

Le comportement de la mémoire impacte directement :

- l’exécution des threads (→ [1.6.2 Threads and execution model](01-06-concurrency-and-parallelism.md#162-threads-and-execution-model))
- la contention (→ [1.6.3 Contention and synchronization](01-06-concurrency-and-parallelism.md#163-contention-and-synchronization))
- la latence sous charge (→ [1.5 System behavior under load](01-05-system-behavior-under-load.md))

Pour cette raison le modèle de runtime et de mémoire ne peut pas être analysé séparément de la concurrence et du comportement du système.

---

<a id="172-allocation-and-object-lifecycle"></a>
## 1.7.2 Allocation et cycle de vie des objets

### Définition

Dans les systèmes à mémoire gérée, les objets sont créés dynamiquement et vivent pendant une certaine période de temps avant d’être récupérés par le runtime.

La manière dont les objets sont alloués et combien de temps ils vivent a un impact direct sur les performances.

Le comportement d’allocation n’est donc pas seulement une question de mémoire, mais aussi une question de latence et de stabilité.

---

### Allocation

L’allocation est le processus de création de nouveaux objets en mémoire.

Dans la plupart des runtimes gérés :

- l’allocation se produit sur le heap
- elle est conçue pour être rapide et efficace
- elle se produit très fréquemment dans les applications typiques

Exemples d’allocation :

- création d’objets request
- construction de structures de données
- traitement de résultats intermédiaires

Dans les systèmes à haut throughput, l’allocation est souvent continue et étroitement liée à l’intensité de la charge de travail.

---

### Taux d’allocation

Le **taux d’allocation** est la quantité de mémoire allouée par unité de temps.

C’est un facteur clé de performance.

Un taux d’allocation élevé signifie :

- plus d’objets créés
- plus grand churn mémoire
- plus grande pression sur le runtime

Même si les allocations individuelles sont rapides, de grands volumes impactent le système.

C’est l’une des raisons pour lesquelles “allocation rapide” ne signifie pas automatiquement “faible overhead mémoire”.

---

### Cycle de vie des objets

Les objets ne vivent pas tous pendant la même durée.

Des catégories typiques incluent :

- **objets à courte durée de vie**  
  créés et écartés rapidement (ex. données temporaires de request)

- **objets à durée de vie moyenne**  
  survivent pendant un certain temps pendant le traitement

- **objets à longue durée de vie**  
  restent en mémoire pendant des périodes étendues (ex. cache, état partagé)

Comprendre la durée de vie des objets est essentiel pour raisonner sur le comportement de la mémoire.

Cette caractéristique détermine quelle quantité de mémoire reste active dans le temps et comment le runtime doit organiser le travail de récupération.

---

### Patterns d’allocation

Les systèmes réels tendent à montrer des patterns comme :

- beaucoup d’objets à courte durée de vie par request
- objets à longue durée de vie occasionnels
- bursts d’allocation sous charge

Ces patterns déterminent :

- l’utilisation de la mémoire
- le comportement de la garbage collection
- la stabilité des performances

Les patterns d’allocation sont souvent plus informatifs que les événements d’allocation isolés, parce que le runtime réagit au comportement agrégé dans le temps.

---

### Impact sur les performances

L’allocation en elle-même est habituellement rapide.

L’impact principal dérive de :

- l’augmentation de l’utilisation de la mémoire
- la pression sur la garbage collection

Un taux d’allocation élevé peut conduire à :

- des cycles de garbage collection plus fréquents
- une augmentation de la latence
- des pauses imprévisibles

Le point important est que le coût de la mémoire est souvent indirect : le système paie non seulement pour créer des objets, mais pour gérer les conséquences de la création d’un grand nombre d’entre eux.

---

### Sous charge

Avec l’augmentation de la charge :

- plus de requêtes sont traitées
- plus d’objets sont créés
- le taux d’allocation augmente

Cela amplifie :

- la pression mémoire
- l’activité de garbage collection
- la variabilité de la latence

Un système stable à faible charge peut donc devenir sensible à la mémoire avec l’augmentation du volume de requêtes, même si la logique de chaque requête reste inchangée.

---

### Interaction avec la concurrence

L’allocation est souvent exécutée par plusieurs threads.

Cela peut conduire à :

- de la contention sur les structures mémoire
- une augmentation de l’overhead de coordination
- des patterns d’utilisation de la mémoire non uniformes

Dans les systèmes à haute concurrence :

- le taux d’allocation croît avec la concurrence
- la mémoire devient un goulet d’étranglement partagé

C’est l’une des manières dont la concurrence et le comportement de la mémoire se renforcent mutuellement sous charge.

---

### Implications pratiques

Pour raisonner sur les performances il est important de considérer :

- combien d’objets sont créés par request
- combien de temps ils vivent
- comment le taux d’allocation change sous charge

Comprendre l’allocation est essentiel pour :

- expliquer le comportement de la latence
- identifier des goulets d’étranglement
- prévoir les limites du système

Cela aide aussi à distinguer entre des problèmes causés par le calcul et des problèmes causés par le churn mémoire.

---

### Interprétation pratique

L’allocation est souvent invisible au niveau du code parce qu’elle est facile à écrire et généralement peu coûteuse par opération.

Cependant, au niveau du système, l’allocation répétée change la charge de travail du runtime.

Un design qui crée de grandes quantités d’objets temporaires peut fonctionner correctement, mais quand même imposer une pression significative sur le sous-système de la mémoire.

---

### Lien avec les concepts suivants

L’allocation et la durée de vie des objets influencent directement :

- le comportement de la garbage collection (→ section suivante)
- la pression mémoire
- la latence sous charge

Elles constituent donc la base causale des effets de runtime décrits dans le reste de ce chapitre.

---

### Idée clé

Les performances dépendent de la quantité de mémoire qui est allouée et de combien de temps elle est maintenue.

Les patterns d’allocation façonnent le comportement du système sous charge.

---

<a id="173-garbage-collection-conceptual"></a>
## 1.7.3 Garbage collection (conceptuelle)

### Définition

La garbage collection (GC) est le processus à travers lequel un runtime géré récupère la mémoire qui n’est plus en usage.

Au lieu d’exiger une désallocation explicite, le runtime :

- identifie les objets non utilisés
- libère leur mémoire
- rend disponible de l’espace pour de nouvelles allocations

La garbage collection est l’un des mécanismes distinctifs des runtimes gérés et l’une des principales manières dont le comportement de la mémoire devient visible dans l’analyse des performances.

---

### Principe de base

Un objet est éligible pour la "collection" lorsqu’il n’est plus atteignable (pointé) par d’autres éléments du programme.

Cela signifie :

- aucune référence active ne pointe vers lui
- il ne peut pas être accédé par le programme

Le runtime périodiquement :

- scanne les références aux objets
- identifie les objets non atteignables
- récupère leur mémoire

Ce modèle permet une gestion automatique de la mémoire, mais implique aussi que le travail de récupération doive être exécuté pendant l’exécution du programme.

---

### Cycle allocation et récupération

L’utilisation de la mémoire suit un cycle :

1. les objets sont alloués
2. les objets deviennent inutilisés
3. la garbage collection récupère la mémoire

Ce cycle se répète continuellement pendant l’exécution.

Le runtime alterne donc entre allocation de nouvelle mémoire et récupération d’ancienne mémoire, avec un comportement global guidé par le taux d’allocation et par les patterns de rétention.

---

### Perspective Java (exemple)

En Java, l’allocation d’objets est fréquente et économique.

Par exemple :

```java
for (int i = 0; i < 1_000_000; i++) {
    String s = new String("test");
}
```

Ce code crée un grand nombre d’objets à courte durée de vie.

Dans un runtime géré :

- ces objets sont alloués rapidement sur le heap
- ils deviennent non atteignables peu après la création
- la garbage collection les récupère

Si de tels patterns d’allocation se vérifient sous charge :

- l’activité GC augmente
- la pression mémoire croît
- la latence peut devenir instable

L’impact dépend non d’une seule allocation, mais du **taux d’allocation dans le temps**.

Pour cette raison le comportement de la mémoire doit être analysé comme un pattern, non comme une opération isolée.

### Exemple : rétention des objets

Les objets qui restent référencés ne sont pas collectés.

```java
List<String> cache = new ArrayList<>();

while (true) {
    cache.add(new String("data"));
}
```

Dans ce cas :

- les objets sont alloués continuellement
- ils ne sont jamais relâchés
- l’utilisation de la mémoire croît dans le temps

Cela conduit à :

- augmentation de la pression mémoire
- cycles de garbage collection plus coûteux
- instabilité potentielle du système

Cet exemple illustre la différence entre churn temporaire d’allocation et rétention persistante.

### Coût de la garbage collection

La garbage collection n’est pas gratuite.

Elle introduit un overhead :

- temps CPU pour analyser la mémoire
- pauses pendant la collecte (selon la stratégie/policy de GC)

Le coût dépend de :

- taux d’allocation
- nombre d’objets actifs
- taille de la mémoire

En d’autres termes, le coût GC dépend non seulement de la quantité de mémoire qui existe, mais de la quantité de mémoire qui est active et encore atteignable.

---

### Effet stop-the-world

Certaines phases (de certaines policies) de la garbage collection peuvent suspendre l’exécution de l’application.

Pendant ces pauses :

- les threads applicatifs sont temporairement en stand-by
- aucun travail applicatif n’est exécuté

Même des pauses brèves peuvent :

- augmenter la latence
- influencer les temps de réponse de queue (p95, p99)

C’est l’une des raisons pour lesquelles les problèmes GC apparaissent souvent d’abord dans l’analyse de la latence basée sur les percentiles plutôt que dans les moyennes.

---

### Comportement générationnel (conceptuel)

La majorité des runtimes modernes utilise une approche générationnelle.

Basée sur l’observation :

- la majorité des objets a une courte durée de vie
- peu d’objets ont une durée de vie prolongée

La mémoire est organisée de telle sorte que :

- les objets à courte durée de vie soient collectés fréquemment
- les objets à longue durée de vie soient collectés moins souvent

Cela améliore l’efficacité parce que récupérer de nombreux objets à courte durée de vie est habituellement plus économique que scanner répétitivement de la mémoire à longue rétention.

---

### Sous charge

Avec l’augmentation de la charge :

- le taux d’allocation augmente
- la garbage collection est exécutée plus fréquemment

Cela peut conduire à :

- plus grande utilisation de la CPU
- pauses plus fréquentes
- augmentation de la variabilité de la latence

Sous charge importante, la GC peut donc passer d’un mécanisme de maintenance en background à une partie visible du comportement des performances du système.

---

### Interaction avec le cycle de vie des objets

Le comportement de la garbage collection dépend de :

- combien d’objets sont créés
- combien de temps ils vivent

Patterns typiques :

- beaucoup d’objets à courte durée de vie → collectes fréquentes
- beaucoup d’objets à longue durée de vie → collectes plus lourdes

Pour cette raison allocation et rétention doivent être analysées ensemble : le nombre d’objets à lui seul n’est pas suffisant.

---

### Effets observables

Les problèmes de garbage collection apparaissent souvent comme :

- pics de latence
- latence de queue (dégradation p95/p99)
- pauses périodiques
- augmentation de l’utilisation CPU sans cause évidente

Ces symptômes sont souvent intermittents, ce qui rend les problèmes liés à la GC difficiles à diagnostiquer sans corréler des signaux de mémoire et de latence.

---

### Implications pratiques

L’analyse des performances doit considérer :

- taux d’allocation
- distribution de la durée de vie des objets
- fréquence et coût des cycles GC

L’optimisation typiquement se concentre sur :

- compréhension des patterns d’allocation
- réduction de la création inutile d’objets
- contrôle de la pression mémoire

Le tuning du collector peut aider, mais habituellement il est plus efficace de comprendre à l’avance pourquoi le runtime est sous pression.

---

### Interprétation pratique

La garbage collection n’est pas un bug ou une anomalie.

C’est un mécanisme nécessaire du runtime.

La question sur les performances n’est pas de savoir si la GC existe, mais si son coût de fonctionnement reste compatible avec la charge de travail et les objectifs de latence du système.

---

### Lien avec les concepts précédents

La garbage collection est directement liée à :

- allocation (→ [1.7.2 Allocation et cycle de vie des objets](#172-allocation-and-object-lifecycle))
- structure de la mémoire (→ [1.7.1 Structure de la mémoire](#171-memory-structure-heap-stack))
- latence de queue (→ [1.5.5 Tail latency amplification](01-05-system-behavior-under-load.md#155-tail-latency-amplification))

Elle est donc à la fois un mécanisme de runtime et un contributeur au niveau système à la variabilité des performances.

---

### Idée clé

La garbage collection permet la gestion automatique de la mémoire mais introduit de la variabilité.

Les performances dépendent de l’efficacité avec laquelle la mémoire est récupérée.

---

<a id="174-memory-pressure-and-performance"></a>
## 1.7.4 Pression mémoire et performance

### Définition

La pression mémoire se réfère au stress placé sur le système de mémoire lorsque allocation, rétention et récupération interagissent sous charge.

Elle ne concerne pas seulement la quantité de mémoire utilisée, mais la manière dont la mémoire est gérée et se comporte dans le temps.

La pression mémoire est donc une condition dynamique, non simplement une mesure statique de l’occupation du heap.

---

### Ce qui crée la pression mémoire

La pression mémoire est guidée par une combinaison de facteurs :

- taux d’allocation élevé
- grand nombre d’objets actifs
- longue durée de vie des objets
- récupération inefficace de la mémoire

Ces facteurs se renforcent mutuellement et déterminent combien de travail le runtime doit accomplir pour maintenir la mémoire utilisable.

---

### Allocation vs rétention

Deux patterns différents peuvent créer de la pression :

- **taux d’allocation élevé**  
  de nombreux objets sont créés et rapidement écartés

- **rétention élevée**  
  les objets restent en mémoire pendant de longues périodes

Ces patterns créent de la pression de manières différentes.

Un taux d’allocation élevé augmente le churn et la fréquence de collecte.

Une rétention élevée augmente la quantité de mémoire qui reste active et doit être scannée ou préservée.

---

### Exemple : taux d’allocation élevé

```java
for (int i = 0; i < 1_000_000; i++) {
    String s = new String("test");
}
```

Caractéristiques :

- beaucoup d’objets à courte durée de vie
- allocation fréquente
- garbage collection fréquente

Effets :

- augmentation de l’activité GC
- overhead CPU
- pics de latence potentiels

Cet exemple met en évidence une pression guidée par le churn plutôt que par la rétention à long terme.

---

### Exemple : rétention de la mémoire

```java
List<String> cache = new ArrayList<>();

while (true) {
    cache.add(new String("data"));
}
```

Caractéristiques :

- les objets sont maintenus
- l’utilisation de la mémoire croît continuellement

Effets :

- augmentation de l’utilisation du heap
- cycles de garbage collection plus lourds
- instabilité ou échec final

Cet exemple met en évidence une pression guidée par la mémoire retenue plutôt que par la seule fréquence d’allocation temporaire.

---

### Sous charge

Avec l’augmentation de la charge du système :

- plus de requêtes sont traitées
- plus d’objets sont créés
- plus d’objets sont retenus

Cela conduit à :

- augmentation du taux d’allocation
- augmentation de l’utilisation de la mémoire
- augmentation de l’activité GC

La pression mémoire amplifie :

- la variabilité de la latence
- la latence de queue

Pour cette raison la dégradation liée à la mémoire devient souvent plus visible lorsque le système passe d’une charge modérée à une charge soutenue élevée.

---

### Interaction avec la garbage collection

La garbage collection répond à la pression mémoire.

Sous pression :

- les collectes deviennent plus fréquentes
- les pauses peuvent augmenter
- l’utilisation de la CPU croît

Dans des cas extrêmes :

- la GC domine l’exécution
- le travail utile diminue

Lorsque cela arrive, le runtime est en train de dépenser une part significative de son effort de travail dans la gestion même de la mémoire plutôt que dans le traitement du travail applicatif.

---

### Symptômes observables

La pression mémoire apparaît souvent comme :

- pics de latence sans goulet d’étranglement CPU clair
- dégradation de la latence de queue (p95, p99)
- pauses périodiques
- augmentation de la fréquence GC
- croissance de l’utilisation de la mémoire dans le temps

Ces symptômes sont particulièrement importants parce qu’ils peuvent être pris pour une lenteur générique si le comportement de la mémoire n’est pas analysé directement.

---

### Intuition pratique

Un système peut apparaître :

- légèrement chargé (CPU modérée)
- mais quand même lent

Cela indique souvent :

- pression mémoire
- overhead lié à la GC

C’est l’une des raisons principales pour lesquelles la seule CPU n’est pas suffisante pour évaluer la santé du système.

---

### Modèle simplifié

Le comportement du système peut être approximé comme :

- taux d’allocation ↑ → activité GC ↑  
- rétention ↑ → utilisation de la mémoire ↑  
- activité GC ↑ → variabilité de la latence ↑  

Ces relations ne sont pas linéaires.

Elles dépendent de la stratégie du runtime, de la forme de la charge de travail, de la durée de vie des objets et de la quantité de données actives.

---

### Implications pratiques

Pour gérer la pression mémoire :

- comprendre les patterns d’allocation
- identifier les objets à longue durée de vie
- monitorer le comportement GC
- corréler les métriques mémoire avec la latence

L’optimisation devrait se concentrer sur :

- réduire les allocations non nécessaires
- contrôler la durée de vie des objets
- éviter une rétention non limitée

Dans de nombreux cas, la solution la plus efficace n’est pas le tuning du collector, mais la réduction du travail mémoire que le runtime est forcé d’exécuter.

---

### Lien avec les concepts précédents

La pression mémoire contribue à :

- dégradation non linéaire (→ [1.5.3 Non-linear degradation](01-05-system-behavior-under-load.md#153-non-linear-degradation))
- effondrement du throughput (→ [1.5.4 Throughput collapse](01-05-system-behavior-under-load.md#154-throughput-collapse))
- amplification de la latence de queue (→ [1.5.5 Tail latency amplification](01-05-system-behavior-under-load.md#155-tail-latency-amplification))

Elle est donc un pont direct entre les internes du runtime et le comportement visible du système sous charge.

---

### Interprétation pratique

La pression mémoire explique pourquoi un système peut se dégrader même lorsqu’il n’est pas manifestement limité par la CPU ou bloqué extérieurement.

Un runtime sous stress au niveau de la mémoire peut apparaître actif, mais produire une latence croissante, un throughput réduit et un comportement instable.

Cela fait de la pression mémoire l’une des causes cachées les plus importantes dans la dégradation des performances des runtimes gérés.

---

### Idée clé

La pression mémoire dérive de l’interaction entre allocation, rétention et garbage collection sous charge.

Comprendre cette interaction est essentiel pour expliquer des problèmes de latence et de stabilité dans les systèmes réels.