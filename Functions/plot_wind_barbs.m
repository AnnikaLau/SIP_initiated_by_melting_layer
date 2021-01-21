function [h_barb_handles,brbindx,speed_lims] = plot_wind_barbs(u,v,x,y,varargin)
% [h_barb_handles,brbindx,speed_lims] = windbarbs(u,v,x,y,[scale],[units],...
%                                        [linewidth],[speed_lims],[color])
%
% WIND BARBS FOR MATLAB
% By M.Hervo
% Inspired by:     James Foster (University of Hawaii)
%                   Pierre Huguenin (MeteoSwiss)
%
% ------------------------------------------------------------------------
% [h_barb_handles,brbindx] = plot_windbarb(u,v,lat,lon,scale,units);
%
% plot_windbarb takes u,v components of the windfield
% and plots them as standard meteorological wind-barbs.
% Scale adjusts the size(s) of the barbs while lat determines
% if the barbs are clockwise (northern hemisphere) or
% anti-clockwise pointing.
%
%
% input:
%   u,v     components of the wind field.
%   y,x the latitude, longitude (or lat,lon) coordinates of the u,v data.
%           Southern hemisphere (negative lat) sites have anticlockwise-
%           pointing feathers. (N.B. if data are not geographical this
%           might be a problem if the x/lat coordinate is partially
%           negative).
%   scale   size of the windbarbs in cm
%   units   'kt' or 'ms' or 'mse' units of u,v. Program assumes the standard
%           5|10|50 knot speeds for half|full|flag feathers. If 'mse' 
%           (e for exact) is chosen the multiplication factor 1.94384 is 
%           used for the conversion ms->kt. [default = 'kt'];
%   linewidth   defaults to 0.5 pt, allows to have windbarbs drawn with thinner
%               linewidth. It is especially useful when profiles are
%               generated very frequently (eg 10-minute profiles)
%   speed_lims  lower and upper speed limits in
%               "min" and "max" fields
%
% output:
%   h_barb_handles  the handles to the patch objects plotted.

% phu 20090309:
% To make it easier to deal with optional input arguments there is a
% new internal interface to this function. This should be transparent for
% older calling function. New function can now specify the third
% 'linewidth' argument
% windbarbs(u,v,lat,lon,scale,units,linewidth) ->
% windbarbs(u,v,lat,lon,varargin)
%
% phu 20090313
% - Changed the interface: speed_lims output arg is now optional and it is possible
% to provide the function with upper and lower bounds for the speed scale. This
% allows for uniform color scale among different plots.
% - Corrected a bug in the display of wind barbs for winds>50kt where the
% full and half feathers were hidden inside the flag(s) patche(s).
%
% haa 2013-08-12
% corrected a bug in the calculation of dd,ff from u,v: u=1, v=1 -> dd=225!!!
%
% hem 2016/10:
%   -Renamed and clean the function
%   -Now 100 times faster on large arrays
%   -Replace patches by lines
%
% ruf 2019/05:
% - introduced a maximum wind component of 200 m/s or 200kt to avoid 
% failure of routine in case of outlier.
% - introduced option 'mse' for exact conversion of windspeed to kt


%% Hard coded inputs
% Does y and x are geographical coordinates
is_latitude=0; % If true, for Negative value of lat, barbs will be anti-clockwise pointing


% define default dimensions for the barb * feather components:
shaft_length = 1;
half_length  = .2;
full_length  = .4;
flag_length  = .4;
feather_ang  = 20.*pi./180;
feather_sep = sin(feather_ang).*flag_length;    % defined so that the base of a flag is exactly one separation wide.

%% Check inputs
if nargin==0
    disp('Random Default Values to test the funtion')
    u=rand(15,1)*10;
    v=rand(15,1)*20;
    x=[zeros(5,1) ; ones(5,1)-0.5 ; ones(5,1)];
    y=[0:100:400 0:100:400 0:100:400]';
end

display_barbs_info = 0;

if nargin < 5 || isempty(varargin{1})
    scale = 1;  % default scale = 1 cm.
else
    scale = varargin{1};
end

if nargin < 6 || isempty(varargin{2})
    units = 'kt';
else
    units = varargin{2};
end

if nargin < 7 || isempty(varargin{3})
    linewidth = 0.5;  % default linewidth = 0.5 pt
else
    linewidth = varargin{3};
end

if nargin < 8 || isempty(varargin{4})
    speed_lims.min = []; % not specified in the input params have to be
    speed_lims.max = []; % computed below based on the data provided to
    % this script. Otherwise: use the user provided
    % speed range limits.
else
    if isempty(varargin{4}.min)
        speed_lims.min = 0;
    else
        speed_lims.min = varargin{4}.min;
    end
    speed_lims.max = varargin{4}.max;
end


if nargin < 9 || isempty(varargin{5})
    color = [];
else
    color = varargin{5};
end
% If No Xlim and Ylim are defined, define them to have a correct output
ax=gca;
if strcmp(ax.YLimMode,'auto')
    xlim([min(x),max(x)])
    if min(y)<max(y)
        ylim([min(y),max(y)])
    end
end
% xlim([min(x),max(x)])
% ylim([min(y),max(y)])


% first check the vectors and remove any NaN observations and wind components over 200 m/s (would cause unreadable windbarbs or even fail of routine):
allindx = 1:numel(u);                % length(u); phu 20070219
nanindx = find(isnan(u+v+y+x) | abs(u>200) | abs(v>200));
brbindx = setxor(allindx,nanindx);   % is equivalent to setdiff IN THIS CASE (allindx is the "Universe") phu 20070219
u(nanindx)=[];
v(nanindx)=[];
y(nanindx)=[];
x(nanindx)=[];

% check for hemisphere and set clockwise/anticlockwise feathers
if is_latitude==1
    sense = sign(y).*ones(size(u));
else
    sense = ones(size(u));
end

% convert u,v to azimuth and speed:
[azmth,speed] = uv2ddff(u,v);
azmth = azmth/360*2*pi;

if isempty(speed_lims.min), disp('Computing speed_lims.min'), speed_lims.min = min(min(speed)); end
if isempty(speed_lims.max), disp('Computing speed_lims.max'), speed_lims.max = max(max(speed)); end

% check units and multiply speed by 2 if units are 'ms' in order to get
% barbs are 2.5,5 and 25 m/s as it is the case in Degreane software.
if strcmp(units,'ms_exact') || strcmp(units,'ms exact') ...
        || strcmp(units,'ms_e') || strcmp(units,'mse')
    speed_knots = 1.94384*speed;
    %     speed_lims.min = 1.94384*speed_lims.min;
    %     speed_lims.max = 1.94384*speed_lims.max;
elseif strcmp(units,'ms')
    speed_knots = 2.*speed;
    %     speed_lims.min = 2*speed_lims.min;
    %     speed_lims.max = 2*speed_lims.max;
else
    speed_knots =  speed;
end

% Load Colormap
cmap  = jet;

% test the axes properties to find out what the scaling is so that
% we can plot 1 cm:
oldunits = get(gca,'Units');
set(gca,'Units','centimeters');
cmposn = get(gca,'Position');
set(gca,'Units',oldunits);

xcmrange = cmposn(3);
ycmrange = cmposn(4);

% get the Xlims and Ylims so that we can define coordinates in proper
% units:
xlims = get(gca,'XLim');
ylims = get(gca,'YLim');

xrange = diff(xlims); yrange = diff(ylims);
xscale = (xrange./xcmrange);
yscale = (yrange./ycmrange);

% use this scalings to form a scale matrix that will convert a unit vector
% into one that is "scale" centimeters long when plotted in these axes:
scalemat = scale.*[xscale 0;0 yscale];

% too tricky to make the call as a matrix/vector. Swallow it and do a loop:
nbarbs = length(u(:));

% initialise handles
h_barb_handles=[];

% Preallocation lines
barb_lines_all=ones(nbarbs*20,2)*-999; % Max length
% Preallocation Color
color_all=ones(nbarbs*20,3)-999;
% initialize line counter
k=1;

%% loop on all wind barbs
for ibarb = 1:nbarbs
    %% Calculate a single wind barb
    % First work out what combination
    % of flag/full/half feathers are needed to represent the speed
    [nflag,nfull,nhalf] = speed2feathers(speed_knots(ibarb));
    % define a mirror matrix for clockwise/anti-clockwise feathers
    clockmat = [sense(ibarb) 0;0 1];
    
    % define a rotation matrix for the wind direction:
    windrotn = [cos(azmth(ibarb)) -sin(azmth(ibarb)); sin(azmth(ibarb)) cos(azmth(ibarb))];
    
    % now trace out the whole barb as a patch object making sure to
    % catch the special cases:
    if nflag+nfull+nhalf == 0               % no feathers:
        % just plot a point:
        %         barb_lines = [];%point_vertices;%[];                    % central point (0,0) is added at the bottom of the script
        barb_lines = [0,0;0 shaft_length];  % VAISALA-style low speed windbarbs (makes plot messy), phu 20070222
        if display_barbs_info ==1
            disp(['Barb #',int2str(ibarb),': (rounded) speed = 0: simply drawing a point']);
        end
    elseif nhalf==1 && nflag+nfull==0        % only a 5 m/s feather:
        % place the half-feather in the second feather spot, not at the end:
        barb_lines = [0 0; ...
            0 shaft_length; ...
            0 shaft_length-feather_sep; ...
            half_length.*cos(feather_ang) ...
            half_length.*sin(feather_ang)+shaft_length-feather_sep; ...
            0 shaft_length-feather_sep]*clockmat;
        if display_barbs_info ==1
            disp(['Barb #',int2str(ibarb),': (rounded) speed = 5; drawing half-feather in from the end']);
        end
    else    % all other cases:
        ifeather = 0;
        if nflag>=1
            flag_offset = 1;
        else
            flag_offset = 0;
        end
        barb_lines = [0 0;0 shaft_length];
        if display_barbs_info ==1
            disp(['Barb #',int2str(ibarb),': (rounded) speed =',int2str(speed_knots(ibarb))]);
        end
        for iflag = 1:nflag
            flag_patch = [0 0; ...
                full_length.*cos(feather_ang) 0;...
                0 0-feather_sep]*clockmat + ...
                repmat([0 shaft_length-ifeather.*feather_sep],3,1);
            
            barb_lines = [barb_lines;flag_patch];
            ifeather=ifeather+1;
            if display_barbs_info ==1
                disp(['  ',int2str(ifeather),': drawing a 50 m/s flag']);
            end
        end
        for ifull = 1:nfull
            full_patch = [0 0; ...
                full_length.*cos(feather_ang) full_length.*sin(feather_ang); ...
                0 0]*clockmat + ...
                repmat([0 shaft_length-(ifeather+flag_offset).*feather_sep],3,1);
            
            barb_lines = [barb_lines;full_patch];
            ifeather=ifeather+1;
            if display_barbs_info ==1
                disp(['  ',int2str(ifeather),': drawing a 10 m/s feather']);
            end
        end
        if nhalf == 1
            half_patch = [0 0; ...
                half_length.*cos(feather_ang) half_length.*sin(feather_ang); ...
                0 0]*clockmat + ...
                repmat([0 shaft_length-(ifeather+flag_offset).*feather_sep],3,1);
            
            barb_lines = [barb_lines;half_patch];
            ifeather=ifeather+1;
            if display_barbs_info ==1
                disp(['  ',int2str(ifeather),': drawing a 5 m/s feather']);
            end
        end
    end
    
    % tack on a final closing vertex:
    barb_lines = [barb_lines;0 0];
    
    % check how many vertices we have
    [nverts,~]=size(barb_lines);
    if display_barbs_info ==1
        disp(['  We have ',int2str(nverts),' vertices for the final barb patch']);
    end
    
    % should now have an outline of the barb as if wind was northerly with
    % feathers pointing in correct direction for the hemisphere. Now apply the
    % wind-direction rotation matrix:
    barb_lines = barb_lines*windrotn;
    if display_barbs_info ==1
        disp(['  Rotated the patch for wind direction of ',int2str(round(azmth(ibarb).*180./pi)),' degrees']);
    end
    % should now have a patch in cart-xy of unit length and with correct
    % direction. Need scale it up so that it is "scale" centimeters long
    % in the current axes and to move it to the correct lat lon point:
    barb_lines_lonlat = barb_lines*scalemat + repmat([x(ibarb) y(ibarb)],nverts,1);
    
    % Add the wind bar at the end of the bartb Matrix
    barb_lines_all(k:k+length(barb_lines_lonlat),:)=[NaN NaN;barb_lines_lonlat];
    
    % Calculate associated Color
    if speed_lims.min == speed_lims.max
        mycolor = [0 0 0];
    else
        mycolor = get_color_vect(speed_lims.min,speed_lims.max,speed(ibarb),cmap);
    end
    color_all(k:k+length(barb_lines_lonlat),:)=repmat(mycolor,length(barb_lines_lonlat)+1,1);
    k=k+length(barb_lines_lonlat)+1;
end

index_fill=all(barb_lines_all==-999,2);
barb_lines_all(index_fill,:)=[];
color_all(index_fill,:)=[];

% colormap jet
% scatter(x,y,25,speed,'filled')
% caxis([speed_lims.min  speed_lims.max])

%% Plot all lines
%Modif hem: Replace patches by lines
%           Now One plot per color (>100 times faster on big vectors)
if isempty(color)
    hold on
    [color_vec,index_color]=unique(color_all,'rows');
    for i=1:length(index_color)
        index=color_vec(i,1)==color_all(:,1) & color_vec(i,2)==color_all(:,2) & color_vec(i,3)==color_all(:,3);
        h_barb_handles=plot( barb_lines_all(index,1),barb_lines_all(index,2),...
            'color',color_vec(i,:),'linewidth',linewidth);
    end
else
    h_barb_handles=plot( barb_lines_all(:,1),barb_lines_all(:,2),...
        'color',color,'linewidth',linewidth);
end

function   [nflag,nfull,nhalf] = speed2feathers(speed)
%
% [nflag,nfull,nhalf] = speed2feathers(speed);
%
% speed2feathers takes the scalar speed and returns the
% number of flag/full/half feathers necessary to represent
% the speed on a standard meteorological wind-barb vector.
%
% input:
%       speed   scalar speed (units assumed to be kt)
%
% output:
%       nflag   number of 50 kt flags needed
%       nfull   number of 10 kt full feathers needed
%       nhalf   number (0|1) of 5 kt half feathers needed
%
round_speed = 5.*round(speed./5);
nflag = floor(round_speed./50);
nfull = floor((round_speed - nflag.*50)./10);
nhalf = floor((round_speed - nflag.*50 - nfull.*10)./5);

function color=get_color_vect(minval,maxval,val,cmap)


crank = round( (val-minval)/(maxval-minval) * (size(cmap,1)-1) +1 ) ;
% Matlab uses:
% index = fix((C-cmin)/(cmax-cmin)*m)+1

if crank>length(cmap)
    crank = length(cmap);
end

color = cmap(crank,:);
