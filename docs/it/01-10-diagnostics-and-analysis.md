## 1.10 – Diagnostica e analisi

<a id="110-diagnostics-and-analysis"></a>

Questo capitolo si interessa del come le problematiche di performance possano essere investigate, interpretate e validate.

Ci si concentra qui sui processi utilizzati per muovere dall'osservazione del sistema a una valutazione difendibile della performance dello stesso.

La diagnostica infatti non è solo una pratica di raccolta dei dati.
  
È la disciplina che si preoccupa di interpretare correttamente quei dati e di collegare i sintomi ai meccanismi di funzionamento sottostanti.

## Indice

- [1.10.1 Osservabilità e segnali](#1101-observability-and-signals)
- [1.10.2 Sintomo vs causa](#1102-symptom-vs-cause)
- [1.10.3 Correlazione e causalità](#1103-correlation-and-causality)
- [1.10.4 Costruire un’ipotesi](#1104-building-a-hypothesis)
- [1.10.5 Restringere il collo di bottiglia](#1105-narrowing-down-the-bottleneck)
- [1.10.6 Analisi iterativa e validazione](#1106-iterative-analysis-and-validation)

---

<a id="1101-observability-and-signals"></a>
## 1.10.1 Osservabilità e segnali

### Definizione

La diagnostica parte evidentemente da segnali osservabili.

Questi segnali forniscono visibilità spesso indiretta sul comportamento interno del sistema sotto carico.
  
Non espongono direttamente i meccanismi di funzionamento, ma ne riflettono piuttosto gli effetti.

Per questo l’osservabilità è essenziale nella performance engineering: i problemi interni sono raramente visibili direttamente, ma lasciano spesso tracce misurabili rispetto a latenza, throughput, comportamento delle risorse e queueing.

---

### Segnali fondamentali

I segnali primari sono:

- latenza (p50, p95, p99)  
- throughput  
- tasso di errore  
- utilizzo delle risorse (CPU, memoria, I/O, rete)  
- lunghezze delle code  

(→ [1.2 Core metrics and formulas](./01-02-core-metrics-and-formulas.md))  
(→ [1.8 Resource-level performance](./01-08-resource-level-performance.md))

Ogni segnale cattura una diversa dimensione del comportamento del sistema.
  
Solo un loro esame combinato fornisce una vista significativa del sistema.

- La latenza mostra l’impatto visibile per l’utente.  
- Il throughput mostra il tasso di lavoro produttivo.  
- Il tasso degli errori indica il comportamento in caso di guasto.  
- Gli indici delle risorse mostrano dove la capacità viene consumata.  
- Le code mostrano dove il lavoro si accumula.

---

### Caratteristiche dei segnali

I segnali devono essere:

- **accurati** → riflettere il comportamento reale  
- **granulari** → esporre la distribuzione (es. percentili, non solo medie)  
- **correlati nel tempo** → allineati attraverso tutti i componenti  

Senza queste proprietà, l’interpretazione diventa inaffidabile, fuorviante o addirittura erronea.

Una metrica mal posta, non bene configurata o addirittura scollegata dall'intervallo di tempo pertinente può nascondere proprio quel meccanismo di funzionamento che intende invece rivelare.

---

### Qualità del segnale e interpretazione

La presenza di segnali non è tuttavia da sola sufficiente.

I segnali devono anche essere:

- pertinenti rispetto alle domande che ci si pone
- osservati rispetto al livello appropriato (sistema, servizio, risorsa, dipendenza)
- interpretati nel contesto

Per esempio:

- l'utilizzo CPU senza informazione sulla run queue può nascondere pressione di scheduling
- latenza media senza analisi dei percentili può nascondere instabilità in coda
- utilizzo della memoria senza comportamento della GC può nascondere pressione del runtime

Il valore diagnostico di una metrica dipende non solo dalla sua esistenza, ma da come viene correlata col resto delle evidenze.

---

### Implicazioni pratiche

Una diagnostica efficace necessità di:

- osservazione complessiva sei segnali  
- correlare tali segnali nel tempo  
- evitare il ragionamento basato su singole metriche  

Osservare una metrica al di fuori di un contesto è spesso fuorviante rispetto alla comprensione della meccanica sottostante.

Questo è uno dei principali motivi per cui spiegazioni semplicistiche sono pericolose nell’analisi delle performance.

Un singolo numero può descrivere un sintomo, ma raramente spiega il comportamento complessivo del sistema in oggetto.

---

### Interpretazione pratica

L’osservabilità è la materia prima della diagnostica.

Senza segnali, non esiste analisi affidabile.  
Con segnali di scarsa qualità, l'analisi sarà inaffidabile.  
Con segnali ben strutturati, l’analisi diventa verificabile e ripetibile.

La diagnostica inizia dunque non con l’ottimizzazione, ma con l'analisi di quanto osservato.

---

### Idea chiave

La diagnostica dipende sia dalla disponibilità sia dalla corretta interpretazione dei segnali osservabili.

---

<a id="1102-symptom-vs-cause"></a>
## 1.10.2 Sintomo vs causa

### Definizione

Un sintomo è un effetto osservabile.

Una causa è il meccanismo sottostante che produce quell’effetto.

Questa distinzione è fondamentale perché la maggior parte dei problemi di performance viene scoperto attraverso sintomi, non attraverso una manifestazione diretta della causa alla radice del problema.

---

### Distinzione

Sintomi tipici:

- elevata latenza  
- importante utilizzo della CPU  
- aumento del tasso di errore  
- garbage collection frequente  

Questi elementi descrivono *che cosa sta succedendo*, non *perché sta succedendo*.

Un sistema può mostrare lo stesso sintomo per ragioni molto diverse, e la stessa causa può produrre sintomi diversi a seconda del carico, del timing e dell’architettura.

---

### Esempio

- un elevato utilizzo della CPU può risultare da:

  - calcolo inefficiente  
  - retry eccessivi  
  - pressione di memoria  
  - contesa  

- un’elevata latenza può risultare da:

  - accumulo di code  
  - ritardi di I/O  
  - sincronizzazione  

(→ [1.9 Common performance problems](./01-09-common-performance-problems.md))

Per queste ragioni i sintomi devono essere trattati come punti d'accesso all’investigazione, non come spiegazioni.

---

### Implicazione diagnostica

Lo stesso sintomo può essere prodotto da cause diverse.

Senza identificare il meccanismo sottostante, le azioni correttive possono prendere di mira la parte sbagliata del sistema.

Per esempio:

- ridurre l’utilizzo della CPU può non ridurre la latenza se la causa radice è il queueing I/O  
- fare tuning della GC può non aiutare se il tasso di allocazione d'oggetti rimane invariato  

Una fix tecnicamente plausibile può quindi avere poco effetto se affronta una sola conseguenza visibile.

---

### Perché avviene la confusione

Sintomi e cause sono spesso confusi perché i sintomi sono relativamente facili da osservare.

Metriche, dashboard e sistemi di monitoraggio di solito mostrano:

- valori elevati
- che cosa è lento
- che cosa sta fallendo

Non spiegano automaticamente:

- perché i valori sono alti
- perché sono lenti
- perché stanno fallendo

Questo divario tra visibilità e spiegazione è esattamente ciò che la diagnostica deve colmare.

---

### Interpretazione pratica

Un buon processo diagnostico tratta ogni sintomo come un indizio, non come una conclusione.

L’obiettivo è passare da:

- “questa metrica è anomala”

a:

- “questo meccanismo sta producendo il comportamento anomalo”

Questo spostamento è ciò che distingue un ragionamento efficace sulle performance dal monitoraggio superficiale.

---

### Idea chiave

Il comportamento osservato non è la causa.

La diagnosi richiede di mappare i sintomi ai meccanismi sottostanti che li generano.

---

<a id="1103-correlation-and-causality"></a>
## 1.10.3 Correlazione e causalità

### Definizione

La correlazione è la variazione simultanea di due segnali.

La causalità è una relazione diretta in cui un fattore ne produce un altro.

Questa distinzione è essenziale nella diagnostica perché molte metriche si muovono insieme sotto carico, ma non tutte sono causalmente collegate nella stessa direzione.

---

### Errore comune

Due metriche cambiano insieme:

- la CPU aumenta  
- la latenza aumenta  

Questo non implica che la CPU sia la causa della latenza.

La correlazione può indicare:

- una causa sottostante comune
- una dipendenza indiretta
- una catena causale nella direzione opposta
- o semplice coincidenza nella stessa finestra temporale

---

### Esempio

Possibili interpretazioni:

- saturazione CPU → ritardi di scheduling → latenza  
- ritardi di I/O → più thread concorrenti → maggiore utilizzo della CPU  
- contesa → retry → sia CPU sia latenza aumentano  

(→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md))  
(→ [1.8 Resource-level performance](./01-08-resource-level-performance.md))

In tutti e tre i casi, CPU e latenza si muovono insieme, ma il meccanismo sottostante è diverso.

---

### Implicazione diagnostica

La correlazione è un punto di partenza, non una conclusione.

Più meccanismi possono produrre gli stessi segnali correlati.
  
Solo un modello causale spiega come uno conduca all’altro.

Per questa ragione, il ragionamento diagnostico deve andare oltre “queste due metriche si sono mosse nello stesso momento”.

Deve spiegare:

- quale è cambiata per prima
- quale meccanismo le collega
- perché la sequenza osservata è coerente con il comportamento del sistema

---

### Approccio pratico

Per stabilire la causalità:

- identificare la sequenza degli eventi  
- verificare la coerenza con il comportamento noto del sistema  
- validare attraverso osservazione o cambiamento controllato  

Questo può includere:

- confrontare stati prima/dopo
- osservare se una metrica precede costantemente un’altra
- cambiare una condizione e verificare la risposta attesa

La causalità diventa più forte quando il sistema si comporta come il meccanismo proposto prevede.

---

### Limiti dell’analisi superficiale

Una dashboard può mostrare la correlazione molto chiaramente ma non può, da sola, provare la causalità.

Per questo la diagnostica richiede ragionamento e non soltanto "visualizzazione".

Un performance engineer deve chiedersi:

- Questa metrica è il driver, la conseguenza o una ulteriore conseguenza dello stesso evento?
- La timeline supporta la spiegazione proposta?
- La spiegazione rimane coerente attraverso osservazioni ripetute?

Senza queste domande, la correlazione può facilmente portare a conclusioni scorrette.

---

### Interpretazione pratica

Una buona diagnostica tratta la correlazione come un generatore di ipotesi.

Aiuta a identificare dove guardare, ma non elimina la necessità di ragionare sui meccanismi sottostanti.

Questo è particolarmente importante nei sistemi complessi dove più colli di bottiglia interagiscono e i sintomi si propagano attraverso i componenti.

---

### Idea chiave

Non inferire causalità dalla correlazione.

La diagnosi richiede di identificare il meccanismo che collega i segnali.

---

<a id="1104-building-a-hypothesis"></a>
## 1.10.4 Costruire un’ipotesi

### Definizione

Un’ipotesi è una spiegazione proposta che collega segnali osservati a un meccanismo del sistema.

Fornisce un modo strutturato per passare dall’osservazione alla spiegazione.

Senza un’ipotesi, l’analisi rimane descrittiva piuttosto che diagnostica.

---

### Processo

Un’ipotesi viene costruita:

1. osservando i segnali  
2. identificando pattern coerenti  
3. mappandoli su meccanismi noti  

(→ [1.2 Core metrics and formulas](./01-02-core-metrics-and-formulas.md))  
(→ [1.5 System behavior under load](./01-05-system-behavior-under-load.md))

Questo processo trasforma dati grezzi in una spiegazione testabile.

Collega:

- misurazioni
- comportamento del sistema
- ragionamento causale

---

### Esempio

Osservato:

- la latenza aumenta  
- la lunghezza della coda aumenta  
- la CPU si avvicina alla saturazione  

Ipotesi:

- aumento del tasso di lavoro in arrivo → accumulo di coda → tempo di attesa più lungo → saturazione CPU  

Questo collega segnali osservabili a un meccanismo di accodamento.

Fornisce anche una direzione all’investigazione: verificare se l’aumento della latenza sia causato principalmente dall’attesa piuttosto che da un tempo di servizio più lento.

---

### Requisiti

Un’ipotesi valida deve essere:

- coerente con i dati osservati  
- fondata sul comportamento del sistema  
- testabile attraverso misurazione o cambiamento  

Un’ipotesi che non può essere testata può essere plausibile, ma non è ancora utile per la diagnostica.

Un’ipotesi che contraddice l’evidenza osservata dovrebbe essere rigettata anche se appare intuitiva.

---

### Implicazione diagnostica

Un’ipotesi guida l’investigazione.

Senza di essa, l’analisi diventa reattiva e non strutturata.

Invece di passare direttamente dal sintomo alla fix, il processo diagnostico dovrebbe passare da:

- sintomo  
- ipotesi su meccanismo candidato  
- validazione  

Questa struttura riduce il guesswork e rende le conclusioni diagnostiche più robuste.

---

### Fonti delle ipotesi

Le ipotesi di solito emergono da:

- combinazioni di segnali osservati
- pattern di performance noti
- comportamento precedente del sistema
- conoscenza architetturale
- scenari di errore ripetuti

Per esempio:

- latenza crescente + code in crescita spesso suggerisce accodamento
- CPU moderata + thread bloccati può suggerire contesa o attesa I/O
- frequenza GC crescente + picchi di latenza può suggerire pressione di memoria

Queste associazioni non provano la spiegazione, ma forniscono un punto di partenza disciplinato.

---

### Interpretazione pratica

Una buona ipotesi è abbastanza specifica da essere testata e abbastanza generica da spiegare il comportamento osservato.

Non dovrebbe essere:

- vaga (“il sistema è lento”)
- circolare (“la latenza è alta perché le richieste sono lente”)
- puramente descrittiva

Dovrebbe esprimere un meccanismo.

Per esempio:

- “La saturazione del thread pool sta aumentando il tempo di coda, il che sta facendo salire la latenza p95.”

Questo tipo di affermazione può essere validato.

---

### Idea chiave

La diagnosi procede attraverso ipotesi esplicite e testabili, non attraverso assunzioni irrelate.

---

<a id="1105-narrowing-down-the-bottleneck"></a>
## 1.10.5 Restringere il collo di bottiglia

### Definizione

La diagnostica mira a identificare la risorsa o il meccanismo che limita la performance del sistema.

Questo fattore limitante determina il comportamento complessivo del sistema sotto carico.

Finché non viene identificato, gli sforzi di ottimizzazione rimangono incerti e spesso inefficaci.

---

### Approccio

L’analisi si concentra su:

- comportamento della CPU  
- latenza I/O  
- ritardi di rete  
- pressione di memoria  

(→ [1.8 Resource-level performance](./01-08-resource-level-performance.md))  
(→ [1.7 Runtime and memory model](./01-07-runtime-and-memory-model.md))

Queste dimensioni vengono esaminate perché la maggior parte dei limiti di performance, alla fine, si manifesta attraverso una o più di esse.

Tuttavia, il collo di bottiglia dominante, in un dato momento, è di solito dato da un solo vincolo primario piuttosto che da tutti i vincoli in ugual misura.

---

### Metodo

- isolare una dimensione alla volta  
- confrontare segnali attraverso le risorse  
- identificare il vincolo dominante  

Questo riduce la complessità concentrandosi sul fattore più impattante.

L’obiettivo non è spiegare ogni metrica, ma trovare il meccanismo che in quel momento governa il comportamento del sistema.

---

### Esempio

Se:

- la CPU è bassa  
- la latenza I/O è alta  
- le code stanno crescendo  

Allora:

- l’I/O è probabilmente il fattore limitante  

Il sistema non è CPU-bound, anche se la CPU è attiva.

Questo tipo di restringimento è essenziale perché spesso sono coinvolte più risorse, ma solo una di esse è di solito dominante.

---

### Implicazione diagnostica

La performance è tipicamente limitata, in un dato momento, da un singolo collo di bottiglia dominante.

Ottimizzare risorse non limitanti produce poco o nessun miglioramento.

Questo è uno dei principi più importanti nella diagnostica:

- misurare in modo ampio
- concludere in modo specifico

Un insieme ampio di segnali è richiesto per evitare di perdere evidenze importanti. 
 
Una conclusione specifica è richiesta per indirizzare l’azione sul vincolo reale.

---

### Perché i colli di bottiglia sono difficili da identificare

I colli di bottiglia sono spesso oscurati da effetti secondari.

Per esempio:

- I/O lento può aumentare il numero di thread
- l’aumento del numero di thread può aumentare l’overhead di scheduling della CPU
- l’aumento dell’attesa può gonfiare la retention di memoria
- i retry possono amplificare la domanda su più componenti contemporaneamente

Di conseguenza, l’effetto visibile può non apparire nel punto esatto del problema originario.

Per questo l'isolamento del collo di bottiglia richiede correlazione attraverso i layer piuttosto che interpretazione isolata di una singola metrica.

---

### Interpretazione pratica

Lo scopo della diagnosi non è solo dire che il sistema è sotto pressione.

È identificare:

- dove la pressione diventa limitante
- quale meccanismo produce il limite
- perché quel vincolo è attualmente dominante

Solo allora l’ottimizzazione diventa significativa.

---

### Idea chiave

Una diagnosi efficace riduce il sistema al suo fattore limitante.

---

<a id="1106-iterative-analysis-and-validation"></a>
## 1.10.6 Analisi iterativa e validazione

### Definizione

La diagnosi è un processo iterativo di test e raffinamento delle ipotesi.

Evolve attraverso osservazioni e validazioni successive.

Questo è necessario perché le spiegazioni iniziali sono spesso incomplete, parzialmente corrette o valide solo per un layer del sistema.

---

### Processo

1. osservare i segnali  
2. costruire un’ipotesi  
3. testare attraverso cambiamenti o misurazioni  
4. validare o rigettare  

Ogni passaggio produce un raffinamento nella comprensione del sistema.

Questo loop viene ripetuto finché la spiegazione proposta è coerente con il comportamento osservato e supportata dall’evidenza.

---

### Esempio

```java
ExecutorService pool = Executors.newFixedThreadPool(10);

for (int i = 0; i < 1000; i++) {
    pool.submit(() -> {
        Thread.sleep(100);
        return null;
    });
}
```

Interpretazione:

- il thread pool fisso limita l’esecuzione parallela  
- i task si accumulano  
- l’accodamento aumenta la latenza  

Questa ipotesi può essere testata:

- aumentando la dimensione del pool  
- riducendo il tempo di blocking  

Se la latenza diminuisce e l’accumulo di code si riduce, l’ipotesi guadagna evidenza.

Se il comportamento non cambia come previsto, la spiegazione deve essere rivista.

---

### Validazione

Un’ipotesi è validata se:

- i cambiamenti producono gli effetti attesi  
- i segnali evolvono in modo coerente con il meccanismo proposto  

In caso contrario, l’ipotesi deve essere rivista.

La validazione quindi dipende dalla coerenza tra:

- cambiamento osservato
- cambiamento atteso
- spiegazione causale proposta

Una fix che cambia una metrica senza migliorare il comportamento del sistema può indicare che è stato preso di mira il meccanismo sbagliato.

---

### Implicazioni pratiche

- evitare conclusioni in un solo passaggio  
- iterare sistematicamente  
- validare le assunzioni con dati osservabili  

Una buona diagnostica raramente è istantanea.

Diventa affidabile attraverso confronto ripetuto tra:

- ciò che viene osservato
- ciò che ci si aspetta
- ciò che cambia realmente dopo l’intervento

Questa disciplina iterativa è ciò che trasforma il troubleshooting in engineering.

---

### Perché l’iterazione conta

I sistemi complessi raramente espongono una spiegazione complessiva in una singola osservazione.

È comune scoprire che:

- un collo di bottiglia iniziale era solo un effetto secondario
- rimuovere un vincolo ne espone un altro
- un miglioramento locale sposta altrove il fattore limitante
- il sistema si comporta diversamente sotto carichi di lavoro diversi

L’iterazione quindi non è un segno di incertezza.
  
È il metodo normale per arrivare a una spiegazione coerente.

---

### Interpretazione pratica

La diagnosi è un loop perché la comprensione del sistema viene costruita progressivamente.

L’obiettivo non è indovinare correttamente al primo tentativo.

L’obiettivo è passare dall’evidenza alla spiegazione attraverso ragionamento controllato e verifica.

Questo è ciò che rende l’analisi delle performance ripetibile e difendibile.

---

### Idea chiave

La diagnosi è un loop.

La comprensione emerge attraverso iterazione, verifica e raffinamento.