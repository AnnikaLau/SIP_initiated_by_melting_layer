function [radar_data,radar_height,model_height] = read_cloud_radar(ncpath,YMD)
filepath = [ncpath,YMD,'_davos_categorize.nc'];
ncdisp(filepath)
par = {'rainrate','lwp','lwp_error','Z','v','width','ldr','Z_error','beta','lidar_depolarisation','temperature','pressure','specific_humidity','uwind','vwind','radar_gas_atten','radar_liquid_atten','sigma_zbeta','mean_zbeta','numgates_zbeta','category_bits','quality_bits'};
radar_time_tmp = double(ncread(filepath,'time'));
radar_time = datenum(0,0,0,radar_time_tmp,0,0)+datenum(YMD,'yyyymmdd');
radar_height = ncread(filepath,'height');
model_height = ncread(filepath,'model_height');

for i = 1:length(par)
    data_tmp.(par{i}) = ncread(filepath,par{i});
end
radar_data = timeserie(radar_time,data_tmp);
end