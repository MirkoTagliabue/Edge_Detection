
% Calcola le soglie T_alta e T_bassa.
% Oss: il risultato dipende fortemente da due parametri coeff_1 ed coeff_2

%%

function [T_alta, T_bassa] = calcola_soglie(Norm_Grad, coeff_1, coeff_2)

    % Calcolo il valore massimo in tutta la matrice Norm_Grad
    norm_grad_max = max( Norm_Grad(:) );

    T_alta = coeff_1 * norm_grad_max;

    T_bassa = coeff_2 * T_alta;

return


