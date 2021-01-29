%Vt_plate = 296*d^0.824 Pinsky & Khain 1997
%Vt_droplet = k2*r; k2 = 8000/s, 40�m<r<600�m, Khvorostyanov and Curry 2002
% load('C:\melting_layer\Data\HoloGondel\droplets_ge_40e-6_cD')
% d = temp1.metricmat(:,114);
% load('C:\melting_layer\Data\HoloGondel\ice_habits_cD')
% a = temp1.metricmat(:,114);
% class = temp1.cpType;
% x = 40e-6:1e-7:400e-6;
% V = 43.7*1e-3; % Volume in m^3

function f_col = get_fcol(d,a,class,V)

V_d = get_fall_velocity(d,'Water');
V_i = get_fall_velocity(a,class);

%Calculate collision probability
f_col = zeros(length(d),1);
for i = 1:length(d)
    for j = 1:length(a)
        f_col(i) = f_col(i)+(abs(V_i(j)-V_d(i))*pi*(d(i)+a(j))^2)/4;
    end
    f_col(i) = f_col(i)/V;
end

end