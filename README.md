# L'algoritmo di Canny
Lo scopo di questo progetto è individuare i bordi presenti in un'immagine, ovverosia i contorni delle figure che sono rappresentate nell'immagine, mediante
implementazione dell'algoritmo di Canny.
L'idea chiave dell'algoritmo è quella di andare a confrontare la velocità di variazione del colore in pixel contigui, se c'è una variazione di colore molto
intensa in 3 pixel contigui, l'algoritmo di Canny catalogherà il pixel centrale come di bordo.  
L'algoritmo prende il nome da John Canny, autore dell'articolo *A Computational Approach to Edge Detection* pubblicato nel 1986. 
Nel presente progetto ne viene realizzata una versione con filtro gaussiano, operatori di Sobel, soppressione dei non massimi e doppia sogliatura con isteresi.  
I codici sono stati implementati in linguaggio MATLAB, tuttavia, essendo tutti gli algoritmi stati scritti from scratch (da zero) utilizzando unicamente la 
libreria standard di MATLAB, i codici risultano compatibili sia con le licenze base di MATLAB (senza la necessità di specifici toolbox a pagamento), 
sia con il software open-source GNU Octave.  

<p align="center">
  <img src="Immagini_Testing/Fig_01.jpg" alt="Immagine originale" width="49%">
  <img src="Immagini_Testing_Bordi/Fig_01_bordi.png" alt="Bordi individuati mediante Canny" width="49%">
</p>


## La rappresentazione delle immagini ed il formato di input

Un'immagine raster è individuata da una griglia rettangolare di pixel, ovverosia da una matrice di pixel. 
In seguito indicheremo con $R$ il numero delle righe e con $C$ il numero delle colonne, ed il numero totale di pixel dell'immagine sarà pertanto $R \cdot C$.  
Nelle immagini in scala di grigi ad 8 bit, ciascun pixel sarà un valore compreso tra 0 e 255 (ovverosia $2^8-1$), dove 0 indica il colore nero, 255 indica 
un bianco acceso, e tutti gli interi intermedi individuano una tonalità di grigio, più scuro quando il valore è vicino allo zero e più chiaro 
quando l'intero è vicino a 255.
Per le immagini a colori invece, ciascun pixel della matrice individua una terna di elementi, corrispondenti alla tonalità dei colori Red, Green e Blue, 
motivo per cui queste immagini vengono dette in scala di colori RGB, dal momento che ciascun pixel avrà un colore dato dalla combinazione lineare
di questi tre colori. Segue pertanto che un'immagine in scala di grigi è individuata da una matrice di dimensione $R \times C$, mentre un'immagine a colori 
sarà un array (o tensore) di dimensione $R \times C \times 3$.  
L'immagine output con i bordi sarà invece un'immagine in bianco e nero, dove i pixel assumeranno solo i valori 0 oppure 255.  
Si osservi che nel caso di immagini RGB a valori in `uint8`, ciascun pixel non è rappresentato con 8 bit, bensì con 24, poiché serviranno 8 bit a 
determinare l'intensità di colore su ciascuno dei 3 canali.

La lettura è affidata alla funzione `imread`. Tra i formati più diffusi utilizzabili, purché il contenuto rispetti la rappresentazione appena 
descritta, figurano:

| Formato | Estensioni comuni |
| --- | --- |
| PNG | `.png` |
| JPEG | `.jpg`, `.jpeg` |
| TIFF | `.tif`, `.tiff` |
| BMP | `.bmp` |

La sola estensione del file non è sufficiente a garantire che l'immagine sia adatta al codice: immagini indicizzate mediante una tavolozza, immagini CMYK o immagini a $16$ bit per canale richiedono una conversione preliminare in scala di grigi o RGB a $8$ bit per canale. Il programma non elabora separatamente la trasparenza.



## L'idea dell'algoritmo e la successione delle procedure

L'algoritmo di Canny lavora con un'immagine in scala di grigi, pertanto, se l'immagine è a colori, bisogna innanzi tutto convertirla.  
Preso atto di ciò, l'idea chiave è individuare i punti nei quali l'intensità dell'immagine cambia più rapidamente, e per farlo si utilizzano tecniche alle
derivate discrete ed alle differenze finite, misurando quanto rapidamente cambia l'intensità di pixel vicini.  
Tuttavia, prima di poter procedere effettivamente al calcolo dei gradienti, bisogna dapprima attenuare il rumore visivo presente nella figura: 
l'immagine così com'è può produrre variazioni locali molto forti, di conseguenza, bisogna prima applicare un filtro gaussiano che medi l'intensità di un pixel con quella dei pixel ad esso vicini.

Si calcolano quindi la norma e la direzione del gradiente in ogni pixel, si selezionano i massimi locali lungo tale direzione, questi pixel saranno
i candidati massimi e costituiranno un insieme da cui poi verrà estratto il sottoinsisme dei pixel effettivamente di bordo. 
Determinato l'insieme dei candidati di bordo, si classificano poi i pixel selezionati mediante due soglie suddividendoli in *bordi deboli* e *bordi forti*, 
oppure scartandoli e non considerandoli più come di bordo. 
Infine, si utilizza l'analisi delle componenti connesse tra i pixel per decidere quali bordi deboli conservare e quali scremare ulteriormente.

Lo script principale [Canny.m](./Canny.m) richiama le sette funzioni secondarie nel seguente ordine:

| Ordine | Procedura secondaria | Ruolo |
| --- | --- | --- |
| 1 | `converti_in_scala_di_grigi` | Convertire, se necessario, l'immagine in scala di grigi |
| 2 | `smoothing_gaussiano` | Attenuare il rumore mediante un filtro gaussiano. |
| 3 | `calcola_grad_e_angolo` | Stimare la norma del gradiente e quantizzarne la direzione. |
| 4 | `individua_candidati_massimi` | Selezionare i pixel che abbiano gradiente in norma maggiore dei pixel ad esso adiacenti lungo la direzione data dall'angolo. |
| 5 | `calcola_soglie` | Determinare due variabili soglia: soglia alta e soglia bassa. |
| 6 | `individua_bordi_deboli_e_forti` | Distinguere bordi forti, bordi deboli e pixel da scartare. |
| 7 | `gestisci_bordi_deboli` | Promuovere i bordi deboli connessi ai bordi forti. |

Al termine della procedura, la matrice `I_bordi` sarà a valori nell'insieme binario $\\{0,255\\}$.  
Le procedure secondarie nella tabella sopra verranno approfondite nelle sezioni sottostanti.


## Conversione in scala di grigi

La funzione [converti_in_scala_di_grigi](./Funzioni_Secondarie/converti_in_scala_di_grigi.m) ha il compito di trasformare un'immagine RGB di dimensioni 
$M \times N \times 3$ in una immagine in scala di grigi di dimensioni $M \times N$.  
Se l'immagine passata alla funzione è già in scala di grigi, la funzione termina senza modificare l'immagine input.

Per trasformare un'immagine da colori in scala di grigi si combinano linearmente i tre colori Red, Green e Blue, utilizzandoli come se fossero dei 
"colori primari".

$$
I_{\mathrm{grigio}}(i,j) = 0.2989 \cdot R(i,j) + 0.5870 \cdot G(i,j) + 0.1140 \cdot B(i,j).
$$

Il motivo per cui si usano proprio questi pesi nella combinazione lineare discende dalla fisica ottica e dal modo in cui l'occhio umano legge le
frequenze di colore

Il risultato della combinazione viene infine convertito a valori `uint8` mediante casting, arrotondando i valori ai livelli interi di grigio rappresentabili, 
la matrice viene infine restituita alla funzione chiamante.

[INSERIRE CONFRONTO IMMAGINE CONVERTITA IN SCALA DI GRIGI]


## Riduzione del rumore mediante filtro gaussiano

La funzione [smoothing_gaussiano](./Funzioni_Secondarie/smoothing_gaussiano.m) attenua le variazioni locali più rapide dell'immagine prima che vengano calcolate le derivate.

Questa fase è necessaria perché le operazioni di derivazione sono sensibili al rumore: una piccola irregolarità tra pixel vicini può produrre un gradiente elevato ed essere interpretata come un bordo. Il filtraggio sostituisce quindi l'intensità di ciascun pixel con una media pesata delle intensità dei pixel circostanti, i
pesi sono dati dalla funzione densità della distribuzione gaussiana.

Il modello di riferimento è la funzione gaussiana bidimensionale:

$$
G_{\sigma}(x,y) = \frac{1}{2\pi\sigma^2}
\exp\left(-\frac{x^2+y^2}{2\sigma^2}\right)
$$

Il filtro gaussiano viene applicato mediante convoluzione dell’immagine in scala di grigi con una maschera $5 \times 5$. I valori della maschera si 
ottengono campionando la funzione gaussiana e normalizzando i pesi affinché la loro somma sia uguale a 1. In questo modo il filtro conserva 
l’intensità di un’immagine costante.

Il parametro $\sigma$ regola la distribuzione dei pesi. Valori piccoli concentrano maggiormente il peso vicino al pixel centrale; aumentando $\sigma$, i 
pixel circostanti acquistano maggiore importanza e l'effetto di sfocatura diventa più marcato, con una possibile perdita dei dettagli più fini.  
La variabile `sigma` è uno dei tre parametri modificabili che determinano la distribuzione ed il numero di pixel classificati "di bordo" nella matrice finale. 

Come dettaglio implementativo si segnala che la matrice originale viene espansa di una cornice di contorno dallo spessore di 2 pixel per permettere la convoluzione anche sui pixel nella cornice della foto originaria. La tecnica è quella del *padding* ed i pixel nuovi avranno la stessa intensità del pixel originario ad esso adiacente.

[INSERIRE IMMAGINI CON BLUR GAUSSIANO]

[INSERIRE IMMAGINI IN CUI CONFRONTO OUTPUT DUOMO CON DUE \SIGMA DIVERSI]


## Calcolo della norma e della direzione del gradiente

La funzione [calcola_grad_e_angolo](./Funzioni_Secondarie/calcola_grad_e_angolo.m) utilizza l'immagine filtrata per stimare, in ogni pixel, il gradiente
dell'intensità dell'immagine e l'angolo di tale vettore gradiente. L'obiettivo è stimare intensità e direzione della variazione del colore in scala di grigi.  
Per ogni pixel bisognerà quindi stim








