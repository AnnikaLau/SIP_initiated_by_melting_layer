function unc = get_uncertainty_ice(a,V)
    lar = find(a>100e-6);
    sma = find(a<=100e-6);
    conc_lar = length(lar)/V;
    conc_sma = length(sma)/V;
    unc = conc_lar*0.05 + conc_sma*0.15 + sqrt(length(a))/V;
end