# 1.1 – Fondamenti

<a id="11-foundations"></a>

Questa sezione introduce i concetti fondamentali necessari per ragionare sulle prestazioni applicative e dei sistemi.

Fornisce un modello concettuale utilizzato attraverso tutta la guida.

Definisce i principi fondamentali utilizzati nell’ingegneria delle prestazioni per l'analisi del comportamento dei sistemi sotto carico.

## Indice

- [1.1.1 Throughput, latenza, concorrenza](#111-throughput-latency-concurrency)
- [1.1.2 Tempo di servizio vs tempo di risposta](#112-service-time-vs-response-time)
- [1.1.3 Sistemi sotto carico](#113-systems-under-load)
- [1.1.4 Saturazione e colli di bottiglia](#114-saturation-and-bottlenecks)
- [1.1.5 Perché i sistemi rallentano](#115-why-systems-slow-down)

---

<a id="111-throughput-latency-concurrency"></a>
## 1.1.1 Throughput, latenza, concorrenza

### Definizione

Queste sono le tre dimensioni principali utilizzate per descrivere le prestazioni di un sistema.

- **Throughput**: Quantità di lavoro eseguito nell'unità di tempo; numero di richieste elaborate per unità di tempo (es. richieste al secondo)  
- **Latenza**: tempo necessario per completare una richiesta (tempo di risposta)  
- **Concorrenza**: numero di richieste in elaborazione nello stesso momento  

Questi concetti sono fondamentali nell’ingegneria delle prestazioni e sono utilizzati in tutta la guida per descrivere il comportamento dei sistemi.

---

### Relazione

Queste grandezze non sono tra loro indipendenti.

Per un sistema stabile:

- aumentare il throughput aumenta tipicamente la concorrenza  
- aumentare la concorrenza tende ad aumentare la latenza  
- la latenza influisce direttamente su quante richieste rimangono “in flight”  

Questa relazione è centrale per comprendere come i sistemi si comportano sotto carico.

---

### Intuizione pratica

Un sistema può essere visto come una pipeline di elaborazione:

- **Input**: le richieste entrano  
- **Execution**: vengono elaborate  
- **Output**: escono  

In ogni momento:

- alcune richieste sono in elaborazione (concorrenza)  
- nuove richieste arrivano (throughput)  
- ogni richiesta richiede tempo per essere completata (latenza)  

Questo modello mentale aiuta a ragionare su flusso, accumulo e ritardi nei sistemi reali.

---

### Esempio

Se un sistema elabora:

- `100` richieste al secondo (100 Req./sec.) 
- ogni richiesta richiede `200 ms` (0.2 s)  

quindi, in media:

- circa `20` richieste sono `in flight` in ogni dato momento  

Questa relazione è formalizzata dalla **Legge di Little**:

→ [1.2.1 Legge di Little](01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency)

---

### Interpretazione pratica

Throughput, latenza e concorrenza formano un sistema chiuso.

Modificare uno di essi impatta necessariamente gli altri.

Per esempio:

- ridurre la latenza riduce la concorrenza a parità di throughput  
- aumentare il throughput aumenta la concorrenza se la latenza rimane costante  
- alta concorrenza aumenta la probabilità di accodamento e contesa  

Questo è un elemento chiave per diagnosticare problemi prestazionali.

---

<a id="112-service-time-vs-response-time"></a>
## 1.1.2 Tempo di servizio vs tempo di risposta

### Definizione

A livello di risorsa, il tempo di risposta è composto da due parti:

- **tempo di servizio (S)**: tempo impiegato a svolgere il lavoro effettivo  
- **tempo di attesa (Wq)**: tempo trascorso in attesa prima di essere elaborato  

Questa distinzione è fondamentale nell’analisi delle prestazioni.

---

### Relazione

Il tempo di risposta (Response Time):

- include sia `esecuzione` che `attesa`  
- esso aumenta quando si formano code  

Anche se il tempo di servizio rimane costante:

- il tempo di risposta può aumentare significativamente a causa dell’attesa  

Questo è uno dei motivi principali per cui i sistemi degradano sotto carico.

---

### Significato pratico

Un sistema lento spesso non è tale perché il lavoro da compiere è "dispendioso", ma perché il lavoro da compiere è in attesa di risorse disponibili.

All’aumentare del carico:

- le code crescono  
- l’attesa domina  
- il tempo di risposta degrada  

Questa scomposizione è formalizzata come:

→ [1.2.3 Tempo di servizio vs tempo di risposta](01-02-core-metrics-and-formulas.md#123-service-time-vs-response-time-queueing)

---

### Interpretazione pratica

Separare il `tempo di servizio` dal `tempo di risposta` consente:

- identificare se il sistema è limitato dalla CPU o dalle code  
- distinguere tra costo di elaborazione e contesa sulle risorse 
- comprendere se l’ottimizzazione deve agire sull’esecuzione o sull’attesa  

In molti sistemi reali, i problemi di latenza sono causati principalmente dall’accodamento piuttosto che dal calcolo.

---

<a id="113-systems-under-load"></a>
## 1.1.3 Sistemi sotto carico

### Definizione

Un sistema sotto carico elabora un flusso continuo di richieste in ingresso.

Il carico è tipicamente espresso come:

- richieste al secondo  
- utenti concorrenti  
- transazioni al secondo  

Il carico definisce le condizioni operative in cui le prestazioni devono essere valutate.

---

### Comportamento

All’aumentare del carico:

- l’utilizzo delle risorse aumenta  
- le code iniziano a formarsi  
- la latenza aumenta  
- il throughput alla fine si stabilizza o degrada  

Questi effetti non sono lineari e dipendono dal design del sistema e dai vincoli delle risorse.

---

### Osservazione chiave

I sistemi non degradano in modo lineare.

A basso carico:

- le prestazioni sono stabili  

Vicino alla saturazione:

- piccoli aumenti di carico possono causare importanti incrementi in termini di latenza  

Questo comportamento non lineare è una caratteristica chiave dei sistemi reali.

---

### Interpretazione pratica

Comprendere il comportamento del sistema sotto carico è essenziale per:

- capacity planning  
- test delle prestazioni  
- diagnosi dei problemi di latenza  

Esso puo' spiegare le ragioni del perché i sistemi possono apparire stabili nei test ma fallire con un carico di produzione leggermente più elevato.

---

<a id="114-saturation-and-bottlenecks"></a>
## 1.1.4 Saturazione e colli di bottiglia

### Saturazione

Una risorsa è satura quando è occupata per la maggior parte o per tutto il tempo.

Esempi tipici:

- CPU al 100% (o quasi...)  
- pool di thread completamente utilizzato  
- pool di connessioni esaurito  

La saturazione indica che una risorsa non può gestire ulteriore domanda senza subire una degradazione.

---

### Collo di bottiglia

Il collo di bottiglia (bottleneck) è la risorsa che limita il throughput del sistema.

Caratteristiche:

- massimo utilizzo  
- code più lunghe  
- contributo dominante al tempo di risposta  

Il collo di bottiglia determina la capacità complessiva del sistema.

---

### Significato pratico

Migliorare risorse che non sono problematiche (colli di bottiglia) ha poco o nessun effetto.

I miglioramenti delle prestazioni richiedono:

- identificare il collo di bottiglia  
- ridurne la domanda o aumentarne la capacità  

Questo è un principio chiave nell’ingegneria delle prestazioni.

---

### Interpretazione pratica

Nei sistemi complessi:

- più risorse possono sembrare limitanti  
- ma tipicamente solo una limita il throughput in un dato momento  

Identificare correttamente il collo di bottiglia è essenziale per evitare ottimizzazioni inefficaci.

---

<a id="115-why-systems-slow-down"></a>
## 1.1.5 Perché i sistemi rallentano

### Meccanismi comuni

Il degradamento delle prestazioni è solitamente indotto da un numero limitato di fattori:

- accodamento dovuto alla saturazione  
- contesa su risorse condivise  
- uso inefficiente delle risorse  
- dipendenze esterne che diventano lente  

Questi meccanismi spesso interagiscono e si amplificano a vicenda.

---

### Effetto dell’accodamento

Quando l’utilizzo di una risorsa si avvicina ai sui limiti:

- il tempo di attesa aumenta rapidamente  
- il tempo di risposta è dominato dall’accodamento  

Questo comportamento è strettamente correlato all’utilizzo e agli effetti di accodamento:

→ [1.2.2 Legge di Utilizzazione](01-02-core-metrics-and-formulas.md#122-utilization-law-resource-level-busy-time)

---

### Effetti di amplificazione

Alcuni pattern amplificano i problemi di prestazioni:

- i retry aumentano il carico su sistemi già saturi  
- i timeout portano a lavoro duplicato  
- dipendenze a cascata propagano i ritardi  

Questi effetti possono trasformare un carico moderato in un degrado severo.

---

### Interpretazione pratica

Il degrado delle prestazioni è raramente causato da un solo, singolo fattore.

Piuttosto, esso emerge da:

- interazioni tra componenti  
- accumulo del tempo di attesa  
- cicli di feedback sotto carico  

Da qui deriva la possibilità di una diagnosi efficace.

---

### Conclusione pratica

La maggior parte dei problemi di prestazioni non è causata da una singola operazione problematica o lenta, ma da:

- interazioni tra componenti  
- accumuli dei tempi di attesa  
- condizioni di sovraccarico  

Comprendere questi meccanismi è essenziale prima di applicare formule o eseguire test.

---

### Idea chiave

Le prestazioni di un sistema sono determinate dalle interazioni tra carico di lavoro, risorse e concorrenza.

La comprensione di queste interazioni è il fondamento dell’ingegneria delle prestazioni.