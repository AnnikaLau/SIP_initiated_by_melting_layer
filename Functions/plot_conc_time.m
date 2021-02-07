load('Z:\6_Auswertung\Annika\2019_RACLETS\Wolken\2019_02_22\GE25e-6\RACLETS_merged_8-10h_rescaled_habits_iData')
iData_big = iData;
load('Z:\6_Auswertung\Annika\2019_RACLETS\Wolken\2019_02_22\LT25e-6\RACLETS_merged_8-10h_lt25e-6_iData')
iData_small = iData;
clear iData
load('C:\melting_layer\Data\HoloGondel\ice_habits_cD')

leg = {'CDNC (*10^{-3})','CDNC (d>40µm)','ICNC','Plates'};
classes = {'Water','Water40','Ice','Ice_Plate'};
mark = {'o','o','h','d','s','*','k','^'};
mfc = {'none','flat','none','none','none','none','none','none'};   %Marker face color
mec = {'flat','none','flat','flat','flat','flat','flat','flat'};   %Marker edge color
col = [rgb('SteelBlue');rgb('SteelBlue');rgb('Red');rgb('Red');rgb('Red');rgb('Green');rgb('Blue');rgb('Purple')];
ls = {'-','--','-','--','--','--','--','--'};
tstart = datenum(2019,2,22,8,0,0);
tend = datenum(2019,2,22,10,0,0);
runs = get_runs();
ylimi=[1e-1 1e3];

close all
fs = 20;
ms = 300;
f=1;

%Total concentration in the whole measurement volume
V = sum(iData_big.Total.volume);
v = sum(iData_small.Total.volume);
conc_tot = [];
conc_unc = [];
majsizRescale = temp1.metricmat(:,114);
class = temp1.cpType;
for i = 1:length(classes)
    if isequal(classes{i},'Water')
        conc.(classes{i}) = (sum(iData_small.(classes{i}).totalCount)/V + sum(iData_small.Water.totalCount)/v)*1e-6;
        unc.(classes{i}) = conc.(classes{i})*0.06;
    else
        idx = contains(class,classes{i});
        majsiz.(classes{i}) = majsizRescale(idx);
        totCount.(classes{i}) = sum(iData_big.(classes{i}).totalCount);
        conc.(classes{i}) = totCount.(classes{i})*1e-3/V;
        if isequal(classes{i},'Water40')
            unc.(classes{i}) = conc.(classes{i})*0.06+sqrt(totCount.(classes{i}))*1e-3/V;
        else
            unc.(classes{i}) = get_uncertainty_ice(majsiz.(classes{i}),V)*1e-3;
        end
    end
    conc_tot = [conc_tot;conc.(classes{i})];
    conc_unc = [conc_unc;unc.(classes{i})];
end


figure(f)
f = f+1;
for cnt=1:length(classes)
    if strcmp(classes{cnt},'Water')
        conc_Water = iData_big.Water.concentration + iData_small.Water.concentration;
        hold on
        scatter(runs(:,1),conc_Water,ms,col(cnt,:),mark{cnt},'MarkerFaceColor',mfc{cnt},'MarkerEdgeColor',mec{cnt});
    else
        hold on
        scatter(runs(:,1),iData_big.(classes{cnt}).concentration*1e3,ms,col(cnt,:),mark{cnt},'MarkerFaceColor',mfc{cnt},'MarkerEdgeColor',mec{cnt});
    end
end

ylabel('Cloud particle conc. (L^{-1})','Fontsize',fs)
tenmin = (tend-tstart)/6;
set(gca,'XTick',tstart:tenmin:tend)
xticklabels({'08:00','08:20','08:40','09:00','09:20','09:40','10:00'})
datetick('x','keepticks','keeplimits')
[~,icons,~,~]=legend(leg,'location','bestoutside','Fontsize',fs);

ylim(ylimi)
xlim([tstart tend])
xlabel('Time (UTC)','Fontsize',fs)
set(gca,'FontSize',fs)
xtickangle(45)
set(gca, 'YScale', 'log')
box on;
for cnt=1:length(classes)
    hold on;
    lineProps.col{1} = col(cnt,:);
    lineProps.style = ls{cnt};
    mseb([tstart tend],[conc_tot(cnt) conc_tot(cnt)],[conc_unc(cnt) conc_unc(cnt)],lineProps,1);
end

for i = 5:8
    icons(i).Children.MarkerSize = 18;
end


