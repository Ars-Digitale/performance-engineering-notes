# 1.6 – Concurrence et parallélisme

<a id="16-concurrency-and-parallelism"></a>

Ce chapitre introduit la concurrence et le parallélisme comme concepts fondamentaux dans la performance engineering des systèmes et des applications.

Il introduit le scheduling du travail, la manière dont interagissent des tâches multiples et pourquoi l’overhead de coordination, la contention et la synchronisation deviennent souvent des facteurs limitants sous charge.

La concurrence et le parallélisme sont essentiels pour la scalabilité, mais ils introduisent aussi de la complexité, de l’overhead et des points de rupture qui influencent directement la latence, le throughput et la stabilité du système.

## Table des matières

- [1.6.1 Concurrence vs parallélisme](#161-concurrency-vs-parallelism)
- [1.6.2 Threads et modèle d’exécution](#162-threads-and-execution-model)
- [1.6.3 Contention et synchronisation](#163-contention-and-synchronization)
- [1.6.4 Problèmes communs de concurrence](#164-common-concurrency-issues)
	- [1.6.4.1 Race conditions](#1641-race-conditions)
	- [1.6.4.2 Deadlock](#1642-deadlocks)
	- [1.6.4.3 Livelock](#1643-livelocks)
	- [1.6.4.4 Starvation](#1644-starvation)
	- [1.6.4.5 Épuisement du thread pool](#1645-thread-pool-exhaustion)

---

<a id="161-concurrency-vs-parallelism"></a>
## 1.6.1 Concurrence vs parallélisme

### Définition

**Concurrence** et **parallélisme** sont des concepts corrélés mais distincts.

Ils sont souvent confondus, mais décrivent des aspects différents du comportement du système.

Comprendre la distinction est essentiel parce qu’un système peut gérer de nombreuses activités simultanément d’un point de vue structurel sans réellement exécuter de nombreuses activités simultanément au niveau matériel.

---

### Concurrence

La **concurrence** se réfère à la capacité d’un système à gérer plusieurs tâches pendant un même intervalle de temps.

Ces tâches :

- peuvent ne pas être exécutées exactement au même moment
- peuvent être « interleaved »
- partagent des ressources système

La concurrence concerne :

- structure
- coordination
- gestion de plusieurs opérations « in flight »

Elle s’intéresse donc principalement à la manière dont le travail est organisé et schedulé.

---

### Parallélisme

Le **parallélisme** se réfère à l’exécution de plusieurs tâches au même instant.

Cela requiert :

- plusieurs unités de traitement (ex. cœurs CPU)
- une véritable exécution simultanée

Le parallélisme concerne :

- exécution
- utilisation du matériel
- accomplir davantage de travail au même instant

Il s’intéresse donc principalement à l’exécution simultanée.

---

### Différence clé

- **Concurrence** = gérer de nombreuses tâches  
- **Parallélisme** = exécuter de nombreuses tâches simultanément  

Un système peut être :

- concurrent mais non parallèle (single core, tâches « interleaved »)
- parallèle mais non hautement concurrent (peu de tâches de longue durée)

Cette distinction compte parce que les propriétés de scalabilité d’un système dépendent non seulement de la quantité de travail existante, mais aussi de la manière dont ce travail est coordonné et schedulé.

---

### Relation avec les performances

La concurrence influe sur :

- combien de requêtes peuvent être en exécution
- comment les ressources sont partagées
- comment la contention apparaît

Le parallélisme influe sur :

- à quelle vitesse le travail peut être exécuté
- avec quelle efficacité le matériel est utilisé

Les deux influencent :

- throughput
- latence
- scalabilité

Dans la pratique, ajouter de la concurrence sans parallélisme suffisant peut augmenter l’attente et la contention, tandis qu’ajouter du parallélisme sans bon contrôle de la concurrence peut gaspiller des ressources ou exposer des problèmes de coordination.

---

### Intuition pratique

Un système concurrent :

- peut accepter de nombreuses requêtes
- peut néanmoins les traiter séquentiellement ou avec un parallélisme limité

Un système parallèle :

- peut traiter plusieurs requêtes au même moment
- mais peut néanmoins souffrir de contention ou d’overhead de coordination

Pour cette raison, la concurrence et le parallélisme ne devraient pas être traités comme automatiquement bénéfiques.

Leur valeur dépend de la manière dont ils interagissent avec le workload, les ressources partagées et les contraintes d’exécution.

---

### Lien avec les concepts précédents

La concurrence augmente :

- le nombre de requêtes in flight (→ [1.2.1 Loi de Little](01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency))

Cela conduit à :

- partage des ressources
- mise en file potentielle (→ [1.5.2 Saturation et mise en file](01-05-system-behavior-under-load.md#152-saturation-and-queueing))

C’est l’une des principales raisons pour lesquelles la concurrence devient un sujet central en performance engineering et non seulement une question de programmation.

---

### Interprétation pratique

La concurrence est souvent nécessaire pour supporter de nombreuses opérations simultanées, surtout dans les systèmes réseau et pilotés par I/O.

Cependant, la concurrence augmente aussi la probabilité de :

- interactions sur état partagé
- accumulation de files
- contention sur les verrous
- overhead de coordination

Le parallélisme peut augmenter le throughput, mais seulement si un travail réellement utile est exécuté au lieu d’un travail bloqué ou sérialisé.

---

### Idée clé

La concurrence détermine combien de tâches sont actives.

Le parallélisme détermine combien de tâches sont exécutées au même moment.

Les performances dépendent des deux, et de la manière dont ils interagissent avec les ressources du système.

---

<a id="162-threads-and-execution-model"></a>
## 1.6.2 Threads et modèle d’exécution

### Définition

Le **modèle d’exécution** définit comment le travail est exécuté à l’intérieur d’un système.

Dans la plupart des systèmes, le travail est réalisé par des **threads**, qui sont exécutés à l’intérieur d’un **processus**.

Le modèle d’exécution détermine comment les requêtes sont mappées sur les unités d’exécution, comment l’attente est gérée et comment les ressources système sont consommées sous charge.

---

### Processus et threads

Un **processus** est un environnement d’exécution isolé :

- il possède son propre espace mémoire
- il contient des ressources (fichiers, sockets, mémoire)

Un **thread** est une unité d’exécution à l’intérieur d’un processus :

- plusieurs threads partagent la même mémoire du processus
- les threads exécutent des tâches en concurrence

Dans la plupart des applications :

- un processus héberge plusieurs threads
- les threads gèrent les requêtes entrantes

Ce modèle à mémoire partagée rend les threads efficaces pour la communication, mais introduit aussi la complexité de l’état partagé.

---

### Threads

Un thread :

- exécute des instructions
- consomme du temps CPU
- peut se bloquer en attente (ex. I/O, locks)

Plusieurs threads permettent à un système de :

- gérer davantage de requêtes
- superposer calcul et attente
- augmenter la concurrence

Cependant, les threads ne sont pas gratuits.

Chaque thread supplémentaire introduit de l’overhead mémoire, de l’overhead de scheduling et de la complexité de coordination.

---

### Cycle de vie du thread

Un thread traverse typiquement différents états :

- **running** (en exécution active)
- **runnable** (prêt à être exécuté, en attente de CPU)
- **waiting** / blocked (en attente d’une ressource ou d’un événement)

Les performances sont influencées par la manière dont les threads se déplacent entre ces états.

Un système avec de nombreux threads en état « runnable » ou « blocked » peut paraître actif, mais accomplir un progrès utile limité.

Comprendre les états des threads est donc essentiel dans le diagnostic des problèmes de concurrence.

---

### Stack et mémoire

Chaque thread possède sa propre **stack** :

- elle mémorise les appels de méthodes et les variables locales
- elle croît et décroît pendant l’exécution

Implications :

- plus de threads → plus grande utilisation mémoire (une stack par thread)
- chaînes d’appels profondes → plus grande utilisation de la stack
- l’épuisement de la stack peut conduire à des ruptures

Cela est particulièrement pertinent dans les systèmes à haute concurrence.

Le nombre de threads influence donc non seulement le scheduling, mais aussi l’empreinte mémoire et la stabilité.

---

### Modèles d’exécution

Des systèmes différents utilisent des **modèles d’exécution** différents.

Les modèles communs incluent :

---

#### Un thread par requête

Chaque requête est gérée par un thread dédié.

Caractéristiques :

- modèle simple
- facile à comprendre
- les opérations bloquantes sont directes

Limites :

- utilisation mémoire élevée avec beaucoup de threads
- scalabilité limitée sous conditions de forte concurrence

Ce modèle est conceptuellement simple, mais il se comporte souvent mal lorsque la concurrence devient très élevée ou lorsque le blocking est fréquent.

---

#### Thread pool

Un nombre fixe de threads gère les requêtes entrantes.

Les requêtes sont mises en file et assignées aux threads disponibles.

Caractéristiques :

- concurrence contrôlée
- overhead réduit par rapport à des threads non limités

Limites :

- mise en file lorsque tous les threads sont occupés
- saturation potentielle du pool

Ce modèle est largement utilisé parce qu’il fournit une utilisation contrôlée des ressources, mais il introduit une file explicite et donc une limite de capacité visible.

---

#### Modèle event-driven / asynchrone

Le travail est géré en utilisant des opérations **non bloquantes** et des **event loops**.

Caractéristiques :

- peu de threads peuvent gérer de nombreuses requêtes concurrentes
- efficace pour des workloads I/O-bound

Limites :

- modèle de programmation plus complexe
- requiert une gestion soignée des flux asynchrones

Ce modèle réduit le nombre de threads bloqués, mais déplace la complexité vers la coordination, les callbacks, la gestion de l’état et le design non bloquant.

---

### Perspective Java (exemple)

En Java, un modèle d’exécution commun utilise des thread pools.

Par exemple :

```java
ExecutorService executor = Executors.newFixedThreadPool(10);

executor.submit(() -> {
    // task logic
});
```

Les requêtes sont :

- envoyées à une file
- exécutées par un nombre limité de threads

Si tous les threads sont occupés :

- les tâches attendent dans la file
- la latence augmente

Pour une explication détaillée des threads en Java, voir :

→ https://ars-digitale.github.io/java-21-study-guide/en/module-07/threads/

Cet exemple est simple, mais il met en évidence une idée clé : des ressources d’exécution limitées introduisent naturellement de la mise en file lorsque la demande dépasse la capacité de traitement immédiate.

---

### Bloquant vs non bloquant

Les threads peuvent :

- **se bloquer** (attendre I/O, verrous, ressources externes)
- **rester actifs** (travail CPU-bound)

Le blocking réduit la concurrence effective :

- les threads sont occupés mais ne progressent pas
- moins de threads sont disponibles pour du nouveau travail

Les approches non bloquantes visent à :

- réduire l’attente inactive
- améliorer l’utilisation des ressources

La distinction est importante parce qu’un nombre élevé de threads ne signifie pas nécessairement un throughput élevé.

Si les threads passent la majorité du temps en attente, la concurrence est présente, mais l’exécution productive est limitée.

---

### Implications pratiques

Le modèle d’exécution détermine :

- comment la concurrence est gérée
- comment les ressources sont utilisées
- comment la mise en file apparaît

Les effets typiques incluent :

- saturation du thread pool → mise en file des requêtes
- opérations bloquantes → throughput réduit
- trop de threads → overhead de context switching

Le modèle d’exécution détermine aussi où les goulets d’étranglement deviennent visibles : dans les files, dans les pools, dans les threads bloqués ou dans les event loops.

---

### Lien avec les concepts précédents

Le comportement des threads impacte directement :

- mise en file (→ [1.5.2 Saturation et mise en file](01-05-system-behavior-under-load.md#152-saturation-and-queueing))
- latence sous charge
- capacité effective du système

Il influence aussi la rapidité avec laquelle un système passe d’un comportement stable à la saturation lorsque la concurrence augmente.

---

### Interprétation pratique

Choisir un modèle d’exécution n’est pas seulement une décision de programmation.

C’est une décision de performance.

Le modèle influe sur :

- consommation mémoire
- overhead de scheduling
- latence en conditions d’attente
- scalabilité sous workload réel

Un design facile à implémenter peut ne pas être celui qui se comporte le mieux sous charge soutenue.

---

### Idée clé

Le modèle d’exécution définit comment le travail est schedulé et traité.

Les threads ne sont pas gratuits.

La manière dont ils sont utilisés détermine :

- quelle quantité de travail peut être gérée
- avec quelle efficacité les ressources sont utilisées
- comment le système se comporte sous charge

---

<a id="163-contention-and-synchronization"></a>
## 1.6.3 Contention et synchronisation

### Définition

La **contention** se produit lorsque plusieurs threads entrent en compétition pour la même ressource.

La **synchronisation** est le mécanisme utilisé pour coordonner l’accès aux ressources partagées.

Ces concepts sont centraux pour comprendre la dégradation des performances dans les systèmes concurrents.

Ils relient correction et performances : les mêmes mécanismes qui protègent l’état partagé peuvent aussi devenir la source d’attente et de scalabilité réduite.

---

### Ressources partagées

Dans les systèmes concurrents, les threads partagent souvent des ressources telles que :

- structures mémoire (objets, caches)
- verrous et moniteurs
- thread pools et files
- connexions à la base de données
- canaux I/O

Lorsque l’accès n’est pas coordonné, une **corruption** des données peut se produire.

Lorsque l’accès est coordonné, de la **contention** peut apparaître.

Cela rend la synchronisation nécessaire, mais non gratuite.

---

### Synchronisation

La synchronisation garantit que les ressources partagées sont accessibles de manière sûre.

Les mécanismes communs incluent :

- verrous (mutex, moniteurs)
- sections synchronisées
- sémaphores
- opérations atomiques

La synchronisation garantit la correction, mais introduit de l’overhead.

Cet overhead peut provenir de :

- attente
- sérialisation de l’exécution
- memory barriers supplémentaires
- coûts de coordination entre threads

---

### Contention

La **contention** surgit lorsque plusieurs threads tentent d’accéder simultanément à la même ressource.

Lorsque la contention se produit :

- les threads peuvent se bloquer ou attendre
- l’exécution est retardée
- le throughput est réduit

Plus les threads sont en compétition :

- plus le temps d’attente est grand
- plus le parallélisme effectif est faible

Un système hautement concurrent peut donc se comporter comme un système partiellement sérialisé si une grande partie de son travail dépend des mêmes ressources partagées.

---

### Contention sur les verrous

Une forme commune de contention implique les verrous.

Lorsqu’un thread détient un verrou :

- les autres threads doivent attendre
- une file de threads en attente peut se former

Les effets incluent :

- augmentation de la latence
- réduction du throughput
- goulets d’étranglement potentiels

La contention sur les verrous est particulièrement problématique lorsque les sections critiques sont longues, fréquemment accédées ou placées sur des hot paths d’exécution.

---

### Contention vs utilisation

Une contention élevée peut se produire même lorsque l’utilisation du CPU est modérée.

Par exemple :

- de nombreux threads sont en attente d’un verrou
- le CPU est partiellement inactif
- le système paraît sous-utilisé mais est en réalité contraint

C’est une source commune de diagnostics trompeurs.

Cela explique pourquoi une utilisation faible ou modérée du CPU ne signifie pas nécessairement que le système dispose d’une capacité disponible.

---

### Synchronisation fine-grained vs coarse-grained

La synchronisation peut être :

- **coarse-grained** (peu de verrous, grandes sections critiques)
- **fine-grained** (beaucoup de verrous, sections critiques plus petites)

Compromis :

- **coarse-grained** → plus simple mais plus de contention
- **fine-grained** → plus scalable mais plus complexe

Le choix entre les deux modèles dépend des caractéristiques du workload, des patterns d’accès et du coût de la complexité additionnelle de design.

---

### Perspective Java (exemple)

En Java, la synchronisation peut être implémentée en utilisant des blocs `synchronized` :

```java
synchronized (lock) {
    // critical section
}
```

Ou bien des verrous explicites :

```java
Lock lock = new ReentrantLock();

lock.lock();
try {
    // critical section
} finally {
    lock.unlock();
}
```

Si de nombreux threads tentent d’entrer dans la même section critique :

- la contention augmente
- les threads se bloquent
- les performances se dégradent

Cet exemple met en évidence comment un mécanisme de correction peut devenir une contrainte de scalabilité sous charge.

---

### Symptômes de la contention

Les indicateurs typiques incluent :

- augmentation du temps de réponse sous charge
- **faible utilisation CPU avec latence élevée**
- threads dans des états blocked ou waiting
- longues files sur des ressources partagées

Ces symptômes apparaissent souvent avant la saturation totale et peuvent être confondus avec d’autres problèmes de ressources s’ils ne sont pas analysés avec attention.

---

### Implications pratiques

La contention limite la scalabilité.

Même avec :

- CPU suffisant
- mémoire adéquate

Un système peut ne pas scaler si :

- les threads passent du temps en attente au lieu d’être en exécution

Réduire la contention a souvent un impact plus grand que l’optimisation des opérations individuelles.

Cela est particulièrement vrai pour les systèmes dont les performances sont contraintes par l’accès partagé plutôt que par le calcul pur.

---

### Lien avec les concepts précédents

La contention contribue à :

- mise en file (→ [1.5.2 Saturation et mise en file](01-05-system-behavior-under-load.md#152-saturation-and-queueing))
- dégradation non linéaire (→ [1.5.3 Dégradation non linéaire](01-05-system-behavior-under-load.md#153-non-linear-degradation))
- effondrement du throughput (→ [1.5.4 Effondrement du throughput](01-05-system-behavior-under-load.md#154-throughput-collapse))

La contention est donc à la fois un phénomène local de synchronisation et un mécanisme de performance au niveau système.

---

### Interprétation pratique

La concurrence augmente les opportunités de recouvrement utile, mais elle augmente aussi la compétition pour les ressources partagées.

Le défi pratique n’est pas simplement d’ajouter davantage de threads, mais de garantir que la concurrence additionnelle produise du travail utile plutôt que de l’attente additionnelle.

---

### Idée clé

La concurrence introduit la nécessité de synchronisation.

La synchronisation introduit la contention.

La contention limite les performances.

Comprendre et contrôler la contention est essentiel pour des systèmes scalables.

---

<a id="164-common-concurrency-issues"></a>
## 1.6.4 Problèmes communs de concurrence

La concurrence introduit de la complexité.

Lorsque plusieurs threads interagissent, des hypothèses incorrectes ou une mauvaise coordination peuvent conduire à des classes spécifiques de problèmes.

Ces problèmes apparaissent souvent sous charge et peuvent affecter sévèrement performances et correction.

Beaucoup d’entre eux sont difficiles à reproduire dans des tests superficiels parce qu’ils dépendent du timing, du scheduling ou de la pression sur les ressources.

---

<a id="1641-race-conditions"></a>
### 1.6.4.1 Race conditions

### Définition

Une **race condition** se produit lorsque plusieurs threads accèdent à des données partagées sans synchronisation adéquate, et que le résultat dépend du timing.

Le résultat n’est donc pas déterministe et peut varier d’une exécution à l’autre.

---

### Exemple

Deux threads mettent à jour un compteur partagé :

- Thread A lit valeur = 10
- Thread B lit valeur = 10
- Thread A écrit 11
- Thread B écrit 11

Résultat attendu : 12  
Résultat réel : 11

La valeur finale dépend de l’ordre dans lequel des opérations non synchronisées sont exécutées.

---

### Impact

- résultats incorrects
- état du système incohérent
- bugs difficiles à reproduire

Les race conditions peuvent aussi corrompre des hypothèses internes de manières qui n’apparaissent que plus tard sous charge.

---

### Pertinence en performance

Les race conditions peuvent ne pas toujours provoquer d’erreurs visibles, mais :

- elles requièrent souvent de la synchronisation additionnelle
- des correctifs impropres peuvent introduire de la contention

C’est l’une des raisons pour lesquelles correction et performances ne peuvent pas être traitées comme des questions complètement séparées dans les systèmes concurrents.

---

<a id="1642-deadlocks"></a>
### 1.6.4.2 Deadlock

### Définition

Un **deadlock** se produit lorsque deux ou plusieurs threads s’attendent indéfiniment les uns les autres.

Chaque thread détient une ressource et attend une autre ressource détenue par l’autre thread.

En conséquence, le progrès s’arrête complètement.

---

### Exemple

- Thread A détient le verrou L1 et attend L2
- Thread B détient le verrou L2 et attend L1

Aucun des deux ne peut progresser davantage.

Ce pattern d’attente circulaire est la caractéristique distinctive du deadlock.

---

### Impact

- le système se bloque
- les requêtes ne sont jamais complétées
- les ressources restent bloquées

Les deadlocks sont particulièrement graves parce qu’ils transforment des ressources actives en ressources bloquées de manière permanente.

---

### Détection

- les threads restent bloqués
- les thread dumps montrent une attente circulaire

Les deadlocks sont souvent détectés via l’analyse des threads plutôt que via des métriques de performance générales.

---

<a id="1643-livelocks"></a>
## 1.6.4.3 Livelock

### Définition

Un **livelock** se produit lorsque les threads ne sont pas bloqués mais changent continuellement d’état en réponse les uns aux autres sans faire de progrès.

Contrairement au deadlock, l’activité continue, mais pas le travail utile.

---

### Exemple

Deux threads retentent de manière répétée une opération :

- les deux détectent un conflit
- les deux retentent au même moment
- le conflit persiste

Le système reste actif, mais le comportement conflictuel continue indéfiniment.

---

### Impact

- le CPU est utilisé
- aucun travail utile n’est complété

Les livelocks peuvent donc ressembler à du traitement actif même si le progrès effectif est égal à zéro.

---

<a id="1644-starvation"></a>
## 1.6.4.4 Starvation

### Définition

La **starvation** se produit lorsque certains threads n’arrivent pas à obtenir des ressources pendant une période prolongée.

D’autres threads continuent à s’exécuter tandis que certains sont de fait ignorés.

Cela signifie que le système est en train d’opérer du progrès, mais pas d’une manière équitable ou prévisible pour tout le travail.

---

### Causes

- scheduling non équitable
- threads à haute priorité qui dominent l’exécution
- monopolisation des ressources

La starvation est particulièrement problématique lorsqu’un sous-ensemble de requêtes subit une latence extrême tandis que le reste du système paraît fonctionnel.

---

### Impact

- certaines requêtes subissent une latence très élevée
- le système paraît partiellement fonctionnel
- la tail latency augmente

Cela rend la starvation particulièrement pertinente tant du point de vue des performances que de celui de l’expérience utilisateur.

---

<a id="1645-thread-pool-exhaustion"></a>
## 1.6.4.5 Épuisement du thread pool

### Définition

L’**épuisement du thread pool** se produit lorsque tous les threads d’un pool sont occupés et que les tâches entrantes doivent attendre.

C’est l’un des goulets d’étranglement liés à la concurrence les plus communs dans les systèmes réels.

---

### Causes

- opérations bloquantes à l’intérieur des threads
- taille insuffisante du pool
- tâches de longue durée

Ces causes peuvent exister indépendamment ou se renforcer mutuellement sous charge croissante.

---

### Effets

- la file des requêtes croît
- la latence augmente
- le throughput peut se dégrader

Si la saturation continue, l’épuisement du thread pool peut aussi contribuer à des timeouts, des retries et de l’instabilité dans les composants upstream.

---

### Lien avec les concepts précédents

L’épuisement du thread pool est un exemple direct de :

- saturation (→ [1.5.2 Saturation et mise en file](01-05-system-behavior-under-load.md#152-saturation-and-queueing))
- dégradation non linéaire (→ [1.5.3 Dégradation non linéaire](01-05-system-behavior-under-load.md#153-non-linear-degradation))

Il constitue donc l’une des expressions pratiques les plus claires des comportements système introduits dans le chapitre précédent.

---

### Idée clé

Les problèmes de concurrence ne sont pas seulement des problèmes de correction.

Ce sont aussi des problèmes de performance.

De nombreuses dégradations de performance sont causées par :

- contention
- blocking
- défaillances de coordination

Comprendre ces problèmes est essentiel pour diagnostiquer des systèmes réels.