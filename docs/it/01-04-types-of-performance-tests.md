## 1.4 – Tipi di test prestazionali

<a id="14-types-of-performance-tests"></a>

Questo capitolo introduce le principali categorie di test prestazionali utilizzate nella performance engineering.

Ogni tipo di test prestazionale risponde a una diversa domanda sul comportamento del sistema sotto carico.

Nel loro insieme, essi aiutano a valutare prestazioni, stabilità, scalabilità, recupero e capacità del sistema in modo controllato e misurabile.

## Indice

- [1.4.1 Scopo del performance testing](#141-purpose-of-performance-testing)
- [1.4.2 Load testing](#142-load-testing)
- [1.4.3 Stress testing](#143-stress-testing)
- [1.4.4 Spike testing](#144-spike-testing)
- [1.4.5 Soak testing](#145-soak-testing)
- [1.4.6 Capacity testing](#146-capacity-testing)

---

<a id="141-purpose-of-performance-testing"></a>
## 1.4.1 Scopo del performance testing

### Definizione

Il performance testing, come già ricorsato nei precedenti paragrafi, valuta come un sistema si comporta in condizioni di workload controllato.

Esso fornisce dati misurabili su:

- latenza  
- throughput  
- tasso di errore  
- utilizzo delle risorse  

(→ [1.2 Metriche e formule di base](./01-02-core-metrics-and-formulas.md))

Il performance testing non è quindi soltanto un’attività di misurazione, ma anche un’attività di validazione.

Viene sfruttato per comparare il comportamento atteso (definito nei NFRs) con il comportamento osservato in condizioni di workload definite.

---

### Ruolo nella performance engineering

Il performance testing non riguarda soltanto la misurazione dei risultati.

Viene utilizzato per:

- validare il comportamento del sistema nelle condizioni attese  
- far emergere colli di bottiglia e limitazioni  
- supportare il capacity planning  
- validare decisioni architetturali  

Esso fornisce anche un framework controllato per confrontare:

- versioni dello stesso sistema
- diverse configurazioni
- cambiamenti infrastrutturali
- scelte di tuning

Senza test controllati, le discussioni sulle prestazioni restano spesso basate su ipotesi piuttosto che su evidenze.

---

### Il workload come modello

Un workload di test rappresenta un modello semplificato dell’utilizzo reale.

Esso definisce:

- tasso di arrivo (richieste al secondo)  
- concorrenza (numero di utenti o richieste attive)  
- pattern delle richieste (distribuzione, mix di operazioni)  

(→ [1.2.1 Legge di Little (concorrenza a livello di sistema)](./01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency))

Un workload non è lo specchio esatto dell'utilizzazione reale di produzione in sé.

È un’approssimazione pratica dei pattern di utilizzo più rilevanti.

Per questa ragione, il valore di un test prestazionale dipende fortemente da quanto realistico sia il modello di workload.

---

### Condizioni controllate

Un test prestazionale è significativo soltanto se le condizioni di esecuzione sono ben definite e controllate.

Questo include:

- la definizione del workload
- la durata del test
- l’ambiente in cui esso viene eseguito
- le metriche raccolte durante l’esecuzione

Se queste condizioni non sono chiare i risultati, pur sempre numerici, saranno scarsamente o del tutto privi di valore conoscitivo e proiettivo.

Il controllo delle condizioni iniziali è uno di quei parametri che trasforma un test da semplice esercizio a indispensabile attività ingegneristica.

---

Il performance testing è dunque il punto d'ingresso a molti dei concetti sviluppati nel proseguio di questo documento.

Come pratica complessiva di test esso fa emergere:

- effetti di accodamento e saturazione (→ [1.5 Comportamento del sistema sotto carico](./01-05-system-behavior-under-load.md))
- limiti di concorrenza (→ [1.6 Concorrenza e parallelismo](./01-06-concurrency-and-parallelism.md))
- effetti di runtime e memoria (→ [1.7 Runtime e modello di memoria](./01-07-runtime-and-memory-model.md))
- saturazione delle risorse (→ [1.8 Prestazioni a livello di risorsa](./01-08-resource-level-performance.md))

Per questa ragione, il design dei test dovrebbe sempre essere collegato ad una conoscenza approfondita e complessiva del sistema.

---

### Significato pratico

Un buon test prestazionale non risponde soltanto a:

- “Quanto è veloce il sistema?”

Esso aiuta anche a rispondere a:

- “In quali condizioni il sistema rimane stabile?”
- “Che cosa cambia all’aumentare del carico?”
- “Quale limite viene raggiunto per primo?”
- “Quale tipo di degradazione compare?”

Queste domande sono essenziali nella performance engineering perché collegano la misurazione all’interpretazione.

---

### Idea chiave

I test prestazionali sono esperimenti controllati.

Sono progettati per osservare il comportamento del sistema in specifiche condizioni di workload.

Il loro valore non risiede soltanto nelle misurazioni che producono, ma soprattutto nella comprensione che forniscono.

---

<a id="142-load-testing"></a>
## 1.4.2 Load testing

### Definizione

Il **load testing** valuta il comportamento del sistema sotto workload standard o tipico.

È il modo più comune e più diretto per validare che un sistema si comporti in modo accettabile in condizioni operative normali.

---

### Obiettivo

- verificare che il sistema soddisfi i requisiti prestazionali  
- validare obiettivi di latenza e throughput  
- osservare l’utilizzo delle risorse in condizioni normali  

Il load testing risponde alla domanda se il sistema si comporti correttamente nell’intervallo operativo che ci si aspetta supporti.

---

### Caratteristiche

- il workload è stabile e controllato  
- il sistema opera entro il suo intervallo atteso  
- l’attenzione è rivolta al comportamento in regime stazionario  

Lo scopo non è portare il sistema ai limiti, ma stabilire se esso si comporti correttamente sotto un carico (di produzione) per cui è stato progettato.

---

### Esempio

Un sistema progettato per:

- 200 richieste al secondo  
- latenza p95 < 300 ms  

Un load test verifica che questi obiettivi siano soddisfatti.

Può anche verificare che:

- il tasso di errore rimanga basso
- il throughput rimanga stabile
- l’utilizzo delle risorse rimanga entro limiti accettabili

---

### Valore diagnostico

Il load testing fornisce una baseline:

- distribuzione normale della latenza  
- utilizzo tipico delle risorse  
- throughput atteso  

Questa baseline è essenziale per il confronto con gli altri test.

Senza una baseline affidabile, è difficile determinare se il comportamento osservato nei test di stress, spike, soak o capacity sia anomalo o semplicemente normale per il sistema sotto analisi.

---

### Limiti del load testing

Il solo load testing non determina:

- la capacità massima del sistema
- i punti di rottura del sistema
- la stabilità di lungo periodo del runtime
- il comportamento di recupero dopo cambiamenti bruschi del carico

Un sistema può superare un load test e fallire comunque sotto sovraccarico, esecuzione prolungata o rapidi burst di traffico.

Per questa ragione, il load testing è necessario ma non sufficiente.

---

### Interpretazione pratica

Il load testing è il punto di riferimento per il resto dell’analisi prestazionale.

Esso definisce il normale comportamento operativo del sistema e permette di interpretare i test successivi nel loro contesto.

Se il sistema si comporta già male sotto il carico standard, ha poco valore passare immediatamente a tipi di test più avanzati.

---

### Idea chiave

Il load testing risponde a: *“Il sistema si comporta correttamente sotto il carico atteso?”*

Esso stabilisce la baseline rispetto alla quale tutti gli altri test prestazionali possono essere interpretati.

---

<a id="143-stress-testing"></a>
## 1.4.3 Stress testing

### Definizione

Lo **stress testing** valuta il comportamento del sistema oltre la sua capacità attesa.

Viene utilizzato per osservare che cosa accade quando il sistema viene spinto fuori dal suo intervallo operativo previsto.

---

### Obiettivo

- identificare i limiti del sistema  
- osservare il comportamento sotto sovraccarico  
- rilevare i modi di fallimento  

Lo stress testing concerne principalmente il comportamento al limite del sistema e la degradazione delle capacità lavorative sotto carico eccedente gli standard previsti.

---

### Caratteristiche

- il workload aumenta oltre i livelli normali  
- il sistema si avvicina o raggiunge la saturazione  

(→ [1.8 Prestazioni a livello di risorsa](./01-08-resource-level-performance.md))

Il sovraccarico può essere applicato progressivamente o mantenuto a un livello chiaramente eccessivo.

In entrambi i casi, l’obiettivo è far emergere il modo in cui il sistema si comporta quando la domanda supera la capacità.

---

### Effetti osservabili

- la latenza aumenta rapidamente  
- il throughput si appiattisce o diminuisce  
- il tasso di errore aumenta  

(→ [1.5.3 Degradazione non lineare](./01-05-system-behavior-under-load.md#153-non-linear-degradation))  
(→ [1.5.4 Collasso del throughput](./01-05-system-behavior-under-load.md#154-throughput-collapse))

Effetti aggiuntivi possono includere:

- accumulo di code
- amplificazione dei timeout
- esaurimento dei pool
- utilizzo instabile delle risorse
- sovraccarico guidato dai retry

---

### Valore diagnostico

Lo stress testing rivela:

- colli di bottiglia  
- punti di saturazione  
- stabilità del sistema sotto pressione  

È particolarmente utile per comprendere se la degradazione sia graduale, brusca, recuperabile o instabile.

Due sistemi con risultati simili nei load test possono comportarsi in modo molto diverso sotto stress.

---

### Comportamento in rottura

Un aspetto importante dello stress testing non è soltanto se e quando il sistema fallisca, ma come fallisca.

Domande rilevanti includono:

- La latenza aumenta prima che compaiano errori?
- Gli errori compaiono gradualmente o improvvisamente?
- Il throughput si appiattisce prima di collassare?
- Il sistema recupera quando il carico viene ridotto?

Queste domande contano operativamente perché il sovraccarico è uno scenario realistico nei sistemi di produzione.

---

### Distinzione dal capacity testing

Lo stress testing e il capacity testing sono collegati, ma differenti.

- lo **stress testing** si concentra sul comportamento in sovraccarico e sui modi di fallimento
- il **capacity testing** si concentra sul massimo carico sostenibile che soddisfa ancora i requisiti

Lo stress testing continua quindi oltre l’intervallo operativo accettabile per esaminare degradazione e rottura.

---

### Interpretazione pratica

Lo stress testing è utile quando la domanda ingegneristica non è soltanto:

- “Quanto carico può supportare il sistema?”

ma anche:

- “Che cosa accade dopo che non può più supportare il carico?”
- “Degrada in modo graduale?”
- “Può recuperare in modo pulito?”

Queste sono domande essenziali per resilienza e robustezza operativa.

---

### Idea chiave

Lo stress testing risponde a: *“Che cosa accade quando il sistema viene spinto oltre i suoi limiti?”*

Esso rivela come il sistema degrada, come fallisce e quanto sovraccarico può tollerare prima di diventare instabile.

---

<a id="144-spike-testing"></a>
## 1.4.4 Spike testing

### Definizione

Lo **spike testing** valuta il comportamento del sistema sotto aumenti improvvisi di carico.

A differenza del load testing o dello stress testing graduale, lo spike testing si concentra sulle transizioni rapide piuttosto che su condizioni operative stabili.

---

### Obiettivo

- osservare la reazione a cambiamenti bruschi del workload  
- valutare elasticità e recupero  
- rilevare instabilità transitoria  

Lo spike testing è particolarmente rilevante per sistemi esposti a traffico bursty, picchi da campagne, domanda guidata da eventi o brevi impennate di attività.

---

### Caratteristiche

- il workload aumenta rapidamente ed in pochissimo tempo  
- il sistema deve adattarsi velocemente  

La caratteristica distintiva non è soltanto il volume di carico, ma la velocità con cui il carico cambia.

Un sistema può gestire un carico elevato quando esso viene raggiunto gradualmente, ma comportarsi male quando lo stesso carico arriva improvvisamente.

---

### Effetti osservabili

- picchi temporanei di latenza  
- accumulo di code  
- potenziali errori durante la transizione  

(→ [1.5 Comportamento del sistema sotto carico](./01-05-system-behavior-under-load.md))

Effetti aggiuntivi possono includere:

- risposta ritardata dello scaling
- esaurimento transitorio delle connessioni
- cascade temporanee di timeout
- recupero lento dopo il burst

---

### Valore diagnostico

Lo spike testing rivela:

- sensibilità al traffico bursty  
- comportamento di accodamento sotto carico improvviso  
- capacità di recupero dopo lo spike  

Questo tipo di testing è prezioso perché molti sistemi sono ottimizzati per condizioni di regime stazionario ma restano fragili durante transizioni brusche.

---

### Comportamento di recupero

La parte più importante dello spike testing è spesso ciò che accade dopo lo spike.

Domande rilevanti includono:

- Il sistema ritorna rapidamente alla latenza normale?
- Le code si svuotano in modo controllato?
- Le risorse vengono rilasciate correttamente?
- Il sistema resta degradato dopo che lo spike è passato?

Un sistema che sopravvive allo spike ma recupera lentamente può comunque essere operativamente debole.

---

### Interpretazione pratica

Lo spike testing è particolarmente utile per sistemi che sono:

- esposti esternamente a traffico bursty
- dipendenti da auto-scaling o comportamento elastico
- sensibili all’accumulo di code
- soggetti a cambiamenti di domanda guidati da eventi

In questi casi, il carico medio è spesso meno importante dei picchi di breve periodo e della reazione del sistema ad essi.

---

### Idea chiave

Lo spike testing risponde a: *“Come reagisce il sistema a cambiamenti improvvisi di carico?”*

Esso valuta non soltanto la resistenza ai burst, ma anche la capacità di recuperare in modo pulito dopo di essi.

---

<a id="145-soak-testing"></a>
## 1.4.5 Soak testing

### Definizione

Il **soak testing** valuta il comportamento del sistema su un periodo esteso sotto carico sostenuto.

Talvolta viene chiamato anche endurance testing.

Il suo scopo è far emergere problemi che non compaiono in test di breve durata.

---

### Obiettivo

- rilevare problemi di lungo periodo  
- osservare la stabilità nel tempo  
- identificare degradazione graduale  

Il soak testing riguarda meno la prestazione di picco e più la coerenza, l’accumulo e la deriva.

---

### Caratteristiche

- il workload è costante o varia lentamente  
- la durata del test è lunga (ore o giorni)  

La dimensione chiave è il tempo.

Alcuni sistemi si comportano correttamente per minuti ma degradano dopo ore a causa di effetti di accumulo.

---

### Effetti osservabili

- crescita della memoria  
- leak di risorse  
- degradazione delle prestazioni nel tempo  

(→ [1.7 Runtime e modello di memoria](./01-07-runtime-and-memory-model.md))

Sintomi aggiuntivi di lunga durata possono includere:

- accumulo di thread
- leakage di connessioni
- code in lento aumento
- crescita dell’overhead del GC
- squilibrio della cache o retention incontrollata

---

### Valore diagnostico

Il soak testing rivela:

- slow memory leak  
- esaurimento delle risorse  
- instabilità di lungo periodo  

È spesso l’unico modo affidabile per validare se il sistema rimanga sano ed operabile durante attività prolungata.

Questo è essenziale per sistemi di produzione che devono funzionare in continuo.

---

### Degradazione dipendente dal tempo

Il soak testing è importante perché alcune rotture non sono basate su soglie, ma sul tempo.

Esempi includono:

- memoria trattenuta lentamente nel tempo
- pool non completamente rilasciati
- task in background che accumulano deriva
- pattern di retry che aumentano lentamente la pressione
- cache che crescono senza eviction efficace

Questi problemi possono non comparire in load test o stress test di breve durata.

---

### Valore operativo

Un sistema che si comporta bene per dieci minuti ma degrada dopo sei ore non è stabile.

Il soak testing contribuisce quindi direttamente a:

- validazione per la messa in produzione
- fiducia nel runtime
- valutazione dell’affidabilità di lungo periodo
- dimensionamento dell’infrastruttura e del runtime

Esso aiuta anche a validare che il monitoraggio rimanga significativo su lunghi periodi di operatività.

---

### Interpretazione pratica

Il soak testing è particolarmente importante per sistemi con:

- lunghi uptime
- elaborazione in background
- runtime con gestione della memoria
- architetture ricche di connessioni
- pool di risorse che cambiano lentamente nel tempo

In tali sistemi, i risultati prestazionali di breve durata non sono sufficienti a garantire la stabilità reale.

---

### Idea chiave

Il soak testing risponde a: *“Il sistema rimane stabile nel tempo?”*

Esso valida il comportamento di lunga durata e rivela problemi causati da accumulo, deriva e degradazione lenta.

---

<a id="146-capacity-testing"></a>
## 1.4.6 Capacity testing

### Definizione

Il **capacity testing** determina il workload massimo che un sistema può gestire soddisfacendo i requisiti prestazionali.

Viene utilizzato per identificare il limite operativo pratico del sistema in condizioni accettabili.

---

### Obiettivo

- identificare il throughput massimo sostenibile  
- determinare limiti operativi sicuri  
- supportare il capacity planning  

Il capacity testing è quindi direttamente collegato a pianificazione, dimensionamento, forecasting e decisioni operative.

---

### Metodo

- eventuali test unitari per baseline dimensionale
- aumentare gradualmente il workload  
- monitorare latenza, throughput ed errori  
- identificare il punto in cui le prestazioni degradano  

L’aumento del carico dovrebbe essere controllato e misurabile.

Questo permette di localizzare il limite del sistema con maggiore precisione rispetto a uno stress test puramente esplorativo.

---

### Interpretazione

Il limite di capacità viene raggiunto quando:

- la latenza supera soglie accettabili  
- il tasso di errore aumenta  
- il throughput non scala più  

(→ [1.2 Metriche e formule di base](./01-02-core-metrics-and-formulas.md))  
(→ [1.5 Comportamento del sistema sotto carico](./01-05-system-behavior-under-load.md))

In pratica, il limite non è sempre un singolo valore esatto.

Può essere meglio compreso come un intervallo in cui il comportamento accettabile inizia a deteriorarsi.

---

### Che cosa rivela il capacity testing

Il capacity testing rivela:

- il carico sostenibile più elevato sotto criteri di accettazione definiti
- il margine tra carico atteso e carico massimo accettabile
- la relazione tra domanda crescente e comportamento degradato
- il punto in cui ulteriore carico non produce più throughput utile

Queste informazioni sono essenziali per decisioni ingegneristiche e di pianificazione.

---

### Relazione con il capacity planning

Il capacity testing è uno dei principali input del capacity planning.

Esso aiuta a rispondere a domande quali:

- Quanto traffico può supportare l’attuale sistema?
- Quanto headroom è disponibile?
- Quando sarà necessario scalare?
- Quale componente vincola per primo la capacità?

Questo rende il capacity testing particolarmente utile per forecasting e preparazione operativa.

---

### Distinzione dallo stress testing

Il capacity testing non consiste nel forzare il fallimento per il fallimento stesso.

Consiste nell’identificare il carico più elevato che soddisfa ancora requisiti definiti.

- il **capacity testing** si ferma al limite accettabile o vicino a esso
- lo **stress testing** continua oltre tale limite per esaminare il comportamento in sovraccarico

La distinzione conta perché molte decisioni di business e ingegneristiche dipendono da un’operatività sicura, non dal fallimento totale.

---

### Significato pratico

La capacità non è soltanto un numero.

Essa dipende da:

- mix del workload
- livello di concorrenza
- obiettivi di latenza
- tasso di errore accettabile
- vincoli sulle risorse

Per questa ragione, ogni valore di capacità deve sempre essere interpretato nel contesto del workload e dei criteri di accettazione utilizzati durante il test.

---

### Interpretazione pratica

Il capacity testing è più utile quando l’obiettivo ingegneristico è rispondere a:

- “Qual è l’intervallo operativo sicuro?”
- “Quanto headroom abbiamo?”
- “Quando dobbiamo scalare?”
- “Che cosa vincola la crescita futura?”

Esso è quindi una delle forme di performance testing più orientate alle decisioni.

---

### Idea chiave

Il capacity testing risponde a: *“Fino a che punto il sistema può scalare prima di degradare?”*

Esso identifica il massimo intervallo operativo sostenibile, non soltanto il punto di fallimento.