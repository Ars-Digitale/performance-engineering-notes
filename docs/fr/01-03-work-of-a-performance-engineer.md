# 1.3 – Travail d’un performance engineer

<a id="13-work-of-a-performance-engineer"></a>

Cette section décrit ce qu’est, en pratique, la performance engineering et comment elle est appliquée aux systèmes réels.

## Table des matières

- [1.3.1 Ce qu’est la performance engineering (en pratique)](#131-what-performance-engineering-is-in-practice)
- [1.3.2 Workflow typique](#132-typical-workflow)
- [1.3.3 Black-box vs white-box](#133-black-box-vs-white-box)
- [1.3.4 Load testing vs diagnostic](#134-load-testing-vs-diagnostics)
- [1.3.5 Ce qui compte vraiment (et ce qui ne compte pas)](#135-what-actually-matters-and-what-doesnt)

---

<a id="131-what-performance-engineering-is-in-practice"></a>
## 1.3.1 Ce qu’est la performance engineering (en pratique)

### Définition

La performance engineering est la discipline qui consiste à comprendre, mesurer et contrôler la manière dont un système se comporte sous charge.

Elle ne se limite ni au performance testing, ni à des outils ou technologies spécifiques.

Elle se réfère plutôt à une méthodologie globale de raisonnement sur les systèmes sous charge ou, éventuellement, sous stress.

Elle se concentre sur le comportement global du système et non sur des métriques isolées ou sur des composants individuels.

---

### Performance et exigences non fonctionnelles

La performance engineering ne se concentre pas sur une seule propriété.

Lorsqu’un système est exercé sous charge, un sous-ensemble d’**exigences non fonctionnelles (NFR)** devient visible :

- latence et throughput (performance)
- scalabilité (verticale et horizontale)
- stabilité et résilience sous stress
- utilisation des ressources et efficacité
- limites de capacité

Ces propriétés ne sont pas indépendantes entre elles.

Elles émergent toutes ensemble à mesure que le système est amené à ses limites.

La charge agit comme une **forcing function** qui révèle la manière dont le système se comporte.

Un système qui paraît parfaitement équilibré à faible charge peut montrer un comportement complètement différent lorsqu’il est stressé.

---

### Ce que la performance engineering observe réellement

Sous charge, un système révèle :

- comment le travail traverse ses composants
- comment les ressources sont consommées
- où apparaissent des contentions (contention)
- où se forment les files (queueing)
- quelles sont les limites qui sont atteintes en premier

Cela requiert :

- comprendre le modèle du système (→ [1.1 Fondements](01-01-foundations.md))
- mesurer les métriques clés (→ [1.2 Métriques et formules de base](01-02-core-metrics-and-formulas.md))
- identifier les facteurs limitants

L’objectif, de manière évidente, n’est pas seulement d’observer le comportement du système, mais aussi de l’expliquer.

---

### Pas seulement du testing

La performance engineering est souvent réduite au seul **load testing**.

En pratique, la phase de testing n’est qu’une partie du travail.

Les tests sont utilisés pour :

- exposer le comportement du système
- valider des hypothèses
- reproduire des problèmes

Mais la performance engineering comprend également :

- analyser le design du système
- investiguer des problèmes de production
- dimensionner les ressources (heap, pools, threads, connexions)
- expliquer le comportement observé

Le testing sans analyse produit des données sans compréhension.

---

### Perspective pratique

Dans les scénarios réels, le travail implique typiquement :

- préparer et calibrer les environnements de test
- interpréter les exigences non fonctionnelles (NFRs)
- identifier et définir des scénarios de test (significatifs) par rapport aux NFRs
- valider le comportement avec des cas d’usage contrôlés
- appliquer de la charge ou du stress pour faire émerger les problèmes (souvent en white-box)
- identifier et corriger les goulets d’étranglement
- dimensionner les composants du système (CPU, mémoire, pools, limites de concurrence)
- ajuster les configurations et les paramètres (Tuning)
- exécuter des benchmarks pour établir des points de référence
- exécuter des tests de longue durée (soak / endurance) pour valider la stabilité dans le temps

Ces activités ne sont pas isolées.

Elles font partie d’un processus continu orienté vers la compréhension des possibilités et des limites du système.

---

### Idée clé

La performance engineering ne consiste pas (seulement) à rendre un système plus rapide et plus performant.

Elle comprend au contraire un ensemble d’activités et de tâches visant à comprendre comment un système se comporte sous charge de travail, et à s’assurer qu’il reste :

- prévisible
- stable
- scalable

La plupart des problèmes ne sont pas causés par une seule opération « lente », mais par :

- interactions entre composants
- accumulation des temps d’attente
- saturation de ressources partagées

Ces mécanismes constituent, ensemble, le noyau de la performance engineering.

---

<a id="132-typical-workflow"></a>
## 1.3.2 Workflow typique

La performance engineering est un processus itératif dans lequel le système est progressivement exercé, analysé, stabilisé et compris sous des niveaux croissants de charge.

L’objectif n’est pas seulement de détecter des problèmes, mais de construire un modèle fiable de la manière dont le système se comporte dans des conditions réalistes (et limites) de production.

---

<a id="1321-environment-preparation-and-calibration"></a>
### 1.3.2.1 Préparation et calibration de l’environnement

- vérifier et aligner l’environnement de test sur les caractéristiques de la production (autant que possible)
- vérifier les configurations (CPU, mémoire, pools, connexions)
- garantir l’observabilité (métriques, logs, traces)

Objectif :

- établir une baseline fiable
- garantir la répétabilité des résultats

Sans calibration, les mesures sont difficiles (ou impossibles) à interpréter et les comparaisons deviennent à tout le moins peu fiables.

---

<a id="1322-use-case-definition-and-workload-modeling"></a>
### 1.3.2.2 Définition des cas d’usage et modélisation du workload

Avant d’appliquer de la charge au système, le workload doit être défini.

Un système n’est pas testé en isolation, mais à travers les requêtes qu’il traite.

Cela requiert l’identification précise de :

- les chemins critiques utilisateur et système
- les opérations typiques (read, write, batch, background job)
- la fréquence relative de chaque opération
- les patterns de concurrence

Un workload réaliste inclut :

- un mix de cas d’usage (Use Cases)
- une distribution pondérée (ex. pourcentages de trafic)
- différents types de requêtes et différents coûts

La définition du workload est l’une des étapes les plus critiques et doit être réalisée en étroite collaboration avec ceux qui définissent les exigences non fonctionnelles (NFRs).

Un workload incorrect mène à des conclusions trompeuses, voire totalement inutiles.

---

<a id="1322-non-functional-requirements"></a>
### Exigences non fonctionnelles (NFR)

En parallèle avec la définition du workload, les **exigences non fonctionnelles** doivent être clarifiées.

Elles définissent ce qui est considéré comme un **comportement acceptable du système**.

Exemples typiques :

- objectifs de throughput (ex. 30 req/s)
- niveaux de concurrence (ex. 500 utilisateurs concurrents)
- objectifs de latence (ex. p95 < 200 ms)
- seuils du taux d’erreur
- contraintes sur l’utilisation des ressources

Les NFR peuvent être :

- définies explicitement par les parties prenantes
- définies seulement partiellement
- manquantes ou incohérentes

Dans tous les cas, elles doivent être :

- réexaminées
- validées
- rendues mesurables

---

### Implication pratique

Le workload et les NFR doivent être alignés.

Pour chaque cas d’usage :

- la charge attendue doit être définie
- le comportement acceptable doit être connu

Sinon :

- les résultats ne peuvent pas être évalués
- les tests ne peuvent être considérés ni comme réussis ni comme échoués

Une définition incorrecte du workload ou l’absence de NFR conduit à des résultats techniquement corrects, mais non actionnables.

---

<a id="1323-initial-load-stress-testing"></a>
### 1.3.2.3 Tests initiaux de charge / stress (découverte des problèmes)

La première phase de « load test » vise à faire émerger une baseline de référence et d’éventuels problèmes principaux.

Objectifs typiques :

- identifier des goulets d’étranglement évidents
- détecter des erreurs fonctionnelles sous charge
- faire émerger des instabilités (timeouts, crashs, saturation)

Cette phase est souvent :

- exploratoire
- itérative
- partiellement white-box (en utilisant une visibilité interne)

L’objectif est la découverte, non la précision.

---

<a id="1324-analysis-and-bottleneck-identification"></a>
### 1.3.2.4 Analyse et identification des goulets d’étranglement

Une fois que les problèmes ont émergé, le système doit être analysé en détail.

Cela implique :

- corréler les métriques (latence, throughput, utilisation)
- identifier où le temps est dépensé
- localiser les points de saturation et les files

Questions typiques :

- quelle ressource est saturée ?
- où la latence s’accumule-t-elle ?
- qu’est-ce qui limite le throughput ?

Cette étape s’appuie sur :

→ [1.1 Fondements](01-01-foundations.md)  
→ [1.2 Métriques et formules de base](01-02-core-metrics-and-formulas.md)

---

<a id="1325-fixes-and-iterative-validation"></a>
### 1.3.2.5 Corrections et validation itérative

Après avoir identifié les goulets d’étranglement, les correctifs doivent être appliqués.

Ils peuvent inclure :

- modifications du code
- mises à jour de configuration
- ajustements des ressources (scalabilité verticale/horizontale)

Chaque correction doit être validée en relançant les tests.

Cela crée une boucle itérative :

- **Test** → **Analyse** → **Corrige** → **Teste** à nouveau

L’objectif est de stabiliser progressivement le système.

---

<a id="1326-intermediate-validation"></a>
### 1.3.2.6 Validation intermédiaire (baseline stable)

Avant de passer à des tests ultérieurs et de longue durée, le système doit atteindre une baseline stable.

Cela signifie :

- aucune erreur critique sous la charge attendue
- comportement prévisible
- latence et taux d’erreur sous contrôle

Cette phase garantit que :

- les problèmes principaux sont résolus
- les résultats sont reproductibles

---

<a id="1327-long-duration-validation"></a>
### 1.3.2.7 Validation de longue durée (soak / endurance)

Une fois qu’on s’est assuré que le système est stable, il doit être investigué dans la durée.

Cette phase évalue le comportement du système sous une charge de travail soutenue dans le temps.

Objectifs typiques :

- détecter des memory leaks lents
- observer l’accumulation de ressources (threads, connexions, buffers)
- identifier des dégradations de performance dans la durée
- valider la stabilité à long terme

Cette phase est essentielle parce que certains problèmes :

- n’apparaissent pas immédiatement
- émergent seulement après un exercice prolongé

Les résultats de cette phase ont un impact direct sur :

- dimensionnement du système
- capacity planning
- configuration de runtime

---

<a id="1328-dimensioning-and-capacity-definition"></a>
### 1.3.2.8 Dimensionnement et définition de la capacité

Sur la base des observations précédentes, et aussi à partir d’éventuels tests unitaires successifs à la phase de stabilisation de la baseline, les composants du système sont dimensionnés.

Cette phase inclut :

- configuration du heap et des mémoires
- thread pools et connection pools
- limites de concurrence
- dimensionnement de l’infrastructure
- clustering

L’objectif est de définir :

- quelle charge le système peut supporter
- dans quelles conditions il reste stable
- quelles marges éventuelles sont requises

Le dimensionnement doit se baser sur le comportement observé, et non sur des hypothèses.

---

<a id="1329-tuning"></a>
### 1.3.2.9 Tuning

Une fois le dimensionnement défini, le tuning affine le comportement du système.

Domaines typiques :

- paramètres du garbage collector
- scheduling des threads et dimensionnement des pools
- paramètres de la base de données et des connexions
- stratégies de caching

Le tuning vise à :

- réduire la latence
- améliorer la stabilité
- optimiser l’utilisation des ressources

Il est souvent itératif et dépendant du contexte spécifique.

---

<a id="13210-verification-and-regression"></a>
### 1.3.2.10 Vérification et régression

Après la phase de tuning, le système doit être validé à nouveau.

Cela inclut :

- rejouer les scénarios clés
- vérifier que les améliorations sont effectives
- s’assurer qu’aucune régression n’est introduite

Cette phase garantit cohérence et fiabilité.

---

<a id="13211-benchmarking"></a>
### 1.3.2.11 Benchmarking et points de référence

Enfin, les benchmarks sont établis.

Ils fournissent :

- des métriques de performance de référence
- des points de comparaison entre versions
- une validation par rapport aux attentes

Les benchmarks ne sont pas des objectifs en eux-mêmes.

Ils sont utilisés pour :

- comprendre le comportement du système
- suivre son évolution dans le temps

---

### Idée clé

La performance engineering se développe selon une boucle itérative :

- **définis le workload** → **teste** → **analyse** → **corrige** → **valide** → **optimise**

L’objectif n’est pas seulement d’améliorer les performances, mais de comprendre les limites du système et de garantir un comportement prévisible sous charge.

---

<a id="133-black-box-vs-white-box"></a>
## 1.3.3 Black-box vs white-box

La performance engineering peut être abordée selon deux perspectives complémentaires :

- **black-box** (observation externe)
- **white-box** (observation interne)

Les deux sont nécessaires pour comprendre le comportement du système sous charge de travail.

---

<a id="1331-black-box"></a>
### 1.3.3.1 Approche black-box

Dans une approche black-box, le système est observé depuis l’extérieur.

Seul le comportement visible extérieurement est mesuré :

- temps de réponse
- throughput
- taux d’erreur

L’implémentation interne n’est pas prise en considération.

---

### Ce que cela fournit

L’observation black-box permet de :

- valider le comportement du système du point de vue de l’utilisateur
- mesurer les performances end-to-end
- détecter des erreurs visibles sous charge

Elle répond à des questions telles que :

- Le système est-il suffisamment rapide ?
- Gère-t-il la charge attendue ?
- Échoue-t-il sous stress ?

---

### Limites

Le seul black-box ne peut pas expliquer :

- où éventuellement du temps est le plus souvent dépensé
- quelle ressource est saturée
- pourquoi les performances se dégradent

Il montre les symptômes, non les causes.

---

<a id="1332-white-box"></a>
### 1.3.3.2 Approche white-box

Dans une approche white-box, le comportement interne du système est observé.

Cela inclut :

- utilisation des ressources (CPU, mémoire, disque, réseau)
- thread pools et connection pools
- files internes
- temps au niveau des composants

L’observation white-box fournit un niveau d’**introspection dans l’exécution du système**.

Dans de nombreux cas, cela inclut une visibilité proche du niveau du code :

- temps au niveau des méthodes
- call paths et flux d’exécution
- hotspots (méthodes lentes ou exécutées fréquemment)
- patterns d’allocation et comportement mémoire
- contention sur les verrous et points de synchronisation

---

### Ce que cela fournit

L’observation white-box permet de :

- identifier les goulets d’étranglement
- comprendre où le temps est dépensé
- détecter la contention (contentio) et la mise en file (queueing)
- analyser la saturation des ressources

Elle répond à des questions telles que :

- Quel composant est lent ?
- Où la latence s’accumule-t-elle ?
- Qu’est-ce qui limite le throughput ?
- Quelle partie de l’exécution est responsable du ralentissement ?

---

### Limites

Le seul white-box ne garantit pas :

- un comportement end-to-end correct
- une expérience utilisateur acceptable

Un système peut paraître intérieurement efficace, tout en échouant sous des conditions de workload réel.

---

<a id="1333-observability-and-tooling"></a>
### 1.3.3.3 Observabilité et instrumentation

L’observabilité fournit les données nécessaires à l’analyse white-box.

Elle inclut typiquement :

- métriques système et applicatives (ex. utilisation CPU, latence, throughput)
- logs (événements, erreurs, changements d’état)
- traces (flux des requêtes entre composants)
- application performance monitoring (APM)

Ces sources fournissent une visibilité continue sur le comportement du système.

---

### Artifacts diagnostiques

En plus de l’observabilité continue, une analyse plus profonde se base souvent sur des artifacts diagnostiques.

Ceux-ci sont typiquement collectés on demand et fournissent un snapshot de l’état du système.

Exemples courants :

- thread dumps (états des threads, verrous, contention)
- heap dumps (utilisation mémoire, rétention des objets, leaks)
- snapshots de profiling (profiling CPU et allocations)
- core dumps (analyse des défaillances au niveau du processus)

Ces artifacts permettent de :

- inspecter l’état interne de l’exécution
- identifier des threads bloqués et des deadlocks
- analyser des memory leaks et des retention paths
- investiguer en détail des anomalies de performance

Ils sont en général plus lourds et plus intrusifs que les outils d’observabilité, et sont utilisés de manière sélective pendant le diagnostic.

---

<a id="1334-combining-both"></a>
### 1.3.3.4 Combiner les deux approches

Une performance engineering efficace requiert la combinaison des deux perspectives.

Workflow typique :

- utiliser le black-box pour détecter les problèmes
- utiliser le white-box pour les expliquer
- valider à nouveau les améliorations avec le black-box

Cela crée une boucle de feedback :

- **observe** → **analyse** → **corrige** → **valide**

---

### Idée clé

L’observation **black-box** révèle qu’un problème existe.

L’observation **white-box** explique pourquoi il existe.

Les deux sont nécessaires pour comprendre et contrôler le comportement du système sous charge.

---

<a id="134-load-testing-vs-diagnostics"></a>
## 1.3.4 Load testing vs diagnostic

Le load testing et le diagnostic sont souvent confondus.

Ils servent des objectifs différents et opèrent à des niveaux différents.

Les deux sont nécessaires pour comprendre le comportement du système sous charge de travail.

---

<a id="1341-load-testing"></a>
### 1.3.4.1 Load testing

Le load testing applique un workload contrôlé au système.

Il est utilisé pour :

- observer le comportement dans des conditions spécifiques
- mesurer la latence, le throughput et les taux d’erreur
- valider des hypothèses sur la capacité et la scalabilité

Le load testing opère principalement au niveau **black-box** :

- les requêtes sont générées extérieurement
- les réponses sont mesurées extérieurement

---

### Ce que cela fournit

Le load testing répond à des questions telles que :

- Le système peut-il supporter la charge attendue ?
- Que se passe-t-il lorsque la charge augmente ?
- Quand les performances se dégradent-elles ?
- Quel est le throughput maximal soutenable ?

---

### Limites

Le seul load testing n’explique pas :

- pourquoi le système ralentit
- quel composant est responsable
- comment les ressources sont utilisées en interne

Il révèle le comportement, mais non les causes.

---

<a id="1342-diagnostics"></a>
### 1.3.4.2 Diagnostic

Le diagnostic investigue le comportement interne du système.

Il est utilisé pour :

- identifier les goulets d’étranglement
- comprendre les chemins d’exécution
- analyser l’utilisation des ressources
- expliquer les problèmes de performance observés

Le diagnostic opère au niveau **white-box** :

- des métriques internes sont analysées
- des traces et des chemins d’exécution sont inspectés
- des artifacts diagnostiques peuvent être collectés

---

### Ce que cela fournit

Le diagnostic répond à des questions telles que :

- Où le temps est-il dépensé ?
- Quelle ressource est saturée ?
- Quel composant est responsable de la latence ?
- Qu’est-ce qui cause la dégradation des performances ?

---

### Outils et techniques

Le diagnostic se base typiquement sur :

- métriques, logs et traces
- application performance monitoring (APM)
- thread dumps et heap dumps
- profiling et analyse de l’exécution

---

### Limites

Le diagnostic sans load testing peut ne pas saisir :

- des conditions de workload réel
- des interactions entre composants
- le comportement sous stress

Il peut expliquer un problème, mais pas nécessairement le reproduire.

---

<a id="1343-relationship-between-load-testing-and-diagnostics"></a>
### 1.3.4.3 Relation entre load testing et diagnostic

Le load testing et le diagnostic doivent être combinés.

Workflow typique :

- appliquer de la charge pour exposer le comportement
- utiliser le diagnostic pour analyser l’état interne
- appliquer des corrections
- valider à nouveau avec le load testing

Cela crée une boucle :

- observe → explique → corrige → valide

---

### Idée clé

Le load testing révèle qu’un problème existe.

Le diagnostic explique pourquoi il existe.

Aucun des deux n’est suffisant à lui seul.

La compréhension du comportement du système requiert les deux.

---

<a id="135-what-actually-matters-and-what-doesnt"></a>
## 1.3.5 Ce qui compte vraiment (et ce qui ne compte pas)

La performance engineering implique un ensemble étendu d’outils, de métriques et de techniques.

Cependant, toutes ne peuvent pas avoir le même niveau d’importance dans des contextes hétérogènes.

Comprendre ce qui compte est essentiel pour éviter de gaspiller des efforts et de tirer des conclusions erronées.

---

### Ce qui compte

Les aspects les plus importants sont :

- **comprendre le comportement du système sous charge**
- **identifier les goulets d’étranglement et les facteurs limitants**
- **utiliser des workloads réalistes et des NFR validés**
- **raisonner sur les interactions entre composants**
- **mesurer et interpréter correctement les résultats**

La performance engineering concerne principalement :

- construire un modèle mental du système
- valider ce modèle à travers des observations
- l’affiner par itération

---

### Ce qui ne compte pas (autant qu’il semble)

Certains aspects sont souvent excessivement mis en avant :

- outils et frameworks
- métriques isolées sans contexte
- scénarios de test synthétiques ou irréalistes
- micro-optimisations sans impact au niveau système
- résultats d’un seul test pris isolément

Ces éléments peuvent être utiles, mais ils ne sont pas suffisants.

---

### Malentendus courants

Divers malentendus apparaissent fréquemment :

- « Si j’exécute un load test, je comprends le système »
- « Si le CPU est bas, le système est sain »
- « Si la latence moyenne est acceptable, le système va bien »
- « Plus de matériel résoudra le problème »

Ces hypothèses conduisent souvent à des conclusions incorrectes.

---

### Pensée au niveau système

Les performances émergent des interactions :

- entre composants
- entre workload et ressources
- entre concurrence et mise en file

Se concentrer sur une seule partie du système est rarement suffisant.

Ce qui est nécessaire, c’est une vision globale.

---

### Implication pratique

Une performance engineering efficace requiert :

- poser les bonnes questions
- valider les hypothèses
- corréler des signaux multiples
- itérer sur la base des preuves

Outils, tests et métriques soutiennent ce processus, mais ne le remplacent pas.

---

### Idée clé

La performance engineering ne consiste pas à collecter des données.

Elle consiste à comprendre ce que les données signifient.

L’objectif n’est pas de produire des chiffres, mais d’expliquer le comportement du système et de prendre des décisions éclairées.