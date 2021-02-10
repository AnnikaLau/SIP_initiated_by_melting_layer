function plot_ceilometer(cl31,start_str,end_str,runs)
%==========================================================================

%Fontsize
fs = 20;

if length(start_str)==8
    start_str=[start_str '000000'];
end
start_dn=datenum(start_str,'yyyymmddHHMMSS');

if length(end_str)==8
    end_str=[end_str '000000'];
end
end_dn=datenum(end_str,'yyyymmddHHMMSS');


disp(['Reading CL31 bulletin for ' start_str ' to ' end_str])


ceilo_str='KLA';

%Create lines for Klosters (1.2km, Gotschnaboden 1.8km, Gotschnagrat 2.3km)
start_m = '20190222080000';
end_m = '20190222100000';
start_m = datenum(start_m,'yyyymmddHHMMSS');
end_m = datenum(end_m,'yyyymmddHHMMSS');
KL = [1.2,1.2];
GB = [1.8,1.8];
GG = [2.3,2.3];

%Create lines for runs of Gotschnabahn
y_runs = zeros(size(runs));
y_runs(:,1) = 1.8;
y_runs(:,2) = 2.3;



%% remove values outside define time_zone & NaNs
if any(or(cl31.time<start_dn, cl31.time>end_dn))
    index=cl31.time<start_dn | cl31.time>end_dn | isnan(cl31.time);
    fields=fieldnames(cl31);
    for i=1:length(fields)
        if size(cl31.(fields{i}),1)==size(index,1)
            cl31.(fields{i})(index,:)=[];
        end
    end
end

if isfield(cl31,'time')
    cl31.datetime = datetime(cl31.time,'convertfrom','Datenum');
end

%% plot

%% clot CL31
%figure;
fig = figure;
fig.Units = 'centimeters';
fig.Position = [0 0 18 9];
fig.PaperPositionMode = 'auto';

pos = fig.Position;

set(fig,'PaperPositionMode','Auto','PaperUnits','Centimeters','PaperSize',[pos(3), pos(4)])
set(gca,'color','none');

cl31.rcs_910_pos=cl31.rcs_910;
cl31.rcs_910_pos(cl31.rcs_910_pos<=0)=NaN;
h1=pcolor(cl31.time,(cl31.range+1200)*1e-3,log10(cl31.rcs_910_pos)');
shading flat;
hold on;
h2=plot(cl31.time,(cl31.cloud+1200)*1e-3,'.','Color',[0.7 0.7 0.7],'markerfacecolor',[0.7 0.7 0.7],'MarkerSize',8);
ylim([1.200 3.000]);

c=colorbar;
ylabel(c,'log10(Att. backscatter coeff. (m^{-1} sr^{-1}))')
ylabel('Altitude (km)')
xlim([start_dn end_dn]);
datetick
caxis([1 4])
cmap = flipud(magma(20));
colormap(cmap);

%Draw lines for Gotschnabahn runs
lw = 5;
hold on
gr = plot(runs',y_runs','Color',[0.7 0.7 0.7],'LineWidth',lw);
%Draw lines of temperature measurements
hold on
kl = plot([start_m end_m],KL,'Color',[0,0.5,0],'LineWidth',lw);
hold on
gb = plot([start_m end_m],GB,'Color',[0.9290, 0.6940, 0.1250],'LineWidth',lw);
hold on
gg = plot([start_m end_m],GG,'Color',[0, 0.4470, 0.7410],'LineWidth',lw);

[~,icons,~,~]=legend(h2(1),'Cloud base height','Fontsize',fs);
icons(3).MarkerSize = 20; 
xlabel('Time (UTC)');
set(gca,'Fontsize',fs);
xtickangle(45)
datetick('x', 'HH:MM', 'keepticks');
one_hour = (end_dn-start_dn)/6;
set(gca,'XTick',start_dn:one_hour:end_dn)
box on;


end
