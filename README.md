# L'algoritmo di Canny
Lo scopo di questo progetto è individuare i bordi presenti in un'immagine, ovverosia i contorni delle figure che sono rappresentate nell'immagine, mediante
implementazione dell'algoritmo di Canny.
L'idea chiave dell'algoritmo è quella di andare a confrontare la velocità di variazione del colore in pixels contigui, se c'è una variazione di colore molto
intensa in 3 pixel contigui, l'algoritmo di Canny catalogherà il pixel centrale come di bordo.  
L'algoritmo prende il nome da John Canny, autore dell'articolo *A Computational Approach to Edge Detection* pubblicato nel 1986. 
Nel presente progetto ne viene realizzata una versione con filtro gaussiano, operatori di Sobel, soppressione dei non massimi e doppia sogliatura con isteresi.  
I codici sono stati implementati in linguaggio MATLAB, tuttavia, essendo tutti gli algoritmi stati scritti from scratch (da zero) utilizzando unicamente la 
libreria standard di MATLAB, i codici risultano pienamente compatibili sia con le licenze base di MATLAB (senza la necessità di specifici toolbox a pagamento), 
sia con il software open-source GNU Octave.

[INSERIRE IMMAGINE ESEMPIO]

## La rappresentazione delle immagini e il formato di input

Un'immagine raster è individuata da una griglia rettangolare di pixel, ovverosia da una matrice di pixel. 
In seguito indicheremo con $R$ il numero delle righe e con $C$ il numero delle colonne, ed il numero totale di pixel dell'immagine sarà pertanto $R \cdot C$.  
Nelle immagini in scala di grigi ad 8 bit, ciascun pixel sarà un valore compreso tra 0 e 255 (ovverosia $2^8-1$), dove 0 indica il colore nero, 255 indica 
un bianco acceso, e tutti gli interi intermedi individuano una tonalità di grigio, più scuro quando il valore è vicino allo zero e più chiaro 
quando l'intero è vicino a 255.
Per le immagini a colori invece, ciascun pixel della matrice individua una terna di elementi, corrispondenti alla tonalità dei colori Red, Green ed Blue, 
motivo per cui queste immagini vengono dette in scala di colori RGB, dal momento che ciascun pixel avrà un colore dato dalla combinazione 
di questi tre colori. Segue pertanto che un'immagine in scala di grigi è individuata da una matrice di dimensione $R \times C$, mentre un'immagine a colori 
sarà un array (o tensore) di dimensione $R \times C \times 3$.  
L'immagine output con i bordi sarà invece un'immagine in bianco e nero, dove i pixel assumeranno solo i valori 0 oppure 255.  
Si osservi che nel caso di immagini RGB a valori in `uint8`, ciascun pixel non è rappresentato con 8 bit, bensì con 24, poiché serviranno 8 bit a 
determinare l'intensità di colore su ciascuno dei 3 canali.


