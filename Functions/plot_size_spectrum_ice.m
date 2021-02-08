function plot_size_spectrum_ice(ice_crystals,V_source)
load(ice_crystals)
V = sum(ncread(V_source,'Total_volume'));
habits = {'Ice_Plate','Ice_Unidentified','Ice_Column','Ice_Irregular','Ice_Aged'};
mr = find(contains(temp1.metricnames,'majsizRescale')==1);
majsizRescale = temp1.metricmat(:,mr);
class = temp1.cpType;
fs = 30;

for i = 1:length(habits)
    totalCount.(habits{i}) = sum(contains(class,habits{i}));
    conc.(habits{i}) = totalCount.(habits{i})*1e-3/V;
    majsiz.(habits{i}) = majsizRescale(temp1.class == habits{i});
    unc.(habits{i}) = get_uncertainty_ice(majsiz.(habits{i}),V)*1e-3;
end

%Small plates
s = find(majsizRescale<100e-6);
p = find(contains(temp1.cpType,'Ice_Plate')==1);
u = find(contains(temp1.cpType,'Ice_Unidentified')==1);
C = [intersect(s,p);intersect(s,u)];
totalCount.Small_plates = length(C);
conc.Small_plates = totalCount.Small_plates*1e-3/V;
unc.Small_plates = conc.Small_plates*0.15+sqrt(totalCount.Small_plates)*1e-3/V;
majsiz.Small_plates = majsizRescale(C);

[~,edges] = histcounts(log10(majsizRescale*1e6),10);
%[~,edges] = histcounts(log10(x*1e6),9); %change if only particles larger than 40um are considered
y = [];
figure(1)
for i=1:length(habits)
    hold on
    hab = histogram(majsiz.(habits{i})*1e6,10.^edges);
    y = [y;hab.Values];
end
y = y/(V*1e3);
y = y';


figure(2)
bar(y,1,'stacked');
xlim([0.5, 10.5])
edges = 0.5:1:10.5;
xticks(edges)
xticklabels({'25','39','60','93','145','224','347','537','832','1288','1995'})
xtickangle(45)
set(gca,'Fontsize',fs)
xlabel('Major axis (µm)')
ylabel('Concentration (L^{-1})')
plates = strcat('Plates',{'             '},num2str(round(conc.Ice_Plate,1)),'L^{-1}','\pm',num2str(round(unc.Ice_Plate,1)),'L^{-1}');
cla_new{1} = plates{1};
small_ice = strcat('Unidentified',{'    '},num2str(round(conc.Ice_Unidentified,1)),'L^{-1}','\pm',num2str(round(unc.Ice_Unidentified,1)),'L^{-1}');
cla_new{2} = small_ice{1};
column = strcat('Columns',{'         '},num2str(round(conc.Ice_Column,1)),'L^{-1}','\pm',num2str(round(unc.Ice_Column,1)),'L^{-1}');
cla_new{3} = column{1};
irregular = strcat('Irregular',{'          '},num2str(round(conc.Ice_Irregular,1)),'L^{-1}','\pm',num2str(round(unc.Ice_Irregular,1)),'L^{-1}');
cla_new{4} = irregular{1};
aged = strcat('Aged',{'               '},num2str(round(conc.Ice_Aged,1)),'L^{-1}','\pm',num2str(round(unc.Ice_Aged,1)),'L^{-1}');
cla_new{5} = aged{1};
small_plates = strcat('Small plates',{'    '},num2str(round(conc.Small_plates,1)),'L^{-1}','\pm',num2str(round(unc.Small_plates,1)),'L^{-1}');
cla_new{6} = small_plates{1};


small_plates = sum(y(1:3,1:2),2);
hold on
bar(small_plates,1,'FaceAlpha',0)
legend(cla_new)
end
