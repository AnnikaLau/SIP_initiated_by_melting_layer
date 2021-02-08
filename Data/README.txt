Figure 1

Plot DHM with measurement locations

Origin: https://shop.swisstopo.admin.ch/de/products/height_models/dhm25200, last access: 9 March 2020
Functions: plot_DHM, xyzread, xyz2grid, cbarrow
Data: /Data/DHM25/DHM200.xyz

[x,y,z] = xyzread('C:\melting_layer\Data\DHM25\DHM200.xyz');
grid = xyz2grid(x,y,z);
xpos = [-10 10];
ypos = [-10 10];
plot_DHM(x,y,grid,'large',xpos,ypos,0);
plot_DHM(x,y,grid,'small',xpos,ypos,0);


Figure 3

Cloud radar plot

Origin: Cloudnet quicklooks Davos: http://lacros.rsd.tropos.de/cloudnet/cloudnet.php?site=davos&year=2019&month=02&day=22&plot=1
Functions: read_cloud_radar, plot_cloud_radar, get_runs
Data: /Data/HoloGondel/190222_runs_gondola_up.txt, /Data/Cloudnet/20190222_davos_categorize.nc

ncpath= 'C:\melting_layer\Data\Cloudnet\';
runs_path = 'C:\melting_layer\Data\HoloGondel\190222_runs_gondola_up.txt';
YMD = '20190222';
[radar,height,~] = read_cloud_radar(ncpath,YMD);
startDate=datenum(2019,02,22,06,00,00);
endDate=datenum(2019,02,22,12,00,00);
runs = get_runs(runs_path);
plot_cloud_radar(radar,height,startDate,endDate,runs);


Ceilometer plot

Origin: http://dx.doi.org/10.16904/envidat.127
Functions: get_Klosters_data_from_files, plot_ceilometer, magma
Data: /Data/Ceilometer, /Data/HoloGondel/190222_runs_gondola_up.txt

root_folder='C:\melting_layer\Data\Ceilometer\';
runs_path = 'C:\melting_layer\Data\HoloGondel\190222_runs_gondola_up.txt';
start_str = '20190222060000';
end_str = '20190222120000';
[cl31, ~, ~]=get_Klosters_data_from_files(start_str,end_str,root_folder);
runs = get_runs(runs_path);
plot_ceilometer(cl31,start_str,end_str,runs);


Temperature and RH plot

Origin: HoloGondel, http://dx.doi.org/10.16904/envidat.129
Functions: plot_temp_RH_Klosters_gondola.py, read_log_files.py, read_time_rides.py
Data: /Data/HoloGondel/190222_holimo_log.txt, /Data/HoloGondel/190222_runs_gondola_up.txt, /Data/weather_stations/raclets_weather_klosters.mat

run plot_temp_RH_Klosters_gondola.py



Figure 4

Plot wind profiler

Origin: http://dx.doi.org/10.16904/envidat.130
Functions: plot_wind_profiler, windbarbs, uv2ddff
Data: /Data/wind_profiler/wp_high_20190222_dav.csv

wind_path = 'C:\melting_layer\Data\wind_profiler\wp_high_20190222_dav.csv';
plot_wind_profiler(wind_path)


Plot DHM with wind

Origin: https://shop.swisstopo.admin.ch/de/products/height_models/dhm25200, last access: 9 March 2020, Bundesamt für Meteorologie und Klimatologie, MeteoSchweiz
Functions: plot_DHM, xyzread, xyz2grid, get_wind_IDAWEB.py, windbarbs, cbarrow
Data: /Data/DHM25/DHM200.xyz, /Data/IDAWEB/order_80401_data.txt

path_DHM = 'C:\melting_layer\Data\DHM25\DHM200.xyz';
[x,y,z] = xyzread(path_DHM );
grid = xyz2grid(x,y,z);
xpos = [-17 10];
ypos = [-10 15];
plot_DHM(x,y,grid,'small',xpos,ypos,1);


Figure 5

Plot random sample of ice crystals

Origin: HoloGondel
Functions: save_particle_images
Data: /Data/HoloGondel/ice_habits

ice_crystals = 'C:\melting_layer\Data\HoloGondel\ice_habits';
saving_folder = 'C:\melting_layer\Functions\Test';
per = 40;
save_particle_images(ice_crystals,saving_folder,per)


Plot histogram of size distribution of ice crystal habits

Origin: HoloGondel
Functions: plot_size_spectrum_ice.m, get_uncertainty_ice.m
Data: /Data/HoloGondel/ice_habits.mat, /Data/HoloGondel/RACLETS_merged_8-10h_rescaled_habits.nc

ice_crystals = 'C:\melting_layer\Data\HoloGondel\ice_habits';
V_source = 'C:\melting_layer\Data\HoloGondel\RACLETS_merged_8-10h_rescaled_habits.nc';
plot_size_spectrum_ice(ice_crystals,V_source)



Figure 6

Plot cloud particle concentration over time

Origin: HoloGondel
Functions: plot_conc_time.m, get_uncertainty_ice.m, get_runs.m, rgb.m, mseb.m
Data: /Data/HoloGondel/RACLETS_merged_8-10h_rescaled_habits.nc, /Data/HoloGondel/RACLETS_merged_8-10h_lt_25e-6.nc', /Data/HoloGondel/ice_habits.mat, /Data/HoloGondel/190222_runs_gondola_up.txt

source_big = 'C:\melting_layer\Data\HoloGondel\RACLETS_merged_8-10h_rescaled_habits.nc';
source_small = 'C:\melting_layer\Data\HoloGondel\RACLETS_merged_8-10h_lt_25e-6.nc';
ice_crystals = 'C:\melting_layer\Data\HoloGondel\ice_habits';
runs_path = 'C:\melting_layer\Data\HoloGondel\190222_runs_gondola_up.txt';
runs = get_runs(runs_path);
plot_conc_time(source_big,source_small,ice_crystals,runs)


Figure 8

Plot parameter over droplet size

Origin: HoloGondel
Functions: calculate_production_rate_observations.py, diffusional_growth_plates.py, calculate_splinter_production.m, get_fall_velocity.m, get_fcol.m, get_pdf.m, plot_parametrization_parameters.m
Data: /Data/HoloGondel/RACLETS_merged_8-10h_rescaled_habits.nc, /Data/HoloGondel/droplets_ge_40e-6.mat, /Data/HoloGondel/ice_habits.mat

V_source = 'C:\melting_layer\Data\HoloGondel\RACLETS_merged_8-10h_rescaled_habits.nc';
droplets = 'C:\melting_layer\Data\HoloGondel\droplets_ge_40e-6';
ice_crystals = 'C:\melting_layer\Data\HoloGondel\ice_habits';
plot_parametrization_parameters(droplets, ice_crystals,V_source)

