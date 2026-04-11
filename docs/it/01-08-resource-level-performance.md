## 1.8 – Performance a livello di risorse

<a id="18-resource-level-performance"></a>

Questo capitolo investiga come le risorse fondamentali di sistema si comportano sotto carico e come esse possano vincolare le performance.

Ci si concentra su CPU, I/O, network e sulle modalità in cui possano emergere colli di bottiglia quando una delle risorse si satura prima delle altre.

Comprendere la performance a livello di risorse è essenziale perché il degrado del sistema è spesso il risultato visibile di limiti delle risorse piuttosto che della sola logica applicativa.

## Indice

- [1.8.1 Comportamento della CPU](#181-cpu-behavior)
- [1.8.2 I/O e disco](#182-io-and-disk)
- [1.8.3 Comportamento della rete](#183-network-behavior)
- [1.8.4 Saturazione delle risorse e colli di bottiglia](#184-resource-saturation-and-bottlenecks)

---

<a id="181-cpu-behavior"></a>
## 1.8.1 Comportamento della CPU

### Definizione

La **CPU** è il componente responsabile dell’esecuzione delle istruzioni.

Le performance della CPU sono determinate non solo da quanto velocemente le istruzioni vengono eseguite, ma da come l’esecuzione viene schedulata tra carichi di lavoro concorrenti.

Questa distinzione è importante perché il degrado legato alla CPU è spesso causato da pressione di scheduling, accodamento e contese, piuttosto che solo dal costo computazionale.

---

### Utilizzo della CPU vs saturazione

L’**utilizzo della CPU** rappresenta quanto della capacità della CPU venga usato.

Un utilizzo elevato non è necessariamente indice di un eventuale problema.

La **saturazione della CPU** si verifica quando:

- c’è più lavoro di quanto la CPU possa eseguire
- i thread sono pronti a eseguire ma non possono essere schedulati immediatamente

Distinzione chiave:

- **alto utilizzo** → la CPU è occupata  
- **saturazione** → la CPU è sovraccarica  

Un sistema può quindi mostrare un elevato utilizzo della CPU e continuare comunque a comportarsi in modo accettabile, finché il lavoro eseguibile non si accumula più velocemente di quanto la CPU possa elaborarlo.

---

### Scheduling e run queue

I thread non eseguono in modo continuo.

Sono schedulati dal sistema operativo.

Ad ogni momento:

- alcuni thread sono in **esecuzione**
- alcuni sono **in attesa** di eseguire (run queue)

Quando il numero di thread eseguibili supera il numero dei core CPU disponibili:

- i thread si accumulano nella run queue
- i ritardi di scheduling aumentano

Questo impatta direttamente la latenza (→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md)) e può essere investigato usando le relazioni di concorrenza (→ [1.2.1 Little’s Law (system-level concurrency)](./01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency)).

La run queue è quindi un segnale critico di pressione della CPU, perché mostra non solo che la CPU è occupata, ma che c'è del lavoro che è in attesa di essere eseguito.

---

### Comportamento osservabile (esempio)

Un sistema sotto pressione della CPU mostra un numero crescente di thread eseguibili.

```bash
$ vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 7  0      0  12000  45000 300000    0    0     2     1 1200 3000 90  8  2  0  0
 8  0      0  11000  45000 300000    0    0     1     2 1300 3200 92  6  2  0  0
```

Interpretazione:

- run queue (`r`) alta → thread in attesa della CPU  
- CPU idle (`id`) vicino a zero → nessuna capacità disponibile  
- utilizzo della CPU (`us + sy`) vicino alla saturazione  

Questo indica che ci sono thread pronti ad eseguire ma che non possono essere schedulati immediatamente per mancanza di core disponibili (→ [1.6 Concurrency and parallelism](./01-06-concurrency-and-parallelism.md)).

Il punto importante è che la saturazione della CPU non è definita solo da valori percentuali, ma dalla presenza di lavoro eseguibile che non può progredire immediatamente.

---

### Impatto sulle performance

Quando la CPU diventa satura:

- i ritardi di scheduling aumentano
- il tempo di risposta aumenta
- il throughput può stabilizzarsi o diminuire

Questo effetto è non lineare (→ [1.5.3 Non-linear degradation](./01-05-system-behavior-under-load.md#153-non-linear-degradation)).

Con l’aumentare della saturazione della CPU, l'applicativo può spendere (progressivamente) più tempo ad attendere di essere schedulato per l'esecuzione piuttosto che a svolgere lavoro utile.

---

### Interazione con la concorrenza

La concorrenza aumenta il numero di thread attivi.

Con la crescita della concorrenza:

- più thread competono per la CPU
- la lunghezza della run queue aumenta
- l’overhead di scheduling aumenta

Oltre un certo punto:

- aggiungere thread riduce le performance invece di migliorarle (→ [1.6 Concurrency and parallelism](./01-06-concurrency-and-parallelism.md)).

Questo è il motivo per cui aggiungere più lavoro concorrente non produce sempre un throughput migliore.

Se il tempo CPU diventa la risorsa limitante, la concorrenza si trasforma in pressione di scheduling.

---

### Implicazioni pratiche

Per ragionare sul comportamento della CPU:

- distinguere utilizzo da saturazione
- osservare i thread eseguibili, non solo la %CPU
- correlare le metriche CPU con la latenza (→ [1.2 Core metrics and formulas](./01-02-core-metrics-and-formulas.md))

I problemi CPU spesso non riguardano il puro utilizzo, ma la **contesa per l’esecuzione**.

È quindi possibile che un sistema appaia “pienamente occupato” senza essere instabile, oppure che appaia solo moderatamente occupato mostrando già ritardi di scheduling.

---

### Interpretazione pratica

L’analisi della CPU dovrebbe concentrarsi sulla capacità del sistema di tenere il passo con il lavoro eseguibile.

Una CPU occupata non è automaticamente un problema.

Una CPU satura diventa un problema quando i task eseguibili si accumulano, la latenza aumenta e il throughput non scala più con la domanda in ingresso.

---

### Idea chiave

**Le performance della CPU sono limitate dallo scheduling**.

Quando i thread non possono essere schedulati immediatamente, la latenza aumenta anche se il sistema appare pienamente utilizzato.

---

<a id="182-io-and-disk"></a>
## 1.8.2 I/O e disco

### Definizione

Le **operazioni di I/O** implicano lettura da o scrittura verso dispositivi di storage.

A differenza delle operazioni CPU, l’I/O è tipicamente più lento e spesso bloccante.

Questo significa che molti problemi di performance che coinvolgono l’I/O sono dominati dal tempo di attesa piuttosto che dal calcolo attivo.

---

### Latenza vs throughput

Le performance dell’I/O hanno due dimensioni chiave:

- **latenza** → tempo per completare una singola operazione  
- **throughput** → numero di operazioni per unità di tempo  

Un throughput alto non garantisce una bassa latenza.

Un sistema può muovere una grande quantità di dati complessiva mentre le singole richieste sperimentano comunque tempi di attesa significativi.

---

### Comportamento bloccante

Molte operazioni di I/O sono bloccanti:

- un thread avvia un’operazione
- attende fino al suo completamento

Durante questo tempo:

- il thread non esegue lavoro utile
- può mantenere risorse (lock, connessioni)

Questo è uno dei motivi principali per cui i colli di bottiglia di I/O spesso si propagano in pressione sui thread pool, accodamento e riduzione della concorrenza effettiva.

---

### Effetti di accodamento

Quando più richieste eseguono I/O:

- le operazioni si accodano al livello del dispositivo
- il tempo di attesa aumenta

Con l’aumentare della lunghezza della coda:

- la latenza aumenta
- la variabilità aumenta (→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md))

Questo può essere espresso come ritardo di accodamento (→ [1.2.3 Service time vs response time (queueing)](./01-02-core-metrics-and-formulas.md#123-service-time-vs-response-time-queueing)).

Il punto importante è che il costo dell’I/O non è limitato alla durata dell’operazione in sé.

Include anche il tempo speso ad aspettare che le operazioni precedenti siano completate.

---

### Comportamento osservabile (esempio)

Un sistema sotto pressione di I/O mostra tempi di attesa crescenti.

```bash
$ iostat -x 1
Device            r/s     w/s   await   %util
sda              120     80     35.0    95.0
sda              130     90     42.0    98.0
```

Interpretazione:

- `await` alto → le richieste spendono un tempo significativo in attesa  
- `%util` vicino al 100% → il dispositivo è saturo  
- latenza crescente indica accumulo di coda  

Questo riflette effetti di accodamento (→ [1.2 Core metrics and formulas](./01-02-core-metrics-and-formulas.md)).

Il valore `await` crescente è particolarmente importante, perché spesso rivela che il dispositivo non è semplicemente occupato, ma sempre più incapace di assorbire il lavoro in ingresso senza ritardo aggiuntivo.

---

### Impatto sulle performance

Quando l’I/O diventa un collo di bottiglia:

- la latenza delle richieste aumenta
- il throughput può degradare
- i thread spendono più tempo ad attendere che ad eseguire

Questo può ridurre la capacità effettiva del sistema anche quando l’utilizzo della CPU rimane moderato.

Un sistema può quindi essere limitato dall’I/O senza apparire limitato dalla CPU.

---

### Interazione con la concorrenza

Più richieste concorrenti portano a:

- più operazioni di I/O
- code sul dispositivo più lunghe
- latenza aumentata

Aumentare la concorrenza non migliora le performance se il dispositivo è saturo (→ [1.6 Concurrency and parallelism](./01-06-concurrency-and-parallelism.md)).

Oltre un certo punto, concorrenza aggiuntiva aumenta solo l’attesa e peggiora il tempo di risposta.

---

### Implicazioni pratiche

Per ragionare sul comportamento dell’I/O:

- concentrarsi sulla latenza (`await`), non solo sul throughput  
- identificare l’accumulo di coda  
- correlare l’attesa di I/O con la latenza applicativa (→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md))  

I problemi di I/O sono spesso fraintesi perché il throughput può rimanere accettabile mentre la latenza degrada significativamente.

---

### Interpretazione pratica

Le performance dell’I/O dovrebbero essere valutate come un sistema di attesa.

La domanda centrale non è solo quante operazioni al secondo il dispositivo possa supportare, ma quanto a lungo le operazioni attendano quando il carico di lavoro si intensifica.

Un sottosistema di storage che si comporta bene a bassa concorrenza può degradare bruscamente quando le richieste iniziano ad accumularsi.

---

### Idea chiave

**Le performance dell’I/O sono dominate dal tempo di attesa**.

Quando le code crescono, la latenza aumenta e la responsività del sistema degrada.

---

<a id="183-network-behavior"></a>
## 1.8.3 Comportamento della rete

### Definizione

Le performance di **rete** sono determinate dal trasferimento di dati tra sistemi.

Dipendono sia dalla latenza sia dalla larghezza di banda.

Nei sistemi distribuiti, il comportamento della rete è spesso un contributore principale al tempo di risposta end-to-end, specialmente quando le richieste attraversano più servizi.

---

### Latenza e round trip

La comunicazione di rete richiede spesso scambi multipli.

Ogni scambio introduce:

- ritardo di trasmissione
- ritardo di propagazione
- ritardo di elaborazione

Round trip multipli amplificano la latenza totale (→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md)).

Questo è particolarmente importante nelle catene di richieste in cui ogni chiamata di servizio dipende dalla risposta della precedente.

Anche piccoli ritardi possono accumularsi significativamente attraverso molteplici hop di rete.

---

### Limitazioni di larghezza di banda

La larghezza di banda definisce la quantità di dati che possono essere trasferiti per unità di tempo.

Quando la larghezza di banda è limitata:

- payload grandi richiedono più tempo per essere trasferiti
- il throughput diventa vincolato

La larghezza di banda quindi conta soprattutto quando la quantità di dati trasferiti diventa abbastanza grande da dominare il tempo di comunicazione.

La latenza, al contrario, conta anche per payload piccoli quando sono richiesti molti round trip.

---

### Amplificazione sotto carico

Con l’aumentare del carico:

- più richieste sono inviate sulla rete
- la contesa aumenta
- si possono formare code nei buffer

Questo porta a:

- aumento della latenza
- ritardi di pacchetti o ritrasmissioni (→ [1.5.5 Tail latency amplification](./01-05-system-behavior-under-load.md#155-tail-latency-amplification))

Sotto carico, la variabilità della rete diventa particolarmente importante perché ritardi occasionali possono influenzare solo una parte del traffico degradando comunque l’esperienza utente complessiva.

---

### Comportamento osservabile (esempio)

Un sistema sotto pressione di rete mostra accumulo di connessioni e di code.

```bash
$ ss -s
Total: 1200
TCP:   900 (estab 850, timewait 30)

Transport Total     IP        IPv6
*         1200      -         -
RAW       0         0         0
UDP       50        40        10
TCP       870       800       70
```

Interpretazione:

- grande numero di connessioni stabilite → alta concorrenza  
- accumulo di connessioni può indicare elaborazione lenta o ritardi di rete  

Un numero crescente di connessioni aperte può indicare che le richieste non stanno completando abbastanza rapidamente, o perché i servizi downstream sono lenti o perché il sistema non è in grado di elaborare efficientemente il lavoro di rete.

---

### Impatto sulle performance

I vincoli di rete portano a:

- aumento del tempo di risposta
- maggiore variabilità
- ritardi a cascata tra servizi

Nelle architetture distribuite, questi ritardi spesso si propagano e si amplificano perché una singola interazione di rete lenta può ritardare molte operazioni dipendenti.

---

### Interazione con il design del sistema

I sistemi distribuiti amplificano gli effetti della rete:

- più servizi introducono più hop di rete
- la latenza si accumula attraverso le chiamate (→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md))

Un sistema con molti confini di servizio può quindi soffrire di latenza indotta dalla rete anche quando ogni singola chiamata appare relativamente poco costosa.

---

### Implicazioni pratiche

Per ragionare sul comportamento della rete:

- considerare il numero di round trip  
- osservare i pattern di connessione  
- correlare l’attività di rete con la latenza  

È anche importante distinguere tra:

- comportamento limitato dalla larghezza di banda
- comportamento limitato dalla latenza
- ritardo indotto dalle dipendenze

Questi sono problemi correlati ma non identici.

---

### Interpretazione pratica

Le performance di rete non riguardano solo quanto velocemente si muovano i byte.

Riguardano anche quanto spesso i sistemi comunicano, quante dipendenze sono coinvolte e come i ritardi in un componente influenzano gli altri.

In molte architetture a servizi, ridurre round trip non necessari può migliorare la latenza più efficacemente che aumentare semplicemente la larghezza di banda.

---

### Idea chiave

**Le performance di rete sono guidate dalla latenza e dai pattern di comunicazione**.

Sotto carico, piccoli ritardi si accumulano e impattano significativamente il tempo di risposta.

---

<a id="184-resource-saturation-and-bottlenecks"></a>
## 1.8.4 Saturazione delle risorse e colli di bottiglia

### Definizione

Un **collo di bottiglia** (bottleneck) è la risorsa che limita le performance del sistema.

La saturazione si verifica quando quella risorsa opera a capacità piena o in intervalli prossimi alla propria capacità limite.

Questo è il punto in cui carico di lavoro aggiuntivo non si traduce più in throughput utile proporzionale.

---

### Identificare la risorsa limitante

In ogni momento, le performance del sistema sono vincolate da una risorsa dominante:

- CPU
- I/O
- rete
- memoria (indirettamente tramite GC → [1.7 Runtime and memory model](./01-07-runtime-and-memory-model.md))

Identificare questa risorsa è essenziale.

Senza identificare la reale risorsa limitante, gli sforzi di ottimizzazione spesso prendono di mira i sintomi piuttosto che le cause.

---

### Principio del singolo collo di bottiglia

Anche nei sistemi complessi:

- le performance sono tipicamente limitate da un vincolo primario

Migliorare risorse non limitanti ha poco effetto.

Questo principio è una delle ragioni per cui la performance engineering deve rimanere orientata al sistema.

Molte risorse possono apparire attive, ma solo una, di solito, determina il limite di capacità corrente.

---

### Effetti a cascata

Quando una risorsa diventa satura:

- le code si accumulano
- la latenza aumenta
- i componenti upstream rallentano

Questo può propagarsi attraverso il sistema (→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md)).

Un collo di bottiglia locale può quindi diventare un problema esteso all’intero sistema, poiché i ritardi si diffondono a chiamanti, worker, pool e servizi dipendenti.

---

### Interazione tra risorse

Le risorse non sono indipendenti:

- I/O lento aumenta il tempo di attesa dei thread → influenza lo scheduling della CPU (→ [1.8.1 CPU behavior](#181-cpu-behavior))  
- i ritardi di rete aumentano la durata delle richieste → aumentano l’utilizzo della memoria (→ [1.7 Runtime and memory model](./01-07-runtime-and-memory-model.md))  
- la saturazione della CPU ritarda l’elaborazione → aumenta la dimensione delle code (→ [1.2.1 Little’s Law (system-level concurrency)](./01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency))  

Questa interazione spiega perché i colli di bottiglia spesso si spostano o appaiono accoppiati al variare delle condizioni di carico di lavoro.

Il fattore limitante può cambiare quando una parte del sistema viene migliorata o quando cambia la composizione del carico di lavoro.

---

### Pattern osservabili

Segni comuni di colli di bottiglia:

- CPU vicina alla saturazione con run queue alta  
- latenza I/O in aumento con elevato utilizzo del dispositivo  
- ritardi di rete con conteggio di connessioni crescenti  

Questi pattern sono utili perché collegano sintomi a livello di sistema con comportamenti specifici delle risorse.

Aiutano a ridurre l’ambiguità diagnostica.

---

### Impatto sul comportamento del sistema

Quando viene raggiunto un collo di bottiglia:

- il throughput smette di aumentare
- la latenza cresce rapidamente
- il sistema diventa instabile sotto ulteriore carico

Questo corrisponde a:

- degrado non lineare (→ [1.5.3 Non-linear degradation](./01-05-system-behavior-under-load.md#153-non-linear-degradation))  
- collasso del throughput (→ [1.5.4 Throughput collapse](./01-05-system-behavior-under-load.md#154-throughput-collapse))  

In questa fase, domanda aggiuntiva spesso peggiora la situazione invece di aumentare l’output utile.

---

### Implicazioni pratiche

Per analizzare le performance:

- identificare la risorsa satura  
- correlare le metriche di risorsa con la latenza  
- concentrare l’ottimizzazione sul fattore limitante  

Una diagnosi corretta dipende quindi dalla comprensione non solo di quali risorse siano occupate, ma di quale di esse stia attualmente determinando il comportamento dell'intero sistema.

---

### Interpretazione pratica

L’analisi dei colli di bottiglia è il ponte tra osservazione e azione.

Lo scopo non è semplicemente raccogliere metriche di CPU, I/O o rete, ma determinare quale risorsa stia vincolando il lavoro utile nel punto operativo corrente.

Una volta identificata quella risorsa, l’ottimizzazione diventa significativa.

---

### Idea chiave

**Le performance del sistema sono limitate dal suo collo di bottiglia**.

Comprendere quale risorsa sia satura è essenziale per spiegare e migliorare il comportamento sotto carico.