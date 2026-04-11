## 1.4 – Types de tests de performance

<a id="14-types-of-performance-tests"></a>

Ce chapitre introduit les principales catégories de tests de performance utilisées dans la performance engineering.

Chaque type de test de performance répond à une question différente sur le comportement du système sous charge.

Dans leur ensemble, ils aident à évaluer les performances, la stabilité, la scalabilité, la récupération et la capacité du système de manière contrôlée et mesurable.

## Table des matières

- [1.4.1 Objectif du performance testing](#141-purpose-of-performance-testing)
- [1.4.2 Load testing](#142-load-testing)
- [1.4.3 Stress testing](#143-stress-testing)
- [1.4.4 Spike testing](#144-spike-testing)
- [1.4.5 Soak testing](#145-soak-testing)
- [1.4.6 Capacity testing](#146-capacity-testing)

---

<a id="141-purpose-of-performance-testing"></a>
## 1.4.1 Objectif du performance testing

### Définition

Le performance testing, comme déjà abordé dans les paragraphes précédents, évalue comment un système se comporte dans des conditions de workload contrôlé.

Il fournit des données mesurables sur :

- latence  
- throughput  
- taux d’erreur  
- utilisation des ressources  

(→ [1.2 Métriques et formules de base](./01-02-core-metrics-and-formulas.md))

Le performance testing n’est donc pas seulement une activité de mesure, mais aussi une activité de validation.

Il est exploité pour comparer le comportement attendu (défini dans les NFRs) avec le comportement observé dans des conditions de workload définies.

---

### Rôle dans la performance engineering

Le performance testing ne concerne pas seulement la mesure des résultats.

Il est utilisé pour :

- valider le comportement du système dans les conditions attendues  
- faire émerger des goulets d’étranglement et des limitations  
- soutenir le capacity planning  
- valider des décisions architecturales  

Il fournit également un framework contrôlé pour comparer :

- des versions du même système
- différentes configurations
- des changements d’infrastructure
- des choix de tuning

Sans tests contrôlés, les discussions sur les performances restent souvent fondées sur des hypothèses plutôt que sur des preuves.

---

### Le workload comme modèle

Un workload de test représente un modèle simplifié de l’utilisation réelle.

Il définit :

- taux d’arrivée (requêtes par seconde)  
- concurrence (nombre d’utilisateurs ou de requêtes actives)  
- patterns des requêtes (distribution, mix d’opérations)  

(→ [1.2.1 Loi de Little (concurrence au niveau système)](./01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency))

Un workload n’est pas le miroir exact de l’utilisation réelle de production en soi.

C’est une approximation pratique des patterns d’utilisation les plus pertinents.

Pour cette raison, la valeur d’un test de performance dépend fortement du degré de réalisme du modèle de workload.

---

### Conditions contrôlées

Un test de performance n’est significatif que si les conditions d’exécution sont bien définies et contrôlées.

Cela inclut :

- la définition du workload
- la durée du test
- l’environnement dans lequel il est exécuté
- les métriques collectées pendant l’exécution

Si ces conditions ne sont pas claires, les résultats, bien que toujours numériques, seront peu ou totalement dépourvus de valeur de connaissance et de projection.

Le contrôle des conditions initiales est l’un de ces paramètres qui transforme un test d’un simple exercice en une activité d’ingénierie indispensable.

---

Le performance testing est donc le point d’entrée de nombreux concepts développés dans la suite de ce document.

Comme pratique globale de test, il fait émerger :

- effets de mise en file et de saturation (→ [1.5 Comportement du système sous charge](./01-05-system-behavior-under-load.md))
- limites de concurrence (→ [1.6 Concurrence et parallélisme](./01-06-concurrency-and-parallelism.md))
- effets de runtime et de mémoire (→ [1.7 Runtime et modèle de mémoire](./01-07-runtime-and-memory-model.md))
- saturation des ressources (→ [1.8 Performances au niveau ressource](./01-08-resource-level-performance.md))

Pour cette raison, le design des tests devrait toujours être relié à une connaissance approfondie et globale du système.

---

### Signification pratique

Un bon test de performance ne répond pas seulement à :

- « À quelle vitesse le système fonctionne-t-il ? »

Il aide aussi à répondre à :

- « Dans quelles conditions le système reste-t-il stable ? »
- « Qu’est-ce qui change à mesure que la charge augmente ? »
- « Quelle limite est atteinte en premier ? »
- « Quel type de dégradation apparaît ? »

Ces questions sont essentielles en performance engineering parce qu’elles relient la mesure à l’interprétation.

---

### Idée clé

Les tests de performance sont des expériences contrôlées.

Ils sont conçus pour observer le comportement du système dans des conditions spécifiques de workload.

Leur valeur ne réside pas seulement dans les mesures qu’ils produisent, mais surtout dans la compréhension qu’ils fournissent.

---

<a id="142-load-testing"></a>
## 1.4.2 Load testing

### Définition

Le **load testing** évalue le comportement du système sous workload standard ou typique.

C’est la manière la plus commune et la plus directe de valider qu’un système se comporte de manière acceptable dans des conditions opérationnelles normales.

---

### Objectif

- vérifier que le système satisfait les exigences de performance  
- valider des objectifs de latence et de throughput  
- observer l’utilisation des ressources dans des conditions normales  

Le load testing répond à la question de savoir si le système se comporte correctement dans l’intervalle opérationnel qu’il est censé supporter.

---

### Caractéristiques

- le workload est stable et contrôlé  
- le système opère dans son intervalle attendu  
- l’attention est portée sur le comportement en régime stationnaire  

L’objectif n’est pas de pousser le système à ses limites, mais d’établir s’il se comporte correctement sous une charge (de production) pour laquelle il a été conçu.

---

### Exemple

Un système conçu pour :

- 200 requêtes par seconde  
- latence p95 < 300 ms  

Un load test vérifie que ces objectifs sont satisfaits.

Il peut aussi vérifier que :

- le taux d’erreur reste faible
- le throughput reste stable
- l’utilisation des ressources reste dans des limites acceptables

---

### Valeur diagnostique

Le load testing fournit une baseline :

- distribution normale de la latence  
- utilisation typique des ressources  
- throughput attendu  

Cette baseline est essentielle pour la comparaison avec les autres tests.

Sans une baseline fiable, il est difficile de déterminer si le comportement observé dans les tests de stress, spike, soak ou capacity est anormal ou simplement normal pour le système analysé.

---

### Limites du load testing

Le seul load testing ne détermine pas :

- la capacité maximale du système
- les points de rupture du système
- la stabilité à long terme du runtime
- le comportement de récupération après des changements brusques de charge

Un système peut réussir un load test et néanmoins échouer sous surcharge, exécution prolongée ou bursts rapides de trafic.

Pour cette raison, le load testing est nécessaire mais non suffisant.

---

### Interprétation pratique

Le load testing est le point de référence pour le reste de l’analyse de performance.

Il définit le comportement opérationnel normal du système et permet d’interpréter les tests suivants dans leur contexte.

Si le système se comporte déjà mal sous la charge standard, il y a peu de valeur à passer immédiatement à des types de tests plus avancés.

---

### Idée clé

Le load testing répond à : *« Le système se comporte-t-il correctement sous la charge attendue ? »*

Il établit la baseline par rapport à laquelle tous les autres tests de performance peuvent être interprétés.

---

<a id="143-stress-testing"></a>
## 1.4.3 Stress testing

### Définition

Le **stress testing** évalue le comportement du système au-delà de sa capacité attendue.

Il est utilisé pour observer ce qui se passe lorsque le système est poussé hors de son intervalle opérationnel prévu.

---

### Objectif

- identifier les limites du système  
- observer le comportement en surcharge  
- détecter les modes de défaillance  

Le stress testing concerne principalement le comportement à la limite du système et la dégradation des capacités de travail sous une charge excédant les standards prévus.

---

### Caractéristiques

- le workload augmente au-delà des niveaux normaux  
- le système s’approche ou atteint la saturation  

(→ [1.8 Performances au niveau ressource](./01-08-resource-level-performance.md))

La surcharge peut être appliquée progressivement ou maintenue à un niveau clairement excessif.

Dans les deux cas, l’objectif est de faire émerger la manière dont le système se comporte lorsque la demande dépasse la capacité.

---

### Effets observables

- la latence augmente rapidement  
- le throughput se stabilise ou diminue  
- le taux d’erreur augmente  

(→ [1.5.3 Dégradation non linéaire](./01-05-system-behavior-under-load.md#153-non-linear-degradation))  
(→ [1.5.4 Effondrement du throughput](./01-05-system-behavior-under-load.md#154-throughput-collapse))

Des effets supplémentaires peuvent inclure :

- accumulation des files
- amplification des timeouts
- épuisement des pools
- utilisation instable des ressources
- surcharge pilotée par les retries

---

### Valeur diagnostique

Le stress testing révèle :

- des goulets d’étranglement  
- des points de saturation  
- la stabilité du système sous pression  

Il est particulièrement utile pour comprendre si la dégradation est graduelle, brutale, récupérable ou instable.

Deux systèmes avec des résultats similaires dans les load tests peuvent se comporter de manière très différente sous stress.

---

### Comportement en rupture

Un aspect important du stress testing n’est pas seulement si et quand le système échoue, mais comment il échoue.

Les questions pertinentes incluent :

- La latence augmente-t-elle avant que des erreurs n’apparaissent ?
- Les erreurs apparaissent-elles progressivement ou soudainement ?
- Le throughput se stabilise-t-il avant de s’effondrer ?
- Le système récupère-t-il lorsque la charge est réduite ?

Ces questions comptent d’un point de vue opérationnel, parce que la surcharge est un scénario réaliste dans les systèmes de production.

---

### Distinction avec le capacity testing

Le stress testing et le capacity testing sont liés, mais différents.

- le **stress testing** se concentre sur le comportement en surcharge et sur les modes de défaillance
- le **capacity testing** se concentre sur la charge maximale soutenable qui satisfait encore les exigences

Le stress testing continue donc au-delà de l’intervalle opérationnel acceptable pour examiner la dégradation et la rupture.

---

### Interprétation pratique

Le stress testing est utile lorsque la question d’ingénierie n’est pas seulement :

- « Quelle charge le système peut-il supporter ? »

mais aussi :

- « Que se passe-t-il après qu’il ne peut plus supporter la charge ? »
- « Se dégrade-t-il de manière progressive ? »
- « Peut-il récupérer proprement ? »

Ce sont des questions essentielles pour la résilience et la robustesse opérationnelle.

---

### Idée clé

Le stress testing répond à : *« Que se passe-t-il lorsque le système est poussé au-delà de ses limites ? »*

Il révèle comment le système se dégrade, comment il échoue et quelle surcharge il peut tolérer avant de devenir instable.

---

<a id="144-spike-testing"></a>
## 1.4.4 Spike testing

### Définition

Le **spike testing** évalue le comportement du système sous des augmentations soudaines de charge.

Contrairement au load testing ou au stress testing graduel, le spike testing se concentre sur les transitions rapides plutôt que sur des conditions opérationnelles stables.

---

### Objectif

- observer la réaction à des changements brusques du workload  
- évaluer élasticité et récupération  
- détecter une instabilité transitoire  

Le spike testing est particulièrement pertinent pour des systèmes exposés à un trafic bursty, à des pics liés à des campagnes, à une demande pilotée par des événements ou à de brèves montées d’activité.

---

### Caractéristiques

- le workload augmente rapidement et en très peu de temps  
- le système doit s’adapter rapidement  

La caractéristique distinctive n’est pas seulement le volume de charge, mais la vitesse à laquelle la charge change.

Un système peut gérer une charge élevée lorsqu’elle est atteinte progressivement, mais se comporter mal lorsque cette même charge arrive soudainement.

---

### Effets observables

- pics temporaires de latence  
- accumulation de files  
- erreurs potentielles pendant la transition  

(→ [1.5 Comportement du système sous charge](./01-05-system-behavior-under-load.md))

Des effets supplémentaires peuvent inclure :

- réponse retardée du scaling
- épuisement transitoire des connexions
- cascades temporaires de timeouts
- récupération lente après le burst

---

### Valeur diagnostique

Le spike testing révèle :

- sensibilité au trafic bursty  
- comportement de mise en file sous charge soudaine  
- capacité de récupération après le spike  

Ce type de testing est précieux parce que de nombreux systèmes sont optimisés pour des conditions de régime stationnaire mais restent fragiles pendant des transitions brusques.

---

### Comportement de récupération

La partie la plus importante du spike testing est souvent ce qui se passe après le spike.

Les questions pertinentes incluent :

- Le système revient-il rapidement à la latence normale ?
- Les files se vident-elles de manière contrôlée ?
- Les ressources sont-elles libérées correctement ?
- Le système reste-t-il dégradé après que le spike est passé ?

Un système qui survit au spike mais récupère lentement peut malgré tout être opérationnellement faible.

---

### Interprétation pratique

Le spike testing est particulièrement utile pour des systèmes qui sont :

- exposés extérieurement à un trafic bursty
- dépendants de l’auto-scaling ou d’un comportement élastique
- sensibles à l’accumulation de files
- soumis à des changements de demande pilotés par des événements

Dans ces cas, la charge moyenne est souvent moins importante que les pics de courte durée et que la réaction du système à ceux-ci.

---

### Idée clé

Le spike testing répond à : *« Comment le système réagit-il à des changements soudains de charge ? »*

Il évalue non seulement la résistance aux bursts, mais aussi la capacité à récupérer proprement après ceux-ci.

---

<a id="145-soak-testing"></a>
## 1.4.5 Soak testing

### Définition

Le **soak testing** évalue le comportement du système sur une période étendue sous charge soutenue.

Il est parfois aussi appelé endurance testing.

Son objectif est de faire émerger des problèmes qui n’apparaissent pas dans des tests de courte durée.

---

### Objectif

- détecter des problèmes de long terme  
- observer la stabilité dans le temps  
- identifier une dégradation graduelle  

Le soak testing concerne moins la performance de pointe et davantage la cohérence, l’accumulation et la dérive.

---

### Caractéristiques

- le workload est constant ou varie lentement  
- la durée du test est longue (heures ou jours)  

La dimension clé est le temps.

Certains systèmes se comportent correctement pendant quelques minutes mais se dégradent après des heures en raison d’effets d’accumulation.

---

### Effets observables

- croissance de la mémoire  
- fuites de ressources  
- dégradation des performances dans le temps  

(→ [1.7 Runtime et modèle de mémoire](./01-07-runtime-and-memory-model.md))

Des symptômes supplémentaires de longue durée peuvent inclure :

- accumulation de threads
- leakage de connexions
- files en lente augmentation
- croissance de l’overhead du GC
- déséquilibre du cache ou rétention incontrôlée

---

### Valeur diagnostique

Le soak testing révèle :

- slow memory leak  
- épuisement des ressources  
- instabilité de long terme  

C’est souvent le seul moyen fiable de valider si le système reste sain et exploitable pendant une activité prolongée.

Cela est essentiel pour les systèmes de production qui doivent fonctionner en continu.

---

### Dégradation dépendante du temps

Le soak testing est important parce que certaines ruptures ne sont pas basées sur des seuils, mais sur le temps.

Des exemples incluent :

- mémoire retenue lentement dans le temps
- pools non complètement libérés
- tasks en background qui accumulent de la dérive
- patterns de retry qui augmentent lentement la pression
- caches qui croissent sans eviction efficace

Ces problèmes peuvent ne pas apparaître dans des load tests ou des stress tests de courte durée.

---

### Valeur opérationnelle

Un système qui se comporte bien pendant dix minutes mais se dégrade après six heures n’est pas stable.

Le soak testing contribue donc directement à :

- validation pour la mise en production
- confiance dans le runtime
- évaluation de la fiabilité de long terme
- dimensionnement de l’infrastructure et du runtime

Il aide aussi à valider que le monitoring reste significatif sur de longues périodes d’opérativité.

---

### Interprétation pratique

Le soak testing est particulièrement important pour des systèmes avec :

- longs uptimes
- traitement en background
- runtimes avec gestion de la mémoire
- architectures riches en connexions
- pools de ressources qui changent lentement dans le temps

Dans de tels systèmes, les résultats de performance de courte durée ne sont pas suffisants pour garantir la stabilité réelle.

---

### Idée clé

Le soak testing répond à : *« Le système reste-t-il stable dans le temps ? »*

Il valide le comportement de longue durée et révèle des problèmes causés par l’accumulation, la dérive et la dégradation lente.

---

<a id="146-capacity-testing"></a>
## 1.4.6 Capacity testing

### Définition

Le **capacity testing** détermine le workload maximal qu’un système peut gérer tout en satisfaisant les exigences de performance.

Il est utilisé pour identifier la limite opérationnelle pratique du système dans des conditions acceptables.

---

### Objectif

- identifier le throughput maximal soutenable  
- déterminer des limites opérationnelles sûres  
- soutenir le capacity planning  

Le capacity testing est donc directement relié à la planification, au dimensionnement, au forecasting et aux décisions opérationnelles.

---

### Méthode

- éventuels tests unitaires pour baseline dimensionnelle
- augmenter graduellement le workload  
- surveiller latence, throughput et erreurs  
- identifier le point où les performances se dégradent  

L’augmentation de la charge devrait être contrôlée et mesurable.

Cela permet de localiser la limite du système avec une plus grande précision que dans un stress test purement exploratoire.

---

### Interprétation

La limite de capacité est atteinte lorsque :

- la latence dépasse des seuils acceptables  
- le taux d’erreur augmente  
- le throughput ne scale plus  

(→ [1.2 Métriques et formules de base](./01-02-core-metrics-and-formulas.md))  
(→ [1.5 Comportement du système sous charge](./01-05-system-behavior-under-load.md))

En pratique, la limite n’est pas toujours une seule valeur exacte.

Elle peut être mieux comprise comme un intervalle dans lequel le comportement acceptable commence à se détériorer.

---

### Ce que révèle le capacity testing

Le capacity testing révèle :

- la charge soutenable la plus élevée sous des critères d’acceptation définis
- la marge entre la charge attendue et la charge maximale acceptable
- la relation entre demande croissante et comportement dégradé
- le point où une charge supplémentaire ne produit plus de throughput utile

Ces informations sont essentielles pour des décisions d’ingénierie et de planification.

---

### Relation avec le capacity planning

Le capacity testing est l’un des principaux inputs du capacity planning.

Il aide à répondre à des questions telles que :

- Quel trafic le système actuel peut-il supporter ?
- Quelle headroom est disponible ?
- Quand faudra-t-il scaler ?
- Quel composant contraint en premier la capacité ?

Cela rend le capacity testing particulièrement utile pour le forecasting et la préparation opérationnelle.

---

### Distinction avec le stress testing

Le capacity testing ne consiste pas à forcer l’échec pour l’échec lui-même.

Il consiste à identifier la charge la plus élevée qui satisfait encore des exigences définies.

- le **capacity testing** s’arrête à la limite acceptable ou près de celle-ci
- le **stress testing** continue au-delà de cette limite pour examiner le comportement en surcharge

La distinction compte parce que de nombreuses décisions business et d’ingénierie dépendent d’une opération sûre, non d’un échec total.

---

### Signification pratique

La capacité n’est pas seulement un nombre.

Elle dépend de :

- mix du workload
- niveau de concurrence
- objectifs de latence
- taux d’erreur acceptable
- contraintes sur les ressources

Pour cette raison, toute valeur de capacité doit toujours être interprétée dans le contexte du workload et des critères d’acceptation utilisés pendant le test.

---

### Interprétation pratique

Le capacity testing est plus utile lorsque l’objectif d’ingénierie est de répondre à :

- « Quel est l’intervalle opérationnel sûr ? »
- « Quelle headroom avons-nous ? »
- « Quand devons-nous scaler ? »
- « Qu’est-ce qui contraint la croissance future ? »

Il est donc l’une des formes de performance testing les plus orientées vers la décision.

---

### Idée clé

Le capacity testing répond à : *« Jusqu’à quel point le système peut-il scaler avant de se dégrader ? »*

Il identifie l’intervalle opérationnel soutenable maximal, et non seulement le point de défaillance.