function plot_parametrization_parameters(droplets, ice_crystals,V_source)

fs = 25;
ms = 400;
tau = 60;
V = sum(ncread(V_source,'Total_volume'));
x = (40e-6:1e-7:400e-6)';
load(droplets)
d = temp1.metricmat(:,114);
d = sort(d);
load(ice_crystals)
a = temp1.metricmat(:,114);
class = temp1.cpType;


[aNsp,aNsp_new] = calculate_splinter_production(droplets,ice_crystals, V_source);
f_col_d = get_fcol(d,a,class,V);
f_col_x = get_fcol(x,a,class,V);
ypdf_x = get_pdf(x);
ypdf_d = get_pdf(d);
yNsp_x = aNsp*x;
yNsp_x_new = aNsp_new*x;
yNsp_d = aNsp*d;
yNsp_d_new = aNsp_new*d;
Gsp_x = f_col_x.*ypdf_x.*yNsp_x;
Gsp_d = f_col_d.*ypdf_d.*yNsp_d;
Gsp_x_new = f_col_x.*yNsp_x_new;
Gsp_d_new = f_col_d.*yNsp_d_new;


%Plot Gsp
figure
subplot(2,2,1)
%Plot Gsp
plot(x*1e6,Gsp_x*tau,'r')
hold on
scatter(d*1e6,Gsp_d.*tau,ms,'bo')
hold on 
xlim([40 400])
ylabel('g_{sp} (min^{-1})')
set(gca,'Fontsize',fs);
box on
%Plot amount of secondary ice Gsp_new
hold on
plot(x*1e6,Gsp_x_new*tau,'r--')
hold on
scatter(d*1e6,Gsp_d_new*tau,ms,'bo')

%Probability of freezing
subplot(2,2,2)
plot(x*1e6,f_col_x*tau*100,'r')
hold on
scatter(d*1e6,f_col_d*tau*100,ms,'bo')
xlim([40 400])
ylabel('f_{col} (% min^{-1})')
set(gca,'Fontsize',fs);
box on;

%Proabability of fragmentation
subplot(2,2,3)
plot(x*1e6,ypdf_x*100,'r')
hold on
scatter(d*1e6,ypdf_d.*100,ms,'bo')
hold on 
xlim([40 400])
ylim([0 105])
xlabel('Droplet diameter (µm)')
ylabel('p_{df} (%)')
set(gca,'Fontsize',fs);
box on;
hold on
plot([40 400],[100,100],'r--')
hold on
scatter(d*1e6,repmat(100,length(d),1),ms,'bo')


%Plot number of fragments Nsp
subplot(2,2,4)
plot(x*1e6,yNsp_x,'r')
hold on
scatter(d*1e6,yNsp_d,ms,'bo')
xlim([40 400])
xlabel('Droplet diameter (µm)')
ylabel('N_{sp}')
set(gca,'Fontsize',fs);
box on;
hold on
plot(x*1e6,yNsp_x_new,'r--')
hold on
scatter(d*1e6,yNsp_d_new,ms,'bo')

end

