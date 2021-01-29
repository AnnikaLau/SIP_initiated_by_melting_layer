% Adapted by Fabiola
function [cl31, pwd, WS600]=get_Klosters_data_from_files(start_str,end_str,root_folder)
%==========================================================================
% [cl31, pwd, WS600]= get_kloster_from_files(start_str,end_str,[root_folder])
% This function read CL31 abnd other instruments installed at Klosters for Davos 2019 field campaign
% Preallocation is made using number of files:
%
% Input parameters:  start_str,end_str : start and end time as string
% (format : 'yyyymmddHHMMSS' or 'yyyymmdd')
% If end_str is not provided it is equal to start_str+1
%
% Output:            cl31 : structure containing data of interest
%
% Exemple of use :
% [cl31, pwd, WS600] = get_kloster_from_files('20150427')
% [cl31] = get_kloster_from_files('20150427000000','20150428000000','M:\pay-data\data\pay\REM\ACQ\CEILO_CL31\KLA/')
% [cl31] = get_kloster_from_files('20150427000000','20150428000000')
% [cl31] = get_kloster_from_files('20150427','20150428')
% [cl31] = get_kloster_from_files('20150427')
%
% Use of external functions : none
%
% Author: Maxime Hervo
% Date: November 2018
%
%==========================================================================

%% Format Inputs
if nargin==0
    %by default values to test the routine
    warning('No Input,Default values')
    
    start_str=datestr(now-1,'yyyymmddHHMMSS');
    end_str  =datestr(now,'yyyymmddHHMMSS');
    
        
    start_str=['20181206000000'];
    end_str  ='20181207000000';
    
end


if nargin<3
    %define root path
    if isunix()
        root_folder='/data/pay/REM/ACQ/CEILO_CL31/';
    else
        root_folder='Z:\3_Data\Davos2019\Ceilometer\';
    end
end


if length(start_str)==8
    start_str=[start_str '000000'];
end
start_dn=datenum(start_str,'yyyymmddHHMMSS');

% if nargin==3
%     end_str =datestr(start_dn+0.9999999,'yyyymmddHHMMSS');
% end

if length(end_str)==8
    end_str=[end_str '000000'];
end
end_dn=datenum(end_str,'yyyymmddHHMMSS');


disp(['Reading CL31 bulletin for ' start_str ' to ' end_str])


ceilo_str='KLA';





%% Make file list
time_vec=floor(start_dn):floor(end_dn);
list=[];
folder_for_selected_files=[];
for j=1:length(time_vec)
    str=[root_folder  ceilo_str '/' datestr(time_vec(j),'yyyy/mm/dd/*')  datestr(time_vec(j),'yyyymmdd') '*.001'];
    list1=dir(str);
    
    
    index=false(length(list1),1);
    for i=1:length(list1)
        time_tmp= time_vec(j)+ str2double(list1(i).name(16:17))/24+str2double(list1(i).name(18:19))/24/60 ;
        if time_tmp<start_dn || time_tmp>end_dn
            index(i)=true;
        end
    end
    disp([num2str(sum(~index)) ' files selected on ' num2str(length(list1))])
    if ~isempty(index)
        list1(index)=[];
        list=[list;list1];
    end
    
end

if isempty(list)
    cl31=[];
    pwd = [];
    WS600 = [];
    
    warning(['NO CL31 data ' str])
    return
end


%% Preallocate
max_number_profiles=10; % 18 profile per file
cl31.octa=NaN(length(list)*max_number_profiles,3);
cl31.cloud=NaN(length(list)*max_number_profiles,3);
cl31.cloud_layer=NaN(length(list)*max_number_profiles,5);
cl31.cloud_amount=NaN(length(list)*max_number_profiles,5);
cl31.obscuration=false(length(list)*max_number_profiles,1);
cl31.vertical_visibility=NaN(length(list)*max_number_profiles,1);

cl31.rcs_910=NaN(length(list)*max_number_profiles,770);
cl31.time=NaN(length(list)*max_number_profiles,1);

cl31.scalefac=NaN(length(list)*max_number_profiles,1);
cl31.resolz=NaN(length(list)*max_number_profiles,1);
cl31.lengthofprof=NaN(length(list)*max_number_profiles,1);
cl31.nrjfac=NaN(length(list)*max_number_profiles,1);
cl31.laser_temp=NaN(length(list)*max_number_profiles,1);
cl31.windows_transmission=NaN(length(list)*max_number_profiles,1);
cl31.tilt_angle=NaN(length(list)*max_number_profiles,1);
% cl31.measur_param=NaN(length(list)*max_number_profiles,1);
cl31.sum_beta=NaN(length(list)*max_number_profiles,1);
cl31.bckgrd_rcs_910=NaN(length(list)*max_number_profiles,1);
cl31.unit_id=NaN(length(list)*max_number_profiles,1);
cl31.software_id=NaN(length(list)*max_number_profiles,1);
cl31.flag= char(zeros(length(list)*max_number_profiles,1));
cl31.error_str= zeros(length(list)*max_number_profiles,48);
cl31.pulse_qty=NaN(length(list)*max_number_profiles,1);


%% read  files
disp(['Read ' num2str(length(list)) ' files for station '])
j=1;jj = 1;
jjj = 1;
jjjj = 1;
for k=1:length(list)
    filename = [list(k).folder '/' list(k).name];
    if exist(filename,'file')>0
        disp(['Read ' filename])
    else
        warning(['No file ' filename]);
        continue
    end
    
    delimiter = '';
    formatSpec = '%s%*[^\n]';
    fid=fopen(filename);
    data=textscan(fid, formatSpec, 'Delimiter', delimiter,'headerlines',0);
    fclose(fid);
    date_str = [list(k).name(8:11) '-' list(k).name(12:13) '-' list(k).name(14:15)];
    
    %% decode file
    try
        for i = 1:length(data{1})
            if contains(data{1}{i},'<sensor>')
                % New sensor
                switch data{1}{i+2}
                    case 'type="CL31"'
                        %% CL31
                        
                        % find where data ends
                        l = 1;
                        while ~contains(data{1}{i+l},'</data>')
                            if contains(data{1}{i+l},['<' date_str])
                                %% read message
                                %disp([num2str(l) ' ' num2str(j)])
                                % Time
                                cl31.time(j) = datenum(data{1}{i+l}(1:21),'<yyyy-mm-dd/HH:MM:SS>');
                                cl31.unit_id(j) = data{1}{i+l}(22+4); %Unit IF (Optionnal)
                                cl31.software_id(j) = str2double(data{1}{i+l}(22+(5:7))); % Software ID
                                %                             disp(datestr(cl31.time(j)))
                                
                                % Second line
                                cl31.flag(j) = data{1}{i+1+l}(2);
                                error_data_tmp=textscan(data{1}{i+1+l},'%s','delimiter',' ','MultipleDelimsAsOne',1);
                                cl31.error_str(j,:)=hex2bin(error_data_tmp{1}{5});
                                
                                %  Cloud Height on line 2: instantaneous
                                cloud_data_tmp=textscan(data{1}{i+1+l},'%s','delimiter',' ','MultipleDelimsAsOne',1);
                                %  disp(cloud_data_tmp{1})
                                switch str2double(cloud_data_tmp{1}{1}(1))
                                    case 0
                                        %nothing to do
                                    case 1
                                        cl31.cloud(j,1)= str2double(cloud_data_tmp{1}{2})*0.3048;
                                    case 2
                                        cl31.cloud(j,1)= str2double(cloud_data_tmp{1}{2})*0.3048;
                                        cl31.cloud(j,2)= str2double(cloud_data_tmp{1}{3})*0.3048;
                                    case 3
                                        cl31.cloud(j,1)= str2double(cloud_data_tmp{1}{2})*0.3048;
                                        cl31.cloud(j,2)= str2double(cloud_data_tmp{1}{3})*0.3048;
                                        cl31.cloud(j,3)= str2double(cloud_data_tmp{1}{4})*0.3048;
                                    case 4
                                        cl31.obscuration(j)=1;
                                        cl31.vertical_visibility(j)=str2double(cloud_data_tmp{1}{2})*0.3048;
                                    otherwise
                                        %                     disp('obscuration')
                                end
                                %   Cloud Height on line 3: Sky condition algorithm
                                cloud_data_tmp=textscan(data{1}{i+2+l},'%s','delimiter',' ','MultipleDelimsAsOne',1);
                                if ~strcmp(cloud_data_tmp{1}{2},'/////')
                                    cl31.cloud_layer(j,1)= str2double(cloud_data_tmp{1}{2})*100*0.3048;
                                end
                                if ~strcmp(cloud_data_tmp{1}{4},'/////')
                                    cl31.cloud_layer(j,2)= str2double(cloud_data_tmp{1}{4})*100*0.3048;
                                end
                                if ~strcmp(cloud_data_tmp{1}{6},'/////')
                                    cl31.cloud_layer(j,3)= str2double(cloud_data_tmp{1}{6})*100*0.3048;
                                end
                                if ~strcmp(cloud_data_tmp{1}{8},'/////')
                                    cl31.cloud_layer(j,4)= str2double(cloud_data_tmp{1}{8})*100*0.3048;
                                end
                                if ~strcmp(cloud_data_tmp{1}{10},'/////')
                                    cl31.cloud_layer(j,5)= str2double(cloud_data_tmp{1}{10})*100*0.3048;
                                end
                                cl31.cloud_amount(j,1)= str2double(cloud_data_tmp{1}{1});
                                cl31.cloud_amount(j,2)= str2double(cloud_data_tmp{1}{3});
                                cl31.cloud_amount(j,3)= str2double(cloud_data_tmp{1}{5});
                                cl31.cloud_amount(j,4)= str2double(cloud_data_tmp{1}{7});
                                cl31.cloud_amount(j,5)= str2double(cloud_data_tmp{1}{9});
                                
                                %Infos
                                param_data_tmp=textscan(data{1}{i+3+l},'%s','delimiter',' ','MultipleDelimsAsOne',1);
                                cl31.scalefac(j)=str2double(param_data_tmp{1}{1});
                                cl31.resolz(j)=str2double(param_data_tmp{1}{2});
                                cl31.lengthofprof(j)=str2double(param_data_tmp{1}{3});
                                cl31.nrjfac(j)=str2double(param_data_tmp{1}{4});
                                cl31.laser_temp(j)=str2double(param_data_tmp{1}{5});
                                cl31.windows_transmission(j)=str2double(param_data_tmp{1}{6});
                                cl31.tilt_angle(j)=str2double(param_data_tmp{1}{7});
                                cl31.bckgrd_rcs_910(j)=str2double(param_data_tmp{1}{8});
                                measur_param_str=param_data_tmp{1}{9};
                                cl31.pulse_qty(j)=str2double(measur_param_str(2:5))*1024;
                                %         cl31.measur_param(j)=str2double(param_data_tmp{1}{8});
                                cl31.sum_beta(j)=str2double(param_data_tmp{1}{10});
                                
                                % Profiles
                                rawline=data{1}{i+l+4};
                                if (length(rawline)-1)/5==770
                                    % If \r\n at the end of the line. Matlab considers it is and extra character
                                    rawline(end)=[];
                                    if j==1
                                        disp('Cr at the end of a Raw line')
                                    end
                                end
                                if length(rawline)/5==770
                                    tempvec = hex2dec(reshape(rawline',5,length(rawline)/5)');
                                    indneg  = find(tempvec>=(16^5)/2);
                                    tempvec(indneg)=tempvec(indneg)-16^5;
                                    cl31.rcs_910(j,:)=tempvec;
                                else
                                    warning(['Error for file ' list(k).name ' for line ' num2str(i+l+5+4) ' (length: ' num2str(length(rawline)/5) ')'])
                                    disp(rawline)
                                end
                                j=j+1;
                                
                            end
                            l = l+ 1;
                            
                        end
                    case 'type="PWD22"'
                        delimiter = {' ',''};
                        formatSpec = '%s%s%s%f%f%s%f%f%f%f%f%f%f%f%[^\n\r]';
                        % find where data ends
                        l = 1;
                        while ~contains(data{1}{i+l},'</data>')
                            if contains(data{1}{i+l},['<' date_str])
                                pwd.time(jjjj) = datenum(data{1}{i+l}(1:21),'<yyyy-mm-dd/HH:MM:SS>');
                                
                                
                                
                                %                             00 1839 1505 R- 61 61 61 0.33 12.16 0
                                % --- cumulative snow
                                % sum,0...999mm
                                % ------ cumulative water
                                % sum,0...99.99mm
                                % ------- water intensity 1 min
                                % ave,mm/h
                                % --- one hour present weather code,
                                % 0...99
                                % --- 15 minute present weather code, 0...99
                                % --- instant present weather code, 0 ... 99
                                % ---- instant present weather, NWS codes
                                % ------ visibility ten minute average, max 20000m
                                % ------ visibility one minute average, max 20000m
                                % - 1=hardware error, 2= hardware warning
                                % 3= backscatter alarm, 4= backscatter warning
                                % - 1= visibility alarm 1, 2= visibility alarm 2,
                                % 3= visibility alarm 3
                                %
                                
                                
                                data_pwd = textscan(data{1}{i+l}(22:end), formatSpec,...
                                    'Delimiter', delimiter, 'MultipleDelimsAsOne', true,...
                                    'EmptyValue' ,NaN, 'ReturnOnError', false,...
                                    'TreatAsEmpty',{'//','///','////','/////','//////'});
                                
                                pwd.visibility_alarm(jjjj)=data_pwd{1,3}{1}(1);
                                pwd.hardware_backscatter_warning(jjjj)=data_pwd{1,3}{1}(2);
                                pwd.visibility_1min(jjjj)=data_pwd{1,4}(1);
                                pwd.visibility_10min(jjjj)=data_pwd{1,5}(1);
                                pwd.instant_present_weather{jjjj}=data_pwd{1,6}{1};
                                pwd.instant_weather_present_code(jjjj)=data_pwd{1,7}(1);
                                pwd.present_weather_code_15min(jjjj)=data_pwd{1,8}(1);
                                pwd.present_weather_code_1hour(jjjj)=data_pwd{1,9}(1);
                                pwd.water_intensity_1min(jjjj)=data_pwd{1,10}(1);
                                pwd.cumulative_water(jjjj)=data_pwd{1,11}(1);
                                pwd.cumulative_snow(jjjj)=data_pwd{1,12}(1);
                                pwd.temperature(jjjj)=data_pwd{1,13}(1);
                                pwd.background_luminance(jjjj)=data_pwd{1,14}(1);
                                %                             pwd.instant_METAR{jjjj}=data_pwd{1}(1+1);
                                %                             pwd.recent_METAR{jjjj}=data_pwd{1}(1+1);
                                
                                jjjj=jjjj+1;
                            end
                            
                            l = l+ 1;
                        end
                    case 'type="WS600"'
                        %% WS600
                        switch data{1}{i+3}
                            case 'note="M0"'
                                % message standard
                                % find where data ends
                                l = 1;
                                while ~contains(data{1}{i+l},'</data>')
                                    if contains(data{1}{i+l},['<' date_str])
                                        WS600.time(jj) = datenum(data{1}{i+l}(1:21),'<yyyy-mm-dd/HH:MM:SS>');
                                        
                                        % Temperature in °C Ta C (Channel 100)
                                        % Dew point temperature in °C Tp C (Channel 110)
                                        % Wind chill temperature in °C Tw C (Channel 111)
                                        % Relative humidity in % Hr P (Channel 200)
                                        % Relative air pressure in hPa Pa H (Channel 305)
                                        % Wind speed in m/s Sa M (Channel 400)
                                        % Wind direction in ° Da D (Channel 500)
                                        % Precipitation quantity in mm Ra M (Channel 620)
                                        % Precipitation type Rt N (Channel 700)
                                        % Precipitation intensity in mm/h Ri M (Channel 820)
                                        %  006.6
                                        %  008.3
                                        %  083.0
                                        %  083.0
                                        %  0884.0
                                        %  000.6
                                        %  165.3
                                        %  00000.05
                                        %  000
                                        %  000.0
                                        
                                        %                                     format_ws = ['%6f%6f%6f%6f'...
                                        %                                         '%7f%6f%6f%8f%4f%6f'];
                                        % starts at 26 to get rid of Mo
                                        WS600_tmp = textscan(data{1}{i+l}(26:end),'%f','delimiter',';');
                                        WS600.T(jj) = WS600_tmp{1}(1);
                                        WS600.T_dew(jj) = WS600_tmp{1}(2);
                                        WS600.T_wind_chill(jj) = WS600_tmp{1}(3);
                                        WS600.RH(jj) = WS600_tmp{1}(4);
                                        WS600.P(jj) = WS600_tmp{1}(5);
                                        WS600.wind_speed(jj) = WS600_tmp{1}(6);
                                        WS600.wind_dir(jj) = WS600_tmp{1}(7);
                                        WS600.precip_qty(jj) = WS600_tmp{1}(8);
                                        WS600.precip_type(jj) = WS600_tmp{1}(9);
                                        WS600.precip_intensity(jj) = WS600_tmp{1}(10);
                                        jj =jj+1;
                                        
                                    end
                                    l = l+ 1;
                                end
                            case 'note="M2"'
                                % message maxwind speed
                                % find where data ends
                                l = 1;
                                while ~contains(data{1}{i+l},'</data>')
                                    if contains(data{1}{i+l},['<' date_str])
                                        WS600.time_max_wind(jjj) = datenum(data{1}{i+l}(1:21),'<yyyy-mm-dd/HH:MM:SS>');
                                        WS600_tmp = textscan(data{1}{i+l}(26:end),'%f','delimiter',';');
                                        WS600.wind_speed_max(jjj) = WS600_tmp{1}(3);
                                        jjj = jjj + 1;
                                    end
                                    l = l+ 1;
                                    
                                end
                        end
                        
                        
                        
                        
                    otherwise
                        disp(data{1}{i+2})
                end
            end
        end
    catch me
        disp_error(me)
        warning('Pb')
    end
    
end
cl31.range=(0:cl31.lengthofprof(1)-1)'*cl31.resolz(1)+cl31.resolz(1)/2;

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

disp('... Reading Done.')
if isfield(pwd,'time')
    pwd.datetime = datetime(pwd.time,'convertfrom','Datenum');
end
if isfield(WS600,'time')
    WS600.datetime = datetime(WS600.time,'convertfrom','Datenum');
end
if isfield(WS600,'time_max_wind')
    WS600.datetime_max_wind = datetime(WS600.time_max_wind,'convertfrom','Datenum');
end
if isfield(cl31,'time')
    cl31.datetime = datetime(cl31.time,'convertfrom','Datenum');
end
end
function bin=hex2bin(x)
% Function to convert Hexadecimal error code to a binary array
% hem 07/2016
for i=1:length(x)
    switch x(i)
        case 'F'
            bin((i*4)-3:i*4)=[1 1 1 1];
        case 'E'
            bin((i*4)-3:i*4)=[1 1 1 0];
        case 'D'
            bin((i*4)-3:i*4)=[1 1 0 1];
        case 'C'
            bin((i*4)-3:i*4)=[1 1 0 0];
        case 'B'
            bin((i*4)-3:i*4)=[1 0 1 1];
        case 'A'
            bin((i*4)-3:i*4)=[1 0 1 0];
        case '9'
            bin((i*4)-3:i*4)=[1 0 0 1];
        case '8'
            bin((i*4)-3:i*4)=[1 0 0 0];
        case '7'
            bin((i*4)-3:i*4)=[0 1 1 1];
        case '6'
            bin((i*4)-3:i*4)=[0 1 1 0];
        case '5'
            bin((i*4)-3:i*4)=[0 1 0 1];
        case '4'
            bin((i*4)-3:i*4)=[0 1 0 0];
        case '3'
            bin((i*4)-3:i*4)=[0 0 1 1];
        case '2'
            bin((i*4)-3:i*4)=[0 0 1 0];
        case '1'
            bin((i*4)-3:i*4)=[0 0 0 1];
        case '0'
            bin((i*4)-3:i*4)=[0 0 0 0];
        otherwise
            error(['Define error array for : ' x(i)])
    end
end
end
