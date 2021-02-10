function v = get_fall_velocity(d,class)
v = zeros(length(d),1);

%Droplets smaller than 60mum
ws = contains(class,'Water') & d<60e-6;
%Droplets larger than 60mum
wl = contains(class,'Water') & d>=60e-6;

%Calculate the fall velocities of cloud droplets
%Rogers and Yan 1989 (book p. 203)
k1 = 1.2e8;
k2 = 8000;
v(ws) = (k1*(d(ws).^2))/4;
v(wl) = k2*d(wl)./2;

%Ice crystals considered as plates, Pruppacher and Klett, 2010.
p = contains(class,'Ice_Plate') | contains(class,'Ice_Unidentified');
v(p) = 156*d(p).^0.86;
%Ice crystals considered as lump graupel, Locatelli and Hobbs, 1974.
g = contains(class,'Ice_Aged') | contains(class,'Ice_Column') | contains(class,'Ice_Irregular');
v(g) = 124*d(g).^0.66;
end

