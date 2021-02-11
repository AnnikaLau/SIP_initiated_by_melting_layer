function [azmth,speed] = uv2ddff(u,v)
for cnt = 1:length(u)
    speed(cnt) = sqrt(u(cnt)^2+v(cnt)^2);
    azmth(cnt) = 180+(180/pi)*atan2(u(cnt),v(cnt));
end
end