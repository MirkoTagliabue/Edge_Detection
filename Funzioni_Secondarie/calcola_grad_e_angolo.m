
% se I è una matrice RxC, questa funzione restituisce Norm_Grad che è una
% matrice RxC contente le norme dei gradienti dei singoli pixel, e
% restituisce anche la matrice angolo di dimensione RxC che contiene
% l'angolo del gradiente del singolo pixel.

% L'idea è di calcolare (\partial I / \partial x)(i,j) = I(i,j+1) - I(i,j-1)
% con tecniche alle differenze finite, coinvolgendo però anche i vicini 
% nel seguente modo. 
% Il risultato totale di (\partial I / \partial x)(x,y) sarà una 
% media pesata di:
% - derivata in \partial x della riga sopra (cioè i-1), con peso 1
% - derivata in \partial x della riga esatta (cioè i), con peso 2
% - derivata in \partial x della riga sotto (cioè i+1), con peso 1
% e ciò è in realtà equivalente a fare una convoluzione con filtro l
% kernel_x di Sobel (visto che comunque gira e rigira è una somma di 9
% termini).

% Stessa cosa poi per (\partial I / \partial y)(i,j).

% I risultati di queste due convoluzioni li salvo in due matrici Derivate_x
% ed Derivate_y dove Derivate_x(i,j) mi da la derivata partziale di I nel
% punto (i,j) con tecniche alle differenze finite (come descritto sopra).

% La matrice Norm_Grad la calcolo con il teorema di Pitagora conoscendo a
% questo punto le componenti del vettore.

% l'angolo lo calcolo con la funzione atan2 che a differenza
% dell'arcotangente classico (il quale ha immagine in (-pi/2, pi/2)) ha 
% output in [-pi, pi].
% Oss: l'unico vantaggio di usare atan2 è in realtà che la funzione atan2
% implementa nativamente un controllo sulla divisione per zero ed il caso
% x=y=0

% Infine, l'angolo misurato sarà approssimato ad uno solo dei 4 angoli:
%   {0°, 45°, 90°, 135°}     
% che individuano le 4 uniche possibili direzioni nell'ottetto-intorno 


%%


function [Norm_Grad, angolo] = calcola_grad_e_angolo(I)


    % Kernel X di sobel:
    K_x = [ -1,0,1; -2,0,2; -1,0,1 ];

    % Kernel Y di sobel:
    K_y = [ 1,2,1 ; 0,0,0 ; -1,-2,-1 ];

    % Determino il numero di righe e colonne della matrice I:
    [R,C] = size(I);

    % Inizializzo le matrici soluzione:
    Norm_Grad = zeros(R,C);
    angolo = zeros(R,C);


    % Eseguo un padding: allargo la matrice I di una riga e 1 colonna di
    % cornice per poter fare una convoluzione precisa anche sul bordo
    % dell'immagine I, a questi pixel assegno l'esatto valore che avevano
    % sul bordo.
    I_pad  = zeros(R+2, C+2);

    I_pad( 2:R+1, 2:C+1) = I;

    I_pad( 1, 2:C+1 ) = I(1,:);
    I_pad( R+2, 2:C+1 ) = I(R,:);
    I_pad( 2:R+1, 1 ) = I(:,1);
    I_pad( 2:R+1, C+2 ) = I(:,C);

    I_pad(1,1)=I(1,1); I_pad(1,C+2)=I(1,C); I_pad(R+2,1)=I(R,1); I_pad(R+2,C+2)=I(R,C);

    Derivate_x = zeros(R,C);
    Derivate_y = zeros(R,C);



    for i = 1 : R
        for j = 1 : C

            % Estraggo la sotto-matrice A di I_pad di dimensione 3x3 centrata in (i,j)
            % NB: c'è una doverosa traslazione di coordinate tra I_pad ed I
            i_pad = i+1;  
            j_pad = j+1;

            A = I_pad(  i_pad-1 : i_pad+1  ,  j_pad-1 : j_pad+1 ) ; 

            Derivate_x(i,j) = sum( sum(K_x .* A) );
            Derivate_y(i,j) = sum( sum(K_y .* A) );

            % Note le componenti del gradiente, mi calcolo la norma del gradiente
            % con Pitagora:
            Norm_Grad(i,j) = sqrt( Derivate_x(i,j)^2 + Derivate_y(i,j)^2 );

            % Calcolo poi l'angolo:
            angolo(i,j) = atan2( Derivate_y(i,j), Derivate_x(i,j) );


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Approssimo infine l'angolo ad uno dei 4 valori {0°, 45°, 90°, 135°}
            % In realtà:  { 0, pi/4, pi/2, 3*pi/4 }

            if -pi <= angolo(i,j) && angolo(i,j) < -7*pi/8 
                angolo(i,j) = 0;
            end
            

            if -7*pi/8 <= angolo(i,j) && angolo(i,j) <= -5*pi/8 
                angolo(i,j) = pi/4;
            end
            

            if -5*pi/8 < angolo(i,j) && angolo(i,j) < -3*pi/8 
                angolo(i,j) = pi/2;
            end


            if -3*pi/8 <= angolo(i,j) && angolo(i,j) <= -pi/8 
                angolo(i,j) = 3*pi/4;
            end


            if -pi/8 < angolo(i,j) && angolo(i,j) < pi/8 
                angolo(i,j) = 0;
            end


            if pi/8 <= angolo(i,j) && angolo(i,j) <= 3*pi/8 
                angolo(i,j) = pi/4;
            end


            if 3*pi/8 < angolo(i,j) && angolo(i,j) < 5*pi/8 
                angolo(i,j) = pi/2;
            end


            if 5*pi/8 <= angolo(i,j) && angolo(i,j) <= 7*pi/8 
                angolo(i,j) = 3*pi/4;
            end


            if 7*pi/8 < angolo(i,j) && angolo(i,j) <= pi 
                angolo(i,j) = 0;
            end

            
            % chiudo il ciclo:

        end  % end for j
    end  % end for i


return   % end function

