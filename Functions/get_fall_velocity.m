function v = get_fall_velocity(temp1)
v = zeros(length(temp1.class),1);

%Find the equivalent particle area diameter
i = find(contains(temp1.metricnames,'pDiam')==1);
d = temp1.metricmat(:,i);
%Find the major axis size
i = find(contains(temp1.metricnames,'majsizRescale')==1);
L = temp1.metricmat(:,i);
%Droplets smaller than 60mum
ws = contains(temp1.cpType,'Water') & d<60e-6;
%Droplets larger than 60mum
wl = contains(temp1.cpType,'Water') & d>=60e-6;

%Calculate the fall velocities of cloud droplets
%Rogers and Yan 1989 (book p. 203)
k1 = 1.2e8;
k2 = 8000;
v(ws) = (k1*(d(ws).^2))/4;
v(wl) = k2*d(wl)./2;

%Ice crystals considered as plates
p = contains(temp1.cpType,'Ice_Plate') | contains(temp1.cpType,'Ice_Unidentified');
v(p) = 156*L(p).^0.86;
%Ice crystals considered as lump graupel
g = contains(temp1.cpType,'Ice_Aged') | contains(temp1.cpType,'Ice_Column') | contains(temp1.cpType,'Ice_Irregular');
v(g) = 124*L(g).^0.66;
end

