
% Cerco nella matrice I i pixel che abbiano gradiente in norma maggiore 
% di entrambi i pixel ad esso adiacenti lungo la direzione data da angolo:
% - pixel destro e sinistro se theta=0°
% - pixel in alto e in basso se theta=90°
% - pixel lungo la diagonale con coeff. angol. m=1, se theta=45°
% - pixel lungo la diagonale con coeff. angol. m=-1, se theta=135°

% NB: onde evitare di implementare una moltitudine di condizioni al bordo
% per assicurarmi di non uscire dalla matrice e finire in segmentation
% fault (che rischierebbero inoltre di rallentare l'esecuzione del
% programma), allargo la cornice della matrice Norm_Grad di un pixel e 
% metto a zero i pixel al contorno nuovi. Questo non crea problemi
% nell'individuazione dei bordi poichè tutti gli elementi della matrice 
% hanno valori >= 0 

%%


function I_bordi = individua_candidati_massimi(Norm_Grad, angolo)

    % Trovo il numero di Righe e di Colonne di Norm_Grad:
    [R,C] = size(Norm_Grad);

    % Inizializzo la matrice dei bordi a valori in uint8
    I_bordi = uint8( zeros(R,C) );


    % Allargo la matrice Norm_Grad di una riga e 1 colonna di cornice per 
    % poter cercare il massimo senza implementare condizioni al contorno 
    % per assicurarmi di non sforare i bordi della matrice.
    
    % Creo una nuova riga sotto ed una nuova colonna a destra:
    Norm_Grad(R+1,:) = zeros(1,C);
    Norm_Grad(:,C+1) = zeros(R+1,1);

    % Traslo la matrice I in basso a destra:
    Norm_Grad(2:R+1,2:C+1) = Norm_Grad(1:R,1:C);

    % Aggiungo una nuova riga sotto e la metto ad 0:
    Norm_Grad(R+2,:) = zeros(1,C+1);

    % Aggiungo una nuova colonna a destra e la metto ad 0:
    Norm_Grad(:,C+2) = zeros(R+2,1);

    % Metto a 0 i valori della cornice sul bordo di sinistra
    Norm_Grad(:,1) = zeros(R+2,1);

    % Metto a 0 i valori della cornice sul bordo superiore
    Norm_Grad(1,:) = zeros(1,C+2);


    for i = 1 : R
        for j = 1 : C

            % NB: c'è una doverosa traslazione di coordinate tra Norm_Grad
            % ed I_bordo
            i_grad = i+1;  
            j_grad = j+1;

            % Avvio il confronto della norma del gradiente:
            
            switch angolo(i,j)

                %%%%%%%%%%%%%%%%

                case 0

                    if Norm_Grad(i_grad,j_grad) >= Norm_Grad(i_grad,j_grad-1) && ...
                            Norm_Grad(i_grad,j_grad) > Norm_Grad(i_grad,j_grad+1)
                        I_bordi(i,j) = 255;
                    end

                %%%%%%%%%%%%%%%%

                case pi/2

                    if Norm_Grad(i_grad,j_grad) >= Norm_Grad(i_grad-1,j_grad) && ...
                            Norm_Grad(i_grad,j_grad) > Norm_Grad(i_grad+1,j_grad)
                        I_bordi(i,j) = 255;
                    end

                %%%%%%%%%%%%%%%%

                case 3*pi/4

                    if Norm_Grad(i_grad,j_grad) >= Norm_Grad(i_grad-1,j_grad-1) && ...
                            Norm_Grad(i_grad,j_grad) > Norm_Grad(i_grad+1,j_grad+1)
                        I_bordi(i,j) = 255;
                    end

                %%%%%%%%%%%%%%%%

                case pi/4

                    if Norm_Grad(i_grad,j_grad) >= Norm_Grad(i_grad-1,j_grad+1) && ...
                            Norm_Grad(i_grad,j_grad) > Norm_Grad(i_grad+1,j_grad-1)
                        I_bordi(i,j) = 255;
                    end

                %%%%%%%%%%%%%%%%

                otherwise
                    error(['angolo(i,j) = %.3f \n angolo non riconosciuto e ' ...
                        'non catalogato'], angolo(i,j));


            end   % end switch-case


        end   % end for su j
    end   % end for su i



return

