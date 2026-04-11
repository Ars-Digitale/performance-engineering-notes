# 1.1 – Fondements

<a id="11-foundations"></a>

Cette section introduit les concepts fondamentaux nécessaires pour raisonner sur les performances applicatives et des systèmes.

Elle fournit un modèle conceptuel utilisé tout au long du guide.

Elle définit les principes fondamentaux utilisés dans l’ingénierie de la performance pour l’analyse du comportement des systèmes sous charge.

## Table des matières

- [1.1.1 Throughput, latence, concurrence](#111-throughput-latency-concurrency)
- [1.1.2 Temps de service vs temps de réponse](#112-service-time-vs-response-time)
- [1.1.3 Systèmes sous charge](#113-systems-under-load)
- [1.1.4 Saturation et goulets d’étranglement](#114-saturation-and-bottlenecks)
- [1.1.5 Pourquoi les systèmes ralentissent](#115-why-systems-slow-down)

---

<a id="111-throughput-latency-concurrency"></a>
## 1.1.1 Throughput, latence, concurrence

### Définition

Ce sont les trois dimensions principales utilisées pour décrire les performances d’un système.

- **Throughput** : Quantité de travail effectuée par unité de temps ; nombre de requêtes traitées par unité de temps (ex. requêtes par seconde)  
- **Latence** : temps nécessaire pour compléter une requête (temps de réponse)  
- **Concurrence** : nombre de requêtes en cours de traitement au même moment  

Ces concepts sont fondamentaux dans l’ingénierie de la performance et sont utilisés tout au long du guide pour décrire le comportement des systèmes.

---

### Relation

Ces grandeurs ne sont pas indépendantes entre elles.

Pour un système stable :

- augmenter le throughput augmente typiquement la concurrence  
- augmenter la concurrence tend à augmenter la latence  
- la latence influence directement le nombre de requêtes restant « in flight »  

Cette relation est centrale pour comprendre comment les systèmes se comportent sous charge.

---

### Intuition pratique

Un système peut être vu comme une pipeline de traitement :

- **Input** : les requêtes entrent  
- **Execution** : elles sont traitées  
- **Output** : elles sortent  

À tout moment :

- certaines requêtes sont en cours de traitement (concurrence)  
- de nouvelles requêtes arrivent (throughput)  
- chaque requête nécessite du temps pour être complétée (latence)  

Ce modèle mental aide à raisonner sur le flux, l’accumulation et les délais dans les systèmes réels.

---

### Exemple

Si un système traite :

- `100` requêtes par seconde (100 Req./sec.)  
- chaque requête nécessite `200 ms` (0.2 s)  

alors, en moyenne :

- environ `20` requêtes sont `in flight` à un instant donné  

Cette relation est formalisée par la **Loi de Little** :

→ [1.2.1 Loi de Little](01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency)

---

### Interprétation pratique

Le throughput, la latence et la concurrence forment un système fermé.

Modifier l’un d’eux impacte nécessairement les autres.

Par exemple :

- réduire la latence réduit la concurrence à throughput constant  
- augmenter le throughput augmente la concurrence si la latence reste constante  
- une forte concurrence augmente la probabilité de mise en file et de contention  

Cela constitue un élément clé pour diagnostiquer des problèmes de performance.

---

<a id="112-service-time-vs-response-time"></a>
## 1.1.2 Temps de service vs temps de réponse

### Définition

Au niveau d’une ressource, le temps de réponse est composé de deux parties :

- **temps de service (S)** : temps consacré à l’exécution effective du travail  
- **temps d’attente (Wq)** : temps passé en attente avant d’être traité  

Cette distinction est fondamentale dans l’analyse des performances.

---

### Relation

Le temps de réponse (Response Time) :

- inclut à la fois l’`exécution` et l’`attente`  
- il augmente lorsque des files d’attente se forment  

Même si le temps de service reste constant :

- le temps de réponse peut augmenter significativement en raison de l’attente  

C’est l’une des principales raisons pour lesquelles les systèmes se dégradent sous charge.

---

### Signification pratique

Un système lent ne l’est souvent pas parce que le travail est coûteux, mais parce que le travail est en attente de ressources disponibles.

À mesure que la charge augmente :

- les files d’attente s’allongent  
- l’attente domine  
- le temps de réponse se dégrade  

Cette décomposition est formalisée comme suit :

→ [1.2.3 Temps de service vs temps de réponse](01-02-core-metrics-and-formulas.md#123-service-time-vs-response-time-queueing)

---

### Interprétation pratique

Séparer le `temps de service` du `temps de réponse` permet de :

- identifier si le système est limité par le CPU ou par les files d’attente  
- distinguer le coût de traitement de la contention sur les ressources  
- comprendre si l’optimisation doit cibler l’exécution ou l’attente  

Dans de nombreux systèmes réels, les problèmes de latence sont principalement causés par la mise en file plutôt que par le calcul.

---

<a id="113-systems-under-load"></a>
## 1.1.3 Systèmes sous charge

### Définition

Un système sous charge traite un flux continu de requêtes entrantes.

La charge est généralement exprimée en :

- requêtes par seconde  
- utilisateurs concurrents  
- transactions par seconde  

La charge définit les conditions opérationnelles dans lesquelles les performances doivent être évaluées.

---

### Comportement

À mesure que la charge augmente :

- l’utilisation des ressources augmente  
- des files d’attente commencent à se former  
- la latence augmente  
- le throughput finit par se stabiliser ou se dégrader  

Ces effets ne sont pas linéaires et dépendent de la conception du système et des contraintes des ressources.

---

### Observation clé

Les systèmes ne se dégradent pas de manière linéaire.

À faible charge :

- les performances sont stables  

À proximité de la saturation :

- de faibles augmentations de charge peuvent provoquer des augmentations importantes de la latence  

Ce comportement non linéaire est une caractéristique clé des systèmes réels.

---

### Interprétation pratique

Comprendre le comportement du système sous charge est essentiel pour :

- le capacity planning  
- les tests de performance  
- le diagnostic des problèmes de latence  

Cela peut expliquer pourquoi les systèmes peuvent sembler stables lors des tests mais échouer avec une charge de production légèrement plus élevée.

---

<a id="114-saturation-and-bottlenecks"></a>
## 1.1.4 Saturation et goulets d’étranglement

### Saturation

Une ressource est saturée lorsqu’elle est occupée la plupart du temps ou en permanence.

Exemples typiques :

- CPU à 100 % (ou presque...)  
- pool de threads entièrement utilisé  
- pool de connexions épuisé  

La saturation indique qu’une ressource ne peut pas gérer une demande supplémentaire sans dégradation.

---

### Goulet d’étranglement

Le goulet d’étranglement (bottleneck) est la ressource qui limite le throughput du système.

Caractéristiques :

- utilisation maximale  
- files d’attente les plus longues  
- contribution dominante au temps de réponse  

Le goulet d’étranglement détermine la capacité globale du système.

---

### Signification pratique

Améliorer des ressources qui ne sont pas problématiques (goulets d’étranglement) a peu ou aucun effet.

Les améliorations de performance nécessitent :

- identifier le goulet d’étranglement  
- réduire sa demande ou augmenter sa capacité  

C’est un principe clé de l’ingénierie de la performance.

---

### Interprétation pratique

Dans les systèmes complexes :

- plusieurs ressources peuvent sembler limitantes  
- mais en général une seule limite le throughput à un instant donné  

Identifier correctement le goulet d’étranglement est essentiel pour éviter des optimisations inefficaces.

---

<a id="115-why-systems-slow-down"></a>
## 1.1.5 Pourquoi les systèmes ralentissent

### Mécanismes courants

La dégradation des performances est généralement induite par un nombre limité de facteurs :

- mise en file due à la saturation  
- contention sur des ressources partagées  
- utilisation inefficace des ressources  
- dépendances externes devenant lentes  

Ces mécanismes interagissent souvent et s’amplifient mutuellement.

---

### Effet de la mise en file

Lorsque l’utilisation d’une ressource approche de ses limites :

- le temps d’attente augmente rapidement  
- le temps de réponse est dominé par la mise en file  

Ce comportement est étroitement lié à l’utilisation et aux effets de file d’attente :

→ [1.2.2 Loi dutilisation](01-02-core-metrics-and-formulas.md#122-utilization-law-resource-level-busy-time)

---

### Effets d’amplification

Certains patterns amplifient les problèmes de performance :

- les retries augmentent la charge sur des systèmes déjà saturés  
- les timeouts entraînent du travail dupliqué  
- les dépendances en cascade propagent les délais  

Ces effets peuvent transformer une charge modérée en une dégradation sévère.

---

### Interprétation pratique

La dégradation des performances est rarement causée par un seul facteur.

Elle émerge plutôt de :

- interactions entre composants  
- accumulation du temps d’attente  
- boucles de rétroaction sous charge  

De cela découle la possibilité d’un diagnostic efficace.

---

### Conclusion pratique

La plupart des problèmes de performance ne sont pas causés par une seule opération problématique ou lente, mais par :

- interactions entre composants  
- accumulation des temps d’attente  
- conditions de surcharge  

Comprendre ces mécanismes est essentiel avant d’appliquer des formules ou d’exécuter des tests.

---

### Idée clé

Les performances d’un système sont déterminées par les interactions entre charge de travail, ressources et concurrence.

La compréhension de ces interactions constitue le fondement de l’ingénierie de la performance.