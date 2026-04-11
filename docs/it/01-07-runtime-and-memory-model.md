## 1.7 – Runtime e modello di memoria

<a id="17-runtime-and-memory-model"></a>

Questo capitolo spiega come i "managed runtime" organizzano la memoria, allocano gli oggetti, recuperano memoria non più utilizzata e si comportano in situazione di memoria "sotto pressione".

Ci si concentra sui meccanismi di runtime e di memoria che influenzano direttamente latenza, stabilità e throughput sotto carico.

Comprendere questi meccanismi è essenziale perché molti problemi di performance non sono causati solo da limiti di CPU o I/O, ma dal modo in cui la memoria viene allocata, mantenuta e recuperata nel tempo.

## Indice

- [1.7.1 Struttura della memoria (heap, stack)](#171-memory-structure-heap-stack)
- [1.7.2 Allocazione e ciclo di vita degli oggetti](#172-allocation-and-object-lifecycle)
- [1.7.3 Garbage collection (concettuale)](#173-garbage-collection-conceptual)
- [1.7.4 Pressione di memoria e performance](#174-memory-pressure-and-performance)

---

<a id="171-memory-structure-heap-stack"></a>
## 1.7.1 Struttura della memoria (heap, stack)

### Modelli di gestione della memoria

Sistemi diversi utilizzano strategie di gestione della memoria diverse.

Due approcci comuni sono:

- **gestione manuale della memoria**  
  La memoria è allocata e liberata esplicitamente dal programmatore (es. C, C++)

- **memoria gestita**  
  La memoria è allocata automaticamente e recuperata dal runtime (es. Java, .NET)

Questa guida si concentra sui **sistemi a memoria gestita**, dove:

- gli oggetti sono allocati dinamicamente
- la memoria è recuperata automaticamente da uno o piu' thread dedicati delle rispettive macchine virtuali (garbage collection)

Questa distinzione è importante perché il comportamento delle performance cambia significativamente a seconda che il ciclo di vita della memoria sia controllato direttamente dal programmatore o indirettamente dal runtime.

---

### Definizione

La memoria è organizzata in diverse regioni con ruoli ben distinti.

Le due aree più importanti per il discorso sulle performance sono:

- **heap**
- **stack**

Queste due regioni supportano aspetti diversi dell’esecuzione del programma e hanno implicazioni di performance molto diverse.

---

### Heap

L’heap è un’area di memoria condivisa utilizzata per l’allocazione dinamica.

Nei runtime gestiti (come Java):

- gli oggetti sono allocati sull’heap
- la memoria è gestita dal runtime
- la garbage collection recupera gli oggetti non utilizzati

Implicazioni:

- l’utilizzo della memoria cresce con il tasso di allocazione
- la garbage collection impatta le performance
- l’accesso condiviso può introdurre contesa

L’heap quindi non è solo un’area di storage, ma una sezione centrale rispetto al comportamento del runtime sotto carico.

---

### Stack

Ogni thread ha il proprio stack.

Lo stack memorizza:

- chiamate di metodo (call frame)
- variabili locali
- valori intermedi

Caratteristiche:

- privato per ogni thread
- cresce e si riduce durante l’esecuzione
- tipicamente molto più piccolo dello heap

Poiché lo stack è privato del thread, l’accesso è semplice ed efficiente, ma il numero di thread influisce direttamente sull’utilizzo totale della memoria dello stack.

---

### Heap vs stack

| Aspetto           | Heap                         | Stack                        |
|------------------|------------------------------|------------------------------|
| Scope            | Condiviso tra thread         | Privato per thread           |
| Allocazione      | Dinamica (oggetti)           | Automatica (chiamate metodo) |
| Durata           | Gestita dal runtime          | Legata all’esecuzione metodo |
| Performance      | Più complessa                | Molto veloce                 |
| Impatto memoria  | Globale                      | Per thread                   |

---

### Interazione con i thread

Ogni thread:

- ha il proprio stack
- condivide l’heap

Questo crea un modello in cui:

- l’esecuzione è isolata per thread (stack)
- i dati sono condivisi tra thread (heap)

Questa interazione è una fonte di:

- contesa (oggetti condivisi)
- overhead di coordinamento

Spiega anche perché concorrenza e comportamento al livello della memoria sono strettamente correlati nei sistemi gestiti dal runtime.

---

### Implicazioni sulle performance

Heap:

- allocazione eccessiva → aumento dell’attività GC
- heap grande → cicli di garbage collection più lunghi
- accesso condiviso → potenziale contesa

Stack:

- molti thread → maggiore utilizzo totale della memoria (uno stack per thread)
- catene di chiamata profonde → aumento dell’utilizzo dello stack
- stack overflow → fallimento in casi estremi

Queste implicazioni diventano particolarmente importanti quando il sistema è sotto carico sostenuto o ad alta concorrenza.

---

### Interpretazione pratica

Heap e stack non sono solo dettagli implementativi.

Influenzano:

- come i dati sono condivisi
- come il lavoro viene eseguito
- come la memoria cresce sotto concorrenza
- dove appare l’overhead del runtime

Un sistema con molti thread e allocazioni frequenti stressa entrambe le regioni in modo diverso: lo stack tramite il numero di thread e la profondità delle chiamate, l’heap tramite creazione e retention degli oggetti.

---

### Idea chiave

L’heap memorizza dati condivisi.

Lo stack supporta l’esecuzione.

Le performance dipendono da come questi due interagiscono sotto carico.

---

### Collegamento con concetti precedenti

Il comportamento della memoria impatta direttamente:

- l’esecuzione dei thread (→ [1.6.2 Threads and execution model](01-06-concurrency-and-parallelism.md#162-threads-and-execution-model))
- la contesa (→ [1.6.3 Contention and synchronization](01-06-concurrency-and-parallelism.md#163-contention-and-synchronization))
- la latenza sotto carico (→ [1.5 System behavior under load](01-05-system-behavior-under-load.md))

Per questo motivo il modello di runtime e memoria non può essere analizzato separatamente dalla concorrenza e dal comportamento del sistema.

---

<a id="172-allocation-and-object-lifecycle"></a>
## 1.7.2 Allocazione e ciclo di vita degli oggetti

### Definizione

Nei sistemi a memoria gestita, gli oggetti sono creati dinamicamente e vivono per un certo periodo di tempo prima di essere recuperati dal runtime.

Il modo in cui gli oggetti sono allocati e quanto a lungo vivono ha un impatto diretto sulle performance.

Il comportamento di allocazione quindi non è solo una questione di memoria, ma anche una questione di latenza e stabilità.

---

### Allocazione

L’allocazione è il processo di creazione di nuovi oggetti in memoria.

Nella maggior parte dei runtime gestiti:

- l’allocazione avviene sull’heap
- è progettata per essere veloce ed efficiente
- avviene molto frequentemente nelle applicazioni tipiche

Esempi di allocazione:

- creazione di oggetti request
- costruzione di strutture dati
- elaborazione di risultati intermedi

Nei sistemi ad alto throughput, l’allocazione è spesso continua e strettamente legata all’intensità del carico di lavoro.

---

### Tasso di allocazione

Il **tasso di allocazione** è la quantità di memoria allocata per unità di tempo.

È un fattore chiave di performance.

Un alto tasso di allocazione significa:

- più oggetti creati
- maggiore churn di memoria
- maggiore pressione sul runtime

Anche se le allocazioni individuali sono veloci, grandi volumi impattano il sistema.

Questo è uno dei motivi per cui “allocazione veloce” non significa automaticamente “basso overhead di memoria.”

---

### Ciclo di vita degli oggetti

Gli oggetti non vivono tutti per la stessa durata.

Categorie tipiche includono:

- **oggetti a vita breve**  
  creati e scartati rapidamente (es. dati temporanei di request)

- **oggetti a vita media**  
  sopravvivono per un certo tempo durante l’elaborazione

- **oggetti a vita lunga**  
  rimangono in memoria per periodi estesi (es. cache, stato condiviso)

Comprendere la durata di vita degli oggetti è essenziale per ragionare sul comportamento della memoria.

Questa caratteristica determina quanta memoria rimane attiva nel tempo e come il runtime deve organizzare il lavoro di recupero.

---

### Pattern di allocazione

I sistemi reali tendono a mostrare pattern come:

- molti oggetti a vita breve per request
- oggetti a vita lunga occasionali
- burst di allocazione sotto carico

Questi pattern determinano:

- utilizzo della memoria
- comportamento della garbage collection
- stabilità delle performance

I pattern di allocazione sono spesso più informativi degli eventi di allocazione isolati, perché il runtime reagisce al comportamento aggregato nel tempo.

---

### Impatto sulle performance

L’allocazione in sé è solitamente veloce.

L’impatto principale deriva da:

- aumento dell’utilizzo della memoria
- pressione sulla garbage collection

Un alto tasso di allocazione può portare a:

- cicli di garbage collection più frequenti
- aumento della latenza
- pause imprevedibili

Il punto importante è che il costo della memoria è spesso indiretto: il sistema paga non solo per creare oggetti, ma per gestire le conseguenze della creazione di molti oggetti.

---

### Sotto carico

Con l’aumentare del carico:

- più richieste vengono elaborate
- più oggetti vengono creati
- il tasso di allocazione aumenta

Questo amplifica:

- la pressione di memoria
- l’attività di garbage collection
- la variabilità della latenza

Un sistema stabile a basso carico può quindi diventare sensibile alla memoria con l’aumentare del volume di richieste, anche se la logica di ogni richiesta rimane invariata.

---

### Interazione con la concorrenza

L’allocazione è spesso eseguita da più thread.

Questo può portare a:

- contesa sulle strutture di memoria
- aumento dell’overhead di coordinamento
- pattern di utilizzo della memoria non uniformi

Nei sistemi ad alta concorrenza:

- il tasso di allocazione cresce con la concorrenza
- la memoria diventa un collo di bottiglia condiviso

Questo è uno dei modi in cui concorrenza e comportamento della memoria si rafforzano a vicenda sotto carico.

---

### Implicazioni pratiche

Per ragionare sulle performance è importante considerare:

- quanti oggetti sono creati per request
- quanto a lungo vivono
- come il tasso di allocazione cambia sotto carico

Comprendere l’allocazione è essenziale per:

- spiegare il comportamento della latenza
- identificare colli di bottiglia
- prevedere i limiti del sistema

Aiuta anche a distinguere tra problemi causati dal calcolo e problemi causati dal churn di memoria.

---

### Interpretazione pratica

L’allocazione è spesso invisibile a livello di codice perché è facile da scrivere e generalmente poco costosa per operazione.

Tuttavia, a livello di sistema, l’allocazione ripetuta cambia il carico di lavoro del runtime.

Un design che crea grandi quantità di oggetti temporanei può funzionare correttamente, ma comunque imporre una pressione significativa sul sottosistema della memoria.

---

### Collegamento con i concetti successivi

Allocazione e durata di vita degli oggetti influenzano direttamente:

- il comportamento della garbage collection (→ sezione successiva)
- la pressione di memoria
- la latenza sotto carico

Costituiscono quindi la base causale degli effetti di runtime descritti nel resto di questo capitolo.

---

### Idea chiave

Le performance dipendono da quanta memoria viene allocata e da quanto a lungo viene mantenuta.

I pattern di allocazione modellano il comportamento del sistema sotto carico.

---

<a id="173-garbage-collection-conceptual"></a>
## 1.7.3 Garbage collection (concettuale)

### Definizione

La garbage collection (GC) è il processo attraverso il quale un runtime gestito recupera memoria che non è più in uso.

Invece di richiedere una deallocazione esplicita, il runtime:

- identifica oggetti non utilizzati
- libera la loro memoria
- rende disponibile spazio per nuove allocazioni

La garbage collection è uno dei meccanismi distintivi dei runtime gestiti e uno dei principali modi in cui il comportamento della memoria diventa visibile nell’analisi delle performance.

---

### Principio di base

Un oggetto è eleggibile per la "collezione" quando non è più raggiungibile (puntato) da altri elementi del programma.

Questo significa:

- nessun riferimento attivo punta ad esso
- non può essere acceduto dal programma

Il runtime periodicamente:

- scansiona i riferimenti agli oggetti
- identifica oggetti non raggiungibili
- recupera la loro memoria

Questo modello permette una gestione automatica della memoria, ma implica anche che il lavoro di recupero debba essere eseguito durante l’esecuzione del programma.

---

### Ciclo allocazione e recupero

L’utilizzo della memoria segue un ciclo:

1. gli oggetti sono allocati
2. gli oggetti diventano inutilizzati
3. la garbage collection recupera la memoria

Questo ciclo si ripete continuamente durante l’esecuzione.

Il runtime alterna quindi allocazione di nuova memoria e recupero di memoria vecchia, con un comportamento complessivo guidato dal tasso di allocazione e dai pattern di retention.

---

### Prospettiva Java (esempio)

In Java, l’allocazione di oggetti è frequente ed economica.

Per esempio:

```java
for (int i = 0; i < 1_000_000; i++) {
    String s = new String("test");
}
```

Questo codice crea un grande numero di oggetti a vita breve.

In un runtime gestito:

- questi oggetti sono allocati rapidamente sullo heap
- diventano non raggiungibili poco dopo la creazione
- la garbage collection li recupera

Se tali pattern di allocazione si verificano sotto carico:

- l’attività GC aumenta
- la pressione di memoria cresce
- la latenza può diventare instabile

L’impatto dipende non da una singola allocazione, ma dal **tasso di allocazione nel tempo**.

Per questo il comportamento della memoria deve essere analizzato come un pattern, non come un’operazione isolata.

### Esempio: retention degli oggetti

Gli oggetti che rimangono referenziati non vengono raccolti.

```java
List<String> cache = new ArrayList<>();

while (true) {
    cache.add(new String("data"));
}
```

In questo caso:

- gli oggetti sono allocati continuamente
- non vengono mai rilasciati
- l’utilizzo della memoria cresce nel tempo

Questo porta a:

- aumento della pressione di memoria
- cicli di garbage collection più costosi
- potenziale instabilità del sistema

Questo esempio illustra la differenza tra churn temporaneo di allocazione e retention persistente.

### Costo della garbage collection

La garbage collection non è gratuita.

Introduce overhead:

- tempo CPU per analizzare la memoria
- pause durante la raccolta (a seconda della strategia/policy di GC)

Il costo dipende da:

- tasso di allocazione
- numero di oggetti attivi
- dimensione della memoria

In altre parole, il costo GC dipende non solo da quanta memoria esiste, ma da quanta memoria è attiva ed ancora raggiungibile.

---

### Effetto stop-the-world

Alcune fasi (di alcune policy) della garbage collection possono sospendere l’esecuzione dell’applicazione.

Durante queste pause:

- i thread applicativi sono temporaneamente in stand-by
- nessun lavoro applicativo viene eseguito

Anche pause brevi possono:

- aumentare la latenza
- influenzare i tempi di risposta in coda (p95, p99)

Questo è uno dei motivi per cui i problemi GC appaiono spesso prima nell’analisi della latenza basata su percentili piuttosto che nelle medie.

---

### Comportamento generazionale (concettuale)

La maggior parte dei runtime moderni utilizza un approccio generazionale.

Basato sull’osservazione:

- la maggior parte degli oggetti ha vita breve
- pochi oggetti hanno durata di vita prolungata

La memoria è organizzata in modo tale che:

- gli oggetti a vita breve siano raccolti frequentemente
- gli oggetti a vita lunga siano raccolti meno spesso

Questo migliora l’efficienza perché recuperare molti oggetti a vita breve è solitamente più economico che scansionare ripetutamente memoria a lunga retention.

---

### Sotto carico

Con l’aumentare del carico:

- il tasso di allocazione aumenta
- la garbage collection viene eseguita più frequentemente

Questo può portare a:

- maggiore utilizzo della CPU
- pause più frequenti
- aumento della variabilità della latenza

Sotto carico importante, la GC può quindi passare da meccanismo di manutenzione in background a parte visibile del comportamento delle performance del sistema.

---

### Interazione con il ciclo di vita degli oggetti

Il comportamento della garbage collection dipende da:

- quanti oggetti sono creati
- quanto a lungo essi vivono

Pattern tipici:

- molti oggetti a vita breve → raccolte frequenti
- molti oggetti a vita lunga → raccolte più pesanti

Per questo allocazione e retention devono essere analizzate insieme: il numero di oggetti da solo non è sufficiente.

---

### Effetti osservabili

I problemi di garbage collection appaiono spesso come:

- picchi di latenza
- latenza di coda (degrado p95/p99)
- pause periodiche
- aumento dell’utilizzo CPU senza causa evidente

Questi sintomi sono spesso intermittenti, il che rende i problemi legati alla GC difficili da diagnosticare senza correlare segnali di memoria e latenza.

---

### Implicazioni pratiche

L’analisi delle performance deve considerare:

- tasso di allocazione
- distribuzione della durata di vita degli oggetti
- frequenza e costo dei cicli GC

L’ottimizzazione tipicamente si concentra su:

- comprensione dei pattern di allocazione
- riduzione della creazione inutile di oggetti
- controllo della pressione di memoria

Il tuning del collector può aiutare, ma di solito è più efficace capire in anticipo perché il runtime è sotto pressione.

---

### Interpretazione pratica

La garbage collection non è un bug o un’anomalia.

È un meccanismo necessario del runtime.

La domanda sulle performance non è se la GC esiste, ma se il suo costo di funzionamento rimane compatibile con il carico di lavoro e gli obiettivi di latenza del sistema.

---

### Collegamento con concetti precedenti

La garbage collection è direttamente collegata a:

- allocazione (→ [1.7.2 Allocazione e ciclo di vita degli oggetti](#172-allocation-and-object-lifecycle))
- struttura della memoria (→ [1.7.1 Struttura della memoria](#171-memory-structure-heap-stack))
- latenza di coda (→ [1.5.5 Tail latency amplification](01-05-system-behavior-under-load.md#155-tail-latency-amplification))

È quindi sia un meccanismo di runtime sia un contributore a livello di sistema alla variabilità delle performance.

---

### Idea chiave

La garbage collection abilita la gestione automatica della memoria ma introduce variabilità.

Le performance dipendono da quanto efficientemente la memoria viene recuperata.

---

<a id="174-memory-pressure-and-performance"></a>
## 1.7.4 Pressione di memoria e performance

### Definizione

La pressione di memoria si riferisce allo stress posto sul sistema della memoria quando allocazione, retention e recupero interagiscono sotto carico.

Non riguarda solo quanta memoria viene utilizzata, ma come la memoria sia gestita e si comporta nel tempo.

La pressione di memoria è quindi una condizione dinamica, non semplicemente una misura statica dell’occupazione dello heap.

---

### Cosa crea pressione di memoria

La pressione di memoria è guidata da una combinazione di fattori:

- alto tasso di allocazione
- grande numero di oggetti attivi
- lunga durata di vita degli oggetti
- recupero inefficiente della memoria

Questi fattori si rafforzano a vicenda e determinano quanto lavoro il runtime deve svolgere per mantenere la memoria utilizzabile.

---

### Allocazione vs retention

Due pattern diversi possono creare pressione:

- **alto tasso di allocazione**  
  molti oggetti sono creati e rapidamente scartati

- **alta retention**  
  gli oggetti rimangono in memoria per lunghi periodi

Questi pattern creano pressione in modi diversi.

Un alto tasso di allocazione aumenta il churn e la frequenza di raccolta.

Un’alta retention aumenta la quantità di memoria che rimane attiva e deve essere scansionata o preservata.

---

### Esempio: alto tasso di allocazione

```java
for (int i = 0; i < 1_000_000; i++) {
    String s = new String("test");
}
```

Caratteristiche:

- molti oggetti a vita breve
- allocazione frequente
- garbage collection frequente

Effetti:

- aumento dell’attività GC
- overhead CPU
- potenziali picchi di latenza

Questo esempio evidenzia una pressione guidata dal churn piuttosto che dalla retention a lungo termine.

---

### Esempio: retention della memoria

```java
List<String> cache = new ArrayList<>();

while (true) {
    cache.add(new String("data"));
}
```

Caratteristiche:

- gli oggetti sono mantenuti
- l’utilizzo della memoria cresce continuamente

Effetti:

- aumento dell’utilizzo dell’heap
- cicli di garbage collection più pesanti
- instabilità o fallimento finale

Questo esempio evidenzia una pressione guidata dalla memoria trattenuta piuttosto che dalla sola frequenza di allocazione temporanea.

---

### Sotto carico

Con l’aumentare del carico del sistema:

- più richieste sono elaborate
- più oggetti sono creati
- più oggetti sono trattenuti

Questo porta a:

- aumento del tasso di allocazione
- aumento dell’utilizzo della memoria
- aumento dell’attività GC

La pressione di memoria amplifica:

- la variabilità della latenza
- la latenza di coda

Per questo il degrado legato alla memoria diventa spesso più visibile quando il sistema passa da carico moderato a carico sostenuto elevato.

---

### Interazione con la garbage collection

La garbage collection risponde alla pressione di memoria.

Sotto pressione:

- le raccolte diventano più frequenti
- le pause possono aumentare
- l’utilizzo della CPU cresce

In casi estremi:

- la GC domina l’esecuzione
- il lavoro utile diminuisce

Quando questo accade, il runtime sta spendendo una quota significativa del suo sforzo di lavoro nella gestione stessa della memoria invece che nell’elaborazione del lavoro applicativo.

---

### Sintomi osservabili

La pressione di memoria appare spesso come:

- picchi di latenza senza un chiaro collo di bottiglia CPU
- degrado della latenza di coda (p95, p99)
- pause periodiche
- aumento della frequenza GC
- crescita dell’utilizzo della memoria nel tempo

Questi sintomi sono particolarmente importanti perché possono essere scambiati per lentezza generica se il comportamento della memoria non viene analizzato direttamente.

---

### Intuizione pratica

Un sistema può apparire:

- poco carico (CPU moderata)
- ma comunque lento

Questo spesso indica:

- pressione di memoria
- overhead legato alla GC

Questo è uno dei motivi principali per cui la sola CPU non è sufficiente per valutare la salute del sistema.

---

### Modello semplificato

Il comportamento del sistema può essere approssimato come:

- tasso di allocazione ↑ → attività GC ↑  
- retention ↑ → utilizzo della memoria ↑  
- attività GC ↑ → variabilità della latenza ↑  

Queste relazioni non sono lineari.

Dipendono dalla strategia del runtime, dalla forma del carico di lavoro, dalla durata di vita degli oggetti e dalla quantità di dati attivi.

---

### Implicazioni pratiche

Per gestire la pressione di memoria:

- comprendere i pattern di allocazione
- identificare gli oggetti a lunga vita
- monitorare il comportamento GC
- correlare metriche di memoria con la latenza

L’ottimizzazione dovrebbe concentrarsi su:

- ridurre allocazioni non necessarie
- controllare la durata di vita degli oggetti
- evitare retention non limitata

In molti casi, la soluzione più efficace non è il tuning del collector, ma la riduzione del lavoro di memoria che il runtime è costretto a eseguire.

---

### Collegamento con concetti precedenti

La pressione di memoria contribuisce a:

- degrado non lineare (→ [1.5.3 Non-linear degradation](01-05-system-behavior-under-load.md#153-non-linear-degradation))
- collasso del throughput (→ [1.5.4 Throughput collapse](01-05-system-behavior-under-load.md#154-throughput-collapse))
- amplificazione della latenza di coda (→ [1.5.5 Tail latency amplification](01-05-system-behavior-under-load.md#155-tail-latency-amplification))

È quindi un ponte diretto tra gli interni del runtime e il comportamento visibile del sistema sotto carico.

---

### Interpretazione pratica

La pressione di memoria spiega perché un sistema può degradare anche quando non è evidentemente limitato dalla CPU o bloccato esternamente.

Un runtime sotto stress al livello della memoria può apparire attivo, ma produrre latenza crescente, throughput ridotto e comportamento instabile.

Questo rende la pressione di memoria una delle cause nascoste più importanti nel degrado delle performance dei runtime gestiti.

---

### Idea chiave

La pressione di memoria deriva dall’interazione tra allocazione, retention e garbage collection sotto carico.

Comprendere questa interazione è essenziale per spiegare problemi di latenza e stabilità nei sistemi reali.