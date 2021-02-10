1902222_holimo_log.txt:
The log file measured by HoloGondel on 22 February 2019. It contains columns 
including the time (UTC), the pressure, the temperature, the relative humidity, etc.
The columns can be read with the function "read_log_files.py".

190222_runs_gondola_up.txt:
Contains the start and end time of each considered measurement ride.

droplets_ge_40e-6.mat:
A structure array that contains the following fields:
prtclID: an ID given to every particle including the time of recording
campaign: name of campaign
instrument: name of instrument
classifiedBy: acronym for the person who classified the data
metricnames: acronyms of the all metrics that have been calculated (check Schlenczek 2018* for the meaning)
metricmat: the values of each metric defined in metricnames
prtclIm: complex image of each particle
class/cpType: label given by the classifier (classifiedBy)

RACLETS_merged_8-10h_lt_25e-6.nc:
A netCDF file that contains calculated properties droplets smaller than 25µm
in their major axis averaged over each of the nine rides,
like the concentration, totalCount, measurement volume etc.
E.g.: concentration_water = ncread(RACLETS_merged_8-10h_lt_25e-6.nc','Water_concentration');

RACLETS_merged_8-10h_rescaled_habits.nc:
A netCDF file that contains calculated properties of each class (Water, Ice, Ice_Plate,
Ice_Unidentified, Ice_Collumn, Ice_Irregular, Ice_aged) for particle larger than 25µm
in their major axis averaged over each of the nine rides,
like the concentration, totalCount, measurement volume etc.
E.g.: concentration_water = ncread('RACLETS_merged_8-10h_rescaled_habits.nc','Water_concentration');



*Schlenczek, O.: Airborne and Ground-based Holographic Measurement of Hydrometeors 
in Liquid-phase, Mixed-phase and Ice Clouds, Ph.D. thesis, Universitätsbibliothek Mainz, 2018