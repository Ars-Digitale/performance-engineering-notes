# 1.5 – Comportamento del sistema sotto carico

<a id="15-system-behavior-under-load"></a>

Questo capitolo analizza il comportamento dei sistemi all’aumentare del carico di lavoro (workload) e in prossimità dei loro limiti di capacità.

Esso si concentra sui principali meccanismi che possono causare degradazione sotto carico, inclusi **saturazione**, **accodamento**, **perdita di throughput** e **amplificazione della tail latency**.

Questi concetti sono centrali nella performance engineering poiché analizzano il perché i sistemi possano apparire stabili a basso carico e diventino instabili in prossimità dei loro limiti capacitivi.

## Indice

- [1.5.1 Carico vs capacità](#151-load-vs-capacity)
- [1.5.2 Saturazione e accodamento](#152-saturation-and-queueing)
- [1.5.3 Degradazione non lineare](#153-non-linear-degradation)
- [1.5.4 Collasso del throughput](#154-throughput-collapse)
- [1.5.5 Amplificazione della tail latency](#155-tail-latency-amplification)

---

<a id="151-load-vs-capacity"></a>
## 1.5.1 Carico vs capacità

### Definizione

Un sistema opera sotto un carico di lavoro, ma possiede una capacità ben definita.

- **Carico**: la quantità di lavoro applicata al sistema (es. richieste al secondo, utenti concorrenti)
- **Capacità**: la quantità massima di lavoro che il sistema può gestire rimanendo stabile

Comprendere la relazione tra carico e capacità è fondamentale nella performance engineering.

Essa definisce l’inviluppo operativo del sistema e determina quando il comportamento sia prevedibile e quando inizi la degradazione.

---

### Comportamento del sistema

A basso carico:

- le risorse sono sottoutilizzate
- il tempo di risposta è stabile
- il throughput aumenta linearmente con il carico

All’aumentare del carico:

- l’utilizzazione delle risorse cresce
- la contesa inizia a comparire
- il tempo di risposta aumenta

Quando il carico si avvicina alla capacità:

- si formano code
- la latenza aumenta rapidamente
- il comportamento del sistema diventa meno prevedibile

Questa transizione è uno degli aspetti più importanti dell’analisi delle prestazioni.

Un sistema raramente passa direttamente da “stabile” a “problematico”.
  
Di solito attraversa una regione di crescente instabilità e ridotta efficienza.

---

### La capacità non è un valore fisso

La capacità è spesso fraintesa come un insieme ristretto di valori.

In realtà, essa dipende da:

- composizione del workload (casi d’uso e distribuzione)
- configurazione delle risorse (CPU, memoria, pool)
- stato del sistema (cold vs warm, effetti della cache)
- dipendenze esterne (database, servizi)

Un sistema può gestire:

- 100 req/s per richieste semplici
- ma solo 20 req/s per richieste complesse

La capacità è quindi sempre contestuale.

Deve essere compresa in relazione a uno specifico workload, ambiente e criteri di accettazione.

---

### Capacità effettiva

La capacità deve essere definita sotto vincoli ben precisi.

Criteri tipici:

- latenza entro limiti accettabili (es. p95)
- tasso di errore sotto soglia
- utilizzo stabile delle risorse

Il carico massimo che soddisfa queste condizioni è la **capacità effettiva**.

Questa è la capacità che conta operativamente.

Un massimo teorico che produce latenza inaccettabile o instabilità non è utile nella pratica.

---

### Implicazione pratica

La capacità non può essere assunta a priori.

Deve essere:

- misurata sotto workload realistico
- validata tramite testing
- monitorata nel tempo

Aumentare il carico oltre la capacità effettiva conduce a:

- rapida degradazione
- comportamento instabile
- potenziale rottura del sistema

Può anche ridurre la capacità del sistema di recuperare rapidamente dopo un sovraccarico.

---

### Collegamento con i concetti precedenti

La relazione tra carico, latenza e concorrenza è formalizzata da:

→ [1.2.1 Legge di Little](01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency)

All’aumentare del carico:

- la concorrenza aumenta
- il tempo di attesa cresce
- il tempo di risposta degrada

Questa relazione costituisce uno dei fondamenti per comprendere il comportamento sotto carico.

---

### Interpretazione pratica

Carico e capacità non dovrebbero mai essere trattati come etichette astratte.

Essi determinano:

- se il sistema opera con headroom
- se è probabile che compaia accodamento (queueing)
- quanto margine esista prima che appaia instabilità

Nella performance engineering, sapere che un sistema “funziona” non è sufficiente.

Ciò che conta è sapere sotto quali condizioni di carico esso rimanga stabile e quanto sia vicino alla sua capacità effettiva.

---

### Idea chiave

Un sistema non si rompe quando raggiunge la capacità.

Inizia a degradare prima di quel punto.

L’obiettivo della performance engineering è identificare:

- dove si trovino i limiti di capacità
- come il sistema si comporti in prossimità di essi
- quanto margine sia richiesto

--- 

<a id="152-saturation-and-queueing"></a>
## 1.5.2 Saturazione e accodamento

### Definizione

La **saturazione** si verifica quando una risorsa è occupata per la maggior parte o per tutto il tempo.

L’**accodamento** (queueing) si verifica quando il lavoro in ingresso non può essere elaborato immediatamente e deve essere messo in attesa: in coda.

Questi due fenomeni sono strettamente correlati.

Essi sono tra i più importanti meccanismi alla base della degradazione delle prestazioni nei sistemi reali.

---

### Saturazione della risorsa

Una risorsa diventa satura quando:

- la sua utilizzazione si avvicina al limite
- ha poco o nessun tempo di inattività

Esempi tipici:

- CPU vicina al 100%
- thread pool completamente occupato
- connection pool esaurito

A questo punto:

- le nuove richieste non possono essere elaborate immediatamente
- devono attendere

La saturazione non significa necessariamente problema.

Significa che il sistema ha perso margine di elaborazione e non è più in grado di assorbire ulteriore lavoro senza ritardo.

---

### Formazione della coda

Quando le richieste di lavoro arrivano più velocemente di quanto possano essere elaborate:

- si forma una coda
- il tempo di attesa aumenta

Questo influisce sul tempo di risposta:

- il tempo di servizio rimane lo stesso
- il tempo di attesa cresce

→ [1.2.3 Tempo di servizio vs tempo di risposta](01-02-core-metrics-and-formulas.md#123-service-time-vs-response-time-queueing)

L’accodamento è quindi la conseguenza visibile di una capacità di elaborazione insufficiente su una determinata risorsa.

---

### Effetto non lineare

L’accodamento non cresce linearmente.

All’aumentare dell’utilizzazione:

- il tempo di attesa cresce lentamente all’inizio
- poi aumenta rapidamente
- infine domina il tempo di risposta

Piccoli aumenti di carico possono causare grandi aumenti di latenza.

Questo spiega perché i sistemi spesso appaiano stabili per lungo tempo e poi degradino improvvisamente vicino alla soglia di saturazione.

---

### Collegamento con l’utilizzazione

L’utilizzazione svolge un ruolo centrale:

→ [1.2.2 Legge di Utilizzazione](01-02-core-metrics-and-formulas.md#122-utilization-law-resource-level-busy-time)

Quando l’utilizzazione si avvicina al proprio limite:

- la probabilità di attesa aumenta
- le code crescono
- la latenza diventa instabile

Il punto importante non è che una risorsa sia “occupata”, ma che quando essa sia persistentemente occupata, il lavoro in ingresso inizi ad accumularsi.

---

### Implicazioni pratiche

L’accodamento è spesso la causa principale della degradazione delle prestazioni.

I sintomi includono:

- aumento improvviso del tempo di risposta
- tail latency elevata (p95, p99)
- code crescenti (thread, connessioni, richieste)

Anche se:

- la CPU non è completamente saturata
- la latenza media sembra accettabile

l’accodamento può comunque essere la fonte dominante del ritardo.

Questo è particolarmente comune nei sistemi con pool condivisi, operazioni bloccanti o colli di bottiglia sulle dipendenze.

---

### Esempio

Un sistema gestisce richieste con:

- tempo di servizio = 10 ms

A basso carico:

- le richieste vengono elaborate immediatamente
- tempo di risposta ≈ 10 ms

All’aumentare del carico:

- le richieste iniziano ad attendere
- il tempo di risposta diventa:

  10 ms (servizio) + tempo di attesa

Ad alto carico:

- il tempo di attesa domina
- il tempo di risposta aumenta rapidamente

Questo esempio vuole illustrare il perché la crescita della latenza sotto carico sia spesso causata più dall’attesa che dal lavoro in sé stesso.

---

### Interpretazione pratica

La saturazione è la condizione.

L’accodamento (queueing) è la conseguenza.

Il sistema non rallenta perché ogni richiesta richiede più computazione, ma perché più richieste stanno competendo per le stesse risorse limitate.

Questa distinzione è essenziale:

- ottimizzare il tempo di servizio può aiutare
- ma ridurre l’accodamento è spesso ancora più importante

---

### Idea chiave

La saturazione non rompe immediatamente il sistema.

Introduce accodamento.

L’accodamento aumenta il tempo di attesa.

Il tempo di attesa domina il tempo di risposta.

Questo è il meccanismo principale alla base della degradazione delle prestazioni sotto carico.

---

<a id="153-non-linear-degradation"></a>
## 1.5.3 Degradazione non lineare

### Definizione

Le prestazioni del sistema non degradano linearmente all’aumentare del carico.

Piuttosto, la degradazione segue un andamento non lineare, specialmente in prossimità dei limiti di capacità.

Ciò significa che la relazione tra carico e tempo di risposta è spesso inizialmente regolare e poi fortemente instabile vicino alla saturazione.

---

### Comportamento lineare vs non lineare

A carico basso o moderato:

- il throughput aumenta proporzionalmente al carico
- la latenza rimane relativamente stabile

In questa regione, il sistema appare prevedibile.

---

Quando il carico si avvicina alla capacità:

- piccoli aumenti di carico producono grandi aumenti di latenza
- la variabilità aumenta
- il comportamento diventa instabile

Questo segna la transizione verso la degradazione non lineare.

Il sistema non si comporta più in modo proporzionale alla domanda.

Inizia a reagire in modo sproporzionato al lavoro aggiuntivo.

---

### Causa radice

La degradazione non lineare è causata principalmente da:

- effetti di accodamento (→ [1.5.2 Saturazione e accodamento](#152-saturation-and-queueing))
- elevata utilizzazione delle risorse
- contesa tra richieste

All’aumentare dell’utilizzazione:

- il tempo di attesa cresce in modo sproporzionato
- il tempo di risposta viene dominato dai ritardi piuttosto che dal servizio

Questo spiega perché la degradazione spesso acceleri improvvisamente invece di crescere gradualmente.

---

### Effetti osservabili

I sintomi tipici includono:

- rapido aumento della latenza p95 e p99
- ampliamento del divario tra latenza media e tail latency
- aumento della varianza nei tempi di risposta
- errori intermittenti o timeout

Questi effetti spesso compaiono improvvisamente.

Il sistema può sembrare sano subito prima di entrare in una regione di grave instabilità.

---

### Intuizione fuorviante

È comune assumere:

- “Se il sistema gestisce 80 req/s, dovrebbe gestire 100 req/s con latenza leggermente più alta”

In realtà:

- le prestazioni possono rimanere stabili fino a un certo punto
- poi degradare bruscamente oltre quel punto

Spesso non esiste una transizione graduale.

Questo costituisce uno degli errori più comuni nel capacity planning e nelle aspettative prestazionali.

---

### Esempio

Un sistema si comporta come segue:

- fino a 70 req/s → latenza stabile (~100 ms)
- a 80 req/s → la latenza aumenta a 150 ms
- a 90 req/s → la latenza salta a 400 ms
- a 100 req/s → il sistema diventa instabile

La degradazione non è proporzionale al carico.

Gli ultimi incrementi di carico hanno un effetto molto maggiore rispetto a quelli precedenti.

---

### Implicazione pratica

Il capacity planning deve tenere conto del comportamento non lineare.

Operare un sistema vicino ai suoi limiti conduce a:

- latenza imprevedibile
- prestazioni instabili
- esperienza utente scadente

I sistemi dovrebbero operare con un ragionevole margine di sicurezza al di sotto della capacità.

Quel margine non è opzionale.

È ciò che permette al sistema di assorbire la normale variabilità senza entrare in un comportamento instabile.

---

### Collegamento con i concetti precedenti

La degradazione non lineare è l’effetto visibile di:

- utilizzazione crescente (→ [1.2.2 Legge di Utilizzazione](01-02-core-metrics-and-formulas.md#122-utilization-law-resource-level-busy-time))
- accodamento crescente (→ [1.5.2 Saturazione e accodamento](#152-saturation-and-queueing))

È quindi una conseguenza a livello di sistema di meccanismi già introdotti nelle sezioni precedenti.

---

### Interpretazione pratica

La degradazione non lineare spiega perché i sistemi non dovrebbero essere gestiti troppo vicino al loro massimo teorico.

Un adeguato margine operativo può fare la differenza tra:

- prestazioni stabili
- degradazione imprevedibile

Questo spiega anche perché il solo utilizzo medio delle risorse sia spesso fuorviante nella valutazione della sicurezza in produzione.

---

### Idea chiave

La degradazione delle prestazioni non è graduale.

Accelera man mano che il sistema si avvicina ai propri limiti.

Comprendere questa non linearità è essenziale per evitare di gestire  sistemi troppo vicino ai loro limiti di capacità.

---

<a id="154-throughput-collapse"></a>
## 1.5.4 Collasso del throughput

### Definizione

Il **collasso del throughput** si verifica quando l’aumento del carico non aumenta più il throughput e può perfino ridurlo.

Invece di scalare con la domanda, il sistema diventa meno efficiente man mano che il carico aumenta.

Questo è uno dei segnali più chiari che il sistema stia operando oltre la propria capacità effettiva.

---

### Comportamento atteso vs collasso

In condizioni normali:

- l’aumento del carico aumenta il throughput
- fino a quando il sistema si avvicina ai limiti di capacità

Tuttavia, oltre un certo punto:

- il throughput smette di aumentare
- può stabilizzarsi o diminuire
- la latenza aumenta significativamente

Questo è il cosiddetto collasso del throughput.

Più lavoro in ingresso non si traduce in altrettanto lavoro completato.

---

### Cause radice

Il collasso del throughput è tipicamente causato da:

- accodamento eccessivo
- contesa su risorse condivise
- thrashing delle risorse (CPU, memoria, I/O)
- amplificazione dei retry
- scheduling o locking inefficienti

Quando il sistema va in sovraccarico:

- si spende più tempo nel gestire la contesa che nel fare lavoro utile
- la capacità di elaborazione effettiva diminuisce

Questa è la ragione chiave per cui maggiore domanda può produrre minore output.

---

### Contributo dell’accodamento

Quando le code crescono:

- le richieste attendono più a lungo
- le risorse del sistema restano occupate
- le nuove richieste aggiungono pressione senza aumentare il lavoro completato

L’accodamento può quindi:

- aumentare la latenza
- ridurre il throughput effettivo

Questo è particolarmente visibile quando il sistema trascorre sempre più tempo a gestire l’arretrato invece di fare reale progresso.

---

### Contesa e thrashing

Ad alto carico:

- i thread competono per risorse condivise
- i lock diventano hotspot
- il context switching aumenta
- la località della cache degrada

In casi estremi:

- il sistema trascorre più tempo a coordinare che a elaborare

Questo conduce a una riduzione del throughput.

Il sistema rimane attivo, ma la sua attività diventa sempre più improduttiva.

---

### Amplificazione dei retry

I fallimenti sotto carico spesso innescano retry.

Questo crea carico aggiuntivo:

- le richieste fallite vengono ritentate
- viene generato più lavoro
- la pressione aumenta ulteriormente

Questo loop di feedback può:

- accelerare il collasso
- rendere difficile il recupero

Il comportamento dei retry non è quindi soltanto una risposta ai sintomi, ma anche una frequente causa del peggioramento del sovraccarico.

---

### Effetti osservabili

I sintomi tipici includono:

- throughput che si stabilizza o diminuisce nonostante l’aumento del carico
- forte aumento della latenza
- aumento dei tassi di errore (timeout, 5xx)
- comportamento instabile o oscillante

A questo stadio, il sistema può sembrare occupato ma non sta più scalando in modo utile.

---

### Esempio

Un sistema si comporta come segue:

- 50 req/s → 50 req/s di throughput
- 80 req/s → 80 req/s di throughput
- 100 req/s → 90 req/s di throughput
- 120 req/s → 70 req/s di throughput

L’aumento del carico riduce il throughput effettivo.

Questo è un indicatore diretto del fatto che il sovraccarico stia "danneggiando" il lavoro utile.

---

### Implicazione pratica

Il collasso del throughput indica che il sistema sta operando oltre la propria capacità effettiva.

A questo punto:

- aggiungere più carico peggiora le prestazioni
- il sistema può diventare instabile

La mitigazione richiede:

- ridurre il carico
- rimuovere i colli di bottiglia
- migliorare l’efficienza delle risorse

In molti casi, la prima azione correttiva non è l’ottimizzazione ma la protezione: rate limiting, admission control o controllo dei retry.

---

### Collegamento con i concetti precedenti

Il collasso del throughput è il risultato di:

- degradazione non lineare (→ [3.5.3 Degradazione non lineare](#353-non-linear-degradation))
- saturazione e accodamento (→ [3.5.2 Saturazione e accodamento](#352-saturation-and-queueing))

Può quindi essere compreso come uno stadio avanzato del comportamento in sovraccarico.

---

### Interpretazione pratica

Un sistema non elabora sempre più lavoro quando gliene viene applicato di aggiuntivo.

A un certo punto, il lavoro aggiuntivo diventa distruttivo anziché produttivo.

Riconoscere questa transizione è essenziale nella performance engineering, perché segna la differenza tra carico elevato e sovraccarico.

---

### Idea chiave

Oltre un certo punto, il carico aggiuntivo riduce la capacità del sistema di elaborare richieste.

Comprendere il collasso del throughput è essenziale per evitare condizioni di sovraccarico.

---

<a id="155-tail-latency-amplification"></a>
## 1.5.5 Amplificazione della tail latency

### Definizione

L’**amplificazione della tail latency** si riferisce all’aumento sproporzionato dei tempi di risposta ad alto percentile (es. p95, p99) sotto carico.

Mentre la latenza media può apparire accettabile, un sottoinsieme di richieste diventa significativamente più lento.

Questo effetto costituisce uno dei più importanti indicatori di un'esperienza utente degradata e d'instabilità nascosta.

---

### Percentili vs media

La latenza media nasconde la variabilità.

I percentili rivelano la distribuzione:

- p50 rappresenta la richiesta tipica
- p95 e p99 rappresentano le richieste più lente

Sotto carico:

- la latenza media può aumentare moderatamente
- la tail latency può aumentare drasticamente

→ [1.2.7 Percentili](01-02-core-metrics-and-formulas.md#127-percentiles-p50-p95-p99)

Per questa ragione, le sole medie non sono sufficienti per valutare la reale qualità prestazionale.

---

### Cause radice

L’amplificazione della tail latency è guidata principalmente da:

- ritardi di accodamento
- contesa su risorse condivise
- distribuzione disomogenea del workload
- variabilità delle dipendenze (es. database, servizi esterni)

Anche piccoli ritardi in alcuni componenti possono:

- propagarsi attraverso il sistema
- amplificare la latenza end-to-end

La tail latency è quindi spesso un effetto emergente, non soltanto locale.

---

### Effetto nei sistemi distribuiti

Nei sistemi con più componenti:

- una richiesta dipende spesso da più servizi
- la latenza complessiva dipende dal componente più lento

All’aumentare del numero di dipendenze:

- la probabilità di una richiesta lenta aumenta
- la tail latency diventa più pronunciata

Questa è una delle ragioni per cui la tail latency sia particolarmente importante nelle architetture distribuite.

---

### Sotto carico

All’aumentare del carico:

- le code crescono
- la contesa aumenta
- la variabilità si espande

Questo conduce a:

- un ampliamento del divario tra media e p95/p99
- tempi di risposta imprevedibili per un sottoinsieme di utenti

Il sistema può quindi apparire per lo più stabile pur producendo comunque un’esperienza inaccettabile per una frazione significativa di richieste.

---

### Effetti osservabili

I sintomi tipici includono:

- latenza media stabile con p95/p99 degradati
- risposte lente intermittenti
- timeout che colpiscono solo una frazione di richieste

Questo può risultare fuorviante:

- il sistema appare “per lo più a posto”
- ma l’esperienza utente è degradata

Questo spiega perché le metriche di coda siano essenziali nel performance testing e nel monitoraggio in produzione.

---

### Esempio

Un sistema mostra:

- latenza media = 120 ms
- latenza p95 = 180 ms (accettabile)
- latenza p99 = 1200 ms (problematica)

La maggior parte delle richieste è veloce, ma una piccola percentuale è molto lenta.

In molti sistemi user-facing, questa piccola percentuale è sufficiente a creare insoddisfazione visibile o violazioni degli SLO.

---

### Implicazione pratica

La valutazione delle prestazioni deve considerare la **tail latency**.

Affidarsi alle medie può:

- nascondere problemi critici
- sottostimare l’impatto sugli utenti

I sistemi dovrebbero essere progettati e testati per:

- controllare il comportamento di coda
- limitare la variabilità sotto carico

Questo è particolarmente importante per sistemi distribuiti, API e applicazioni interattive.

---

### Collegamento con i concetti precedenti

L’amplificazione della tail latency è una conseguenza di:

- accodamento (→ [1.5.2 Saturazione e accodamento](#152-saturation-and-queueing))
- degradazione non lineare (→ [1.5.3 Degradazione non lineare](#153-non-linear-degradation))
- interazioni e dipendenze di sistema

Essa è quindi una delle manifestazioni più visibili dello stress del sistema sotto carico.

---

### Interpretazione pratica

Le prestazioni non sono definite dalla richiesta media.

Sono definite dalla prevedibilità dei tempi di risposta, specialmente per le richieste più lente.

Un sistema con latenza media accettabile ma comportamento p95/p99 scarso non è realmente stabile dal punto di vista dell’utente o operativo.

---

### Idea chiave

Le prestazioni non sono definite dalla richiesta media.

Sono definite da come il sistema si comporta per le richieste più lente.

Controllare la tail latency è essenziale per sistemi prevedibili e affidabili.