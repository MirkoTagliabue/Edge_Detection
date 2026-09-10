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

Si calcolano quindi la norma e la direzione del gradiente in ogni pixel, si selezionano i massimi locali lungo tale direzione; questi pixel saranno
i candidati punti di bordo e costituiranno un insieme da cui poi verrà estratto il sottoinsieme dei pixel effettivamente di bordo. 
Determinato l'insieme dei candidati di bordo, si classificano poi i pixel selezionati mediante due soglie suddividendoli in *bordi deboli* e *bordi forti*, 
oppure scartandoli e non considerandoli più come di bordo. 
Infine, si utilizza l'analisi delle componenti connesse tra i pixel per decidere quali bordi deboli conservare e quali scremare ulteriormente.

Lo script principale [Canny.m](./Canny.m) richiama le sette funzioni secondarie nel seguente ordine:

| Ordine | Procedura secondaria | Ruolo |
| --- | --- | --- |
| 1 | [`converti_in_scala_di_grigi`](./Funzioni_Secondarie/converti_in_scala_di_grigi.m) | Convertire, se necessario, l'immagine in scala di grigi |
| 2 | [`smoothing_gaussiano`](./Funzioni_Secondarie/smoothing_gaussiano.m) | Attenuare il rumore mediante un filtro gaussiano. |
| 3 | [`calcola_grad_e_angolo`](./Funzioni_Secondarie/calcola_grad_e_angolo.m) | Stimare la norma del gradiente e quantizzarne la direzione. |
| 4 | [`individua_candidati_massimi`](./Funzioni_Secondarie/individua_candidati_massimi.m) | Selezionare i pixel che abbiano gradiente in norma maggiore dei pixel ad esso adiacenti lungo la direzione data dall'angolo. |
| 5 | [`calcola_soglie`](./Funzioni_Secondarie/calcola_soglie.m) | Determinare due variabili soglia: soglia alta e soglia bassa. |
| 6 | [`individua_bordi_deboli_e_forti`](./Funzioni_Secondarie/individua_bordi_deboli_e_forti.m) | Distinguere bordi forti, bordi deboli e pixel da scartare. |
| 7 | [`gestisci_bordi_deboli`](./Funzioni_Secondarie/gestisci_bordi_deboli.m) | Promuovere i bordi deboli connessi ai bordi forti. |

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

Segue un confronto tra prima e dopo la conversione in scala di grigi:  

<p align="center">
  <img src="Immagini_Testing/Fig_01.jpg" alt="Immagine originale a colori" width="49%">
  <img src="Immagini_per_README/Fig_01_scala_di_grigi.png" alt="Immagine convertita in scala di grigi" width="49%">
</p>


## Riduzione del rumore mediante filtro gaussiano

La funzione [smoothing_gaussiano](./Funzioni_Secondarie/smoothing_gaussiano.m) attenua le variazioni locali più rapide dell'immagine prima che vengano calcolate le derivate.

Questa fase è necessaria perché le operazioni di derivazione sono sensibili al rumore: una piccola irregolarità tra pixel vicini può produrre un gradiente elevato ed essere interpretata come un bordo. Il filtraggio sostituisce quindi l'intensità di ciascun pixel con una media pesata delle intensità dei pixel circostanti, i
pesi sono dati dalla funzione densità della distribuzione gaussiana.

Il modello di riferimento è la funzione gaussiana bidimensionale:

$$
f_{\sigma}(x,y) = \frac{1}{2\pi\sigma^2}
\exp\left(-\frac{x^2+y^2}{2\sigma^2}\right)
$$

Il filtro gaussiano viene applicato mediante convoluzione dell’immagine in scala di grigi con una maschera $5 \times 5$. I valori della maschera si 
ottengono campionando la funzione gaussiana e normalizzando i pesi affinché la loro somma sia uguale a 1.

Il parametro $\sigma$ regola la distribuzione dei pesi. Valori piccoli concentrano maggiormente il peso vicino al pixel centrale; aumentando $\sigma$, i 
pixel circostanti acquistano maggiore importanza e l'effetto di sfocatura diventa più marcato, con una possibile perdita dei dettagli più fini.  
La variabile `sigma` è uno dei tre parametri modificabili che determinano la distribuzione ed il numero di pixel classificati "di bordo" nella matrice finale.  
Valori tipici di `sigma` comunque vanno da 0.1 ad 2, anche se comunque dipende fortemente dalla scena rappresentata nell'immagine e da quanti dettagli nei 
bordi si desidera ottenere.

Come dettaglio implementativo si segnala che la matrice originale viene espansa di una cornice di contorno dallo spessore di 2 pixel per permettere la convoluzione anche sui pixel nella cornice della foto originaria. La tecnica è quella del *padding* ed i pixel nuovi avranno la stessa intensità del pixel originario ad esso adiacente.  
Segue un confronto tra prima e dopo l'applicazione della sfumatura (blur) gaussiana all'immagine in scala di grigi:  

<p align="center">
  <img src="Immagini_per_README/Fig_01_scala_di_grigi.png" alt="Immagine in scala di grigi" width="49%">
  <img src="Immagini_per_README/Fig_01_blur_gaussiano.png" alt="Immagine dopo il filtraggio gaussiano" width="49%">
</p>
<br>


Segue anche un confronto, su un'immagine diversa rappresentante ora il Duomo di Milano, della differenza dell'immagine finale per due distinti 
valori di `sigma`. Il Duomo di Milano, con tutti i suoi dettagli architettonici gotici è perfetto per questo confronto, dal momento che più `sigma` è 
basso più dettagli sono conservati. L'immagine originale è la seguente:  

<p align="center">
  <img src="Immagini_Testing/Fig_03.jpg" alt="Duomo di Milano: immagine originale" width="49%">
</p>

Sotto seguono due diverse immagini con i bordi estrapolati. L'immagine di sinistra è prodotta con `sigma = 9`, quella di destra con `sigma=0.15`. 

<p align="center">
  <img src="Immagini_per_README/Fig_03_sigma_9.png" alt="Bordi del Duomo con sigma = 9" width="49%">
  <img src="Immagini_per_README/Fig_03_sigma_0_15.png" alt="Bordi del Duomo con sigma = 0.15" width="49%">
</p>

Si osservi che in generale non è detto che più `sigma` è piccolo, meglio è, dal momento che un valore di `sigma` troppo piccolo coinciderebbe con l'applicare
una sfumatura gaussiana di bassissima intensità, ed il pericolo è poi quello che l'algoritmo di Canny classifichi come bordo leggere sfumature di colore che
in realtà bordi non sono.


## Calcolo della norma e della direzione del gradiente

La funzione [calcola_grad_e_angolo](./Funzioni_Secondarie/calcola_grad_e_angolo.m) utilizza l'immagine filtrata per stimare, in ogni pixel, il gradiente
dell'intensità dell'immagine e l'angolo di tale vettore gradiente. L'obiettivo è stimare intensità e direzione della variazione del colore in scala di grigi.  
Detta $I = I(i,j)$ la matrice descrivente l'immagine (con blur gaussiano), per ogni pixel bisognerà quindi stimare:

$$
\nabla I(i,j) = \begin{pmatrix}
\frac{\partial I}{\partial x}(i,j), \hspace{0.1cm}
\frac{\partial I}{\partial y}(i,j)
\end{pmatrix}.
$$

e per calcolare le derivate si possono usare differenze finite per la derivata prima al secondo ordine di accuratezza:

$$
\frac{\partial I}{\partial x}(i,j) \approx \frac{ I(i,j+1) - I(i,j-1) }{2}
$$

in realtà, si coinvolgono nel calcolo gli altri pixel dell'intorno $3 \times 3$, al fine di rendere il metodo più robusto, e così, 
per stimare $\frac{\partial I}{\partial x}(i,j)$ si usano anche le righe sopra e sotto, andando a computare poi una media pesata dove la riga del 
pixel in questione pesa $2$ e le righe sovrastanti e sottostanti pesano $1$, si ottiene dunque che:

$$
4 \cdot \frac{\partial I}{\partial x}(i,j) \approx \frac{\partial I}{\partial x}(i-1,j) + 2 \cdot \frac{\partial I}{\partial x}(i,j) + 
  \frac{\partial I}{\partial x}(i+1,j)
$$

e di conseguenza, a meno di un fattore moltiplicativo, per stimare la derivata in $\partial x$ di tutti i pixel di $I$ è sufficiente eseguire una convoluzione 
della matrice $I$ con una maschera $K_x$ detta filtro di Sobel, dove la maschera in questione vale:

$$
K_x =
\begin{pmatrix}
-1 & 0 & 1 \\
-2 & 0 & 2 \\
-1 & 0 & 1
\end{pmatrix}
$$

Discorso analogo vale per la stima di $\hspace{0.1cm} \frac{\partial I}{\partial y} \hspace{0.1cm}$  dove si userà un filtro di Sobel con maschera:

$$
K_y =
\begin{pmatrix}
1 & 2 & 1 \\
0 & 0 & 0 \\
-1 & -2 & -1
\end{pmatrix}
$$

Note le componenti $x$ ed $y$ del vettore gradiente, è possibile stimare la norma del gradiente con il teorema di Pitagora 
ed è possibile stimare l'angolo $\theta$ del gradiente con la funzione arcotangente, più precisamente tramite la funzione `atan2`, che a differenza 
dell'arcotangente classico ha immagine in $[- \pi, \pi]$, anziché in $\left(-\frac{\pi}{2},\frac{\pi}{2} \right)$, ed implementa nativamente la divisione per 
zero, oltre che la gestione dell'edge-case dell'angolo del vettore nullo.  
Noto $\theta \in [- \pi, \pi]$ lo si approssima ad uno dei $4$ valori: $\\{0^\circ, 45^\circ, 90^\circ, 135^\circ \\}$, in base 
a questo valore si ragionerà in seguito in orizzontale, in verticale, oppure su una delle due diagonali nell'intorno $3 \times 3$ del pixel in esame.

L'output di questa funzione sono le due matrici `Norm_Grad` e `angolo`, entrambe della stessa dimensione $R \times C$ della matrice $I$, contenenti la
prima la norma dei gradienti di ogni pixel e la seconda l'angolo (già quantizzato) del gradiente di ogni pixel. 


## Individuazione dei candidati mediante soppressione dei non massimi

La funzione [individua_candidati_massimi](./Funzioni_Secondarie/individua_candidati_massimi.m) seleziona i pixel che costituiscono massimi locali della norma 
del gradiente lungo la direzione del gradiente stesso. Questa operazione viene detta *non-maximum suppression*, ovverosia soppressione dei non massimi. I 
pixel selezionati saranno i candidati punti di bordo, da cui poi si estrarrà (nelle procedure successive) il sottoinsieme degli effettivi pixel di bordo.
Per ogni pixel $(i,j)$, si accederà innanzi tutto alla direzione contenuta in $\theta(i,j)$, e nota tale direzione si confronterà, nell'intorno $3 \times 3$ 
la norma del gradiente del pixel in esame con quella dei suoi pixel adiacenti lungo la direzione indicata da $\theta(i,j)$, in particolare:  
- pixel sinistro e destro se $\theta(i,j) = 0^ \circ$,
- pixel sopra e sotto se $\theta(i,j) = 90^ \circ$,  
- pixel sulla diagonale da in basso a sinistra ad in alto a destra (antidiagonale) se $\theta(i,j) = 45^\circ$,
- pixel sulla diagonale da in basso a destra ad in alto a sinistra (diagonale principale) se $\theta(i,j) = 135^\circ$.  

Se il pixel ha gradiente in norma strettamente maggiore di uno dei suoi vicini e maggiore o uguale alla norma dell'altro, allora lo si considera un candidato 
punto di bordo. Si evita invece di considerare bordo il caso in cui un pixel abbia gradiente in norma strettamente uguale ad entrambi i suoi pixel adiacenti.  

L'output di questa funzione sarà la matrice `I_bordi` a valori nell'insieme binario $\\{0,255 \\}$ dove un pixel viene messo a $0$ se non è un candidato 
bordo e viene invece messo a $255$ se è un candidato bordo. 


## Calcolo della soglia alta e della soglia bassa

La funzione [calcola_soglie](./Funzioni_Secondarie/calcola_soglie.m) determina i due valori che saranno utilizzati per classificare i candidati.
Una sola soglia imporrebbe una scelta piuttosto rigida: una soglia alta eliminerebbe anche i tratti meno evidenti dei contorni, mentre una soglia bassa 
conserverebbe molte variazioni poco significative. La doppia soglia permette invece di separare i pixel considerati abbastanza marcati da essere conservati 
direttamente da quelli per i quali sarà necessario valutare anche la connessione con gli altri bordi.
La funzione dipende da due parametri regolabili `coeff_1` e `coeff_2`, il cui valore viene utilizzato per computare i valori delle soglie. Posto:  

$$
M := \max_{(i,j)} \left( Norm \textunderscore Grad(i,j) \right);
$$

allora avremo:

$$
\begin{align*}
& T \textunderscore {alta} = coeff \textunderscore 1 * M \\
& T \textunderscore {bassa} =coeff \textunderscore 2 * T \textunderscore  alta
\end{align*}
$$

Valori tipici di `coeff_1` e `coeff_2` sono ad esempio:

$$
coeff \textunderscore 1 = \frac{20}{100} \hspace{2cm} coeff \textunderscore 2 = \frac{1}{5}
$$

anche se non c'è una regola precisa e la scelta di quali valori assegnare alle variabili `coeff_1` e `coeff_2` dipende molto
dalla scena rappresentata nell'immagine.  
Più `coeff_1` è alto, più l'algoritmo diventa selettivo nel giudicare un pixel come punto di bordo forte, e dunque più `coeff_1` è alto, meno bordi ci saranno.  
D'altro canto, più `coeff_2` è alto, più l'algoritmo diventa selettivo nel giudicare un pixel come punto di bordo debole, e dunque, più `coeff_2` è alto, 
meno pixel saranno promossi a bordo per il merito di essere contigui a pixel già di bordo.  
L'output della funzione sono le due soglie `T_alta` e `T_bassa`.  

## Classificazione dei bordi deboli e forti

La funzione [individua_bordi_deboli_e_forti](./Funzioni_Secondarie/individua_bordi_deboli_e_forti.m) utilizza le due soglie precedentemente calcolate
per classificare i candidati punti di bordo come *bordi forti*, *bordi deboli*, oppure come punti non di bordo.  
In particolare la funzione scorre tutta la matrice binaria `I_bordi` e quando trova un pixel candidato bordo applica il seguente costrutto if-else:
- se `Norm_Grad(i,j)` $\geq$ `T_alta` $\Rightarrow$ $(i,j)$ è un punto di bordo forte
- se `T_bassa` $\leq$ `Norm_Grad(i,j)` $<$ `T_alta` $\Rightarrow$ $(i,j)$ è un punto di bordo debole
- se `Norm_Grad(i,j)` $<$ `T_bassa` $\Rightarrow$ $(i,j)$ non è un punto di bordo

La funzione restituisce due output. Uno di questi è un vettore contenente le coordinate dei bordi forti, implementato come matrice $N \times 2$ dove N è 
il numero di bordi forti e ciascuna delle due colonne della matrice contiene una delle due coordinate del pixel in questione.  
L'altro output è la matrice `I_bordi` (che viene sovrascritta alla precedente) che ora è una matrice a valori nell'insieme ternario $\\{0, 100, 255 \\}$, dove
un pixel vale 0 se non è di bordo, 255 se è un pixel di bordo forte, e vale 100 se è un pixel di bordo debole.  
Il valore 100 è un valore "fittizio" e qualsiasi altro numero compreso tra 1 e 254 andava bene ugualmente, tuttavia, scegliendo un valore 
abbastanza intermedio tra 0 e 255 è possibile rappresentare dove si trovano i bordi deboli e quelli forti all'interno dell'immagine.  
Seguono due immagini, sulla sinistra l'immagine con in evidenza i bordi forti (in bianco acceso) e quelli deboli (in grigio chiaro), sulla destra l'immagine 
definitiva ottenuta dopo aver deciso quali bordi deboli promuovere a bordo forte e quali invece scartare.  

<p align="center">
  <img src="Immagini_per_README/Fig_01_bordi_deboli.png" alt="Bordi deboli in grigio e bordi forti in bianco, prima dell’isteresi" width="49%">
  <img src="Immagini_Testing_Bordi/Fig_01_bordi.png" alt="Bordi finali dopo l’isteresi" width="49%">
</p>


## Gestione dei bordi deboli mediante isteresi

La funzione [gestisci_bordi_deboli](./Funzioni_Secondarie/gestisci_bordi_deboli.m) ha il compito di decidere quali pixel di bordo debole promuovere a 
pixel di bordo e quali pixel di bordo debole scartare.  
L'idea chiave è la seguente: si fa scorrere il vettore dei bordi forti, se un bordo forte è connesso (nel suo intorno $3 \times 3$) ad un bordo debole, 
allora il bordo debole viene promosso a bordo forte, ed inserito nel vettore dei bordi forti. Quando si è fatto passare tutto il vettore dei bordi forti, i 
rimanenti bordi deboli non connessi a bordi forti vengono declassati a pixel non di bordo.  
Di fatto, la tecnica algoritmica utilizzata è quella di una visita in ampiezza (Breadth First Search) con più sorgenti, avviata contemporaneamente da 
tutti i bordi forti. Qui il vettore dei bordi forti gioca il ruolo di coda (implementata tramite vettore e due indici posizione).  
Al termine di questa funzione, la matrice `I_bordi` restituita sarà una matrice a valori nell'insieme binario $$ \\{ 0, 255 \\} $$ e sarà la matrice 
dei bordi definitiva, se un pixel vale 255 è un bordo, in caso contrario non lo è.


## Testing su varie immagini

Segue una raccolta di immagini in cui viene confrontata l'immagine originale con il bordo da essa estrapolato. Per altre immagini si confronti la cartella 
[Immagini_Testing_Bordi](./Immagini_Testing_Bordi/) e si legga il file [INSERIRE IL LINK]

<br>
<br>
<p align="center">
  <img src="Immagini_Testing/Fig_02.jpg" alt="Figura 02: immagine originale" width="49%">
  <img src="Immagini_Testing_Bordi/Fig_02_bordi.png" alt="Figura 02: bordi individuati mediante Canny" width="49%">
</p>
<br>
<br>

<p align="center">
  <img src="Immagini_Testing/Fig_04.jpg" alt="Figura 04: immagine originale" width="49%">
  <img src="Immagini_Testing_Bordi/Fig_04_bordi.png" alt="Figura 04: bordi individuati mediante Canny" width="49%">
</p>
<br>
<br>

<p align="center">
  <img src="Immagini_Testing/Fig_05.jpg" alt="Figura 05: immagine originale" width="49%">
  <img src="Immagini_Testing_Bordi/Fig_05_bordi.png" alt="Figura 05: bordi individuati mediante Canny" width="49%">
</p>
<br>
<br>

<p align="center">
  <img src="Immagini_Testing/Fig_08.jpg" alt="Figura 08: immagine originale" width="49%">
  <img src="Immagini_Testing_Bordi/Fig_08_bordi.png" alt="Figura 08: bordi individuati mediante Canny" width="49%">
</p>
<br>
<br>

<p align="center">
  <img src="Immagini_Testing/Fig_10.jpg" alt="Figura 10: immagine originale" width="49%">
  <img src="Immagini_Testing_Bordi/Fig_10_bordi.png" alt="Figura 10: bordi individuati mediante Canny" width="49%">
</p>
<br>
<br>

<p align="center">
  <img src="Immagini_Testing/Fig_11.jpg" alt="Figura 11: immagine originale" width="49%">
  <img src="Immagini_Testing_Bordi/Fig_11_bordi.png" alt="Figura 11: bordi individuati mediante Canny" width="49%">
</p>
<br>
<br>

<p align="center">
  <img src="Immagini_Testing/Fig_13.jpg" alt="Figura 13: immagine originale" width="49%">
  <img src="Immagini_Testing_Bordi/Fig_13_bordi.png" alt="Figura 13: bordi individuati mediante Canny" width="49%">
</p>
<br>
<br>


## Crediti Fotografici

Nella cartella [Immagini_Testing](./Immagini_Testing/) sono presenti alcune immagini utilizzate per testare l'algoritmo di Canny e nella cartella 
[Immagini_Testing_Bordi](./Immagini_Testing_Bordi/) sono presenti le rispettive immagini con i bordi estrapolati.  
Le fotografie utilizzate per il testing provengono da [Unsplash](https://unsplash.com) e sono messe a disposizione gratuitamente secondo i termini della [licenza Unsplash](https://unsplash.com/license).

Ringrazio gli autori per aver condiviso le proprie fotografie, che hanno permesso di sperimentare l’algoritmo su soggetti e contesti differenti. Nella tabella seguente sono riportati gli autori e i collegamenti alle fotografie originali.

<details>
<summary>Mostra gli autori e le fotografie originali</summary>

| Immagine | Autore | Fotografia originale |
| --- | --- | --- |
| `Fig_01.jpg` | Pedro Lastra | [Unsplash](https://unsplash.com/photos/Nyvq2juw4_o) |
| `Fig_02.jpg` | Boris Smokrovic | [Unsplash](https://unsplash.com/photos/DPXytK8Z59Y) |
| `Fig_03.jpg` | Lea V | [Unsplash](https://unsplash.com/photos/z2IED5kTd-8) |
| `Fig_04.jpg` | Nick Fewings | [Unsplash](https://unsplash.com/photos/aHr40GPT3MI) |
| `Fig_05.jpg` | Marcin Nowak | [Unsplash](https://unsplash.com/photos/iXqTqC-f6jI) |
| `Fig_06.jpg` | Christina Terzidou | [Unsplash](https://unsplash.com/photos/wBxl3rSwutM) |
| `Fig_07.jpg` | dlxmedia.hu | [Unsplash](https://unsplash.com/photos/52AgXRhDaPI) |
| `Fig_08.jpg` | Matteo del Piano | [Unsplash](https://unsplash.com/photos/7Y015gklIDg) |
| `Fig_09.jpg` | Uriel Soberanes | [Unsplash](https://unsplash.com/photos/xadzcCQZ_Xc) |
| `Fig_10.jpg` | Wexor Tmg | [Unsplash](https://unsplash.com/photos/L-2p8fapOA8) |
| `Fig_11.jpg` | Stefan C. Asafti | [Unsplash](https://unsplash.com/photos/nW02kL8o-tY) |
| `Fig_12.jpg` | Timo Volz | [Unsplash](https://unsplash.com/photos/ZlFKIG6dApg) |
| `Fig_13.jpg` | Nick Karvounis | [Unsplash](https://unsplash.com/photos/Ciqxn7FE4vE) |
| `Fig_14.jpg` | Eiliv Aceron | [Unsplash](https://unsplash.com/photos/ZuIDLSz3XLg) |

</details>

