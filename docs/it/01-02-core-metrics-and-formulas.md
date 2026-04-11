# 1.2 – Metriche e formule di base

<a id="12-core-metrics-and-formulas"></a>

Questo documento presenta un riferimento sintetico delle principali formule utilizzate nella **performance engineering applicativa + di sistema**.

Queste formule formalizzano i concetti introdotti in:

→ [1.1 Fondamenti](01-01-foundations.md)

Esse dovrebbero esser lette come complemento al modello concettuale, non in modo isolato.

Forniscono la base quantitativa utilizzata per ragionare sul comportamento dei sistemi, validare ipotesi e interpretare i risultati dei test prestazionali.


## Indice

- [1.2.1 Legge di Little (concorrenza a livello di sistema)](#121-littles-law-system-level-concurrency)
- [1.2.2 Legge di Utilizzazione (tempo occupato a livello di risorsa)](#122-utilization-law-resource-level-busy-time)
- [1.2.3 Tempo di servizio vs tempo di risposta (accodamento)](#123-service-time-vs-response-time-queueing)
- [1.2.4 Domanda di servizio (visite × tempo di servizio)](#124-service-demand-visits--service-time)
- [1.2.5 Throughput](#125-throughput)
- [1.2.6 Tasso di errore](#126-error-rate)
- [1.2.7 Percentili (p50, p95, p99)](#127-percentiles-p50-p95-p99)
	- [1.2.7.1 Come calcolare un percentile (campione ordinato)](#1271-how-to-compute-a-percentile-ordered-sample)
	- [1.2.7.2 Interpretazione vs media (perché le code contano)](#1272-interpretation-vs-average-why-tails-matter)
- [1.2.8 CDF empirica (soglia → percentuale)](#128-empirical-cdf-threshold--percentage)
- [1.2.9 Latenza long-tail (che cos’è)](#129-long-tail-latency-what-it-is)
- [1.2.10 Checklist rapida (cosa misurare nei test)](#1210-quick-checklist-what-to-measure-in-tests)

---

<a id="notation-typical"></a>
## **Notazione** (tipica)

| Symbol | Definition |
| ------ | ------ |
| `X` or `λ` | **throughput** / tasso di arrivo (richieste al secondo)	|
| `R` or `W` | **tempo di risposta** / tempo nel sistema (secondi)			|
| `S`        | **tempo di servizio** su una risorsa (secondi per richiesta)	|
| `U`        | **utilizzazione** di una risorsa (0–1)					|
| `L`        | **concorrenza media** / richieste in flight (conteggio)	|
| `V`        | **numero medio di visite** a una risorsa per richiesta	|
| `D`        | **domanda di servizio** su una risorsa (secondi per richiesta)	|

Questa notazione è utilizzata in modo coerente in tutta la guida e consente di applicare le formule in modo uniforme in contesti differenti.

---

<a id="121-littles-law-system-level-concurrency"></a>
## 1.2.1 Legge di Little (concorrenza a livello di sistema)

### Definizione

Questa legge mette in relazione la **concorrenza** media con il **throughput** e il **tempo nel sistema**.

### Formula

$$
L = \lambda \cdot W
$$

### Dove

- `L` = numero medio di richieste nel sistema (in-flight / concorrenza)
- `λ` = tasso di arrivo / throughput (richieste/s)
- `W` = tempo medio nel sistema (s) (spesso il tempo medio di risposta end-to-end)

### Significato pratico

Se si conosce il `throughput` e il `tempo medio di risposta`, si puo' stimare il numero di richieste che sono, contemporaneamente, “in flight” sul sistema.

Questo rende la Legge di Little uno degli strumenti più utili per ragionare sul carico e sulla concorrenza di un sistema.

### Esempio

Se `λ = 200 req/s` e `W = 0.15 s`:

$$
L = 200 \cdot 0.15 = 30
$$

In media ci sono circa **30** richieste in flight.

---

### Interpretazione pratica

La Legge di Little collega tre grandezze osservabili:

- throughput  
- latenza  
- concorrenza  

Questo consente di:

- stimare la concorrenza a partire da misurazioni  
- validare il comportamento del sistema  
- rilevare incoerenze nelle metriche  

Questa legge è estensivamente utilizzata nella performance engineering, nel capacity planning e nella diagnostica dei sistemi.

---

<a id="122-utilization-law-resource-level-busy-time"></a>
## 1.2.2 Legge di Utilizzazione (tempo occupato a livello di risorsa)

### Definizione

L’utilizzazione è la **frazione di tempo** in cui una *singola risorsa* è occupata durante un intervallo fisso di tempo (tipicamente 1 secondo).  
Essa misura la “percentuale di tempo occupato”.

### Formula

$$
U = X \cdot S
$$

### Dove

- `U` = utilizzazione (0–1)
- `X` = throughput osservato da quella risorsa (req/s)
- `S` = tempo medio di servizio su quella risorsa (s/req)

### Risorsa

Una **singola unità di servizio**, ad es. core CPU, thread/worker, connessione DB, ecc.

### Esempio

Un worker DB gestisce `50 req/s`, ogni query richiede `10 ms = 0.01 s`:

$$
U = 50 \cdot 0.01 = 0.5 \Rightarrow 50\%
$$

Interpretazione: la risorsa è occupata **0.5 secondi per secondo**.

---

### Interpretazione pratica

L’utilizzazione è un indicatore chiave della saturazione di una risorsa.

Quando l’utilizzazione si avvicina a 1:

- l’accodamento (Queueing) aumenta  
- la latenza cresce in modo non lineare  
- la stabilità del sistema diminuisce  

Questo la rende uno dei segnali più importanti nella diagnosi dei colli di bottiglia (bottlenecks).

---

<a id="123-service-time-vs-response-time-queueing"></a>
## 1.2.3 Tempo di servizio vs tempo di risposta (accodamento)

### Definizione

Il tempo di risposta (Response Time) su una risorsa include:

- il tempo di servizio (lavoro effettivo)
- il tempo di coda (attesa)

### Formula

$$
R = S + W_q
$$

### Dove

- `R`  = tempo di risposta sulla risorsa
- `S`  = tempo di servizio
- `W_q` = tempo di attesa in coda

### Significato pratico

Quando l’utilizzazione si avvicina alla saturazione, l’accodamento (Queueing) cresce in modo non lineare e **domina** il tempo di risposta, causando **latenza long-tail**.

---

### Interpretazione pratica

Questa formula spiega perché i sistemi rallentano sotto carico anche quando il costo computazionale non cambia.

In molti sistemi reali:

- il tempo di servizio rimane relativamente stabile  
- il tempo di attesa aumenta rapidamente  

Di conseguenza:

- il tempo di risposta è dominato dall’accodamento  
- la latenza diventa imprevedibile  

Questo è un punto chiave nella diagnosi dei problemi prestazionali.

---

<a id="124-service-demand-visits--service-time"></a>
## 1.2.4 Domanda di servizio (visite × tempo di servizio)

### Definizione

Servizio totale richiesto a una risorsa per richiesta, tenendo conto di visite multiple.

### Formula
$$
D = V \cdot S
$$

### Dove
- `D` = domanda di servizio sulla risorsa (s)
- `V` = visite medie alla risorsa per richiesta
- `S` = tempo di servizio per visita (s)

### Esempio

Una richiesta esegue `V = 3` query DB, ciascuna richiede `S = 5 ms = 0.005 s`:

$$
D = 3 \cdot 0.005 = 0.015 \text{ s} = 15 \text{ ms}
$$

---

### Interpretazione pratica

La domanda di servizio rappresenta il lavoro totale richiesto a una risorsa per ogni richiesta.

È particolarmente utile per:

- identificare le risorse maggiormente utilizzate  
- stimare i limiti di capacità  
- comprendere il comportamento in scalabilità  

Ridurre la domanda di servizio è spesso più efficace che aumentare la capacità grezza.

---

<a id="125-throughput"></a>
## 1.2.5 Throughput

### Definizione

Richieste completate per unità di tempo.

### Formula
**Formula:** `X = N / T`

### Dove

- `N` = numero di richieste completate
- `T` = finestra di osservazione (secondi)

---

### Interpretazione pratica

Il `throughput` è uno degli indicatori principali delle prestazioni di un sistema.

Riflette la capacità del sistema di elaborare lavoro.

Tuttavia, il throughput deve sempre essere interpretato insieme a:

- latenza  
- tasso di errore  
- utilizzazione delle risorse  

Un throughput elevato, da solo, non garantisce un comportamento accettabile del sistema.

---

<a id="126-error-rate"></a>
## 1.2.6 Tasso di errore

### Definizione

Frazione di richieste che falliscono (timeout, 5xx, ecc.).

### Formula

**Formula:** `ErrorRate = (N_err / N_total) × 100%`

---

### Interpretazione pratica

Il tasso di errore riflette l’affidabilità del sistema sotto carico.

Un aumento del tasso di errore indica spesso:

- condizioni di sovraccarico  
- esaurimento delle risorse  
- instabilità  

Il tasso di errore dovrebbe sempre essere monitorato insieme a latenza e throughput.

---

<a id="127-percentiles-p50-p95-p99"></a>
## 1.2.7 Percentili (p50, p95, p99)

### Definizione

Il percentile `p`-esimo è il valore al di sotto del quale ricade **il p% delle osservazioni**.

- `p50` ≈ mediana (“richiesta tipica”)
- `p95` = soglia per il 5% più lento
- `p99` = soglia per l’1% più lento

I percentili catturano la **distribuzione** e il **comportamento della coda** meglio delle medie.

---

### Interpretazione pratica

I percentili sono essenziali per comprendere l'esperienza reale dell'utente.

In molti sistemi:

- la latenza media appare accettabile  
- la latenza di coda (p95/p99) è significativamente peggiore  

Questa differenza è critica per la valutazione del sistema e la definizione degli SLO.

---

<a id="1271-how-to-compute-a-percentile-ordered-sample"></a>
### 1.2.7.1 Come calcolare un percentile (campione ordinato)

Date `N` valori ordinati in modo crescente:

$$
v_1 \le v_2 \le \dots \le v_N
$$

Calcola la posizione teorica:

**Formula:** `P = (p / 100) × (N + 1)`

- Se `P` è un intero → percentile = `v_P`
- In caso contrario, poni `k = floor(P)` e `δ = P - k` (parte frazionaria), quindi interpola:

$$
\text{Percentile}(p) \approx v_k + \delta \cdot (v_{k+1} - v_k)
$$

> Nota: le definizioni di percentile variano leggermente tra i diversi strumenti. Questo metodo è un approccio comunemente utilizzato.

---

<a id="1272-interpretation-vs-average-why-tails-matter"></a>
### 1.2.7.2 Interpretazione vs media (perché le code contano)

- Se `p50` è molto più basso della media, la distribuzione è **asimmetrica a destra** (poche richieste lente gonfiano la media).
- Se `p95` o `p99` è molto al di sopra della media, hai **latenza long-tail**.

Un pattern tipico:

- la media sembra “accettabile”
- `p95/p99` sono negativi

  
→ l’esperienza utente è degradata per una frazione non trascurabile di utenti e gli SLO sono a rischio.

---

### Interpretazione pratica

I percentili mettono in evidenza comportamenti che le medie nascondono.

Sono essenziali per:

- definire gli obiettivi di livello di servizio (SLO)  
- rilevare problemi di latenza di coda  
- comprendere il comportamento nel caso peggiore  

Ignorare i percentili porta spesso a conclusioni scorrette sulle prestazioni del sistema.

---

<a id="128-empirical-cdf-threshold--percentage"></a>
## 1.2.8 CDF empirica (soglia → percentuale)

### Definizione

Data una soglia `t`, la funzione di distribuzione cumulativa empirica (CDF) indica la frazione di campioni pari o inferiori a `t`.

### Formula

**Formula:** `F(t) = count(x_i ≤ t) / N`

### Significato pratico

La CDF risponde alla domanda: “Se il mio SLO è `200 ms`, quale % di richieste lo rispetta?”

I percentili rispondono alla domanda inversa: “Quale soglia corrisponde al 95% delle richieste?”

---

### Interpretazione pratica

CDF e percentili sono viste complementari degli stessi dati.

- CDF: data una soglia → quale frazione la rispetta  
- Percentile: data una frazione → quale soglia le corrisponde  

Entrambi sono utili per l’analisi delle prestazioni e la validazione degli SLO.

---

<a id="129-long-tail-latency-what-it-is"></a>
## 1.2.9 Latenza long-tail (che cos’è)

### Definizione

Una piccola frazione di richieste (es. 5% o 1%) è **molto più lenta** della maggioranza.

---

### Perché la coda “domina”

- Gli SLO sono tipicamente definiti su `p95/p99`, quindi le code determinano il pass/fail.
- Nei sistemi distribuiti, la dipendenza più lenta determina spesso la latenza end-to-end.
- Gli eventi di coda sono frequentemente guidati da **contesa/accodamento**.

---

### Cause comuni (alto livello)

- saturazione del thread pool / connection pool (accodamento)
- contesa su lock / punti caldi di sincronizzazione
- query DB lente, indici mancanti, attese su lock
- retry + timeout che amplificano la latenza di coda
- hot key nelle cache / carico non uniforme sugli shard
- pause GC / pressione di memoria (stop-the-world)
- jitter di rete / perdita di pacchetti / ritrasmissioni
- picchi di I/O disco, compactions, flush fsync/wal

---

### Interpretazione pratica

La latenza long-tail è uno degli aspetti più critici delle prestazioni di un sistema.

Spiega perché:

- le metriche medie possono apparire accettabili  
- l’esperienza utente è comunque degradata  

Gestire la latenza di coda è spesso più importante che migliorare la prestazione media.

---

<a id="1210-quick-checklist-what-to-measure-in-tests"></a>
## 1.2.10 Checklist rapida (cosa misurare nei test)

- Latenza: `p50/p90/p95/p99`
- Throughput: `RPS/TPS`
- Tasso di errore: `timeouts/5xx`
- Utilizzazione: CPU, memoria, DB, pool
- Lunghezze delle code: thread pool, connection pool, backlog dei messaggi
- Tempi delle dipendenze: DB/Redis/API esterne

---

### Interpretazione pratica

Queste metriche costituiscono il set minimo richiesto per comprendere il comportamento del sistema durante i test prestazionali.

Esse consentono di:

- identificare i colli di bottiglia  
- rilevare instabilità  
- correlare il carico di lavoro con il comportamento del sistema  

Misurare solo un sottoinsieme di queste metriche porta spesso a un’analisi incompleta o fuorviante.

---

### Idea chiave

Le formule non sono astrazioni isolate.

Sono strumenti utilizzati per spiegare il comportamento osservato e validare i modelli del sistema.

La loro valutazione è un elemento essenziale della performance engineering.