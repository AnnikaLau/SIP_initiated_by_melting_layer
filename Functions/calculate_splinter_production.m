function [apdf,ypdf_d,aNsp,yNsp_d,aNsp_new,yNsp_new,yGsp_d,yGsp_d_new] = calculate_splinter_production()
%Load all particles larger than 40µm
load('C:\melting_layer\Data\HoloGondel\droplets_ge_40e-6_cD')
d = temp1.metricmat(:,114);
d = sort(d);
%Droplet concentration:
V = 43.7e-3;
n_d = length(d);
d_conc = n_d/V;
d_unc = sqrt(n_d)/V + 0.06*d_conc;
%load ice crystal data
load('C:\melting_layer\Data\HoloGondel\ice_habits_cD')
a = temp1.metricmat(:,114);
class = temp1.cpType;

Vt_d = get_fall_velocity(d,'Water');
yfcol_d = get_fcol(d,a,class,V);

%Fragmentation probability
apdf = 4.4e6; 
ypdf_d = apdf*(d.^2);

%Number of fragments
aNsp = 9e4;
yNsp_d = aNsp*d;

%Amount of secondary ice per droplet with diameter d
% aGsp = afcold.*apdf*aNsp;
yGsp_d = ypdf_d.*yNsp_d.*yfcol_d;
Gsp_d = sum(yGsp_d)/V;
SI = num2str(round(mean(yGsp_d)*d_conc*60*1e-3,2));
SI_unc = num2str(round(mean(yGsp_d)*d_unc*60*1e-3,2));
disp(strcat('The splinter generation rate per minute per litre is ',{' '},SI,...
    ' with an uncertainty of ',{' '},SI_unc))

%Find out new Nsp to explain observed production rate
%Min and max production rate
%Estimated splinter production rate of case study
pr_min = (0.24-0.09)*1e3/60; %m^-3 s^-1
pr_max = (0.24+0.09)*1e3/60; %m^-3 s^-1;

aNsp2_min = aNsp;
yGspd2_min = yfcol_d.*ypdf_d*aNsp2_min.*d;
while mean(yGspd2_min)*(d_conc+d_unc) < pr_min
    aNsp2_min = aNsp2_min + 0.1e4;
    yGspd2_min = yfcol_d.*ypdf_d*aNsp2_min.*d;
end
aNsp2_max = aNsp;
yGspd2_max = yfcol_d.*ypdf_d*aNsp2_max.*d;
while mean(yGspd2_max)*(d_conc-d_unc) < pr_max
    aNsp2_max = aNsp2_max + 0.1e4;
    yGspd2_max = yfcol_d.*ypdf_d*aNsp2_max.*d;
end
aNsp2_mean = (aNsp2_min+aNsp2_max)/2;
aNsp2_unc = (aNsp2_max-aNsp2_min)/2;
disp(strcat('N_{sp} has to be ',...
    {' '},num2str(round(aNsp2_mean,-4)), '\pm',{' '},num2str(round(aNsp2_unc,-4))))
s_min = round(aNsp2_min*200e-6);
s_max = round(aNsp2_max*200e-6);
s_mean = round(aNsp2_mean*200e-6);
s_unc = (s_max-s_min)/2;
disp(strcat('A droplet with 200µm produces ',{' '}, num2str(s_mean),...
    '\pm',{' '},num2str(s_unc),' splinters'))


%Assume pdf=1 and recalculate Nsp
aNsp3_min = aNsp;
yGspd3_min = yfcol_d*aNsp3_min.*d;
while mean(yGspd3_min)*(d_conc+d_unc) < pr_min
    aNsp3_min = aNsp3_min + 0.1e4;
    yGspd3_min = yfcol_d*aNsp3_min.*d;
end
aNsp3_max = aNsp;
yGspd3_max = yfcol_d*aNsp3_max.*d;
while mean(yGspd3_max)*(d_conc-d_unc) < pr_max
    aNsp3_max = aNsp3_max + 0.1e4;
    yGspd3_max = yfcol_d*aNsp3_max.*d;
end
aNsp3_mean = (aNsp3_min+aNsp3_max)/2;
aNsp3_unc = (aNsp3_max-aNsp3_min)/2;
disp(strcat('N_{sp} has to be ',...
    {' '},num2str(round(aNsp3_mean,-3)), '\pm',num2str(round(aNsp3_unc,-4)),...
    'if pdf=1'))
s_min = round(aNsp3_min*200e-6);
s_max = round(aNsp3_max*200e-6);
s_mean = round(aNsp3_mean*200e-6);
s_unc = (s_max-s_min)/2;
disp(strcat('A droplet with 200µm produces ',{' '}, num2str(s_mean),'\pm',...
    num2str(s_unc),' splinters'))


% %Number of fragments after tuning
aNsp_new = (aNsp3_max+aNsp3_min)/2;
yNsp_new = aNsp_new*d;
yGsp_d_new = yfcol_d*aNsp_new.*d;
end
