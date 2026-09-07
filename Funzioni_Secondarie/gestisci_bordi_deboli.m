
% Ciclo sui bordi forti, se un bordo debole è adiacente ad un bordo forte,
% allora viene promosso a bordo forte. Se un bordo debole viene promosso a
% bordo forte allora uso anche lui per individuare nuovi possibili bordi
% forti.

% Al termine dell'analisi di tutti i bordi forti, eseguo un doppio ciclo su
% tutta la matrice. I rimanenti vecchi bordi deboli verranno soppressi a
% pixel non di bordo.

% Si ricorda che i bordi deboli nella matrice I_bordi hanno valore 100


%%


function I_bordi = gestisci_bordi_deboli(I_bordi, vett_bordi_forti)

    % Individuo il numero iniziale di bordi forti
    [N,~] = size(vett_bordi_forti);

    % Trovo il numero di Righe e di Colonne di I_bordi:
    [R,C] = size(I_bordi);

    % Onde evitare riallocazione dinamica durante il ciclo, inizializzo il 
    % vettore con i bordi forti al numero massimo di elementi che può
    % ospitare. Al max avrà R*C elementi. Inizializzo a zero gli elementi
    % da N+1 ad R*C:
    vett_bordi_forti(N+1:R*C,:) = zeros(R*C-N,2);
    
    % inizializzo un contatore che uso per scorrere il vettore vett_bordi_forti
    k = 1;


    while k <= N

        % Estraggo le coordinate del bordo forte in questione
        i = vett_bordi_forti(k,1);
        j = vett_bordi_forti(k,2);


        % Se accanto a questo pixel c'è un bordo debole, lo promuovo a
        % bordo forte:

        % anzichè implementare 8 if-case, ragiono con un un doppio ciclo 
        % che passa tutti e 9 i pixel attorno ad (i,j) 

        for i_aux = i-1 : i+1
            for j_aux = j-1 : j+1
                

                % se il pixel che ho in mano è proprio (i,j) -> vai alla
                % prossima iterazione del ciclo
                if i_aux == i && j_aux ==j
                    continue;
                end


                % Se sto per commettere Segmentation Fault -> 
                % -> vai alla prossima iterazione
                if i_aux<=0 || i_aux>R || j_aux<=0 || j_aux>C
                    continue;
                end


                if I_bordi(i_aux,j_aux) == 100
                    I_bordi(i_aux,j_aux) = 255;
                    N=N+1;
                    vett_bordi_forti(N,1) = i_aux;
                    vett_bordi_forti(N,2) = j_aux;
                end


            end  % end for j_aux
        end  %end for i_aux


        % Dopo che ho finito di usare l'elemento k-esimo incremento k
        k = k + 1;


    end  % end while su k <= N


    %%
    % I restanti bordi deboli li sopprimo tutti:
    I_bordi(I_bordi == 100) = 0;



return

