# 1.3 – Lavoro di un performance engineer

<a id="13-work-of-a-performance-engineer"></a>

Questa sezione descrive che cosa sia, in pratica, la performance engineering e come venga applicata ai sistemi reali.

## Indice

- [1.3.1 Che cos’è la performance engineering (in pratica)](#131-what-performance-engineering-is-in-practice)
- [1.3.2 Workflow tipico](#132-typical-workflow)
- [1.3.3 Black-box vs white-box](#133-black-box-vs-white-box)
- [1.3.4 Load testing vs diagnostica](#134-load-testing-vs-diagnostics)
- [1.3.5 Ciò che conta davvero (e ciò che non conta)](#135-what-actually-matters-and-what-doesnt)

---

<a id="131-what-performance-engineering-is-in-practice"></a>
## 1.3.1 Che cos’è la performance engineering (in pratica)

### Definizione

La performance engineering è la disciplina che consiste nel comprendere, misurare e controllare il modo in cui un sistema si comporta sotto carico.

Essa non si limita al performance testing, né a specifici strumenti o tecnologie.

Essa si riferisce piuttosto ad una metodologia complessiva di ragionamento sui sistemi sotto carico o, eventualmente, sotto stress.

Essa si concentra sul comportamento complessivo del sistema e non su metriche isolate o su singoli componenti.

---

### Prestazioni e requisiti non funzionali

La performance engineering non si concentra su una singola proprietà.

Quando un sistema viene esercitato sotto carico, diventa visibile un sottoinsieme di **requisiti non funzionali (NFR)**:

- latenza e throughput (prestazioni)
- scalabilità (verticale e orizzontale)
- stabilità e resilienza sotto stress
- utilizzo delle risorse ed efficienza
- limiti di capacità

Queste proprietà non sono tra loro indipendenti.

Emergono tutte insieme man mano che il sistema viene portato ai suoi limiti.

Il carico agisce come una **forcing function** che rivela il modo in cui il sistema si comporta.

Un sistema che appare perfettamente equilibrato a basso carico può mostrare un comportamento completamente diverso quando viene stressato.

---

### Che cosa osserva realmente la performance engineering

Sotto carico, un sistema rivela:

- come il lavoro attraversa i suoi componenti
- come vengono consumate le risorse
- dove compaiano contese (contention)
- dove si formano le code (queueing)
- quali sono i limiti che vengono raggiunti per primi

Questo richiede:

- comprendere il modello del sistema (→ [1.1 Fondamenti](01-01-foundations.md))
- misurare le metriche chiave (→ [1.2 Metriche e formule di base](01-02-core-metrics-and-formulas.md))
- identificare i fattori limitanti

L’obiettivo evidentemente non è solo quello di osservare il comportamento del sistema, ma anche di spiegarlo.

---

### Non solo testing

La performance engineering viene spesso ridotta al solo **load testing**.

In pratica, la fase di testing è solo una parte del lavoro.

I test vengono utilizzati per:

- esporre il comportamento del sistema
- validare ipotesi
- riprodurre problemi

Ma la performance engineering comprende anche:

- analizzare il design del sistema
- investigare problemi di produzione
- dimensionare le risorse (heap, pool, thread, connessioni)
- spiegare il comportamento osservato

Il Testing senza l'analisi produce dati senza comprensione.

---

### Prospettiva pratica

Negli scenari reali, il lavoro coinvolge tipicamente:

- preparare e calibrare gli ambienti di test
- Interpretare i requisiti non funzionali (NFRs)
- individuare e definire scenari (significativi) di test rispetto agli NFRs
- validare il comportamento con casi d’uso controllati
- applicare carico o stress per far emergere i problemi (spesso in white-box)
- identificare e correggere i colli di bottiglia
- dimensionare i componenti del sistema (CPU, memoria, pool, limiti di concorrenza)
- mettere a punto configurazioni e parametri (Tuning)
- eseguire benchmark per stabilire punti di riferimento
- eseguire test di lunga durata (soak / endurance) per validare la stabilità nel tempo

Queste attività non sono isolate.

Fanno parte di un processo continuo orientato alla comprensione delle possibilità e dei limiti del sistema.

---

### Idea chiave

La performance engineering non consiste (solamente) nel rendere un sistema più veloce e prestazionale.

Comprende invece un insieme ti attività e tasks, atti al comprendere come un sistema si comporta sotto carico di lavoro, e all'assicurarsi che esso rimanga:

- prevedibile
- stabile
- scalabile

La maggior parte dei problemi non è causata da una singola operazione "lenta", ma da:

- interazioni tra componenti
- accumulo dei tempi di attesa
- saturazione di risorse condivise

Questi meccanismi costituiscono, insieme, il nucleo della performance engineering.

---

<a id="132-typical-workflow"></a>
## 1.3.2 Workflow tipico

La performance engineering è un processo iterativo in cui il sistema viene progressivamente esercitato, analizzato, stabilizzato e compreso sotto livelli crescenti di carico.

L’obiettivo non è solo rilevare problemi, ma costruire un modello affidabile di come il sistema si comporta in condizioni realistiche (e limite) di produzione.

---

<a id="1321-environment-preparation-and-calibration"></a>
### 1.3.2.1 Preparazione e calibrazione dell’ambiente

- verificare e allineare l’ambiente di test alle caratteristiche della produzione (per quanto possibile)
- verificare le configurazioni (CPU, memoria, pool, connessioni)
- garantire osservabilità (metriche, log, trace)

Obiettivo:

- stabilire una baseline affidabile
- garantire la ripetibilità dei risultati

Senza calibrazione, le misurazioni sono difficili (o impossibili) da interpretare e i confronti diventano quantomeno inaffidabili.

---

<a id="1322-use-case-definition-and-workload-modeling"></a>
### 1.3.2.2 Definizione dei casi d’uso e modellazione del workload

Prima di applicare carico al sistema, il workload deve essere definito.

Un sistema non viene testato in isolamento, ma attraverso le richieste che elabora.

Questo richiede l'identificazione precisa di:

- i percorsi critici utente e di sistema
- le operazioni tipiche (read, write, batch, background job)
- la frequenza relativa di ciascuna operazione
- i pattern di concorrenza

Un workload realistico include:

- un mix di casi d’uso (Use Cases)
- una distribuzione pesata (es. percentuali di traffico)
- diversi tipi di richieste e diversi costi

La definizione del workload è uno dei passaggi più critici e va fatto in stretta collaborazione con chi definisce i requisiti non funzionali (NFRs).

Un workload scorretto porta a conclusioni fuorvianti o addirittura del tutto inutili.

---

<a id="1322-non-functional-requirements"></a>
### Requisiti non funzionali (NFR)

In parallelo con la definizione del workload, i **requisiti non funzionali** devono essere chiariti.

Essi definiscono ciò che viene considerato un **comportamento accettabile del sistema**.

Esempi tipici:

- obiettivi di throughput (es. 30 req/s)
- livelli di concorrenza (es. 500 utenti concorrenti)
- obiettivi di latenza (es. p95 < 200 ms)
- soglie del tasso di errore
- vincoli sull’utilizzo delle risorse

Gli NFR possono essere:

- definiti esplicitamente dagli stakeholder
- definiti solo parzialmente
- mancanti o incoerenti

In tutti i casi, devono essere:

- riesaminati
- validati
- resi misurabili

---

### Implicazione pratica

Workload e NFR devono essere allineati.

Per ciascun caso d’uso:

- il carico atteso deve essere definito
- il comportamento accettabile deve essere noto

Altrimenti:

- i risultati non possono essere valutati
- i test non possono essere considerati né riusciti né falliti

Una definizione scorretta del workload o l’assenza di NFR porta a risultati tecnicamente corretti, ma non azionabili.

---

<a id="1323-initial-load-stress-testing"></a>
### 1.3.2.3 Test iniziali di carico / stress (scoperta dei problemi)

La prima fase di "load test" mira a far emergere una baseline di riferimento ed eventuali problemi principali.

Obiettivi tipici:

- identificare colli di bottiglia evidenti
- rilevare errori funzionali sotto carico
- far emergere instabilità (timeout, crash, saturazione)

Questa fase è spesso:

- esplorativa
- iterativa
- parzialmente white-box (usando visibilità interna)

L’obiettivo è la scoperta, non la precisione.

---

<a id="1324-analysis-and-bottleneck-identification"></a>
### 1.3.2.4 Analisi e identificazione dei colli di bottiglia

Una volta che i problemi siano emersi, il sistema deve essere analizzato nel dettaglio.

Questo comporta:

- correlare le metriche (latenza, throughput, utilizzazione)
- identificare dove viene speso il tempo
- localizzare i punti di saturazione e le code

Domande tipiche:

- quale risorsa è satura?
- dove si accumula la latenza?
- che cosa limita il throughput?

Questo passaggio si basa su:

→ [1.1 Fondamenti](01-01-foundations.md)  
→ [1.2 Metriche e formule di base](01-02-core-metrics-and-formulas.md)

---

<a id="1325-fixes-and-iterative-validation"></a>
### 1.3.2.5 Correzioni e validazione iterativa

Dopo avere identificato i colli di bottiglia, debbono essere applicati i correttivi.

Queste possono includere:

- modifiche al codice
- aggiornamenti di configurazione
- aggiustamenti delle risorse (scalabilità verticale/orizzontale)

Ogni correzione deve essere validata rieseguendo i test.

Questo crea un ciclo iterativo:

- **Test** → **Analizza** → **Correggi** → **Testa** di nuovo

L’obiettivo è stabilizzare progressivamente il sistema.

---

<a id="1326-intermediate-validation"></a>
### 1.3.2.6 Validazione intermedia (baseline stabile)

Prima di passare ai test ulteriori e di lunga durata, il sistema deve raggiungere una baseline stabile.

Questo significa:

- nessun errore critico sotto il carico atteso
- comportamento prevedibile
- latenza e tassi di errore sotto controllo

Questa fase garantisce che:

- i problemi principali siano risolti
- i risultati siano riproducibili

---

<a id="1327-long-duration-validation"></a>
### 1.3.2.7 Validazione di lunga durata (soak / endurance)

Una volta ci si sia assicurati che il sistema è stabile, esso deve essere investigato sulla durata.

Questa fase valuta il comportamento del sistema sotto un carico di lavoro sostenuto nel tempo.

Obiettivi tipici:

- rilevare memory leak lenti
- osservare l’accumulo di risorse (thread, connessioni, buffer)
- identificare degradazioni prestazionali sulla durata
- validare la stabilità di lungo periodo

Questa fase è essenziale perché alcuni problemi:

- non compaiono immediatamente
- emergono soltanto dopo esercizio prolungato

I risultati di questa fase hanno un impatto diretto su:

- dimensionamento del sistema
- capacity planning
- configurazione di runtime

---

<a id="1328-dimensioning-and-capacity-definition"></a>
### 1.3.2.8 Dimensionamento e definizione della capacità

Sulla base delle osservazioni precedenti, e anche a partire da eventuali test unitari successivi alla fase di stabilizzazione della baseline, i componenti del sistema vengono dimensionati.

Questa fase include:

- configurazione di heap e memorie
- thread pool e connection pool
- limiti di concorrenza
- dimensionamento dell’infrastruttura
- clustering

L’obiettivo è definire:

- quanto carico il sistema può gestire
- in quali condizioni esso rimane stabile
- quali margini eventuali sono richiesti

Il dimensionamento deve basarsi sul comportamento osservato, non su ipotesi.

---

<a id="1329-tuning"></a>
### 1.3.2.9 Tuning

Una volta definito il dimensionamento, il tuning rifinisce il comportamento del sistema.

Aree tipiche:

- parametri del garbage collector
- scheduling dei thread e dimensionamento dei pool
- impostazioni del database e delle connessioni
- strategie di caching

Il tuning mira a:

- ridurre la latenza
- migliorare la stabilità
- ottimizzare l’utilizzo delle risorse

Spesso è iterativo e dipendente dal contesto specifico.

---

<a id="13210-verification-and-regression"></a>
### 1.3.2.10 Verifica e regressione

Dopo la fase di tuning, il sistema deve essere nuovamente validato.

Questo include:

- rieseguire gli scenari chiave
- verificare che i miglioramenti siano effettivi
- assicurare che non vengano introdotte regressioni

Questa fase garantisce coerenza e affidabilità.

---

<a id="13211-benchmarking"></a>
### 1.3.2.11 Benchmarking e punti di riferimento

Infine, vengono stabiliti i benchmark.

Essi forniscono:

- metriche prestazionali di riferimento
- punti di confronto tra versioni
- validazione rispetto alle aspettative

I benchmark non sono obiettivi in sé.

Sono utilizzati per:

- comprendere il comportamento del sistema
- seguirne l’evoluzione nel tempo

---

### Idea chiave

La performance engineering si sviluppa secondo un ciclo iterativo:

- **definisci il workload** → **testa** → **analizza** → **correggi** → **valida** → **ottimizza**

L’obiettivo non è solo migliorare le prestazioni, ma comprendere i limiti del sistema e garantire un comportamento prevedibile sotto carico.

---

<a id="133-black-box-vs-white-box"></a>
## 1.3.3 Black-box vs white-box

La performance engineering può essere affrontata da due prospettive complementari:

- **black-box** (osservazione esterna)
- **white-box** (osservazione interna)

Entrambe sono necessarie per comprendere il comportamento del sistema sotto carico di lavoro.

---

<a id="1331-black-box"></a>
### 1.3.3.1 Approccio black-box

In un approccio black-box, il sistema viene osservato dall’esterno.

Viene misurato solo il comportamento visibile esternamente:

- tempo di risposta
- throughput
- tasso di errore

L’implementazione interna non viene presa in considerazione.

---

### Ciò che fornisce

L’osservazione black-box consente di:

- validare il comportamento del sistema dal punto di vista dell’utente
- misurare le prestazioni end-to-end
- rilevare errori visibili sotto carico

Essa risponde a domande quali:

- Il sistema è sufficientemente veloce?
- Gestisce il carico atteso?
- Fallisce sotto stress?

---

### Limiti

Il solo black-box non può spiegare:

- dove eventualmente viene piu spesso speso del tempo
- quale risorsa è satura
- perché le prestazioni degradano

Mostra i sintomi, non le cause.

---

<a id="1332-white-box"></a>
### 1.3.3.2 Approccio white-box

In un approccio white-box, viene osservato il comportamento interno del sistema.

Questo include:

- utilizzazione delle risorse (CPU, memoria, disco, rete)
- thread pool e connection pool
- code interne
- tempi a livello di componente

L’osservazione white-box fornisce un livello di **introspezione nell’esecuzione del sistema**.

In molti casi, questo include visibilità vicina al livello del codice:

- tempi a livello di metodo
- call path e flussi di esecuzione
- hotspot (metodi lenti o eseguiti frequentemente)
- pattern di allocazione e comportamento della memoria
- contesa sui lock e punti di sincronizzazione

---

### Ciò che fornisce

L’osservazione white-box consente di:

- identificare i colli di bottiglia
- comprendere dove viene speso il tempo
- rilevare contesa (contentio) e accodamento (queueing)
- analizzare la saturazione delle risorse

Essa risponde a domande quali:

- Quale componente è lento?
- Dove si accumula la latenza?
- Che cosa limita il throughput?
- Quale parte dell’esecuzione è responsabile del rallentamento?

---

### Limiti

Il solo white-box non garantisce:

- un comportamento end-to-end corretto
- un’esperienza utente accettabile

Un sistema può apparire internamente efficiente ma fallire comunque sotto condizioni di workload reale.

---

<a id="1333-observability-and-tooling"></a>
### 1.3.3.3 Osservabilità e strumentazione

L’osservabilità fornisce i dati necessari per l’analisi white-box.

Essa include tipicamente:

- metriche di sistema e applicative (es. utilizzo CPU, latenza, throughput)
- log (eventi, errori, cambiamenti di stato)
- trace (flusso delle richieste tra componenti)
- application performance monitoring (APM)

Queste fonti forniscono visibilità continua sul comportamento del sistema.

---

### Artifact diagnostici

Oltre all’osservabilità continua, un’analisi più profonda si basa spesso su artifact diagnostici.

Questi vengono tipicamente raccolti on demand e forniscono uno snapshot dello stato del sistema.

Esempi comuni includono:

- thread dump (stati dei thread, lock, contesa)
- heap dump (uso della memoria, retention degli oggetti, leak)
- snapshot di profiling (profiling CPU e allocazioni)
- core dump (analisi dei guasti a livello di processo)

Questi artifact consentono di:

- ispezionare lo stato interno dell’esecuzione
- identificare thread bloccati e deadlock
- analizzare memory leak e retention path
- investigare in dettaglio anomalie prestazionali

Sono in genere più pesanti e intrusivi rispetto agli strumenti di osservabilità, e vengono utilizzati in modo selettivo durante la diagnostica.

---

<a id="1334-combining-both"></a>
### 1.3.3.4 Combinare entrambi gli approcci

Una performance engineering efficace richiede la combinazione di entrambe le prospettive.

Workflow tipico:

- usare il black-box per rilevare i problemi
- usare il white-box per spiegarli
- validare nuovamente i miglioramenti con il black-box

Questo crea un ciclo di feedback:

- **osserva** → **analizza** → **correggi** → **valida**

---

### Idea chiave

L’osservazione **black-box** rivela che esiste un problema.

L’osservazione **white-box** spiega perché esiste.

Entrambe sono necessarie per comprendere e controllare il comportamento del sistema sotto carico.

---

<a id="134-load-testing-vs-diagnostics"></a>
## 1.3.4 Load testing vs diagnostica

Il load testing e la diagnostica vengono spesso confusi.

Essi servono scopi differenti e operano a livelli differenti.

Entrambi sono necessari per comprendere il comportamento del sistema sotto carico di lavoro.

---

<a id="1341-load-testing"></a>
### 1.3.4.1 Load testing

Il load testing applica un workload controllato al sistema.

Viene utilizzato per:

- osservare il comportamento in condizioni specifiche
- misurare latenza, throughput e tassi di errore
- validare ipotesi su capacità e scalabilità

Il load testing opera principalmente a livello **black-box**:

- le richieste vengono generate esternamente
- le risposte vengono misurate esternamente

---

### Ciò che fornisce

Il load testing risponde a domande quali:

- Il sistema può gestire il carico atteso?
- Cosa accade quando il carico aumenta?
- Quando le prestazioni degradano?
- Qual è il throughput massimo sostenibile?

---

### Limiti

Il solo load testing non spiega:

- perché il sistema rallenta
- quale componente è responsabile
- come vengono utilizzate internamente le risorse

Rivela il comportamento, ma non le cause.

---

<a id="1342-diagnostics"></a>
### 1.3.4.2 Diagnostica

La diagnostica investiga il comportamento interno del sistema.

Viene utilizzata per:

- identificare i colli di bottiglia
- comprendere i percorsi di esecuzione
- analizzare l’utilizzo delle risorse
- spiegare i problemi prestazionali osservati

La diagnostica opera a livello **white-box**:

- vengono analizzate metriche interne
- vengono ispezionati trace e percorsi di esecuzione
- possono essere raccolti artifact diagnostici

---

### Ciò che fornisce

La diagnostica risponde a domande quali:

- Dove viene speso il tempo?
- Quale risorsa è satura?
- Quale componente è responsabile della latenza?
- Che cosa causa il degrado delle prestazioni?

---

### Strumenti e tecniche

La diagnostica si basa tipicamente su:

- metriche, log e trace
- application performance monitoring (APM)
- thread dump e heap dump
- profiling e analisi dell’esecuzione

---

### Limiti

La diagnostica senza load testing può non cogliere:

- condizioni di workload reale
- interazioni tra componenti
- comportamento sotto stress

Può spiegare un problema, ma non necessariamente riprodurlo.

---

<a id="1343-relationship-between-load-testing-and-diagnostics"></a>
### 1.3.4.3 Relazione tra load testing e diagnostica

Il load testing e la diagnostica devono essere combinati.

Workflow tipico:

- applicare carico per esporre il comportamento
- usare la diagnostica per analizzare lo stato interno
- applicare correzioni
- validare di nuovo con il load testing

Questo crea un ciclo:

- osserva → spiega → correggi → valida

---

### Idea chiave

Il load testing rivela che un problema esiste.

La diagnostica spiega perché esiste.

Nessuno dei due è sufficiente da solo.

La comprensione del comportamento del sistema richiede entrambi.

---

<a id="135-what-actually-matters-and-what-doesnt"></a>
## 1.3.5 Ciò che conta davvero (e ciò che non conta)

La performance engineering coinvolge un insieme esteso di strumenti, metriche e tecniche.

Tuttavia, non tutte possono avere lo stesso livello di importanza in contesti eterogenei.

Capire che cosa conta è essenziale per evitare di sprecare effort e trarre conclusioni errate.

---

### Ciò che conta

Gli aspetti più importanti sono:

- **comprendere il comportamento del sistema sotto carico**
- **identificare i colli di bottiglia e i fattori limitanti**
- **utilizzare workload realistici e NFR validati**
- **ragionare sulle interazioni tra componenti**
- **misurare e interpretare correttamente i risultati**

La performance engineering riguarda principalmente:

- costruire un modello mentale del sistema
- validare quel modello attraverso osservazioni
- raffinarlo tramite iterazione

---

### Ciò che non conta (quanto sembra)

Alcuni aspetti vengono spesso enfatizzati eccessivamente:

- strumenti e framework
- metriche isolate senza contesto
- scenari di test sintetici o irrealistici
- micro-ottimizzazioni senza impatto a livello di sistema
- risultati di un singolo test presi in isolamento

Questi elementi possono essere utili, ma non sono sufficienti.

---

### Fraintendimenti comuni

Compaiono frequentemente diversi fraintendimenti:

- “Se eseguo un load test, comprendo il sistema”
- “Se la CPU è bassa, il sistema è sano”
- “Se la latenza media è accettabile, il sistema va bene”
- “Più hardware risolverà il problema”

Queste assunzioni portano spesso a conclusioni scorrette.

---

### Pensiero a livello di sistema

Le prestazioni emergono dalle interazioni:

- tra componenti
- tra workload e risorse
- tra concorrenza e accodamento

Concentrarsi su una singola parte del sistema è raramente sufficiente.

Ciò che serve è una visione globale.

---

### Implicazione pratica

Una performance engineering efficace richiede:

- porre le domande corrette
- validare le ipotesi
- correlare segnali multipli
- iterare sulla base delle evidenze

Strumenti, test e metriche supportano questo processo, ma non lo sostituiscono.

---

### Idea chiave

La performance engineering non consiste nel raccogliere dati.

Riguarda il comprendere che cosa i dati significhino.

L’obiettivo non è produrre numeri, ma spiegare il comportamento del sistema e prendere decisioni informate.