

function I_smooth = smoothing_gaussiano(I,sigma)

    % Creo delle matrici 5x5 per il filtro gaussiano:
    X = [-2:2; -2:2; -2:2; -2:2; -2:2];
    Y = [-2*ones(1,5); -1*ones(1,5); zeros(1,5); ones(1,5); 2*ones(1,5)];

    % Creo la matrice filtro:
    H=zeros(5,5);
    H = exp( -(X.^2 + Y.^2) ./ (2*sigma^2) );

    % Normalizzo H dividendola per la somma di tutti i suoi elementi:
    H = H / sum( H(:) );

    % Determino il numero di righe e colonne della matrice I:
    [R,C] = size(I);

    % Eseguo un padding: allargo la matrice I di due righe e 2 colonne di
    % cornice per poter fare una convoluzione precisa anche sul bordo
    % dell'immagine I, a questi pixel assegno l'esatto valore che avevano
    % sul bordo.
    I_pad  = zeros(R+4, C+4);

    I_pad( 3:R+2, 3:C+2) = I;

    I_pad(2 , 3:C+2) = I(1,:);
    I_pad(1 , 3:C+2) = I(1,:);

    I_pad(R+3 , 3:C+2) = I(R,:);
    I_pad(R+4 , 3:C+2) = I(R,:);

    I_pad(3:R+2 , 2) = I(:,1);
    I_pad(3:R+2 , 1) = I(:,1);

    I_pad(3:R+2 , C+3) = I(:,C);
    I_pad(3:R+2 , C+4) = I(:,C);

    I_pad(1,1)=I(1,1); I_pad(1,2)=I(1,1); I_pad(2,1)=I(1,1); I_pad(2,2)=I(1,1);
    I_pad(1,C+3)=I(1,C); I_pad(1,C+4)=I(1,C); I_pad(2,C+3)=I(1,C); I_pad(2,C+4)=I(1,C);
    I_pad(R+3,1)=I(R,1); I_pad(R+3,2)=I(R,1); I_pad(R+4,1)=I(R,1); I_pad(R+4,2)=I(R,1);
    I_pad(R+3,C+3)=I(R,C); I_pad(R+3,C+4)=I(R,C); I_pad(R+4,C+3)=I(R,C); I_pad(R+4,C+4)=I(R,C);



    % inizializzo la matrice output:
    I_smooth = zeros(R, C);


    % Faccio una convuluzione del filtro H con la matrice I:
    for i = 1 : R
        for j = 1 : C

            % Estraggo la sotto-matrice A di I_pad di dimensione 5x5 centrata in (i,j)
            % NB: c'è una doverosa traslazione di coordinate tra I_pad ed I
            i_pad = i+2;  
            j_pad = j+2;

            A = I_pad(  i_pad-2 : i_pad+2  ,  j_pad-2 : j_pad+2 ) ; 

            I_smooth(i,j) = sum( sum(H .* A) );
            
        end
    end


return

