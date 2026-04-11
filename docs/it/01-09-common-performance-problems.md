## 1.9 – Problemi comuni di performance

<a id="19-common-performance-problems"></a>

Questo capitolo descrive problemi comuni di performance che appaiono nei sistemi reali sotto carico.

Questi problemi non appartengono a categorie isolate. Spesso interagiscono, si rafforzano a vicenda e diventano visibili come crescita della latenza, perdita di throughput, instabilità o degrado in coda.

Lo scopo di questo capitolo è collegare sintomi ricorrenti ai meccanismi sottostanti già introdotti nei capitoli precedenti.

## Indice

- [1.9.1 Inefficienza CPU-bound](#191-cpu-bound-inefficiency)
- [1.9.2 Allocazione eccessiva e churn di memoria](#192-excessive-allocation-and-memory-churn)
- [1.9.3 Contesa e hot spot di sincronizzazione](#193-contention-and-synchronization-hot-spots)
- [1.9.4 Colli di bottiglia dovuti a blocking e attesa](#194-blocking-and-waiting-bottlenecks)
- [1.9.5 Accumulo di code ed effetti di saturazione](#195-queue-buildup-and-saturation-effects)
- [1.9.6 Amplificazione delle dipendenze e latenza a cascata](#196-dependency-amplification-and-cascading-latency)

---

<a id="191-cpu-bound-inefficiency"></a>
## 1.9.1 Inefficienza CPU-bound

### Definizione

Un’inefficienza CPU-bound si verifica quando il sistema spende eccessivo tempo CPU svolgendo un lavoro che potrebbe essere ridotto, ottimizzato o addirittura evitato.

Questo non significa necessariamente che il sistema sia sempre CPU-saturo.

Significa che il tempo CPU disponibile viene consumato in modo inefficiente, riducendo la quantità di lavoro utile che il sistema può svolgere prima di raggiungere la saturazione.

---

### Cause tipiche

- algoritmi inefficienti (es. complessità non necessaria)
- calcoli ripetuti
- mancanza di caching per operazioni costose
- trasformazioni di dati eccessive

Queste cause sono comuni perché l’inefficienza CPU emerge spesso da codice funzionalmente corretto ma strutturalmente dispendioso.

Nella performance engineering, l'inefficienza è maggiormente impattante quando si riscontra in hot path o in operazioni altamente ripetitive.

---

### Esempio

```java
public int countMatches(List<String> items, String target) {
    int count = 0;
    for (String s : items) {
        if (s.toLowerCase().equals(target.toLowerCase())) {
            count++;
        }
    }
    return count;
}
```

Interpretazione:

- chiamate ripetute a `toLowerCase()` creano lavoro non necessario
- il tempo CPU aumenta con la dimensione dell’input
- calcolo evitabile negli hot path

Il problema non è solo il costo del loop in sé, ma la trasformazione ripetuta di valori che potrebbero essere normalizzati una sola volta invece che a ogni confronto.

---

### Meccanismo

L’inefficienza CPU-bound spreca capacità di esecuzione.

Viene consumato più tempo CPU del necessario per produrre lo stesso risultato.

Con la crescita del carico di lavoro:

- l’utilizzo della CPU aumenta prima
- il lavoro eseguibile si accumula prima
- il throughput utile raggiunge prima il suo limite

Questo trasforma codice inefficiente in un collo di bottiglia al livello di sistema, quando il volume delle richieste aumenta.

---

### Impatto sotto carico

- aumento dell’utilizzo della CPU
- riduzione del throughput
- saturazione della CPU anticipata

Questo porta a ritardi di scheduling (→ [1.8.1 CPU behavior](./01-08-resource-level-performance.md#181-cpu-behavior)) e a crescita non lineare della latenza (→ [1.5.3 Non-linear degradation](./01-05-system-behavior-under-load.md#153-non-linear-degradation)).

In termini pratici, il sistema raggiunge il proprio limite CPU prima del previsto, lasciando meno margine per burst o crescita concorrente del traffico.

---

### Sintomi osservabili

I sintomi tipici includono:

- alto utilizzo della CPU sotto carico moderato
- latenza in aumento con l’aumentare del volume di richieste
- throughput che si appiattisce prima del previsto
- tempo CPU significativo speso in operazioni ripetute o evitabili

Questi sintomi spesso appaiono prima della saturazione totale della CPU e inizialmente possono sembrare un generico problema di scalabilità.

---

### Implicazioni pratiche

- ottimizzare gli hot path
- evitare lavoro ripetuto
- ridurre la complessità algoritmica

È anche importante identificare quali inefficienze contano davvero al livello del sistema.

Un’operazione inefficiente eseguita una volta può essere irrilevante.

La stessa inefficienza eseguita milioni di volte diventa un collo di bottiglia.

---

### Interpretazione pratica

L’inefficienza CPU è una delle ragioni più comuni per cui un sistema non riesce a scalare nonostante hardware apparentemente adeguato.

Il problema non è la mancanza di CPU in termini assoluti, ma il cattivo utilizzo della CPU disponibile.

L’ottimizzazione è quindi tanto più preziosa quanto più aumenta la quantità di lavoro utile svolto, per unità di tempo CPU.

---

### Idea chiave

L’inefficienza CPU riduce la quantità di lavoro utile che il sistema può svolgere prima di raggiungere la saturazione.

---

<a id="192-excessive-allocation-and-memory-churn"></a>
## 1.9.2 Allocazione eccessiva e churn di memoria

### Definizione

L’allocazione eccessiva si verifica quando il sistema crea un gran numero di oggetti a vita breve, aumentando il churn di memoria e la pressione sul runtime.

Questo è un problema comune nei managed runtime, dove l’allocazione è spesso poco costosa per operazione, ma che diventa molto dispendiosa, in aggregato, quando viene eseguita eccessivamente e sotto carico.

---

### Esempio

```java
for (Order o : orders) {
    result.add(new ReportRow(o.getId(), o.getAmount(), o.getStatus()));
}
```

Interpretazione:

- molti oggetti sono creati per iterazione
- gli oggetti hanno vita breve
- il tasso di allocazione aumenta

Se questo pattern appare in codice eseguito frequentemente, il volume totale di allocazione può diventare significativo anche quando ogni singolo oggetto resta poco impattante.

---

### Meccanismo

- un alto tasso di allocazione aumenta il churn di memoria
- la garbage collection viene eseguita più frequentemente

(→ [1.7.2 Allocation and object lifecycle](./01-07-runtime-and-memory-model.md#172-allocation-and-object-lifecycle))  
(→ [1.7.3 Garbage collection](./01-07-runtime-and-memory-model.md#173-garbage-collection-conceptual))

Il sistema soffre quindi non solo nella fase di creazione degli oggetti, ma per tracciarli, eliminarli e gestire, in generale, gli effetti sul runtime di un frequente turnover della memoria.

---

### Impatto sotto carico

- aumento dell’attività GC
- overhead CPU per la gestione della memoria
- variabilità della latenza

Questo contribuisce alla pressione sulla memoria (→ [1.7.4 Memory pressure and performance](./01-07-runtime-and-memory-model.md#174-memory-pressure-and-performance)).

Con l’aumentare del carico, l’overhead legato all’allocazione diventa spesso più visibile attraverso pause, jitter e allargamento dei percentili di latenza.

---

### Sintomi osservabili

I sintomi tipici includono:

- aumento della frequenza della garbage collection
- picchi periodici di latenza
- gap crescente tra latenza media e latenza di coda
- utilizzo moderato della CPU con tempi di risposta instabili
- comportamento della memoria che degrada con l’aumentare del throughput

Questi sintomi sono particolarmente comuni nei sistemi che allocano pesantemente nei percorsi di elaborazione delle richieste.

---

### Implicazioni pratiche

- ridurre la creazione non necessaria di oggetti
- riutilizzare oggetti quando appropriato
- analizzare i pattern di allocazione

È anche importante distinguere tra:

- allocazione necessaria
- allocazione evitabile
- allocazione trattenuta che avrebbe dovuto invece esser temporanea

Questa distinzione aiuta a determinare se il problema sia churn, retention o entrambi.

---

### Interpretazione pratica

L’allocazione eccessiva è spesso invisibile in code review perché il codice rimane semplice e corretto.

Il suo effetto diventa visibile solo a runtime, quando la creazione ripetuta di oggetti cambia il comportamento della GC e la pressione di memoria.

Un sistema può quindi apparire logicamente efficiente e comunque comportarsi male perché crea troppo traffico di memoria transiente.

---

### Idea chiave

Il churn di memoria aumenta l’overhead del runtime e introduce variabilità della latenza.

---

<a id="193-contention-and-synchronization-hot-spots"></a>
## 1.9.3 Contesa e hot spot di sincronizzazione

### Definizione

La contesa (contention) si verifica quando più thread competono per la stessa risorsa, forzando un accesso serializzato.

Un hot spot di sincronizzazione è una parte del sistema in cui questa competizione diventa concentrata e ritarda ripetutamente l’esecuzione.

Questi hot spot sono particolarmente problematici perché riducono il parallelismo effettivo esattamente dove ci si aspetta che la concorrenza possa aiutare.

---

### Esempio

```java
public class Counter {
    private int value = 0;

    public synchronized void increment() {
        value++;
    }
}
```

Interpretazione:

- l’accesso è serializzato attraverso la sincronizzazione
- solo un thread progredisce alla volta
- il throughput è limitato dalla sezione critica

Il problema non è che la sincronizzazione esista, ma che un percorso condiviso e frequentemente acceduto possa diventare il punto limitante per l’intero sistema.

---

### Meccanismo

- i thread si bloccano mentre aspettano il lock
- la contesa aumenta con la concorrenza

(→ [1.6 Concurrency and parallelism](./01-06-concurrency-and-parallelism.md))

Quando più thread competono per la stessa sezione sincronizzata:

- il tempo di attesa cresce
- il parallelismo effettivo diminuisce
- più tempo viene speso nel coordinamento che nel progresso

Questo fa sì che il sistema si comporti come se il suo livello di concorrenza fosse inferiore a quanto il numero di thread suggerisca.

---

### Impatto sotto carico

- aumento del tempo di attesa
- riduzione del throughput
- aumento della latenza

Questo porta a effetti di accodamento (→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md)).

Sotto carico più elevato, gli hot spot di sincronizzazione diventano spesso visibili come crescita della latenza senza crescita proporzionale della CPU, perché i thread sono in attesa invece di eseguire lavoro.

---

### Sintomi osservabili

I sintomi tipici includono:

- latenza in aumento con utilizzo moderato della CPU
- molti thread bloccati o in attesa
- scalabilità ridotta con l’aumentare della concorrenza
- throughput limitato da una piccola sezione critica
- percorsi di codice con uso intensivo di lock che appaiono negli hot path di esecuzione

Questi sintomi sono spesso fuorvianti perché il sistema può apparire solo parzialmente utilizzato pur essendo già vincolato.

---

### Implicazioni pratiche

- minimizzare lo stato mutabile condiviso
- ridurre la dimensione della sezione critica
- usare pattern di concorrenza più scalabili

È anche importante identificare se il collo di bottiglia sia causato da:

- scope del lock
- frequenza di accesso
- sezioni critiche lunghe
- sincronizzazione non necessaria

Cause diverse richiedono soluzioni diverse.

---

### Interpretazione pratica

I problemi di contention sono spesso fraintesi come lentezza generica.

In realtà, il problema centrale è la serializzazione: molti thread sono presenti, ma solo pochi stanno progredendo nel lavoro utile.

La performance engineering quindi non si preoccupa soltanto d’aggiungere concorrenza, ma deve soprattutto assicurarsi che la concorrenza presente non collassi in attesa.

---

### Idea chiave

**La contesa converte lavoro parallelo in esecuzione serializzata**.

---

<a id="194-blocking-and-waiting-bottlenecks"></a>
## 1.9.4 Colli di bottiglia dovuti a blocking e attesa

### Definizione

Il blocking si verifica quando un thread aspetta che un’operazione esterna sia completata, impedendogli di svolgere lavoro utile.

Questo include l’attesa di:

- I/O
- risposte di rete
- lock
- servizi esterni
- altri eventi coordinati

Il blocking è spesso necessario, ma diventa un collo di bottiglia quando troppe risorse di esecuzione sono occupate ad attendere invece che a progredire.

---

### Esempio

```java
public String fetchData() throws Exception {
    Thread.sleep(50); // simulate blocking call
    return "data";
}
```

Interpretazione:

- il thread è inattivo durante l’attesa
- le risorse rimangono allocate
- la concorrenza non si traduce in throughput

Il thread esiste, ma non sta facendo avanzare lavoro utile durante il periodo di blocco.

---

### Meccanismo

- i thread spendono tempo ad aspettare invece che ad eseguire
- i thread pool possono saturarsi

(→ [1.6 Concurrency and parallelism](./01-06-concurrency-and-parallelism.md))

Quando più thread si bloccano:

- meno thread rimangono disponibili per nuovo lavoro
- l’accodamento appare al livello del modello di esecuzione
- la latenza cresce anche se la CPU non è pienamente utilizzata

Questo è il motivo per cui i colli di bottiglia da blocking spesso coesistono con un utilizzo moderato della CPU.

---

### Impatto sotto carico

- aumento della latenza
- riduzione del throughput
- esaurimento dei thread

Questo amplifica accodamento e saturazione (→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md)).

Sotto carico sostenuto, il comportamento bloccante crea spesso un loop di feedback in cui le richieste in coda aspettano thread che, a loro volta, stanno aspettando operazioni lente.

---

### Sintomi osservabili

I sintomi tipici includono:

- molti thread in stati di attesa o bloccati
- code di richieste in crescita
- CPU moderata con throughput scarso
- latenza in aumento durante operazioni heavy di I/O o heavy di dipendenze
- thread pool che appaiono pieni senza corrispondente lavoro produttivo

Questi sintomi sono particolarmente comuni nei servizi che mescolano concorrenza delle richieste con chiamate downstream sincrone.

---

### Implicazioni pratiche

- ridurre le operazioni bloccanti
- usare pattern asincroni o non bloccanti quando appropriato
- dimensionare con attenzione i thread pool

È anche utile distinguere tra:

- blocking inevitabile
- blocking evitabile
- blocking collocato in percorsi di esecuzione ad alta frequenza

Questa distinzione aiuta a identificare dove sia necessario un redesign.

---

### Interpretazione pratica

Il blocking riduce la concorrenza effettiva.

Un sistema può avere molti thread, ma se una grand parte di essi è in attesa, il sistema si comporta come se avesse molta meno capacità di esecuzione.

Questo è il motivo per cui i problemi di blocking sono spesso problemi del modello di esecuzione prima di diventare problemi di pura risorsa.

---

### Idea chiave

Il blocking riduce la concorrenza effettiva e limita il throughput del sistema.

---

<a id="195-queue-buildup-and-saturation-effects"></a>
## 1.9.5 Accumulo di code ed effetti di saturazione

### Definizione

L’accumulo di code si verifica quando il lavoro in ingresso supera la capacità di elaborazione, causando l’attesa delle richieste prima che siano elaborate.

Questo è uno dei problemi di performance più comuni e più importanti, perché il queueing trasforma un sovraccarico magari moderato in una latenza rapidamente crescente.

---

### Meccanismo

- il tasso di arrivo supera la capacità di servizio
- le code crescono nel tempo

Questo può essere descritto usando Little’s Law (→ [1.2.1 Little’s Law (system-level concurrency)](./01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency)).

Mentre la domanda in ingresso continua e l’elaborazione rimane limitata, l’attesa si accumula e il tempo di risposta inizia a includere un ritardo di coda sempre più grande.

---

### Impatto sotto carico

- il tempo di attesa aumenta
- il tempo di risposta aumenta
- la latenza diventa instabile

Questo porta a degrado non lineare (→ [1.5.3 Non-linear degradation](./01-05-system-behavior-under-load.md#153-non-linear-degradation)) e a limiti di throughput.

Una volta che l’accodamento diventa dominante, il sistema può deteriorarsi molto rapidamente anche se l’aumento originario del carico era relativamente piccolo.

---

### Sintomi osservabili

- lunghezze di coda crescenti
- tempi di risposta in aumento
- throughput stabile o in diminuzione

Altri sintomi possono includere:

- burst di errori di timeout
- ampliamento della latenza p95/p99
- recupero ritardato dopo sovraccarico temporaneo

Questi effetti spesso indicano che il sistema sta operando vicino o oltre la sua capacità effettiva.

---

### Implicazioni pratiche

- controllare la concorrenza
- aumentare la capacità della risorsa che è collo di bottiglia
- ridurre il tasso di arrivo se necessario

È anche importante determinare dove si stia formando la coda:

- thread pool
- connection pool
- dispositivo
- buffer di rete
- servizio downstream

La posizione della coda spesso rivela il vero collo di bottiglia.

---

### Interpretazione pratica

L’accumulo di code non è solo un dettaglio operativo.

Spesso è il meccanismo diretto attraverso cui il sovraccarico diventa visibile agli utenti.

Un sistema può ancora funzionare, ma una volta che il lavoro inizia ad attendere in modo sistematico, la crescita della latenza diventa inevitabile.

---

### Idea chiave

**Le code crescono quando la domanda supera la capacità, determinando la latenza**.

---

<a id="196-dependency-amplification-and-cascading-latency"></a>
## 1.9.6 Amplificazione delle dipendenze e latenza a cascata

### Definizione

L’amplificazione delle dipendenze si verifica quando la latenza in un componente si propaga e aumenta la latenza attraverso il sistema.

Questo problema è particolarmente importante nei sistemi distribuiti, dove una richiesta spesso dipende da più chiamate downstream prima di potersi completare.

---

### Meccanismo

- le richieste dipendono da più servizi downstream
- i ritardi si accumulano attraverso le chiamate
- componenti lenti influenzano l’intero sistema

Anche quando ogni singolo ritardo è piccolo, l’effetto totale può diventare significativo una volta che più dipendenze, retry o catene di chiamate seriali siano coinvolte.

---

### Esempio

```java
public Response process() {
    Data a = serviceA.call();
    Data b = serviceB.call();
    return combine(a, b);
}
```

Interpretazione:

- la latenza totale dipende da più dipendenze
- la dipendenza più lenta domina il tempo di risposta

Nei sistemi reali, questo effetto diventa più forte quando le richieste dipendono da molti servizi, database remoti o operazioni sincrone concatenate.

---

### Impatto sotto carico

- amplificazione della latenza attraverso i servizi
- aumento della variabilità
- degrado della latenza di coda

(→ [1.5.5 Tail latency amplification](./01-05-system-behavior-under-load.md#155-tail-latency-amplification))

Sotto carico, l’amplificazione delle dipendenze diventa spesso più severa perché sistemi downstream lenti trattengono thread, richieste e code upstream per periodi più lunghi.

---

### Sintomi osservabili

I sintomi tipici includono:

- aumenti improvvisi di latenza senza saturazione locale della CPU
- degrado del comportamento p95/p99 causato dalla variabilità downstream
- catene di richieste che diventano più lente mentre una dipendenza rallenta
- instabilità che si diffonde da un servizio a un altro
- retry e timeout che aumentano la pressione attraverso il sistema

Questi sintomi sono spesso difficili da interpretare senza correlare il comportamento attraverso più componenti.

---

### Implicazioni pratiche

- minimizzare il numero di dipendenze sincrone
- usare timeout e strategie di fallback
- isolare i componenti lenti

È anche utile identificare:

- quale dipendenza contribuisce maggiormente al ritardo end-to-end
- se le chiamate siano seriali o parallele
- se i retry peggiorino il problema
- se i componenti lenti inneschino accodamento upstream

Questo trasforma un vago problema di “lentezza distribuita” in un comportamento di sistema diagnosticabile.

---

### Interpretazione pratica

La latenza di un sistema non è determinata solo dal "proprio codice".

Spesso è determinata dalla dipendenza più lenta nel percorso della richiesta.

Più dipendenze ha un sistema, più è probabile che la variabilità in un punto diventi visibile ovunque.

---

### Idea chiave

**La latenza del sistema è spesso determinata dalla dipendenza più lenta**.