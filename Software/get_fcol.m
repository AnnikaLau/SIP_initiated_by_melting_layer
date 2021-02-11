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