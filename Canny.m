

clearvars, close all;


addpath('Immagini_Testing');
addpath('Funzioni_Secondarie');

%%
% Definisco i parametri iniziali:
sigma = 1.0;  % Deviazione standard del filtro gaussiano
coeff_1 = 20/100;  % Percentuale del picco massimo di Norm_Grad come soglia_alta
coeff_2 = 1/5;  % Rapporto tra soglia_bassa e soglia_alta

%%

I = imread(fullfile('Immagini_Testing', 'Fig_03.jpg'));

% In ambiente MATLAB andava bene anche solo:
    % I = imread('Fig_01.jpg');
% L'instruzione sopra con comando "fullfile" serve unicamente in ambiente
% GNU Octave per la piena compatibilità con "addpath('Immagini_Testing')"

% In questo punto I può essere:
% 1) o una matrice MxN di elementi unsigned int ad 8 bit dove un elemento 
%    di I, diciamo I(i,j) è un intero da 0 a 255. E' il caso delle immagini
%    in scala di grigi.
% 2) un tensore MxNx3 di elementi di tipo uint8 dove l'elemento I(i,j,:) è 
%    un vettore di 3 elementi uint8 contenenti rispettivamente l'intensità 
%    di Red, l'intensità di Green e l'intensità di Blue. E' il caso delle 
%    immagini a colori in RGB.


% Tengo memorizzata l'immagine originaria 
I_orig = I;


%%
% Converto l'immagine in scala di grigi. Se l'immagine è già in scala di
% grigi, allora non succede nulla.
I = converti_in_scala_di_grigi(I);

% Trovo il numero di Righe e di Colonne di I:
[R,C] = size(I);

% Faccio una operazione di casting, da unsigned int a 8 bit a double:
I = double(I);  


%% 
% Faccio una convoluzione con un filtro gaussiano per ridurre il rumore
I = smoothing_gaussiano(I,sigma);


%%
% Calcolo gradiente e angolo di ogni pixel con tecniche alle differenze finite
[Norm_Grad, angolo] = calcola_grad_e_angolo(I);


%%
% Ora cerco i pixel candidati bordi:
% La matrice restituita sarà una matrice a valori uint8
I_bordi = individua_candidati_massimi(Norm_Grad, angolo);


%%
% Calcolo le soglie:
[T_alta, T_bassa] = calcola_soglie(Norm_Grad, coeff_1, coeff_2);


%%
% Determino i bordi deboli e forti:
[I_bordi, vett_bordi_forti] = individua_bordi_deboli_e_forti(Norm_Grad, I_bordi, T_alta, T_bassa);


%%
% Eseguo il back-tracking con isteresi:
I_bordi = gestisci_bordi_deboli(I_bordi, vett_bordi_forti);


%%
% stampo l'immagine originaria:
figure(1), image(I_orig), colormap(gray(256)), axis image; 
% Il comando axis fa si che l'immagine mantenga le sue proporzioni originali
% Il comando colormap(gray(256)) invece:
% - se l'immagine è in RGB (cioè a colori), e quindi di dimensione MxNx3,
%   allora il comando viene ignorato
% - se invece I è invece una matrice MxN, dice di stampare in scala di 
%   grigi, anzichè (ad esempio) in scala di gialli.



%%
% stampo i bordi:
figure(2), image(I_bordi), colormap(gray(256)), axis image; 

