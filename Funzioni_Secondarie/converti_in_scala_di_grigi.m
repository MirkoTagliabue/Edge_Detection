
% L'immagine prende in input una immagine I a valori in uint8 e ne
% restituisce una immagine in scala di grigi a valori in uint8. Se 
% l'immagine è già in scala di grigi, questa funzione non fa nulla.


%%


function I_convertita = converti_in_scala_di_grigi(I)


    % Se I è già in scala di grigi, non devo convertire nulla.
    if numel( size(I) ) == 2
        I_convertita = I;
    end



    if numel( size(I) ) == 3

        [R,C,Z] = size(I);      % oppure: [R,C,~] = size(I);
        I = double(I);
        I_convertita = zeros(R,C);

        for i=1:R
            for j=1:C
                I_convertita(i,j) = 0.2989*I(i,j,1) + 0.5870*I(i,j,2) + 0.1140*I(i,j,3);
            end
        end

        I_convertita = uint8(I_convertita); % casting

    end % end if 

% Scala Grigi = 0.2989*R + 0.5870*G + 0.1140*B;
% Il motivo per cui si usano proprio quei pesi nella combinazione lineare
% discende dalla fisica ottica e dal modo in cui l'occhio umano legge le
% frequenze di colore


return