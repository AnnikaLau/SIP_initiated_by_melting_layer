function plot_cloud_radar(radar,height,startDate,endDate,runs)
%Fontsize:
fs = 20;
datax = radar.time;
datax(~isfinite(datax)) = nan;

datay = height;

dataz = radar.data.('Z');
dataz(~isfinite(dataz)) = nan;

% mask for reflecitivy factor /
Z = radar.data.Z;
dataz(Z<-65) = NaN;

fig = figure;
fig.Units = 'centimeters';
fig.Position = [0 0 21 6.5];
fig.PaperPositionMode = 'auto';

pos = fig.Position;

set(fig,'PaperPositionMode','Auto','PaperUnits','Centimeters','PaperSize',[pos(3), pos(4)])
set(gca,'color','none');
ax1 = gca; % current axes
ax1.Position = [0.1 0.18 0.93 0.8];


p = pcolor(datax,datay*1e-3,dataz);
p.EdgeColor = 'None';
cbar = colorbar;
caxis([-40 20]);
cbar.Label.String = {'Reflectivity'; '(dBZ)'};
cbar.Label.FontSize = 14;
cmap = jet(20);


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


xlim([startDate endDate]);
set(gca,'XTick',xticks)
set(gca,'XTick',startDate:datenum(0,0,0,1,0,0):endDate);
set(gcf,'paperpositionmode','auto')
datetick('x','HH:MM','keeplimits','keepticks');
xlabel('Time (UTC)');
ylabel('Altitude (km)');
box on;

ylim([1.6 7]);


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
