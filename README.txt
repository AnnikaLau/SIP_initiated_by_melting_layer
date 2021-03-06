The folder "Software" contains all code that was used for plotting of data and for calculations done for the corresponding published manuscript "Continuous secondary ice production initiated by updrafts through the melting layer in mountainous regions" by Lauber et al. 2021, ACP. The corresponding data is published under https://doi.org/10.5281/zenodo.4534382.

Functions holding different copyrights are stated in the README file in the folder "Software".
In the following, all functions and data used for each plot are named as well as the plotting routine. The original publication for each data is named under origin.



Figure 1

Plot DHM with measurement locations

Origin: https://shop.swisstopo.admin.ch/de/products/height_models/dhm25200
Functions: plot_DHM.m, xyzread.m, xyz2grid.m, cbarrow.m
Data: /Data/DHM25/DHM200.xyz

Run on MATLAB:
path_DHM = '.../Data/DHM25/DHM200.xyz';
[x,y,z] = xyzread(path_DHM);
grid = xyz2grid(x,y,z);
xpos = [-10 10];
ypos = [-10 10];
plot_DHM(x,y,grid,'large',xpos,ypos,0);
plot_DHM(x,y,grid,'small',xpos,ypos,0);



Figure 3

Cloud radar plot

Origin: Cloudnet
Functions: read_cloud_radar.m, plot_cloud_radar.m, get_runs.m
Data: /Data/HoloGondel/190222_runs_gondola_up.txt, /Data/Cloudnet/20190222_davos_categorize.nc

Run on MATLAB:
ncpath= '.../Data/Cloudnet/';
runs_path = '.../Data/HoloGondel/190222_runs_gondola_up.txt';
YMD = '20190222';
[radar,height,~] = read_cloud_radar(ncpath,YMD);
startDate=datenum(2019,02,22,06,00,00);
endDate=datenum(2019,02,22,12,00,00);
runs = get_runs(runs_path);
plot_cloud_radar(radar,height,startDate,endDate,runs);


Ceilometer plot

Origin: http://dx.doi.org/10.16904/envidat.127
Functions: get_Klosters_data_from_files.m, plot_ceilometer.m, magma.m
Data: /Data/Ceilometer, /Data/HoloGondel/190222_runs_gondola_up.txt

Run on MATLAB:
root_folder='.../Data/Ceilometer/';
runs_path = '.../Data/HoloGondel/190222_runs_gondola_up.txt';
start_str = '20190222060000';
end_str = '20190222120000';
[cl31, ~, ~]=get_Klosters_data_from_files(start_str,end_str,root_folder);
runs = get_runs(runs_path);
plot_ceilometer(cl31,start_str,end_str,runs);


Temperature and RH plot

Origin: HoloGondel, http://dx.doi.org/10.16904/envidat.129
Functions: plot_temp_RH_Klosters_gondola.py, read_log_files.py, read_time_rides.py
Data: /Data/HoloGondel/190222_holimo_log.txt, /Data/HoloGondel/190222_runs_gondola_up.txt, /Data/Klosters_weather/raclets_weather_klosters.mat

Run on Python:
path_log_file = '.../Data/HoloGondel/190222_holimo_log.txt'
path_time_rides '.../Data/HoloGondel/190222_runs_gondola_up.txt'
path_data_Klosters = '.../Data/Klosters_weather/raclets_weather_klosters.mat'
from plot_temp_RH_Klosters_gondola import *
plot_temp_RH_Klosters_gondola(path_log_file,path_time_rides,path_data_Klosters)



Figure 4

Plot wind profiler

Origin: http://dx.doi.org/10.16904/envidat.130
Functions: plot_wind_profiler.m, windbarbs.m, uv2ddff.m
Data: /Data/Wind_profiler/wp_high_20190222_dav.csv

Run on MATLAB:
wind_path = '.../Data/Wind_profiler/wp_high_20190222_dav.csv';
plot_wind_profiler(wind_path)


Plot DHM with wind

Origin: https://shop.swisstopo.admin.ch/de/products/height_models/dhm25200, last access: 9 March 2020, Bundesamt für Meteorologie und Klimatologie, MeteoSchweiz
Functions: get_wind_IDAWEB.py, plot_DHM.m, xyzread.m, xyz2grid.m,  windbarbs.m, cbarrow.m
Data: /Data/DHM25/DHM200.xyz, /Data/Wind/order_80401_data.txt, /Data/Wind/Holfuy_data.csv

Run on MATLAB:
path_DHM = '.../Data/DHM25/DHM200.xyz';
[x,y,z] = xyzread(path_DHM );
grid = xyz2grid(x,y,z);
xpos = [-17 10];
ypos = [-10 15];
plot_DHM(x,y,grid,'small',xpos,ypos,1);



Figure 5

Plot random sample of ice crystals

Origin: HoloGondel
Functions: save_particle_images.m
Data: /Data/HoloGondel/ice_habits

Run on MATLAB:
ice_crystals_path = '.../Data/HoloGondel/ice_habits';
saving_folder = '.../Data/HoloGondel/';
per = 40;
save_particle_images(ice_crystals_path,saving_folder,per)


Plot histogram of size distribution of ice crystal habits

Origin: HoloGondel
Functions: plot_size_spectrum_ice.m, get_uncertainty_ice.m
Data: /Data/HoloGondel/ice_habits.mat, /Data/HoloGondel/RACLETS_merged_8-10h_rescaled_habits.nc

Run on MATLAB
ice_crystals_path = '.../Data/HoloGondel/ice_habits';
V_source = '.../Data/HoloGondel/RACLETS_merged_8-10h_rescaled_habits.nc';
plot_size_spectrum_ice(ice_crystals_path,V_source)



Figure 6

Plot cloud particle concentration over time

Origin: HoloGondel
Functions: plot_conc_time.m, get_uncertainty_ice.m, get_runs.m, rgb.m, mseb.m
Data: /Data/HoloGondel/RACLETS_merged_8-10h_rescaled_habits.nc, /Data/HoloGondel/RACLETS_merged_8-10h_lt_25e-6.nc', /Data/HoloGondel/ice_habits.mat, /Data/HoloGondel/190222_runs_gondola_up.txt

Run on MATLAB
source_big = '.../Data/HoloGondel/RACLETS_merged_8-10h_rescaled_habits.nc';
source_small = '.../Data/HoloGondel/RACLETS_merged_8-10h_lt_25e-6.nc';
ice_crystals_path = '.../Data/HoloGondel/ice_habits';
runs_path = '.../Data/HoloGondel/190222_runs_gondola_up.txt';
runs = get_runs(runs_path);
plot_conc_time(source_big,source_small,ice_crystals_path,runs)



Figure 8

Plot parameter over droplet size

Origin: HoloGondel
Functions: calculate_production_rate_observations.py, diffusional_growth_plates.py, calculate_splinter_production.m, get_fall_velocity.m, get_fcol.m, get_pdf.m, plot_parametrization_parameters.m
Data: /Data/HoloGondel/RACLETS_merged_8-10h_rescaled_habits.nc, /Data/HoloGondel/droplets_ge_40e-6.mat, /Data/HoloGondel/ice_habits.mat

Run on MATLAB
V_source = '.../Data/HoloGondel/RACLETS_merged_8-10h_rescaled_habits.nc';
droplets_path = .../Data/HoloGondel/droplets_ge_40e-6';
ice_crystals_path = '.../Data/HoloGondel/ice_habits';
plot_parametrization_parameters(droplets_path, ice_crystals_path,V_source)

