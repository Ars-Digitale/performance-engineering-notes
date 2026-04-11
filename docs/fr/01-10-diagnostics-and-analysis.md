## 1.10 – Diagnostic et analyse

<a id="110-diagnostics-and-analysis"></a>

Ce chapitre s’intéresse à la manière dont les problématiques de performance peuvent être investiguées, interprétées et validées.

On se concentre ici sur les processus utilisés pour passer de l’observation du système à une évaluation défendable de la performance de celui-ci.

Le diagnostic en effet n’est pas seulement une pratique de collecte des données.
  
C’est la discipline qui se préoccupe d’interpréter correctement ces données et de relier les symptômes aux mécanismes de fonctionnement sous-jacents.

## Table des matières

- [1.10.1 Observabilité et signaux](#1101-observability-and-signals)
- [1.10.2 Symptôme vs cause](#1102-symptom-vs-cause)
- [1.10.3 Corrélation et causalité](#1103-correlation-and-causality)
- [1.10.4 Construire une hypothèse](#1104-building-a-hypothesis)
- [1.10.5 Réduire le goulot d’étranglement](#1105-narrowing-down-the-bottleneck)
- [1.10.6 Analyse itérative et validation](#1106-iterative-analysis-and-validation)

---

<a id="1101-observability-and-signals"></a>
## 1.10.1 Observabilité et signaux

### Définition

Le diagnostic part évidemment de signaux observables.

Ces signaux fournissent une visibilité souvent indirecte sur le comportement interne du système sous charge.
  
Ils n’exposent pas directement les mécanismes de fonctionnement, mais en reflètent plutôt les effets.

Pour cette raison l’observabilité est essentielle dans la performance engineering : les problèmes internes sont rarement visibles directement, mais ils laissent souvent des traces mesurables en ce qui concerne la latence, le throughput, le comportement des ressources et le queueing.

---

### Signaux fondamentaux

Les signaux primaires sont :

- latence (p50, p95, p99)  
- throughput  
- taux d’erreur  
- utilisation des ressources (CPU, mémoire, I/O, réseau)  
- longueurs des files  

(→ [1.2 Core metrics and formulas](./01-02-core-metrics-and-formulas.md))  
(→ [1.8 Resource-level performance](./01-08-resource-level-performance.md))

Chaque signal capture une dimension différente du comportement du système.
  
Seul un examen combiné de ceux-ci fournit une vue significative du système.

- La latence montre l’impact visible pour l’utilisateur.  
- Le throughput montre le taux de travail productif.  
- Le taux des erreurs indique le comportement en cas de défaillance.  
- Les indices des ressources montrent où la capacité est consommée.  
- Les files montrent où le travail s’accumule.

---

### Caractéristiques des signaux

Les signaux doivent être :

- **précis** → refléter le comportement réel  
- **granulaires** → exposer la distribution (ex. percentiles, pas seulement moyennes)  
- **corrélés dans le temps** → alignés à travers tous les composants  

Sans ces propriétés, l’interprétation devient peu fiable, trompeuse ou même erronée.

Une métrique mal placée, pas bien configurée ou même déconnectée de l’intervalle de temps pertinent peut cacher précisément ce mécanisme de fonctionnement qu’elle entend au contraire révéler.

---

### Qualité du signal et interprétation

La présence de signaux n’est toutefois pas à elle seule suffisante.

Les signaux doivent aussi être :

- pertinents par rapport aux questions que l’on se pose
- observés par rapport au niveau approprié (système, service, ressource, dépendance)
- interprétés dans le contexte

Par exemple :

- l’utilisation CPU sans information sur la run queue peut cacher de la pression de scheduling
- la latence moyenne sans analyse des percentiles peut cacher de l’instabilité en queue
- l’utilisation de la mémoire sans comportement de la GC peut cacher de la pression du runtime

La valeur diagnostique d’une métrique dépend non seulement de son existence, mais de la manière dont elle est corrélée avec le reste des évidences.

---

### Implications pratiques

Un diagnostic efficace nécessite de :

- observer de manière globale les signaux  
- corréler ces signaux dans le temps  
- éviter le raisonnement basé sur des métriques uniques  

Observer une métrique en dehors d’un contexte est souvent trompeur en ce qui concerne la compréhension de la mécanique sous-jacente.

C’est l’une des principales raisons pour lesquelles des explications simplistes sont dangereuses dans l’analyse des performances.

Un seul nombre peut décrire un symptôme, mais explique rarement le comportement global du système en question.

---

### Interprétation pratique

L’observabilité est la matière première du diagnostic.

Sans signaux, il n’existe pas d’analyse fiable.  
Avec des signaux de mauvaise qualité, l’analyse sera peu fiable.  
Avec des signaux bien structurés, l’analyse devient vérifiable et répétable.

Le diagnostic commence donc non avec l’optimisation, mais avec l’analyse de ce qui est observé.

---

### Idée clé

Le diagnostic dépend à la fois de la disponibilité et de la correcte interprétation des signaux observables.

---

<a id="1102-symptom-vs-cause"></a>
## 1.10.2 Symptôme vs cause

### Définition

Un symptôme est un effet observable.

Une cause est le mécanisme sous-jacent qui produit cet effet.

Cette distinction est fondamentale parce que la majorité des problèmes de performance est découverte à travers des symptômes, non à travers une manifestation directe de la cause à la racine du problème.

---

### Distinction

Symptômes typiques :

- latence élevée  
- utilisation importante de la CPU  
- augmentation du taux d’erreur  
- garbage collection fréquente  

Ces éléments décrivent *ce qui se passe*, non *pourquoi cela se passe*.

Un système peut montrer le même symptôme pour des raisons très différentes, et la même cause peut produire des symptômes différents selon la charge, le timing et l’architecture.

---

### Exemple

- une utilisation élevée de la CPU peut résulter de :

  - calcul inefficace  
  - retries excessifs  
  - pression de mémoire  
  - contention  

- une latence élevée peut résulter de :

  - accumulation de files  
  - retards d’I/O  
  - synchronisation  

(→ [1.9 Common performance problems](./01-09-common-performance-problems.md))

Pour ces raisons les symptômes doivent être traités comme des points d’accès à l’investigation, non comme des explications.

---

### Implication diagnostique

Le même symptôme peut être produit par des causes différentes.

Sans identifier le mécanisme sous-jacent, les actions correctives peuvent prendre pour cible la mauvaise partie du système.

Par exemple :

- réduire l’utilisation de la CPU peut ne pas réduire la latence si la cause racine est le queueing I/O  
- faire du tuning de la GC peut ne pas aider si le taux d’allocation d’objets reste inchangé  

Un fix techniquement plausible peut donc avoir peu d’effet s’il ne traite qu’une seule conséquence visible.

---

### Pourquoi la confusion se produit

Symptômes et causes sont souvent confondus parce que les symptômes sont relativement faciles à observer.

Les métriques, les dashboards et les systèmes de monitoring montrent habituellement :

- des valeurs élevées
- ce qui est lent
- ce qui est en train d’échouer

Ils n’expliquent pas automatiquement :

- pourquoi les valeurs sont élevées
- pourquoi c’est lent
- pourquoi cela est en train d’échouer

Cet écart entre visibilité et explication est exactement ce que le diagnostic doit combler.

---

### Interprétation pratique

Un bon processus diagnostique traite chaque symptôme comme un indice, non comme une conclusion.

L’objectif est de passer de :

- “cette métrique est anormale”

à :

- “ce mécanisme est en train de produire le comportement anormal”

Ce déplacement est ce qui distingue un raisonnement efficace sur les performances d’un monitoring superficiel.

---

### Idée clé

Le comportement observé n’est pas la cause.

Le diagnostic requiert de mapper les symptômes aux mécanismes sous-jacents qui les génèrent.

---

<a id="1103-correlation-and-causality"></a>
## 1.10.3 Corrélation et causalité

### Définition

La corrélation est la variation simultanée de deux signaux.

La causalité est une relation directe dans laquelle un facteur en produit un autre.

Cette distinction est essentielle dans le diagnostic parce que beaucoup de métriques évoluent ensemble sous charge, mais elles ne sont pas toutes causalement reliées dans la même direction.

---

### Erreur commune

Deux métriques changent ensemble :

- la CPU augmente  
- la latence augmente  

Cela n’implique pas que la CPU soit la cause de la latence.

La corrélation peut indiquer :

- une cause sous-jacente commune
- une dépendance indirecte
- une chaîne causale dans la direction opposée
- ou une simple coïncidence dans la même fenêtre temporelle

---

### Exemple

Interprétations possibles :

- saturation CPU → retards de scheduling → latence  
- retards d’I/O → plus de threads concurrents → plus grande utilisation de la CPU  
- contention → retries → CPU et latence augmentent toutes deux  

(→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md))  
(→ [1.8 Resource-level performance](./01-08-resource-level-performance.md))

Dans les trois cas, CPU et latence évoluent ensemble, mais le mécanisme sous-jacent est différent.

---

### Implication diagnostique

La corrélation est un point de départ, non une conclusion.

Plusieurs mécanismes peuvent produire les mêmes signaux corrélés.
  
Seul un modèle causal explique comment l’un conduit à l’autre.

Pour cette raison, le raisonnement diagnostique doit aller au-delà de “ces deux métriques ont évolué au même moment”.

Il doit expliquer :

- laquelle a changé en premier
- quel mécanisme les relie
- pourquoi la séquence observée est cohérente avec le comportement du système

---

### Approche pratique

Pour établir la causalité :

- identifier la séquence des événements  
- vérifier la cohérence avec le comportement connu du système  
- valider à travers l’observation ou un changement contrôlé  

Cela peut inclure :

- comparer les états avant/après
- observer si une métrique précède constamment une autre
- changer une condition et vérifier la réponse attendue

La causalité devient plus forte lorsque le système se comporte comme le prévoit le mécanisme proposé.

---

### Limites de l’analyse superficielle

Un dashboard peut montrer la corrélation très clairement mais ne peut pas, à lui seul, prouver la causalité.

Pour cette raison le diagnostic requiert du raisonnement et pas seulement de la "visualisation".

Un performance engineer doit se demander :

- Cette métrique est-elle le driver, la conséquence ou une conséquence supplémentaire du même événement ?
- La timeline supporte-t-elle l’explication proposée ?
- L’explication reste-t-elle cohérente à travers des observations répétées ?

Sans ces questions, la corrélation peut facilement conduire à des conclusions incorrectes.

---

### Interprétation pratique

Un bon diagnostic traite la corrélation comme un générateur d’hypothèses.

Cela aide à identifier où regarder, mais n’élimine pas la nécessité de raisonner sur les mécanismes sous-jacents.

Cela est particulièrement important dans les systèmes complexes où plusieurs goulots d’étranglement interagissent et où les symptômes se propagent à travers les composants.

---

### Idée clé

Ne pas inférer la causalité à partir de la corrélation.

Le diagnostic requiert d’identifier le mécanisme qui relie les signaux.

---

<a id="1104-building-a-hypothesis"></a>
## 1.10.4 Construire une hypothèse

### Définition

Une hypothèse est une explication proposée qui relie des signaux observés à un mécanisme du système.

Elle fournit une manière structurée de passer de l’observation à l’explication.

Sans hypothèse, l’analyse reste descriptive plutôt que diagnostique.

---

### Processus

Une hypothèse est construite :

1. en observant les signaux  
2. en identifiant des patterns cohérents  
3. en les mappant sur des mécanismes connus  

(→ [1.2 Core metrics and formulas](./01-02-core-metrics-and-formulas.md))  
(→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md))

Ce processus transforme des données brutes en une explication testable.

Il relie :

- mesures
- comportement du système
- raisonnement causal

---

### Exemple

Observé :

- la latence augmente  
- la longueur de la file augmente  
- la CPU s’approche de la saturation  

Hypothèse :

- augmentation du taux de travail entrant → accumulation de file → temps d’attente plus long → saturation CPU  

Cela relie des signaux observables à un mécanisme de mise en file d’attente.

Cela fournit aussi une direction à l’investigation : vérifier si l’augmentation de la latence est causée principalement par l’attente plutôt que par un temps de service plus lent.

---

### Exigences

Une hypothèse valide doit être :

- cohérente avec les données observées  
- fondée sur le comportement du système  
- testable à travers mesure ou changement  

Une hypothèse qui ne peut pas être testée peut être plausible, mais elle n’est pas encore utile pour le diagnostic.

Une hypothèse qui contredit l’évidence observée devrait être rejetée même si elle paraît intuitive.

---

### Implication diagnostique

Une hypothèse guide l’investigation.

Sans elle, l’analyse devient réactive et non structurée.

Au lieu de passer directement du symptôme au fix, le processus diagnostique devrait passer de :

- symptôme  
- hypothèse sur un mécanisme candidat  
- validation  

Cette structure réduit le guesswork et rend les conclusions diagnostiques plus robustes.

---

### Sources des hypothèses

Les hypothèses émergent habituellement de :

- combinaisons de signaux observés
- patterns de performance connus
- comportement précédent du système
- connaissance architecturale
- scénarios d’erreur répétés

Par exemple :

- latence croissante + files en croissance suggère souvent de la mise en file d’attente
- CPU modérée + threads bloqués peut suggérer de la contention ou de l’attente I/O
- fréquence GC croissante + pics de latence peut suggérer de la pression de mémoire

Ces associations ne prouvent pas l’explication, mais fournissent un point de départ discipliné.

---

### Interprétation pratique

Une bonne hypothèse est suffisamment spécifique pour être testée et suffisamment générale pour expliquer le comportement observé.

Elle ne devrait pas être :

- vague (“le système est lent”)
- circulaire (“la latence est élevée parce que les requêtes sont lentes”)
- purement descriptive

Elle devrait exprimer un mécanisme.

Par exemple :

- “La saturation du thread pool est en train d’augmenter le temps de file, ce qui fait monter la latence p95.”

Ce type d’affirmation peut être validé.

---

### Idée clé

Le diagnostic procède à travers des hypothèses explicites et testables, non à travers des suppositions non reliées.

---

<a id="1105-narrowing-down-the-bottleneck"></a>
## 1.10.5 Réduire le goulot d’étranglement

### Définition

Le diagnostic vise à identifier la ressource ou le mécanisme qui limite la performance du système.

Ce facteur limitant détermine le comportement global du système sous charge.

Tant qu’il n’est pas identifié, les efforts d’optimisation restent incertains et souvent inefficaces.

---

### Approche

L’analyse se concentre sur :

- comportement de la CPU  
- latence I/O  
- retards réseau  
- pression de mémoire  

(→ [1.8 Resource-level performance](./01-08-resource-level-performance.md))  
(→ [1.7 Runtime and memory model](./01-07-runtime-and-memory-model.md))

Ces dimensions sont examinées parce que la majorité des limites de performance, à la fin, se manifeste à travers une ou plusieurs d’entre elles.

Cependant, le goulot d’étranglement dominant, à un moment donné, est d’habitude donné par une seule contrainte primaire plutôt que par toutes les contraintes à égalité.

---

### Méthode

- isoler une dimension à la fois  
- comparer les signaux à travers les ressources  
- identifier la contrainte dominante  

Cela réduit la complexité en se concentrant sur le facteur le plus impactant.

L’objectif n’est pas d’expliquer chaque métrique, mais de trouver le mécanisme qui, à ce moment-là, gouverne le comportement du système.

---

### Exemple

Si :

- la CPU est basse  
- la latence I/O est élevée  
- les files sont en train de croître  

Alors :

- l’I/O est probablement le facteur limitant  

Le système n’est pas CPU-bound, même si la CPU est active.

Ce type de réduction est essentiel parce que plusieurs ressources sont souvent impliquées, mais une seule d’entre elles est habituellement dominante.

---

### Implication diagnostique

La performance est typiquement limitée, à un moment donné, par un seul goulot d’étranglement dominant.

Optimiser des ressources non limitantes produit peu ou pas d’amélioration.

C’est l’un des principes les plus importants dans le diagnostic :

- mesurer de manière large
- conclure de manière spécifique

Un ensemble large de signaux est requis pour éviter de perdre des évidences importantes. 
 
Une conclusion spécifique est requise pour orienter l’action sur la contrainte réelle.

---

### Pourquoi les goulots d’étranglement sont difficiles à identifier

Les goulots d’étranglement sont souvent obscurcis par des effets secondaires.

Par exemple :

- un I/O lent peut augmenter le nombre de threads
- l’augmentation du nombre de threads peut augmenter l’overhead de scheduling de la CPU
- l’augmentation de l’attente peut gonfler la rétention de mémoire
- les retries peuvent amplifier la demande sur plusieurs composants en même temps

Par conséquent, l’effet visible peut ne pas apparaître au point exact du problème d’origine.

Pour cette raison l’isolement du goulot d’étranglement requiert de la corrélation à travers les layers plutôt qu’une interprétation isolée d’une métrique unique.

---

### Interprétation pratique

Le but du diagnostic n’est pas seulement de dire que le système est sous pression.

C’est d’identifier :

- où la pression devient limitante
- quel mécanisme produit la limite
- pourquoi cette contrainte est actuellement dominante

Seulement alors l’optimisation devient significative.

---

### Idée clé

Un diagnostic efficace réduit le système à son facteur limitant.

---

<a id="1106-iterative-analysis-and-validation"></a>
## 1.10.6 Analyse itérative et validation

### Définition

Le diagnostic est un processus itératif de test et d’affinement des hypothèses.

Il évolue à travers des observations et des validations successives.

Cela est nécessaire parce que les explications initiales sont souvent incomplètes, partiellement correctes ou valides seulement pour un layer du système.

---

### Processus

1. observer les signaux  
2. construire une hypothèse  
3. tester à travers des changements ou des mesures  
4. valider ou rejeter  

Chaque passage produit un affinement dans la compréhension du système.

Cette boucle est répétée jusqu’à ce que l’explication proposée soit cohérente avec le comportement observé et supportée par l’évidence.

---

### Exemple

```java
ExecutorService pool = Executors.newFixedThreadPool(10);

for (int i = 0; i < 1000; i++) {
    pool.submit(() -> {
        Thread.sleep(100);
        return null;
    });
}
```

Interprétation :

- le thread pool fixe limite l’exécution parallèle  
- les tâches s’accumulent  
- la mise en file d’attente augmente la latence  

Cette hypothèse peut être testée :

- en augmentant la taille du pool  
- en réduisant le temps de blocking  

Si la latence diminue et que l’accumulation de files se réduit, l’hypothèse gagne en évidence.

Si le comportement ne change pas comme prévu, l’explication doit être révisée.

---

### Validation

Une hypothèse est validée si :

- les changements produisent les effets attendus  
- les signaux évoluent de manière cohérente avec le mécanisme proposé  

Dans le cas contraire, l’hypothèse doit être révisée.

La validation dépend donc de la cohérence entre :

- changement observé
- changement attendu
- explication causale proposée

Un fix qui change une métrique sans améliorer le comportement du système peut indiquer que le mauvais mécanisme a été visé.

---

### Implications pratiques

- éviter les conclusions en une seule étape  
- itérer systématiquement  
- valider les suppositions avec des données observables  

Un bon diagnostic est rarement instantané.

Il devient fiable à travers une comparaison répétée entre :

- ce qui est observé
- ce qui est attendu
- ce qui change réellement après l’intervention

Cette discipline itérative est ce qui transforme le troubleshooting en engineering.

---

### Pourquoi l’itération compte

Les systèmes complexes exposent rarement une explication complète dans une seule observation.

Il est commun de découvrir que :

- un goulot d’étranglement initial n’était qu’un effet secondaire
- supprimer une contrainte en expose une autre
- une amélioration locale déplace ailleurs le facteur limitant
- le système se comporte différemment sous des charges de travail différentes

L’itération n’est donc pas un signe d’incertitude.
  
C’est la méthode normale pour arriver à une explication cohérente.

---

### Interprétation pratique

Le diagnostic est une boucle parce que la compréhension du système se construit progressivement.

L’objectif n’est pas de deviner correctement à la première tentative.

L’objectif est de passer de l’évidence à l’explication à travers un raisonnement contrôlé et une vérification.

C’est ce qui rend l’analyse des performances répétable et défendable.

---

### Idée clé

Le diagnostic est une boucle.

La compréhension émerge à travers itération, vérification et affinement.