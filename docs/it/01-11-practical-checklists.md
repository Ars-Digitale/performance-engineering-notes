## 1.11 – Checklist pratiche

<a id="111-practical-checklists"></a>

Questo capitolo fornisce checklist pratiche per preparare, eseguire e analizzare test di performance.

A differenza dei capitoli precedenti, che spiegano concetti e meccanismi, questo capitolo si concentra sulla disciplina operativa.

L’obiettivo è ridurre errori evitabili e assicurare che i test di performance producano risultati interpretabili, affidabili e utili.

## Indice

- [1.11.1 Prima di eseguire un test](#1111-before-running-a-test)
- [1.11.2 Durante l’esecuzione del test](#1112-during-test-execution)
- [1.11.3 Dopo l’analisi del test](#1113-after-test-analysis)
- [1.11.4 Errori comuni](#1114-common-pitfalls)

---

<a id="1111-before-running-a-test"></a>
## 1.11.1 Prima di eseguire un test

### Obiettivi

Definire chiaramente che cosa il test intenda validare.

Obiettivi tipici includono:

- target di latenza  
- obiettivi di throughput  
- limiti di capacità  

Un test senza un obiettivo chiaro può comunque generare dati, ma quei dati saranno difficili da valutare e interpretare.

La prima domanda dovrebbe sempre essere:

- che cosa questo test dovrebbe provare, validare o rivelare?

---

### Definizione del carico di lavoro

Definire il carico di lavoro con precisione:

- tasso di richieste o concorrenza  
- mix di richieste  
- durata  

(→ [1.4 Types of performance tests](./01-04-types-of-performance-tests.md))

Il carico di lavoro deve essere abbastanza specifico da essere riproducibile e abbastanza realistico da essere significativo.

Un carico di lavoro vago o artificiale può produrre risultati tecnicamente corretti ma operativamente irrilevanti.

---

### Coerenza dell’ambiente

Assicurarsi che:

- l’ambiente di test sia stabile  
- la configurazione corrisponda alle assunzioni di produzione  
- le dipendenze esterne siano controllate  

Se l’ambiente cambia durante il testing, l’interpretazione si rivela impossibile.

I risultati di performance sono confrontabili solo se le condizioni di esecuzione rimangono sufficientemente coerenti.

Questo è particolarmente importante quando si valutano:

- cambiamenti di configurazione
- cambiamenti di codice
- cambiamenti infrastrutturali

---

### Setup delle metriche

Verificare che tutte le metriche richieste siano disponibili:

- percentili di latenza  
- throughput  
- utilizzo delle risorse  
- tasso di errore  

(→ [1.2 Core metrics and formulas](./01-02-core-metrics-and-formulas.md))

È anche utile assicurarsi che segnali di supporto siano disponibili quando rilevanti, come:

- lunghezze delle code
- timing delle dipendenze
- attività GC
- stati dei thread o dei pool

Il test non dovrebbe iniziare prima che l'osservabilità sia in essere.

---

### Controlli di preparazione

Prima di eseguire il test, confermare che:

- il sistema target sia nello stato atteso
- il monitoring sia attivo
- il generatore di carico di lavoro sia configurato correttamente
- la durata del test sia appropriata per l’obiettivo scelto
- i criteri di successo e fallimento siano ben noti in anticipo

Questo evita un problema comune nel performance testing: eseguire un test tecnicamente valido che in seguito non può essere interpretato con autorevolezza.

---

### Interpretazione pratica

La preparazione è parte del test.

La maggior parte dei risultati inaffidabili non è causata da un comportamento complesso del sistema, ma da una scarsa preparazione del test:

- obiettivi poco chiari
- carico di lavoro non realistico
- ambiente incoerente
- metriche incomplete

Un test ben preparato rende la diagnostica successiva molto più agevole.

---

### Idea chiave

Un test è significativo solo se obiettivi, carico di lavoro e misurazioni sono chiaramente definiti.

---

<a id="1112-during-test-execution"></a>
## 1.11.2 Durante l’esecuzione del test

### Monitoring

Osservare il comportamento del sistema in tempo reale:

- evoluzione della latenza  
- stabilità del throughput  
- utilizzo delle risorse  

Il monitoring durante l’esecuzione è importante perché alcuni problemi sono visibili solo mentre il test è in esecuzione, specialmente:

- saturazione improvvisa
- accodamento inatteso
- recupero instabile
- guasti delle dipendenze

Attendere solamente la fine del test può nascondere comportamenti essenziali che dipendono invece dal tempo.

---

### Controlli di coerenza

Assicurarsi che:

- il carico di lavoro sia applicato come previsto  
- nessun disturbo esterno influenzi il test  

Questo include verificare che:

- il tasso di richieste previsto sia effettivamente generato
- il mix di operazioni rimanga coerente
- nessuna attività non correlata stia distorcendo i risultati
- gli errori siano causati dalle condizioni di test piuttosto che da rumore esterno

Una discrepanza tra carico di lavoro previsto e carico di lavoro reale può invalidare l’intera interpretazione.

---

### Segnali precoci

Osservare:

- rapido aumento della latenza  
- errori inattesi  
- saturazione delle risorse  

(→ [1.8 Resource-level performance](./01-08-resource-level-performance.md))

Questi sono spesso i primi segnali che il sistema si sta avvicinando a un limite o che il carico di lavoro sta esponendo un collo di bottiglia non anticipato.

L’identificazione precoce è importante perché consente all’operatore del test di:

- catturare evidenze rilevanti
- preservare contesto utile
- evitare di perdere la parte più informativa dell’esecuzione

---

### Osservazioni a runtime

Durante l’esecuzione, è utile osservare non solo valori assoluti, ma anche il cambiamento nel tempo.

Esempi:

- latenza in aumento mentre il throughput rimane stabile
- lunghezze delle code in crescita prima della saturazione della CPU
- errori che appaiono solo dopo una soglia specifica
- degradazione di p95/p99 prima che la media cambi significativamente

Questi pattern spesso rivelano più di snapshot isolate.

Aiutano a distinguere tra:

- instabilità transiente
- sovraccarico stabile
- degrado lento
- collasso improvviso

---

### Disciplina di intervento

Durante un test, evitare di cambiare parametri a meno che il cambiamento non faccia parte del piano di test.

Un intervento non pianificato rende i risultati più difficili da interpretare perché mescola cause multiple nella stessa finestra di osservazione.

Se l’intervento diventa necessario, dovrebbe essere:

- documentato
- marcato temporalmente
- esplicitamente collegato al comportamento osservato

Questo preserva il valore diagnostico dell’esecuzione.

---

### Interpretazione pratica

L’esecuzione è la fase in cui la preparazione teorica incontra il comportamento reale del sistema.

Un test ben progettato può comunque diventare fuorviante se l’operatore non conferma che:

- il carico di lavoro sia corretto
- l’ambiente rimanga stabile
- il sistema si stia comportando come previsto o, cosa importante, in modo inatteso come il test intendeva rivelare

---

### Idea chiave

L’esecuzione non è passiva.

È richiesta osservazione continua per rilevare precocemente le anomalie.

---

<a id="1113-after-test-analysis"></a>
## 1.11.3 Dopo l’analisi del test

### Revisione dei dati

Analizzare i dati raccolti:

- distribuzione della latenza  
- trend di throughput  
- utilizzo delle risorse  

La revisione dei dati dovrebbe concentrarsi non solo sui valori medi, ma anche sulla forma del comportamento nel tempo.

Per esempio:

- quando il degradamento è iniziato
- se il throughput ha scalato come previsto
- se la latenza in coda si è ampliata prima che apparissero errori

Questo rende l’analisi più diagnostica e meno descrittiva.

---

### Correlazione

Mettere in relazione i segnali:

- latenza vs CPU  
- latenza vs I/O  
- errori vs carico  

(→ [1.10 Diagnostics and analysis](./01-10-diagnostics-and-analysis.md))

La correlazione aiuta a identificare quale risorsa o meccanismo sia più probabilmente associato al degradamento osservato.

Tuttavia, la correlazione dovrebbe essere trattata come un punto di partenza analitico, non come una conclusione finale.

---

### Interpretazione

Identificare:

- colli di bottiglia  
- limiti di scalabilità  
- pattern anomali  

L’interpretazione dovrebbe rispondere a domande come:

- che cosa è cambiato per primo?
- che cosa è degradato dopo?
- quale vincolo è diventato dominante?
- il degrado è stato graduale, brusco o dipendente dal tempo?

Questo è il punto in cui misurazioni grezze diventano comprensione del sistema.

---

### Reporting

Riassumere:

- comportamento osservato  
- problemi identificati  
- raccomandazioni  

Un report descrittivo è più efficace che un mero elenco di numeri.

Dovrebbe spiegare:

- che cosa il sistema era atteso fare
- che cosa ha effettivamente fatto
- dove si è discostato dalle aspettative
- quale evidenza supporta la conclusione

Questo rende i risultati utilizzabili per engineering, operations e test futuri.

---

### Orientamento ai passi successivi

Dopo l’analisi, definire che cosa dovrebbe accadere in seguito.

Questo può includere:

- rieseguire lo stesso test dopo modifiche
- raffinare il realismo del carico di lavoro
- raccogliere diagnostica più profonda
- isolare un sospetto collo di bottiglia
- espandere verso test di stress, soak o capacità

Senza una decisione sui passi successivi, l’analisi rimane informativa ma non operativamente utile.

---

### Interpretazione pratica

L’analisi post-test è il punto in cui la performance engineering diventa presa di decisione.

Lo scopo non è solo dichiarare che una metrica è cambiata, ma spiegare:

- perché il cambiamento è importante
- che cosa implica sul sistema
- che cosa dovrebbe essere fatto dopo

---

### Idea chiave

L’analisi trasforma dati grezzi in comprensione azionabile.

---

<a id="1114-common-pitfalls"></a>
## 1.11.4 Errori comuni

### Interpretare male le medie

- le medie nascondono la latenza in coda  
- i percentili forniscono una vista più chiara  

(→ [1.2.7 Percentiles](./01-02-core-metrics-and-formulas.md#127-percentiles-p50-p95-p99))

Un sistema può apparire sano in media pur producendo performance inaccettabili per una frazione significativa di richieste.

Questo è uno degli errori più comuni nell’interpretazione dei test.

---

### Ignorare il realismo del carico di lavoro

- carichi di lavoro non realistici producono risultati fuorvianti  
- i pattern di produzione devono essere approssimati  

Un carico di lavoro troppo sintetico può essere più facile da generare, ma se non riflette il reale mix di richieste, la concorrenza e il comportamento delle dipendenze, le conclusioni possono non trasferirsi alle condizioni di produzione.

Il realismo non richiede riproduzione perfetta, ma richiede un’approssimazione credibile.

---

### Confondere sintomo e causa

- alta CPU non è sempre il problema alla radice  
- la latenza deve essere analizzata nel contesto  

(→ [1.10 Diagnostics and analysis](./01-10-diagnostics-and-analysis.md))

Questo errore spesso porta a ottimizzazione inefficace.

Il sintomo visibile può essere solo la conseguenza di un meccanismo più profondo come accodamento, blocking o rallentamento di una dipendenza.

---

### Trascurare i colli di bottiglia

- ottimizzare risorse non limitanti ha poco effetto  
- il focus deve rimanere sul vincolo dominante  

(→ [1.8 Resource-level performance](./01-08-resource-level-performance.md))

Questa è una fonte frequente di sforzo mal posto.

Un sistema può contenere molte imperfezioni, ma solo alcune di esse contano nel punto operativo corrente.

---

### Eseguire test senza criteri di accettazione

Un test è difficile da interpretare se non esiste una definizione preventiva di comportamento accettabile.

Senza soglie esplicite, diventa poco chiaro se il risultato significhi:

- successo
- fallimento
- degrado
- rischio accettabile

I numeri di performance sono utili solo quando confrontati con aspettative definite.

---

### Trattare un solo test come definitivo

Una singola esecuzione di test raramente cattura il comportamento completo di un sistema.

Esecuzioni ripetute possono esporre:

- effetti di warm-up
- variabilità delle dipendenze
- drift di lungo termine
- comportamento di soglia sotto profili di carico diversi

Un’analisi di performance affidabile richiede di solito confronto, ripetizione e validazione.

---

### Ignorare la dimensione temporale

Alcuni problemi non appaiono immediatamente.

Un test breve può perdere:

- crescita lenta della memoria
- accumulo di code ritardato
- degrado graduale delle dipendenze
- instabilità del runtime nel tempo

Per questo la durata del test deve corrispondere al tipo di comportamento che si sta valutando.

---

### Interpretazione pratica

La maggior parte degli errori nel performance testing non è causata da strumenti inappropriati.

È causata da:

- assunzioni deboli
- visibilità incompleta
- cattiva interpretazione
- mancanza di disciplina metodologica

Evitare questi errori è spesso più prezioso che aggiungere maggiore dettaglio di misurazione.

---

### Idea chiave

Assunzioni scorrette portano a conclusioni scorrette.

Evitare errori comuni è essenziale per un’analisi di performance affidabile.