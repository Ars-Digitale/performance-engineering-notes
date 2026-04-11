# 1.2 – Métriques et formules de base

<a id="12-core-metrics-and-formulas"></a>

Ce document présente une référence synthétique des principales formules utilisées dans la **performance engineering applicative + système**.

Ces formules formalisent les concepts introduits dans :

→ [1.1 Fondements](01-01-foundations.md)

Elles doivent être lues comme un complément au modèle conceptuel, et non de manière isolée.

Elles fournissent la base quantitative utilisée pour raisonner sur le comportement des systèmes, valider des hypothèses et interpréter les résultats des tests de performance.


## Table des matières

- [1.2.1 Loi de Little (concurrence au niveau système)](#121-littles-law-system-level-concurrency)
- [1.2.2 Loi dutilisation (temps occupé au niveau ressource)](#122-utilization-law-resource-level-busy-time)
- [1.2.3 Temps de service vs temps de réponse (mise en file)](#123-service-time-vs-response-time-queueing)
- [1.2.4 Demande de service (visites × temps de service)](#124-service-demand-visits--service-time)
- [1.2.5 Throughput](#125-throughput)
- [1.2.6 Taux d’erreur](#126-error-rate)
- [1.2.7 Percentiles (p50, p95, p99)](#127-percentiles-p50-p95-p99)
	- [1.2.7.1 Comment calculer un percentile (échantillon ordonné)](#1271-how-to-compute-a-percentile-ordered-sample)
	- [1.2.7.2 Interprétation vs moyenne (pourquoi les queues comptent)](#1272-interpretation-vs-average-why-tails-matter)
- [1.2.8 CDF empirique (seuil → pourcentage)](#128-empirical-cdf-threshold--percentage)
- [1.2.9 Latence long-tail (ce que c’est)](#129-long-tail-latency-what-it-is)
- [1.2.10 Checklist rapide (quoi mesurer dans les tests)](#1210-quick-checklist-what-to-measure-in-tests)

---

<a id="notation-typical"></a>
## **Notation** (typique)

| Symbol | Definition |
| ------ | ------ |
| `X` or `λ` | **throughput** / taux d’arrivée (requêtes par seconde)	|
| `R` or `W` | **temps de réponse** / temps dans le système (secondes)			|
| `S`        | **temps de service** sur une ressource (secondes par requête)	|
| `U`        | **utilisation** d’une ressource (0–1)					|
| `L`        | **concurrence moyenne** / requêtes in flight (comptage)	|
| `V`        | **nombre moyen de visites** à une ressource par requête	|
| `D`        | **demande de service** sur une ressource (secondes par requête)	|

Cette notation est utilisée de manière cohérente dans tout le guide et permet d’appliquer les formules de manière uniforme dans des contextes différents.

---

<a id="121-littles-law-system-level-concurrency"></a>
## 1.2.1 Loi de Little (concurrence au niveau système)

### Définition

Cette loi met en relation la **concurrence** moyenne avec le **throughput** et le **temps dans le système**.

### Formule

$$
L = \lambda \cdot W
$$

### Où

- `L` = nombre moyen de requêtes dans le système (in-flight / concurrence)
- `λ` = taux d’arrivée / throughput (requêtes/s)
- `W` = temps moyen dans le système (s) (souvent le temps moyen de réponse end-to-end)

### Signification pratique

Si l’on connaît le `throughput` et le `temps moyen de réponse`, on peut estimer le nombre de requêtes qui sont, simultanément, “in flight” dans le système.

Cela fait de la Loi de Little l’un des outils les plus utiles pour raisonner sur la charge et la concurrence d’un système.

### Exemple

Si `λ = 200 req/s` et `W = 0.15 s` :

$$
L = 200 \cdot 0.15 = 30
$$

En moyenne, il y a environ **30** requêtes in flight.

---

### Interprétation pratique

La Loi de Little relie trois grandeurs observables :

- throughput  
- latence  
- concurrence  

Cela permet de :

- estimer la concurrence à partir de mesures  
- valider le comportement du système  
- détecter des incohérences dans les métriques  

Cette loi est largement utilisée dans la performance engineering, le capacity planning et le diagnostic des systèmes.

---

<a id="122-utilization-law-resource-level-busy-time"></a>
## 1.2.2 Loi d’utilisation (temps occupé au niveau ressource)

### Définition

L’utilisation est la **fraction de temps** pendant laquelle une *ressource unique* est occupée durant un intervalle de temps fixe (typiquement 1 seconde).  
Elle mesure le « pourcentage de temps occupé ».

### Formule

$$
U = X \cdot S
$$

### Où

- `U` = utilisation (0–1)
- `X` = throughput observé par cette ressource (req/s)
- `S` = temps moyen de service sur cette ressource (s/req)

### Ressource

Une **unité de service unique**, par ex. cœur CPU, thread/worker, connexion DB, etc.

### Exemple

Un worker DB traite `50 req/s`, chaque requête nécessite `10 ms = 0.01 s` :

$$
U = 50 \cdot 0.01 = 0.5 \Rightarrow 50\%
$$

Interprétation : la ressource est occupée **0.5 seconde par seconde**.

---

### Interprétation pratique

L’utilisation est un indicateur clé de la saturation d’une ressource.

Lorsque l’utilisation s’approche de 1 :

- la mise en file (Queueing) augmente  
- la latence croît de manière non linéaire  
- la stabilité du système diminue  

Cela en fait l’un des signaux les plus importants dans le diagnostic des goulets d’étranglement (bottlenecks).

---

<a id="123-service-time-vs-response-time-queueing"></a>
## 1.2.3 Temps de service vs temps de réponse (mise en file)

### Définition

Le temps de réponse (Response Time) sur une ressource inclut :

- le temps de service (travail effectif)
- le temps de file (attente)

### Formule

$$
R = S + W_q
$$

### Où

- `R`  = temps de réponse sur la ressource
- `S`  = temps de service
- `W_q` = temps d’attente en file

### Signification pratique

Lorsque l’utilisation s’approche de la saturation, la mise en file (Queueing) croît de manière non linéaire et **domine** le temps de réponse, provoquant une **latence long-tail**.

---

### Interprétation pratique

Cette formule explique pourquoi les systèmes ralentissent sous charge même lorsque le coût computationnel ne change pas.

Dans de nombreux systèmes réels :

- le temps de service reste relativement stable  
- le temps d’attente augmente rapidement  

Par conséquent :

- le temps de réponse est dominé par la mise en file  
- la latence devient imprévisible  

C’est un point clé dans le diagnostic des problèmes de performance.

---

<a id="124-service-demand-visits--service-time"></a>
## 1.2.4 Demande de service (visites × temps de service)

### Définition

Service total requis d’une ressource par requête, en tenant compte de visites multiples.

### Formule
$$
D = V \cdot S
$$

### Où
- `D` = demande de service sur la ressource (s)
- `V` = visites moyennes à la ressource par requête
- `S` = temps de service par visite (s)

### Exemple

Une requête exécute `V = 3` requêtes DB, chacune nécessite `S = 5 ms = 0.005 s` :

$$
D = 3 \cdot 0.005 = 0.015 \text{ s} = 15 \text{ ms}
$$

---

### Interprétation pratique

La demande de service représente le travail total requis d’une ressource pour chaque requête.

Elle est particulièrement utile pour :

- identifier les ressources les plus utilisées  
- estimer les limites de capacité  
- comprendre le comportement en montée en charge  

Réduire la demande de service est souvent plus efficace qu’augmenter la capacité brute.

---

<a id="125-throughput"></a>
## 1.2.5 Throughput

### Définition

Requêtes complétées par unité de temps.

### Formule
**Formule :** `X = N / T`

### Où

- `N` = nombre de requêtes complétées
- `T` = fenêtre d’observation (secondes)

---

### Interprétation pratique

Le `throughput` est l’un des principaux indicateurs des performances d’un système.

Il reflète la capacité du système à traiter du travail.

Cependant, le throughput doit toujours être interprété avec :

- la latence  
- le taux d’erreur  
- l’utilisation des ressources  

Un throughput élevé, à lui seul, ne garantit pas un comportement acceptable du système.

---

<a id="126-error-rate"></a>
## 1.2.6 Taux d’erreur

### Définition

Fraction des requêtes qui échouent (timeouts, 5xx, etc.).

### Formule

**Formule :** `ErrorRate = (N_err / N_total) × 100%`

---

### Interprétation pratique

Le taux d’erreur reflète la fiabilité du système sous charge.

Une augmentation du taux d’erreur indique souvent :

- des conditions de surcharge  
- un épuisement des ressources  
- de l’instabilité  

Le taux d’erreur doit toujours être surveillé avec la latence et le throughput.

---

<a id="127-percentiles-p50-p95-p99"></a>
## 1.2.7 Percentiles (p50, p95, p99)

### Définition

Le percentile `p`-ième est la valeur en dessous de laquelle se trouve **p% des observations**.

- `p50` ≈ médiane (« requête typique »)
- `p95` = seuil pour les 5% les plus lents
- `p99` = seuil pour les 1% les plus lents

Les percentiles capturent mieux la **distribution** et le **comportement de queue** que les moyennes.

---

### Interprétation pratique

Les percentiles sont essentiels pour comprendre l’expérience réelle de l’utilisateur.

Dans de nombreux systèmes :

- la latence moyenne paraît acceptable  
- la latence de queue (p95/p99) est significativement pire  

Cette différence est critique pour l’évaluation du système et la définition des SLO.

---

<a id="1271-how-to-compute-a-percentile-ordered-sample"></a>
### 1.2.7.1 Comment calculer un percentile (échantillon ordonné)

Étant données `N` valeurs triées par ordre croissant :

$$
v_1 \le v_2 \le \dots \le v_N
$$

Calculez la position théorique :

**Formule :** `P = (p / 100) × (N + 1)`

- Si `P` est un entier → percentile = `v_P`
- Sinon, posez `k = floor(P)` et `δ = P - k` (partie fractionnaire), puis interpolez :

$$
\text{Percentile}(p) \approx v_k + \delta \cdot (v_{k+1} - v_k)
$$

> Note : les définitions du percentile varient légèrement selon les outils. Cette méthode est une approche couramment utilisée.

---

<a id="1272-interpretation-vs-average-why-tails-matter"></a>
### 1.2.7.2 Interprétation vs moyenne (pourquoi les queues comptent)

- Si `p50` est bien inférieur à la moyenne, la distribution est **asymétrique à droite** (quelques requêtes lentes gonflent la moyenne).
- Si `p95` ou `p99` est très au-dessus de la moyenne, vous avez une **latence long-tail**.

Un pattern typique :

- la moyenne semble « acceptable »
- `p95/p99` sont mauvais

  
→ l’expérience utilisateur est dégradée pour une fraction non négligeable d’utilisateurs et les SLO sont en risque.

---

### Interprétation pratique

Les percentiles mettent en évidence des comportements que les moyennes masquent.

Ils sont essentiels pour :

- définir les objectifs de niveau de service (SLO)  
- détecter les problèmes de latence de queue  
- comprendre le comportement dans le pire cas  

Ignorer les percentiles conduit souvent à des conclusions incorrectes sur les performances du système.

---

<a id="128-empirical-cdf-threshold--percentage"></a>
## 1.2.8 CDF empirique (seuil → pourcentage)

### Définition

Étant donné un seuil `t`, la fonction de distribution cumulative empirique (CDF) indique la fraction d’échantillons inférieurs ou égaux à `t`.

### Formule

**Formule :** `F(t) = count(x_i ≤ t) / N`

### Signification pratique

La CDF répond à la question : « Si mon SLO est `200 ms`, quel % de requêtes le respecte ? »

Les percentiles répondent à la question inverse : « Quel seuil correspond à 95% des requêtes ? »

---

### Interprétation pratique

La CDF et les percentiles sont des vues complémentaires des mêmes données.

- CDF : étant donné un seuil → quelle fraction le respecte  
- Percentile : étant donnée une fraction → quel seuil lui correspond  

Les deux sont utiles pour l’analyse des performances et la validation des SLO.

---

<a id="129-long-tail-latency-what-it-is"></a>
## 1.2.9 Latence long-tail (ce que c’est)

### Définition

Une petite fraction des requêtes (ex. 5% ou 1%) est **beaucoup plus lente** que la majorité.

---

### Pourquoi la queue « domine »

- Les SLO sont typiquement définis sur `p95/p99`, donc les queues déterminent le pass/fail.
- Dans les systèmes distribués, la dépendance la plus lente détermine souvent la latence end-to-end.
- Les événements de queue sont fréquemment pilotés par la **contention / mise en file**.

---

### Causes communes (haut niveau)

- saturation du thread pool / connection pool (mise en file)
- contention sur les verrous / points chauds de synchronisation
- requêtes DB lentes, index manquants, attentes sur verrou
- retries + timeouts qui amplifient la latence de queue
- hot keys dans les caches / charge non uniforme sur les shards
- pauses GC / pression mémoire (stop-the-world)
- jitter réseau / perte de paquets / retransmissions
- pics de disque I/O, compactions, flush fsync/wal

---

### Interprétation pratique

La latence long-tail est l’un des aspects les plus critiques des performances d’un système.

Elle explique pourquoi :

- les métriques moyennes peuvent paraître acceptables  
- l’expérience utilisateur est malgré tout dégradée  

Gérer la latence de queue est souvent plus important qu’améliorer la performance moyenne.

---

<a id="1210-quick-checklist-what-to-measure-in-tests"></a>
## 1.2.10 Checklist rapide (quoi mesurer dans les tests)

- Latence : `p50/p90/p95/p99`
- Throughput : `RPS/TPS`
- Taux d’erreur : `timeouts/5xx`
- Utilisation : CPU, mémoire, DB, pools
- Longueurs des files : thread pools, connection pools, backlog des messages
- Temps des dépendances : DB/Redis/API externes

---

### Interprétation pratique

Ces métriques constituent l’ensemble minimal requis pour comprendre le comportement du système pendant les tests de performance.

Elles permettent de :

- identifier les goulets d’étranglement  
- détecter des instabilités  
- corréler la charge de travail avec le comportement du système  

Mesurer seulement un sous-ensemble de ces métriques conduit souvent à une analyse incomplète ou trompeuse.

---

### Idée clé

Les formules ne sont pas des abstractions isolées.

Ce sont des outils utilisés pour expliquer le comportement observé et valider les modèles du système.

Leur évaluation constitue un élément essentiel de la performance engineering.