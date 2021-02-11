source = 'C:\melting_layer\Data\HoloGondel\RACLETS_merged_8-10h_rescaled_habits.nc';
vinfo = ncinfo(source);
dimNames = {vinfo.Dimensions.Name};
varNames = {vinfo.Variables.Name};
attNames = {vinfo.Attributes.Name};

Total_volume = ncread(source,'Total_volume');