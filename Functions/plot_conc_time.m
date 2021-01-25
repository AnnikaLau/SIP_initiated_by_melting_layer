load('Z:\6_Auswertung\Annika\2019_RACLETS\Wolken\2019_02_22\GE25e-6\RACLETS_merged_8-10h_rescaled_habits_wolke')
load('Z:\6_Auswertung\Annika\2019_RACLETS\Wolken\2019_02_22\LT25e-6\RACLETS_merged_8-10h_lt25e-6_rescaled_habits_iData')

leg = {'CDNC (*10^{-3})','CDNC (d>40µm)','ICNC','Plates'};%
classes = {'Water','Water40','Ice','Ice_Plate'};%
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
V = sum(this.tsData.Total.data.volume);
v = sum(iData.Total.volume);
conc_tot = [];
conc_unc = [];
for i = 1:length(classes)
    if isequal(classes{i},'Water')
        conc.(classes{i}) = sum(this.tsData.(classes{i}).data.totalCount)*1e-6/V + sum(iData.Water.totalCount)*1e-6/v;
        unc.(classes{i}) = conc.(classes{i})*0.06;
    else
        totCount.(classes{i}) = sum(this.tsData.(classes{i}).data.totalCount);
        conc.(classes{i}) = totCount.(classes{i})*1e-3/V;
        if isequal(classes{i},'Water40')
            unc.(classes{i}) = conc.(classes{i})*0.06+sqrt(totCount.(classes{i}))*1e-3/V;
        else
            unc.(classes{i}) = conc.(classes{i})*0.15+sqrt(totCount.(classes{i}))*1e-3/V;
        end
    end
    conc_tot = [conc_tot;conc.(classes{i})];
    conc_unc = [conc_unc;unc.(classes{i})];
end

%Concentration over time
for r=1:size(runs,1)
    clear pos
    pos = find(this.tsData.Total.time >= runs(r,1) & this.tsData.(classes{i}).time <= runs(r,2));
    volume(r) = sum(this.tsData.Total.data.volume(pos));
    volume_small(r) = sum(iData.Total.volume(pos));
    for c = 1:length(classes)
        if isequal(classes{c},'Water')
            conc_time.(classes{c})(r,1) = sum(this.tsData.(classes{c}).data.totalCount(pos))*1e-3/volume(r)+...
                sum(iData.(classes{c}).totalCount(pos))*1e-3/volume_small(r);
        else
            conc_time.(classes{c})(r,1) = sum(this.tsData.(classes{c}).data.totalCount(pos))*1e-3/volume(r);
        end
    end
end


figure(f)
f = f+1;
for cnt=1:length(classes)
    if strcmp(classes{cnt},'Water')
        conc_time.(classes{cnt}) = conc_time.(classes{cnt})*1e-3;
    end
    hold on
    scatter(runs(:,1),conc_time.(classes{cnt}),ms,col(cnt,:),mark{cnt},'MarkerFaceColor',mfc{cnt},'MarkerEdgeColor',mec{cnt});
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
% ylabel('Particle conc. (cm^{-3})','Fontsize',fs)
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


