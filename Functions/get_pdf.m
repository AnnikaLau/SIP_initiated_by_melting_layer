%Probabilty of fragmentation

function pdf = get_pdf(d)
apdf = 4.4e6;
pdf = apdf*(d.^2);
end