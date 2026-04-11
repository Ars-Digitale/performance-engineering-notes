## 1.9 – Problèmes communs de performance

<a id="19-common-performance-problems"></a>

Ce chapitre décrit des problèmes communs de performance qui apparaissent dans les systèmes réels sous charge.

Ces problèmes n’appartiennent pas à des catégories isolées. Ils interagissent souvent, se renforcent mutuellement et deviennent visibles sous la forme d’une croissance de la latence, d’une perte de throughput, d’une instabilité ou d’une dégradation en queue.

Le but de ce chapitre est de relier des symptômes récurrents aux mécanismes sous-jacents déjà introduits dans les chapitres précédents.

## Table des matières

- [1.9.1 Inefficacité CPU-bound](#191-cpu-bound-inefficiency)
- [1.9.2 Allocation excessive et churn mémoire](#192-excessive-allocation-and-memory-churn)
- [1.9.3 Contention et hot spots de synchronisation](#193-contention-and-synchronization-hot-spots)
- [1.9.4 Goulots d’étranglement dus au blocking et à l’attente](#194-blocking-and-waiting-bottlenecks)
- [1.9.5 Accumulation de files d’attente et effets de saturation](#195-queue-buildup-and-saturation-effects)
- [1.9.6 Amplification des dépendances et latence en cascade](#196-dependency-amplification-and-cascading-latency)

---

<a id="191-cpu-bound-inefficiency"></a>
## 1.9.1 Inefficacité CPU-bound

### Définition

Une inefficacité CPU-bound se vérifie lorsque le système dépense un temps CPU excessif en accomplissant un travail qui pourrait être réduit, optimisé ou même évité.

Cela ne signifie pas nécessairement que le système soit toujours CPU-saturé.

Cela signifie que le temps CPU disponible est consommé de manière inefficace, réduisant la quantité de travail utile que le système peut accomplir avant d’atteindre la saturation.

---

### Causes typiques

- algorithmes inefficients (ex. complexité non nécessaire)
- calculs répétés
- absence de caching pour des opérations coûteuses
- transformations de données excessives

Ces causes sont communes parce que l’inefficacité CPU émerge souvent d’un code fonctionnellement correct mais structurellement coûteux.

En performance engineering, l’inefficacité est davantage impactante lorsqu’elle se constate dans des hot paths ou dans des opérations hautement répétitives.

---

### Exemple

```java
public int countMatches(List<String> items, String target) {
    int count = 0;
    for (String s : items) {
        if (s.toLowerCase().equals(target.toLowerCase())) {
            count++;
        }
    }
    return count;
}
```

Interprétation :

- des appels répétés à `toLowerCase()` créent un travail non nécessaire
- le temps CPU augmente avec la taille de l’entrée
- calcul évitable dans les hot paths

Le problème n’est pas seulement le coût de la boucle en elle-même, mais la transformation répétée de valeurs qui pourraient être normalisées une seule fois au lieu de l’être à chaque comparaison.

---

### Mécanisme

L’inefficacité CPU-bound gaspille de la capacité d’exécution.

Plus de temps CPU que nécessaire est consommé pour produire le même résultat.

Avec la croissance de la charge de travail :

- l’utilisation de la CPU augmente plus tôt
- le travail exécutable s’accumule plus tôt
- le throughput utile atteint plus tôt sa limite

Cela transforme un code inefficace en un goulot d’étranglement au niveau système lorsque le volume des requêtes augmente.

---

### Impact sous charge

- augmentation de l’utilisation de la CPU
- réduction du throughput
- saturation de la CPU anticipée

Cela conduit à des retards de scheduling (→ [1.8.1 CPU behavior](./01-08-resource-level-performance.md#181-cpu-behavior)) et à une croissance non linéaire de la latence (→ [1.5.3 Non-linear degradation](./01-05-system-behavior-under-load.md#153-non-linear-degradation)).

En termes pratiques, le système atteint sa propre limite CPU plus tôt que prévu, laissant moins de marge pour des bursts ou une croissance concurrente du trafic.

---

### Symptômes observables

Les symptômes typiques incluent :

- utilisation élevée de la CPU sous charge modérée
- latence en augmentation avec l’augmentation du volume de requêtes
- throughput qui s’aplatit plus tôt que prévu
- temps CPU significatif passé dans des opérations répétées ou évitables

Ces symptômes apparaissent souvent avant la saturation totale de la CPU et peuvent initialement ressembler à un problème générique de scalabilité.

---

### Implications pratiques

- optimiser les hot paths
- éviter le travail répété
- réduire la complexité algorithmique

Il est aussi important d’identifier quelles inefficacités comptent vraiment au niveau du système.

Une opération inefficace exécutée une fois peut être négligeable.

La même inefficacité exécutée des millions de fois devient un goulot d’étranglement.

---

### Interprétation pratique

L’inefficacité CPU est l’une des raisons les plus communes pour lesquelles un système n’arrive pas à scaler malgré un hardware apparemment adéquat.

Le problème n’est pas le manque de CPU en termes absolus, mais la mauvaise utilisation de la CPU disponible.

L’optimisation est donc d’autant plus précieuse qu’elle augmente la quantité de travail utile accomplie par unité de temps CPU.

---

### Idée clé

L’inefficacité CPU réduit la quantité de travail utile que le système peut accomplir avant d’atteindre la saturation.

---

<a id="192-excessive-allocation-and-memory-churn"></a>
## 1.9.2 Allocation excessive et churn mémoire

### Définition

L’allocation excessive se vérifie lorsque le système crée un grand nombre d’objets à courte durée de vie, augmentant le churn mémoire et la pression sur le runtime.

C’est un problème commun dans les managed runtimes, où l’allocation est souvent peu coûteuse par opération, mais devient très coûteuse, en agrégat, lorsqu’elle est exécutée excessivement et sous charge.

---

### Exemple

```java
for (Order o : orders) {
    result.add(new ReportRow(o.getId(), o.getAmount(), o.getStatus()));
}
```

Interprétation :

- beaucoup d’objets sont créés par itération
- les objets ont une courte durée de vie
- le taux d’allocation augmente

Si ce pattern apparaît dans un code exécuté fréquemment, le volume total d’allocation peut devenir significatif même lorsque chaque objet individuel reste peu impactant.

---

### Mécanisme

- un taux d’allocation élevé augmente le churn mémoire
- la garbage collection est exécutée plus fréquemment

(→ [1.7.2 Allocation and object lifecycle](./01-07-runtime-and-memory-model.md#172-allocation-and-object-lifecycle))  
(→ [1.7.3 Garbage collection](./01-07-runtime-and-memory-model.md#173-garbage-collection-conceptual))

Le système souffre donc non seulement dans la phase de création des objets, mais pour les tracer, les éliminer et gérer, en général, les effets sur le runtime d’un turnover fréquent de la mémoire.

---

### Impact sous charge

- augmentation de l’activité GC
- overhead CPU pour la gestion de la mémoire
- variabilité de la latence

Cela contribue à la pression sur la mémoire (→ [1.7.4 Memory pressure and performance](./01-07-runtime-and-memory-model.md#174-memory-pressure-and-performance)).

Avec l’augmentation de la charge, l’overhead lié à l’allocation devient souvent plus visible à travers des pauses, du jitter et un élargissement des percentiles de latence.

---

### Symptômes observables

Les symptômes typiques incluent :

- augmentation de la fréquence de la garbage collection
- pics périodiques de latence
- écart croissant entre latence moyenne et latence de queue
- utilisation modérée de la CPU avec des temps de réponse instables
- comportement de la mémoire qui se dégrade avec l’augmentation du throughput

Ces symptômes sont particulièrement communs dans les systèmes qui allouent fortement dans les chemins de traitement des requêtes.

---

### Implications pratiques

- réduire la création non nécessaire d’objets
- réutiliser les objets lorsque c’est approprié
- analyser les patterns d’allocation

Il est aussi important de distinguer entre :

- allocation nécessaire
- allocation évitable
- allocation retenue qui aurait dû au contraire être temporaire

Cette distinction aide à déterminer si le problème est le churn, la rétention ou les deux.

---

### Interprétation pratique

L’allocation excessive est souvent invisible en code review parce que le code reste simple et correct.

Son effet devient visible seulement à runtime, lorsque la création répétée d’objets change le comportement de la GC et la pression mémoire.

Un système peut donc apparaître logiquement efficient et malgré cela se comporter mal parce qu’il crée trop de trafic mémoire transitoire.

---

### Idée clé

Le churn mémoire augmente l’overhead du runtime et introduit de la variabilité de la latence.

---

<a id="193-contention-and-synchronization-hot-spots"></a>
## 1.9.3 Contention et hot spots de synchronisation

### Définition

La contention se vérifie lorsque plusieurs threads entrent en compétition pour la même ressource, forçant un accès sérialisé.

Un hot spot de synchronisation est une partie du système dans laquelle cette compétition devient concentrée et retarde répétitivement l’exécution.

Ces hot spots sont particulièrement problématiques parce qu’ils réduisent le parallélisme effectif exactement là où l’on s’attend à ce que la concurrence puisse aider.

---

### Exemple

```java
public class Counter {
    private int value = 0;

    public synchronized void increment() {
        value++;
    }
}
```

Interprétation :

- l’accès est sérialisé à travers la synchronisation
- un seul thread progresse à la fois
- le throughput est limité par la section critique

Le problème n’est pas que la synchronisation existe, mais qu’un chemin partagé et fréquemment accédé puisse devenir le point limitant pour l’ensemble du système.

---

### Mécanisme

- les threads se bloquent en attendant le lock
- la contention augmente avec la concurrence

(→ [1.6 Concurrency and parallelism](./01-06-concurrency-and-parallelism.md))

Lorsque plusieurs threads entrent en compétition pour la même section synchronisée :

- le temps d’attente croît
- le parallélisme effectif diminue
- plus de temps est dépensé dans la coordination que dans le progrès

Cela fait que le système se comporte comme si son niveau de concurrence était inférieur à ce que le nombre de threads suggère.

---

### Impact sous charge

- augmentation du temps d’attente
- réduction du throughput
- augmentation de la latence

Cela conduit à des effets de mise en file d’attente (→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md)).

Sous charge plus élevée, les hot spots de synchronisation deviennent souvent visibles sous la forme d’une croissance de la latence sans croissance proportionnelle de la CPU, parce que les threads sont en attente au lieu d’exécuter du travail.

---

### Symptômes observables

Les symptômes typiques incluent :

- latence en augmentation avec utilisation modérée de la CPU
- beaucoup de threads bloqués ou en attente
- scalabilité réduite avec l’augmentation de la concurrence
- throughput limité par une petite section critique
- chemins de code avec usage intensif de locks qui apparaissent dans les hot paths d’exécution

Ces symptômes sont souvent trompeurs parce que le système peut apparaître seulement partiellement utilisé tout en étant déjà contraint.

---

### Implications pratiques

- minimiser l’état mutable partagé
- réduire la taille de la section critique
- utiliser des patterns de concurrence plus scalables

Il est aussi important d’identifier si le goulot d’étranglement est causé par :

- scope du lock
- fréquence d’accès
- longues sections critiques
- synchronisation non nécessaire

Des causes différentes requièrent des solutions différentes.

---

### Interprétation pratique

Les problèmes de contention sont souvent mal compris comme une lenteur générique.

En réalité, le problème central est la sérialisation : beaucoup de threads sont présents, mais seuls quelques-uns progressent dans le travail utile.

La performance engineering donc ne se préoccupe pas seulement d’ajouter de la concurrence, mais doit surtout s’assurer que la concurrence présente ne s’effondre pas en attente.

---

### Idée clé

**La contention convertit le travail parallèle en exécution sérialisée**.

---

<a id="194-blocking-and-waiting-bottlenecks"></a>
## 1.9.4 Goulots d’étranglement dus au blocking et à l’attente

### Définition

Le blocking se vérifie lorsqu’un thread attend qu’une opération externe soit complétée, l’empêchant d’accomplir un travail utile.

Cela inclut l’attente de :

- I/O
- réponses réseau
- locks
- services externes
- autres événements coordonnés

Le blocking est souvent nécessaire, mais il devient un goulot d’étranglement lorsque trop de ressources d’exécution sont occupées à attendre au lieu de progresser.

---

### Exemple

```java
public String fetchData() throws Exception {
    Thread.sleep(50); // simulate blocking call
    return "data";
}
```

Interprétation :

- le thread est inactif pendant l’attente
- les ressources restent allouées
- la concurrence ne se traduit pas en throughput

Le thread existe, mais n’est pas en train de faire avancer du travail utile pendant la période de blocage.

---

### Mécanisme

- les threads passent du temps à attendre au lieu d’exécuter
- les thread pools peuvent se saturer

(→ [1.6 Concurrency and parallelism](./01-06-concurrency-and-parallelism.md))

Lorsque plusieurs threads se bloquent :

- moins de threads restent disponibles pour du nouveau travail
- la mise en file d’attente apparaît au niveau du modèle d’exécution
- la latence croît même si la CPU n’est pas pleinement utilisée

C’est la raison pour laquelle les goulots d’étranglement dus au blocking coexistent souvent avec une utilisation modérée de la CPU.

---

### Impact sous charge

- augmentation de la latence
- réduction du throughput
- épuisement des threads

Cela amplifie la mise en file d’attente et la saturation (→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md)).

Sous charge soutenue, le comportement bloquant crée souvent une boucle de feedback dans laquelle les requêtes en file attendent des threads qui, à leur tour, attendent des opérations lentes.

---

### Symptômes observables

Les symptômes typiques incluent :

- beaucoup de threads dans des états d’attente ou bloqués
- files de requêtes en croissance
- CPU modérée avec throughput médiocre
- latence en augmentation pendant des opérations heavy en I/O ou heavy en dépendances
- thread pools qui apparaissent pleins sans travail productif correspondant

Ces symptômes sont particulièrement communs dans les services qui mélangent concurrence des requêtes et appels downstream synchrones.

---

### Implications pratiques

- réduire les opérations bloquantes
- utiliser des patterns asynchrones ou non bloquants lorsque c’est approprié
- dimensionner avec attention les thread pools

Il est aussi utile de distinguer entre :

- blocking inévitable
- blocking évitable
- blocking placé dans des chemins d’exécution à haute fréquence

Cette distinction aide à identifier là où un redesign est nécessaire.

---

### Interprétation pratique

Le blocking réduit la concurrence effective.

Un système peut avoir beaucoup de threads, mais si une grande partie d’entre eux est en attente, le système se comporte comme s’il avait beaucoup moins de capacité d’exécution.

C’est la raison pour laquelle les problèmes de blocking sont souvent des problèmes du modèle d’exécution avant de devenir des problèmes de pure ressource.

---

### Idée clé

Le blocking réduit la concurrence effective et limite le throughput du système.

---

<a id="195-queue-buildup-and-saturation-effects"></a>
## 1.9.5 Accumulation de files d’attente et effets de saturation

### Définition

L’accumulation de files d’attente se vérifie lorsque le travail entrant dépasse la capacité de traitement, causant l’attente des requêtes avant qu’elles soient traitées.

C’est l’un des problèmes de performance les plus communs et les plus importants, parce que le queueing transforme une surcharge peut-être modérée en une latence rapidement croissante.

---

### Mécanisme

- le taux d’arrivée dépasse la capacité de service
- les files croissent dans le temps

Cela peut être décrit en utilisant Little’s Law (→ [1.2.1 Little’s Law (system-level concurrency)](./01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency)).

Pendant que la demande entrante continue et que le traitement reste limité, l’attente s’accumule et le temps de réponse commence à inclure un retard de file de plus en plus grand.

---

### Impact sous charge

- le temps d’attente augmente
- le temps de réponse augmente
- la latence devient instable

Cela conduit à une dégradation non linéaire (→ [1.5.3 Non-linear degradation](./01-05-system-behavior-under-load.md#153-non-linear-degradation)) et à des limites de throughput.

Une fois que la mise en file d’attente devient dominante, le système peut se détériorer très rapidement même si l’augmentation d’origine de la charge était relativement petite.

---

### Symptômes observables

- longueurs de file croissantes
- temps de réponse en augmentation
- throughput stable ou en diminution

D’autres symptômes peuvent inclure :

- bursts d’erreurs de timeout
- élargissement de la latence p95/p99
- récupération retardée après une surcharge temporaire

Ces effets indiquent souvent que le système opère près ou au-delà de sa capacité effective.

---

### Implications pratiques

- contrôler la concurrence
- augmenter la capacité de la ressource qui est le goulot d’étranglement
- réduire le taux d’arrivée si nécessaire

Il est aussi important de déterminer où la file est en train de se former :

- thread pool
- connection pool
- dispositif
- buffer réseau
- service downstream

La position de la file révèle souvent le vrai goulot d’étranglement.

---

### Interprétation pratique

L’accumulation de files d’attente n’est pas seulement un détail opérationnel.

C’est souvent le mécanisme direct à travers lequel la surcharge devient visible pour les utilisateurs.

Un système peut encore fonctionner, mais une fois que le travail commence à attendre de manière systématique, la croissance de la latence devient inévitable.

---

### Idée clé

**Les files croissent lorsque la demande dépasse la capacité, déterminant la latence**.

---

<a id="196-dependency-amplification-and-cascading-latency"></a>
## 1.9.6 Amplification des dépendances et latence en cascade

### Définition

L’amplification des dépendances se vérifie lorsque la latence dans un composant se propage et augmente la latence à travers le système.

Ce problème est particulièrement important dans les systèmes distribués, où une requête dépend souvent de plusieurs appels downstream avant de pouvoir se compléter.

---

### Mécanisme

- les requêtes dépendent de plusieurs services downstream
- les retards s’accumulent à travers les appels
- des composants lents influencent l’ensemble du système

Même lorsque chaque retard individuel est petit, l’effet total peut devenir significatif une fois que plusieurs dépendances, retries ou chaînes d’appels sériels sont impliquées.

---

### Exemple

```java
public Response process() {
    Data a = serviceA.call();
    Data b = serviceB.call();
    return combine(a, b);
}
```

Interprétation :

- la latence totale dépend de plusieurs dépendances
- la dépendance la plus lente domine le temps de réponse

Dans les systèmes réels, cet effet devient plus fort lorsque les requêtes dépendent de nombreux services, de bases de données distantes ou d’opérations synchrones enchaînées.

---

### Impact sous charge

- amplification de la latence à travers les services
- augmentation de la variabilité
- dégradation de la latence de queue

(→ [1.5.5 Tail latency amplification](./01-05-system-behavior-under-load.md#155-tail-latency-amplification))

Sous charge, l’amplification des dépendances devient souvent plus sévère parce que des systèmes downstream lents retiennent des threads, des requêtes et des files upstream pendant des périodes plus longues.

---

### Symptômes observables

Les symptômes typiques incluent :

- augmentations soudaines de latence sans saturation locale de la CPU
- dégradation du comportement p95/p99 causée par la variabilité downstream
- chaînes de requêtes qui deviennent plus lentes pendant qu’une dépendance ralentit
- instabilité qui se diffuse d’un service à un autre
- retries et timeouts qui augmentent la pression à travers le système

Ces symptômes sont souvent difficiles à interpréter sans corréler le comportement à travers plusieurs composants.

---

### Implications pratiques

- minimiser le nombre de dépendances synchrones
- utiliser des timeouts et des stratégies de fallback
- isoler les composants lents

Il est aussi utile d’identifier :

- quelle dépendance contribue le plus au retard end-to-end
- si les appels sont sériels ou parallèles
- si les retries aggravent le problème
- si les composants lents déclenchent une mise en file d’attente upstream

Cela transforme un vague problème de “lenteur distribuée” en un comportement système diagnostiable.

---

### Interprétation pratique

La latence d’un système n’est pas déterminée seulement par son "propre code".

Elle est souvent déterminée par la dépendance la plus lente dans le chemin de la requête.

Plus un système a de dépendances, plus il est probable que la variabilité à un endroit devienne visible partout.

---

### Idée clé

**La latence du système est souvent déterminée par la dépendance la plus lente**.