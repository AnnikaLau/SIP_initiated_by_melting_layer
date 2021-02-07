%[x,y,z] = xyzread('C:\melting_layer\Data\DHM25\DHM200.xyz');
%grid = xyz2grid(x,y,z);
%xpos = [-10 10];
%ypos = [-10 10];
%plot_DHM(x,y,grid,'large',xpos,ypos,0);
%plot_DHM(x,y,grid,'small',xpos,ypos,0);

function [u,v,a1,b1,wd,ws] = plot_DHM(x,y,grid,grid_size,xpos,ypos,wind)
FS = 14; %Fontsize
if strcmp(grid_size,'small')
    fig = figure;
    fig.Units = 'centimeters';
    fig.Position = [0 0 15 15];
    fig.PaperPositionMode = 'auto';
    pos = fig.Position;    
    set(fig,'PaperPositionMode','Auto','PaperUnits','Centimeters','PaperSize',[pos(3), pos(4)])
    set(gca,'color','none');
    ax1 = gca; % current axes
    ax1.Position = [0.12 0.12 0.82 0.85];
    ms = 50; %marker size
elseif strcmp(grid_size,'large')
    fig = figure;
    fig.Units = 'centimeters';
    fig.Position = [0 0 15 15];
    fig.PaperPositionMode = 'auto';  
    pos = fig.Position; 
    set(fig,'PaperPositionMode','Auto','PaperUnits','Centimeters','PaperSize',[pos(3), pos(4)])
    set(gca,'color','none');
    ax1 = gca; % current axes
    ax1.Position = [0.12 0.12 0.82 0.85];
    ms = 15; %marker size
    FS = FS*1.25;
end


x1 = unique(x);
y1 = unique(y);

%Davos Wolfgang: x0 = 784208, y0 = 190000
%Gotschnagrat: x0 = 783777, y0 = 192585
%see https://www.ornitho.ch/index.php?m_id=48&action=DMS (x and y
%exchanged)
%Gotschnaboden (Google Maps: 46.862091, 9.858036), using the website:
%784455,192950
x0 = 783777;
y0 = 192585;
xGo = 784455; %Gotschnaboden
yGo = 192950;
xDW = 784208;
yDW = 190000;
xWFJ = 780623;
yWFJ = 189594;
xKL = 786136;
yKL = 193773;
x1 = (x1 - x0).*1e-3;
y1 = (y1 - y0).*1e-3;


pcolor(x1,flip(y1),grid);
shading flat;

if strcmp(grid_size,'large')
    xlim([-40 20]);
    ylim([-20 30]);
    yticks(-20:20:60);
    hold on;
    rectangle('Position',[xpos(1) ypos(1) xpos(2)-xpos(1) ypos(2)-ypos(1)],'Linewidth',1);
elseif strcmp(grid_size,'small')
    xlim(xpos);
    ylim(ypos);
end

xlabel('Distance (km)');
ylabel('Distance (km)');

zlimits = [0 3000];
cmap = demcmap(zlimits);
colormap(cmap);
cb = colorbar('Location','SouthOutside');
cbarrow('right');
cb.FontSize = FS;
ylabel(cb, 'Elevation (m a.s.l.)','Fontsize',FS+2)
caxis([0 3000]);
cb.Ticks = 0:500:3000;
cb.TickLabels = {'0',' ','1000',' ','2000',' ','3000'};
box on;
set(gca,'Fontsize',FS);
set(gca,'layer','top');


if wind==1
    %Use function get_wind_IDAWEB.py to get the wind data
    stat = {'TSG','DAV','SLFPAR','NABDAV','SLFSLF','SLFWFJ','SLFKL3','SLFKL2',...
        'SLFKLO','SRS','WFJ','ARO','ARD','Holfuy'};
    px = [770100,783518,780430,784460,783800,780850,790100,785500,785050,769617,...
        780616,771030,770730,783521];
    py = [183500,187458,191680,187745,187400,189260,190800,198200,199500,205125,...
        189634,184825,183320,192545];
    wd = [341.54,30.23,307.2,15.08,75.6,316.2,348.2,165,190,283.92,333.62,13.54,...
        46.46,291];
    ws = [7.58,5.52,nan,3.52,nan,nan,nan,nan,nan,0.86,12.41,2.52,1.46,6.2];
    u = zeros(length(stat),1);
    v = zeros(length(stat),1);
    a1 = zeros(length(stat),1);
    b1 = zeros(length(stat),1);
    a = zeros(length(stat),1);
    b = zeros(length(stat),1);
    for cnt=1:length(stat)
        hold on
        a1(cnt)=(px(cnt)-x0)*1e-3;
        b1(cnt)=(py(cnt)-y0)*1e-3;
        scatter(a1(cnt),b1(cnt), 'ko','filled');
        if wd(cnt)<=90
            alpha = wd(cnt);
            a(cnt) = 1.5*sind(alpha);
            b(cnt) = 1.5*cosd(alpha);
            u(cnt) = (a(cnt)*ws(cnt))/1.5;
            v(cnt) = (b(cnt)*ws(cnt))/1.5;
            if isnan(ws(cnt))
                hold on
                plot([a1(cnt),a1(cnt)+a(cnt)],[b1(cnt),b1(cnt)+b(cnt)],'k')
            end
        elseif wd(cnt)<=180
            alpha = 180-wd(cnt);
            a(cnt) = 1.5*sind(alpha);
            b(cnt) = 1.5*cosd(alpha);
            u(cnt) = (a(cnt)*ws(cnt))/1.5;
            v(cnt) = -(b(cnt)*ws(cnt))/1.5;
            if isnan(ws(cnt))
                hold on
                plot([a1(cnt),a1(cnt)+a(cnt)],[b1(cnt),b1(cnt)-b(cnt)],'k')
            end
        elseif wd(cnt)<=270
            alpha = wd(cnt)-180;
            a(cnt) = 1.5*sind(alpha);
            b(cnt) = 1.5*cosd(alpha);
            
            u(cnt) = -(a(cnt)*ws(cnt))/1.5;
            v(cnt) = -(b(cnt)*ws(cnt))/1.5;
            if isnan(ws(cnt))
                hold on
                plot([a1(cnt),a1(cnt)-a(cnt)],[b1(cnt),b1(cnt)-b(cnt)],'k')
            end
        else
            alpha = 360-wd(cnt);
            a(cnt) = 1.5*sind(alpha);
            b(cnt) = 1.5*cosd(alpha);
            u(cnt) = -(a(cnt)*ws(cnt))/1.5;
            v(cnt) = (b(cnt)*ws(cnt))/1.5;
            if isnan(ws(cnt))
                hold on
                plot([a1(cnt),a1(cnt)-a(cnt)],[b1(cnt),b1(cnt)+b(cnt)],'k')
            end
        end
    end
    speed_lims.min = 0;
    speed_lims.max = 25;
    windbarbs(u*(-1),v*(-1),a1,b1,1,[],1.5,speed_lims);
    
end

hold on
plot([0,(xGo-x0)*1e-3],[0,(yGo-y0)*1e-3],'r','LineWidth',2)
%Davos Wolfgang
hold on
scatter((xDW-x0)*1e-3,(yDW-y0)*1e-3,ms,'r','filled')
%Weissfluhjoch
hold on
scatter((xWFJ-x0)*1e-3,(yWFJ-y0)*1e-3,ms,'r','filled')
%Klosters
hold on
scatter((xKL-x0)*1e-3,(yKL-y0)*1e-3,ms,'r','filled')
%Gotschnaboden
hold on
scatter((xGo-x0)*1e-3,(yGo-y0)*1e-3,ms,'r','filled')
%Gotschnagrat
hold on
scatter(0,0,ms,'r','filled')


end