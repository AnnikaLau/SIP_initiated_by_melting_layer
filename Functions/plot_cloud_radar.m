% ncpath= 'Z:\3_Data\Davos2019\Cloudnet\processed\categorize\2019\'
% YMD = '20190222'
% [radar,height,model_height] = read_cloud_radar(ncpath,YMD);
% var = 'Z';
% startDate=datenum(2019,02,22,06,00,00);
% endDate=datenum(2019,02,22,12,00,00);

function plot_cloud_radar(radar,height,var,startDate,endDate)
%Fontsize:
fs = 20;
datax = radar.time;
datax(~isfinite(datax)) = nan;

datay = height;

dataz = radar.data.(var);
dataz(~isfinite(dataz)) = nan;

% mask for reflecitivy factor /
Z = radar.data.Z;
if strcmp(var,'lwp')
else
    dataz(Z<-65) = NaN;
end

if strcmp(var,'lwp')
    fig = figure;
    fig.Units = 'centimeters';
    fig.Position = [0 0 21 6.6];
    fig.PaperPositionMode = 'auto';
    
    pos = fig.Position;
    
    set(fig,'PaperPositionMode','Auto','PaperUnits','Centimeters','PaperSize',[pos(3), pos(4)])
    set(gca,'color','none');
    ax1 = gca; % current axes
    ax1.Position = [0.1 0.24 0.68 0.73];
else
    fig = figure;
    fig.Units = 'centimeters';
    fig.Position = [0 0 21 6.5];
    fig.PaperPositionMode = 'auto';
    
    pos = fig.Position;
    
    set(fig,'PaperPositionMode','Auto','PaperUnits','Centimeters','PaperSize',[pos(3), pos(4)])
    set(gca,'color','none');
    ax1 = gca; % current axes
    ax1.Position = [0.1 0.18 0.93 0.8];
end

if strcmp(var,'Z')
    p = pcolor(datax,datay*1e-3,dataz);
    p.EdgeColor = 'None';
    cbar = colorbar;
    caxis([-40 20]);
    cbar.Label.String = {'Reflectivity'; '(dBZ)'};
    cbar.Label.FontSize = 14;
    cmap = jet(20);
elseif strcmp(var,'v')
    dataz = dataz;
    p = pcolor(datax,datay,dataz);
    p.EdgeColor = 'None';
    cbar = colorbar;
    caxis([-2 2]);
    cbar.Label.String = {'Doppler velocity';'(ms^{-1})'};
    cbar.Label.FontSize = 14;
    cmap = flipud(brewermap(16,'RdBu'));
elseif strcmp(var,'width')
    p = pcolor(datax,datay,dataz);
    p.EdgeColor = 'None';
    cbar = colorbar;
    caxis([0 0.8]);
    cmap = jet(20);
    cbar.Label.String = {'Spectral width';'(ms^{-1})'};
    cbar.Label.FontSize = 14;
    xt_label = cbar.Ticks;
elseif strcmp(var,'ldr')
    p = pcolor(datax,datay,dataz);
    p.EdgeColor = 'None';
    cbar = colorbar;
    caxis([-30 -24]);
    cbar.Label.String = {'LDR';'(dB)'};
    cbar.Label.FontSize = 14;
    cmap = jet(20);
    xt_label = cbar.Ticks;
elseif strcmp(var,'beta')
    p = pcolor(datax,datay,log10(dataz));
    p.EdgeColor = 'None';
    cbar = colorbar;
    caxis([log10(10^(-7)) log10(10^(-4))]);
    turbo;
    cmap = jet(20);
    xt = cbar.Ticks;
    xt_label = cellstr(num2str(xt(:),'10^{%1.0f}') );
    set(cbar,'TickLabels',xt_label);
    cbar.Label.String = {'beta';'(sr^{-1}m^{-1})'};
    cbar.Label.FontSize = 14;
elseif strcmp(var,'lidar_depolarisation')
    p = pcolor(datax,datay,dataz);
    p.EdgeColor = 'None';
    cbar = colorbar;
    caxis([0 0.3]);
    cbar.Label.String = 'Lidar DR';
    cbar.Label.FontSize = 14;
    cmap = jet(20);
    xt_label = cbar.Ticks;
elseif strcmp(var,'lwp')
    c = [0 0.45 0.74];
    n = 3; % average every n values
    datax_mean = arrayfun(@(i) nanmean(datax(i:i+n-1)),1:n:length(datax)-n+1)'; % the averaged vector
    dataz_mean = arrayfun(@(i) nanmean(dataz(i:i+n-1)),1:n:length(dataz)-n+1)'; % the averaged vector
    bar(datax_mean,dataz_mean,'FaceColor',c,'EdgeColor','none');
elseif strcmp(var,'category_bits')
    p = pcolor(datax,datay,dataz);
    p.EdgeColor = 'None';
    cbar = colorbar;
    cbar.Label.String = 'Category bits';
    cbar.Label.FontSize = 14;
    c = NaN(48,3);
    c(2,:) = [255 0 0];
    c(3,:) = [0 0 255];
    c(4,:) = [NaN NaN NaN];
    c(5,:) = [0 191 255];
    c(6,:) = [255 255 0];
    c(7,:) = [50 205 50];
    c(10,:) = [255 165 0];
    c(11,:) = [32 178 170];
    c(16,:) = [NaN NaN NaN];
    c(32,:) = [169 169 169];
    c(48,:) = [128 128 128];
    
    c = c./255;
    c = [1 1 1;c];
    %c(any(isnan(c), 2), :) = [];
    cmap = c;
end

if strcmp(var,'lwp') == 1
else
    colormap(cmap);
    x1=get(gca,'position');
    x=get(cbar,'Position');
    x(3)=0.02;
    x(4) = 0.7;
    x(2) = 0.26;
    x(1) = 0.84;
    set(cbar,'Position',x)
    x1(3) = 0.6774;
    set(gca,'position',x1)
    if strcmp(var,'category_bits') == 0
        cbarrow;
    end
end

xlim([startDate endDate]);
set(gca,'XTick',xticks)
set(gca,'XTick',startDate:datenum(0,0,0,1,0,0):endDate);
set(gcf,'paperpositionmode','auto')
datetick('x','HH:MM','keeplimits','keepticks');
xlabel('Time (UTC)');
ylabel('Altitude (km)');
box on;
if strcmp(var,'lwp')
    ylim([0 200]);
    ylabel('LWP (g m^{-2})');
else
    ylim([1.6 7]);
    if strcmp(var,'lidar_depolarisation') || strcmp(var,'ldr') || strcmp(var,'width')
        cbar.Ticks = xt_label;
    end
end
set(gca,'Fontsize',fs);
xtickangle(45)

box on;
set(gca, 'Layer', 'top')

lw = 5;
KL = [1.2,1.2];
GB = [1.8,1.8];
GG = [2.3,2.3];
%Draw lines of temperature measurements
start_m = '20190222080000';
end_m = '20190222100000';
start_m = datenum(start_m,'yyyymmddHHMMSS');
end_m = datenum(end_m,'yyyymmddHHMMSS');
%Create lines for runs of Gotschnabahn
runs = [datenum(2019,02,22,08,07,17),datenum(2019,02,22,08,10,04);...
    datenum(2019,02,22,08,17,58),datenum(2019,02,22,08,20,16);...
    datenum(2019,02,22,08,29,00),datenum(2019,02,22,08,31,20);...
    datenum(2019,02,22,08,40,06),datenum(2019,02,22,08,42,27);...
    datenum(2019,02,22,08,51,20),datenum(2019,02,22,08,53,39);...
    datenum(2019,02,22,09,04,54),datenum(2019,02,22,09,07,10);...
    datenum(2019,02,22,09,16,04),datenum(2019,02,22,09,18,21);...
    datenum(2019,02,22,09,28,29),datenum(2019,02,22,09,30,51);...
    datenum(2019,02,22,09,45,55),datenum(2019,02,22,09,48,20)];
y_runs = zeros(size(runs));
y_runs(:,1) = 1.8;
y_runs(:,2) = 2.3;
hold on
gr = plot(runs',y_runs','Color',[0.7 0.7 0.7],'LineWidth',lw);
hold on
kl = plot([start_m end_m],KL,'Color',[0,0.5,0],'LineWidth',lw);
hold on
gb = plot([start_m end_m],GB,'Color',[0.9290, 0.6940, 0.1250],'LineWidth',lw);
hold on
gg = plot([start_m end_m],GG,'Color',[0, 0.4470, 0.7410],'LineWidth',lw);

end
