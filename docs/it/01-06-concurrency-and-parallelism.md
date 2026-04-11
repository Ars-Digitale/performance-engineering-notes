# 1.6 – Concorrenza e parallelismo

<a id="16-concurrency-and-parallelism"></a>

Questo capitolo introduce concorrenza e parallelismo come concetti fondamentali nella performance engineering dei sistemi e delle applicazioni.

Esso introduce lo scheduling del lavoro, come interagiscano task multipli e perché overhead di coordinamento, contesa e sincronizzazione diventino spesso fattori limitanti sotto carico.

Concorrenza e parallelismo sono essenziali per la scalabilità, ma introducono anche complessità, overhead e punti di rottura che influenzano direttamente latenza, throughput e stabilità del sistema.

## Indice

- [1.6.1 Concorrenza vs parallelismo](#161-concurrency-vs-parallelism)
- [1.6.2 Thread e modello di esecuzione](#162-threads-and-execution-model)
- [1.6.3 Contesa e sincronizzazione](#163-contention-and-synchronization)
- [1.6.4 Problemi comuni di concorrenza](#164-common-concurrency-issues)
	- [1.6.4.1 Race conditions](#1641-race-conditions)
	- [1.6.4.2 Deadlock](#1642-deadlocks)
	- [1.6.4.3 Livelock](#1643-livelocks)
	- [1.6.4.4 Starvation](#1644-starvation)
	- [1.6.4.5 Esaurimento del thread pool](#1645-thread-pool-exhaustion)

---

<a id="161-concurrency-vs-parallelism"></a>
## 1.6.1 Concorrenza vs parallelismo

### Definizione

**Concorrenza** e **parallelismo** sono concetti correlati ma distinti.

Essi sono spesso confusi, ma descrivono aspetti differenti del comportamento del sistema.

Comprendere la distinzione è essenziale perché un sistema può gestire molte attività contemporaneamente da un punto di vista strutturale senza eseguire realmente molte attività simultaneamente a livello hardware.

---

### Concorrenza

La **concorrenza** si riferisce alla capacità di un sistema di gestire più task durante uno stesso intervallo di tempo.

Questi task:

- possono non essere eseguiti esattamente nello stesso momento
- possono essere "interleaved"
- condividono risorse di sistema

La concorrenza riguarda:

- struttura
- coordinamento
- gestione di più operazioni "in flight"

Essa è quindi principalmente interessata a come il lavoro viene organizzato e schedulato.

---

### Parallelismo

Il **parallelismo** si riferisce all’esecuzione di più task nello stesso istante.

Questo richiede:

- più unità di elaborazione (es. core CPU)
- vera esecuzione simultanea

Il parallelismo riguarda:

- esecuzione
- utilizzo dell’hardware
- svolgere più lavoro nello stesso istante

Esso è quindi principalmente interessato all'esecuzione simultanea.

---

### Differenza chiave

- **Concorrenza** = gestire molti task  
- **Parallelismo** = eseguire molti task simultaneamente  

Un sistema può essere:

- concorrente ma non parallelo (single core, task "interleaved")
- parallelo ma non altamente concorrente (pochi task di lunga durata)

Questa distinzione conta perché le proprietà di scalabilità di un sistema dipendono non solo da quanto lavoro esista, ma anche da come tale lavoro venga coordinato e schedulato.

---

### Relazione con le prestazioni

La concorrenza influisce su:

- quante richieste possono essere in esecuzione
- come vengono condivise le risorse
- come sorge la contesa

Il parallelismo influisce su:

- quanto velocemente il lavoro possa essere eseguito
- quanto efficacemente venga utilizzato l’hardware

Entrambi influenzano:

- throughput
- latenza
- scalabilità

Nella pratica, aggiungere concorrenza senza sufficiente parallelismo può aumentare attesa e contesa, mentre aggiungere parallelismo senza un buon controllo della concorrenza può sprecare risorse o esporre problemi di coordinamento.

---

### Intuizione pratica

Un sistema concorrente:

- può accettare molte richieste
- può comunque elaborarle sequenzialmente o con parallelismo limitato

Un sistema parallelo:

- può elaborare più richieste nello stesso momento
- ma può comunque soffrire di contesa o overhead di coordinamento

Per questa ragione, concorrenza e parallelismo non dovrebbero essere trattati come automaticamente benefici.

Il loro valore dipende da come interagiscono con workload, risorse condivise e vincoli di esecuzione.

---

### Collegamento con i concetti precedenti

La concorrenza aumenta:

- il numero di richieste in flight (→ [1.2.1 Legge di Little](01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency))

Questo conduce a:

- condivisione delle risorse
- potenziale accodamento (→ [1.5.2 Saturazione e accodamento](01-05-system-behavior-under-load.md#152-saturation-and-queueing))

Questa è una delle principali ragioni per cui la concorrenza diventa un tema centrale nella performance engineering e non soltanto una questione di programmazione.

---

### Interpretazione pratica

La concorrenza è spesso necessaria per supportare molte operazioni simultanee, specialmente nei sistemi di rete e guidati da I/O.

Tuttavia, la concorrenza aumenta anche la probabilità di:

- interazioni su stato condiviso
- accumulo di code
- contesa sui lock
- overhead di coordinamento

Il parallelismo può aumentare il throughput, ma solo se viene realmente eseguito lavoro utile anziché lavoro bloccato o serializzato.

---

### Idea chiave

La concorrenza determina quanti task siano attivi.

Il parallelismo determina quanti task vengano eseguiti nello stesso momento.

Le prestazioni dipendono da entrambi, e da come interagiscono con le risorse del sistema.

---

<a id="162-threads-and-execution-model"></a>
## 1.6.2 Thread e modello di esecuzione

### Definizione

Il **modello di esecuzione** definisce come il lavoro venga eseguito all’interno di un sistema.

Nella maggior parte dei sistemi, il lavoro viene svolto da **thread**, che vengono eseguiti all’interno di un **processo**.

Il modello di esecuzione determina come le richieste vengano mappate sulle unità di esecuzione, come venga gestita l’attesa e come vengano consumate le risorse di sistema sotto carico.

---

### Processi e thread

Un **processo** è un ambiente di esecuzione isolato:

- possiede il proprio spazio di memoria
- contiene risorse (file, socket, memoria)

Un **thread** è un’unità di esecuzione all’interno di un processo:

- più thread condividono la stessa memoria del processo
- i thread eseguono task in concorrenza

Nella maggior parte delle applicazioni:

- un processo ospita più thread
- i thread gestiscono le richieste in ingresso

Questo modello a memoria condivisa rende i thread efficienti per la comunicazione, ma introduce anche la complessità dello stato condiviso.

---

### Thread

Un thread:

- esegue istruzioni
- consuma tempo CPU
- può bloccarsi in attesa (es. I/O, lock)

Più thread permettono a un sistema di:

- gestire più richieste
- sovrapporre computazione e attesa
- aumentare la concorrenza

Tuttavia, i thread non sono gratuiti.

Ogni thread aggiuntivo introduce overhead di memoria, overhead di scheduling e complessità di coordinamento.

---

### Ciclo di vita del thread

Un thread attraversa tipicamente diversi stati:

- **running** (in esecuzione attiva)
- **runnable** (pronto a essere eseguito, in attesa di CPU)
- **waiting** / blocked (in attesa di una risorsa o di un evento)

Le prestazioni sono influenzate da come i thread si spostano tra questi stati.

Un sistema con molti thread in stato "runnable" o "blocked" può apparire attivo, ma espletare un progresso utile limitato.

Comprendere gli stati dei thread è quindi essenziale nella diagnosi dei problemi di concorrenza.

---

### Stack e memoria

Ogni thread possiede il proprio **stack**:

- memorizza chiamate di metodo e variabili locali
- cresce e si riduce durante l’esecuzione

Implicazioni:

- più thread → maggiore utilizzo di memoria (uno stack per thread)
- catene di chiamata profonde → maggiore utilizzo dello stack
- l’esaurimento dello stack può portare a rotture

Questo è particolarmente rilevante nei sistemi ad alta concorrenza.

Il numero di thread influisce quindi non solo sullo scheduling, ma anche sull’impronta di memoria e sulla stabilità.

---

### Modelli di esecuzione

Sistemi differenti utilizzano **modelli di esecuzione** differenti.

I modelli comuni includono:

---

#### Un thread per richiesta

Ogni richiesta viene gestita da un thread dedicato.

Caratteristiche:

- modello semplice
- facile da comprendere
- le operazioni bloccanti sono dirette

Limiti:

- elevato utilizzo di memoria con molti thread
- scalabilità limitata sotto condizioni di alta concorrenza

Questo modello è concettualmente semplice, ma spesso si comporta male quando la concorrenza diventa molto elevata o quando il blocking è frequente.

---

#### Thread pool

Un numero fisso di thread gestisce le richieste in ingresso.

Le richieste vengono accodate e assegnate ai thread disponibili.

Caratteristiche:

- concorrenza controllata
- overhead ridotto rispetto a thread non limitati

Limiti:

- accodamento quando tutti i thread sono occupati
- potenziale saturazione del pool

Questo modello è ampiamente utilizzato perché fornisce utilizzo controllato delle risorse, ma introduce una coda esplicita e quindi un limite di capacità visibile.

---

#### Modello event-driven / asincrono

Il lavoro viene gestito usando operazioni **non bloccanti** e **event loop**.

Caratteristiche:

- pochi thread possono gestire molte richieste concorrenti
- efficiente per workload I/O-bound

Limiti:

- modello di programmazione più complesso
- richiede gestione accurata dei flussi asincroni

Questo modello riduce il numero di thread bloccati, ma sposta la complessità su coordinamento, callback, gestione dello stato e design non bloccante.

---

### Prospettiva Java (esempio)

In Java, un modello di esecuzione comune utilizza thread pool.

Per esempio:

```java
ExecutorService executor = Executors.newFixedThreadPool(10);

executor.submit(() -> {
    // task logic
});
```

Le richieste vengono:

- inviate a una coda
- eseguite da un numero limitato di thread

Se tutti i thread sono occupati:

- i task attendono nella coda
- la latenza aumenta

Per una spiegazione dettagliata dei thread in Java, vedi:

→ https://ars-digitale.github.io/java-21-study-guide/en/module-07/threads/

Questo esempio è semplice, ma evidenzia un’idea chiave: risorse di esecuzione limitate introducono naturalmente accodamento quando la domanda supera la capacità di elaborazione immediata.

---

### Bloccante vs non bloccante

I thread possono:

- **bloccarsi** (attendere I/O, lock, risorse esterne)
- **rimanere attivi** (lavoro CPU-bound)

Il blocking riduce la concorrenza effettiva:

- i thread sono occupati ma non progrediscono
- meno thread sono disponibili per nuovo lavoro

Gli approcci non bloccanti mirano a:

- ridurre l’attesa inattiva
- migliorare l’utilizzo delle risorse

La distinzione è importante perché un alto numero di thread non significa necessariamente alto throughput.

Se i thread trascorrono la maggior parte del tempo in attesa, la concorrenza è presente, ma l’esecuzione produttiva è limitata.

---

### Implicazioni pratiche

Il modello di esecuzione determina:

- come venga gestita la concorrenza
- come vengano utilizzate le risorse
- come compaia l’accodamento

Effetti tipici includono:

- saturazione del thread pool → accodamento delle richieste
- operazioni bloccanti → throughput ridotto
- troppi thread → overhead di context switching

Il modello di esecuzione determina anche dove i colli di bottiglia diventino visibili: nelle code, nei pool, nei thread bloccati o negli event loop.

---

### Collegamento con i concetti precedenti

Il comportamento dei thread impatta direttamente:

- accodamento (→ [1.5.2 Saturazione e accodamento](01-05-system-behavior-under-load.md#152-saturation-and-queueing))
- latenza sotto carico
- capacità effettiva del sistema

Esso influenza anche la rapidità con cui un sistema passa da un comportamento stabile alla saturazione quando la concorrenza aumenta.

---

### Interpretazione pratica

Scegliere un modello di esecuzione non è solo una decisione di programmazione.

È una decisione prestazionale.

Il modello influisce su:

- consumo di memoria
- overhead di scheduling
- latenza in condizioni di attesa
- scalabilità sotto workload reale

Un design facile da implementare può non essere quello che si comporta meglio sotto carico sostenuto.

---

### Idea chiave

Il modello di esecuzione definisce come il lavoro venga schedulato ed elaborato.

I thread non sono gratuiti.

Il modo in cui vengono utilizzati determina:

- quanto lavoro possa essere gestito
- quanto efficientemente vengano utilizzate le risorse
- come il sistema si comporti sotto carico

---

<a id="163-contention-and-synchronization"></a>
## 1.6.3 Contesa e sincronizzazione

### Definizione

La **contesa** si verifica quando più thread competono per la stessa risorsa.

La **sincronizzazione** è il meccanismo usato per coordinare l’accesso alle risorse condivise.

Questi concetti sono centrali per comprendere la degradazione delle prestazioni nei sistemi concorrenti.

Essi collegano correttezza e prestazioni: gli stessi meccanismi che proteggono lo stato condiviso possono anche diventare la fonte di attesa e di ridotta scalabilità.

---

### Risorse condivise

Nei sistemi concorrenti, i thread condividono spesso risorse come:

- strutture di memoria (oggetti, cache)
- lock e monitor
- thread pool e code
- connessioni a database
- canali I/O

Quando l’accesso non è coordinato, può verificarsi **corruzione** dei dati.

Quando l’accesso è coordinato, può comparire **contesa**.

Questo rende la sincronizzazione necessaria, ma non gratuita.

---

### Sincronizzazione

La sincronizzazione garantisce che le risorse condivise siano accessibili in modo sicuro.

I meccanismi comuni includono:

- lock (mutex, monitor)
- sezioni sincronizzate
- semafori
- operazioni atomiche

La sincronizzazione garantisce correttezza, ma introduce overhead.

Tale overhead può derivare da:

- attesa
- serializzazione dell’esecuzione
- memory barrier aggiuntive
- costi di coordinamento tra thread

---

### Contesa

La **contesa** sorge quando più thread tentano di accedere simultaneamente alla stessa risorsa.

Quando si verifica contesa:

- i thread possono bloccarsi o attendere
- l’esecuzione viene ritardata
- il throughput si riduce

Più thread competono:

- maggiore è il tempo di attesa
- minore è il parallelismo effettivo

Un sistema altamente concorrente può quindi comportarsi come un sistema parzialmente serializzato se molto del suo lavoro dipende dalle stesse risorse condivise.

---

### Contesa sui lock

Una forma comune di contesa coinvolge i lock.

Quando un thread detiene un lock:

- gli altri thread devono attendere
- può formarsi una coda di thread in attesa

Gli effetti includono:

- aumento della latenza
- riduzione del throughput
- potenziali colli di bottiglia

La contesa sui lock è particolarmente problematica quando le sezioni critiche sono lunghe, frequentemente accedute o collocate su hot path di esecuzione.

---

### Contesa vs utilizzazione

Elevata contesa può verificarsi anche quando l’utilizzazione della CPU è moderata.

Per esempio:

- molti thread sono in attesa di un lock
- la CPU è parzialmente inattiva
- il sistema appare sottoutilizzato ma è in realtà vincolato

Questa è una fonte comune di diagnosi fuorvianti.

Essa spiega perché un utilizzo basso o moderato della CPU non significhi necessariamente che il sistema abbia capacità disponibile.

---

### Sincronizzazione fine-grained vs coarse-grained

La sincronizzazione può essere:

- **coarse-grained** (pochi lock, grandi sezioni critiche)
- **fine-grained** (molti lock, sezioni critiche più piccole)

Compromessi:

- **coarse-grained** → più semplice ma maggiore contesa
- **fine-grained** → più scalabile ma più complessa

La scelta tra i due modelli dipende dalle caratteristiche del workload, dai pattern di accesso e dal costo della complessità aggiuntiva di design.

---

### Prospettiva Java (esempio)

In Java, la sincronizzazione può essere implementata usando blocchi `synchronized`:

```java
synchronized (lock) {
    // critical section
}
```

Oppure lock espliciti:

```java
Lock lock = new ReentrantLock();

lock.lock();
try {
    // critical section
} finally {
    lock.unlock();
}
```

Se molti thread tentano di entrare nella stessa sezione critica:

- la contesa aumenta
- i thread si bloccano
- le prestazioni degradano

Questo esempio evidenzia come un meccanismo di correttezza possa diventare un vincolo di scalabilità sotto carico.

---

### Sintomi della contesa

Indicatori tipici includono:

- aumento del tempo di risposta sotto carico
- **basso utilizzo CPU con alta latenza**
- thread in stati blocked o waiting
- lunghe code su risorse condivise

Questi sintomi spesso compaiono prima della saturazione totale e possono essere scambiati per altri problemi di risorse se non analizzati con attenzione.

---

### Implicazioni pratiche

La contesa limita la scalabilità.

Anche con:

- CPU sufficiente
- memoria adeguata

Un sistema può non scalare se:

- i thread trascorrono tempo in attesa invece di trovarsi in esecuzione

Ridurre la contesa ha spesso un impatto maggiore dell’ottimizzazione delle singole operazioni.

Questo è particolarmente vero per sistemi in cui le prestazioni siano vincolate dall’accesso condiviso piuttosto che dalla computazione pura.

---

### Collegamento con i concetti precedenti

La contesa contribuisce a:

- accodamento (→ [1.5.2 Saturazione e accodamento](01-05-system-behavior-under-load.md#152-saturation-and-queueing))
- degradazione non lineare (→ [1.5.3 Degradazione non lineare](01-05-system-behavior-under-load.md#153-non-linear-degradation))
- collasso del throughput (→ [1.5.4 Collasso del throughput](01-05-system-behavior-under-load.md#154-throughput-collapse))

La contesa è quindi sia un fenomeno locale di sincronizzazione sia un meccanismo prestazionale a livello di sistema.

---

### Interpretazione pratica

La concorrenza aumenta le opportunità di sovrapposizione utile, ma aumenta anche la competizione per le risorse condivise.

La sfida pratica non è semplicemente aggiungere più thread, ma garantire che la concorrenza aggiuntiva produca lavoro utile anziché attesa aggiuntiva.

---

### Idea chiave

La concorrenza introduce la necessità di sincronizzazione.

La sincronizzazione introduce contesa.

La contesa limita le prestazioni.

Comprendere e controllare la contesa è essenziale per sistemi scalabili.

---

<a id="164-common-concurrency-issues"></a>
## 1.6.4 Problemi comuni di concorrenza

La concorrenza introduce complessità.

Quando più thread interagiscono, assunzioni scorrette o scarso coordinamento possono condurre a specifiche classi di problemi.

Questi problemi compaiono spesso sotto carico e possono influenzare severamente prestazioni e correttezza.

Molti di essi sono difficili da riprodurre in test superficiali perché dipendono da timing, scheduling o pressione sulle risorse.

---

<a id="1641-race-conditions"></a>
### 1.6.4.1 Race conditions

### Definizione

Una **race condition** si verifica quando più thread accedono a dati condivisi senza adeguata sincronizzazione, e il risultato dipende dal timing.

L’esito non è quindi deterministico e può variare da un’esecuzione all’altra.

---

### Esempio

Due thread aggiornano un contatore condiviso:

- Thread A legge valore = 10
- Thread B legge valore = 10
- Thread A scrive 11
- Thread B scrive 11

Risultato atteso: 12  
Risultato reale: 11

Il valore finale dipende dall’ordine in cui operazioni non sincronizzate vengono eseguite.

---

### Impatto

- risultati errati
- stato del sistema incoerente
- bug difficili da riprodurre

Le race condition possono anche corrompere assunzioni interne in modi che compaiono solo più tardi sotto carico.

---

### Rilevanza prestazionale

Le race condition possono non causare sempre errori visibili, ma:

- richiedono spesso sincronizzazione aggiuntiva
- fix impropri possono introdurre contesa

Questa è una delle ragioni per cui correttezza e prestazioni non possano essere trattate come questioni completamente separate nei sistemi concorrenti.

---

<a id="1642-deadlocks"></a>
### 1.6.4.2 Deadlock

### Definizione

Un **deadlock** si verifica quando due o più thread si attendono indefinitamente l’un l’altro.

Ogni thread detiene una risorsa e attende un’altra risorsa detenuta dall'altro thread.

Di conseguenza, il progresso si arresta completamente.

---

### Esempio

- Thread A detiene il lock L1 e attende L2
- Thread B detiene il lock L2 e attende L1

Nessuno dei due può procedere ulteriormente.

Questo pattern di attesa circolare è la caratteristica distintiva del deadlock.

---

### Impatto

- il sistema si blocca
- le richieste non vengono mai completate
- le risorse rimangono bloccate

I deadlock sono particolarmente gravi perché trasformano risorse attive in risorse permanentemente bloccate.

---

### Rilevazione

- i thread rimangono bloccati
- i thread dump mostrano attesa circolare

I deadlock sono spesso rilevati tramite analisi dei thread piuttosto che tramite metriche prestazionali generali.

---

<a id="1643-livelocks"></a>
## 1.6.4.3 Livelock

### Definizione

Un **livelock** si verifica quando i thread non sono bloccati ma cambiano continuamente stato in risposta reciproca senza fare progresso.

A differenza del deadlock, l’attività continua, ma il lavoro utile no.

---

### Esempio

Due thread ritentano ripetutamente un’operazione:

- entrambi rilevano un conflitto
- entrambi ritentano nello stesso momento
- il conflitto persiste

Il sistema rimane attivo, ma il comportamento conflittuale continua indefinitamente.

---

### Impatto

- la CPU viene utilizzata
- nessun lavoro utile viene completato

I livelock possono quindi sembrare elaborazione attiva anche se il progresso effettivo è pari a zero.

---

<a id="1644-starvation"></a>
## 1.6.4.4 Starvation

### Definizione

La **starvation** si verifica quando alcuni thread non riescono a ottenere risorse per un periodo prolungato.

Altri thread continuano a eseguire mentre alcuni vengono di fatto ignorati.

Ciò significa che il sistema sta operando progresso, ma non in modo equo o prevedibile per tutto il lavoro.

---

### Cause

- scheduling non equo
- thread ad alta priorità che dominano l’esecuzione
- monopolizzazione delle risorse

La starvation è particolarmente problematica quando un sottoinsieme di richieste sperimenta latenza estrema mentre il resto del sistema appare funzionale.

---

### Impatto

- alcune richieste sperimentano latenza molto elevata
- il sistema appare parzialmente funzionale
- la tail latency aumenta

Questo rende la starvation particolarmente rilevante sia dal punto di vista prestazionale sia da quello dell’esperienza utente.

---

<a id="1645-thread-pool-exhaustion"></a>
## 1.6.4.5 Esaurimento del thread pool

### Definizione

L’**esaurimento del thread pool** si verifica quando tutti i thread di un pool sono occupati e i task in ingresso devono attendere.

Questo è uno dei colli di bottiglia legati alla concorrenza più comuni nei sistemi reali.

---

### Cause

- operazioni bloccanti all’interno dei thread
- dimensione insufficiente del pool
- task di lunga durata

Queste cause possono esistere indipendentemente oppure rafforzarsi a vicenda sotto carico crescente.

---

### Effetti

- la coda delle richieste cresce
- la latenza aumenta
- il throughput può degradare

Se la saturazione continua, l’esaurimento del thread pool può anche contribuire a timeout, retry e instabilità nei componenti upstream.

---

### Collegamento con i concetti precedenti

L’esaurimento del thread pool è un esempio diretto di:

- saturazione (→ [1.5.2 Saturazione e accodamento](01-05-system-behavior-under-load.md#152-saturation-and-queueing))
- degradazione non lineare (→ [1.5.3 Degradazione non lineare](01-05-system-behavior-under-load.md#153-non-linear-degradation))

Esso costituisce quindi una delle più chiare espressioni pratiche dei comportamenti di sistema introdotti nel capitolo precedente.

---

### Idea chiave

I problemi di concorrenza non sono soltanto problemi di correttezza.

Sono anche problemi prestazionali.

Molte degradazioni delle prestazioni sono causate da:

- contesa
- blocking
- fallimenti di coordinamento

Comprendere questi problemi è essenziale per diagnosticare sistemi reali.