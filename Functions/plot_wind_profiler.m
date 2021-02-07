function plot_wind_profiler(wind_path)
T = readtable(wind_path, 'HeaderLines',1);
wp.u = table2array(T(:,6));
wp.v = table2array(T(:,7));
t = table2array(T(:,1));
wp.t = zeros(size(wp.u));
for i = 1:length(t)
    wp.t(i) = datenum(num2str(t(i)),'yyyymmddHHMMSS');
end
wp.z = table2array(T(:,2));
wp.speed = table2array(T(:,4));
wp.dir = table2array(T(:,2));

start_str = ['20190222' '080000'];
end_str = ['20190222' '100000'];
start_dn = datenum(start_str,'yyyymmddHHMMSS');
end_dn = datenum(end_str,'yyyymmddHHMMSS');
speed_lims.min = 0;
speed_lims.max = 25;
y_max_high = 6;
y_max_low = 6;
y_min_low = 2;

%% plot WP
if ~isempty(wp)
    index =  wp.t>=start_dn & wp.t <= end_dn;
    
    wp_u = wp.u(index);
    wp_v = wp.v(index);
    wp_t = wp.t(index);
    wp_z = wp.z(index);
    wp_speed = wp.speed(index);
    wp_dir = wp.dir(index);
    
    xlim([start_dn end_dn])
    datetick
    caxis([speed_lims.min speed_lims.max])
    colormap jet;
    c=colorbar;
    ylabel(c,'Wind speed (m s^{-1})')
    ylim([ y_min_low y_max_low])
    xtickangle(45)
    width_barbs =1;
    
    windbarbs(wp_u,wp_v,wp_t,wp_z*1e-3,width_barbs,[],1.5,speed_lims);
    
    ylabel('Altitude (km)')
    set(gca,'Fontsize',14)
    xlabel('Time (UTC)')
    box on
    datetick('x','HH:MM','keeplimits')
    set(gcf,'paperpositionmode','auto')
    
end

end