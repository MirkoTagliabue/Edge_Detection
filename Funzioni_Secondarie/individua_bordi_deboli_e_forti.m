

% Al termine di questa funzione la matrice I_bordi sarà una matrice avente
% solo i valori:
%    255 -> se il bordo è forte 
%    100 -> se il bordo è debole        // 100 è un valore 'fittizio' 
%    0 -> se il pixel non è un bordo 

% vett_bordi_forti sarà una matrice Nx2 contenente i bordi forti. La prima
% colonna della matrice contiene la prima coordinata dell'i-esimo bordo
% forte, mentre la seconda colonna contiene la seconda coordinata.


function [I_bordi, vett_bordi_forti] = individua_bordi_deboli_e_forti(Norm_Grad, I_bordi, T_alta, T_bassa)


    % Trovo il numero di Righe e di Colonne di Norm_Grad:
    [R,C] = size(Norm_Grad);

    % Onde evitare la riallocazione dinamica del vettore (lo inizializzo
    % subito al valore massimo di elementi che può contenere)
    vett_bordi_forti = zeros(R*C,2);  


    N = 0;  % contatore numero bordi forti




    for i = 1 : R
        for j = 1 : C

            if I_bordi(i,j) == 255    % se il pixel è un candidato bordo...
                

                %%%%%%%%%%%%%%%%

                % Se il pixel è un bordo forte:

                if Norm_Grad(i,j) >= T_alta  
                    
                    N = N+1;
                    vett_bordi_forti(N,1) = i;
                    vett_bordi_forti(N,2) = j;

                end   % end if bordo fore


                %%%%%%%%%%%%%%%%
                
                % se il pixel è un bordo debole:

                if T_bassa <= Norm_Grad(i,j) && Norm_Grad(i,j) < T_alta
                    I_bordi(i,j) = 100;
                end


                %%%%%%%%%%%%%%%%
                
                % Se il pixel non è un bordo forte o debole, lo sopprimo

                if Norm_Grad(i,j) < T_bassa
                    I_bordi(i,j) = 0;
                end


                %%%%%%%%%%%%%%%%


            end   % end if (pixel=bordo)


        end   % end for j
    end   % end for i


    % Infine estrapolo solo le prime N righe che realmente mi servono:
    vett_bordi_forti = vett_bordi_forti(1:N,:);


    %%%%%%%%%%%%%%%%

    % Se non c'è nessun bordo (esempio: immagine a tinta unica):
    if N == 0
       vett_bordi_forti = [ ];
    end



return  % end function

