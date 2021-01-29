# -*- coding: utf-8 -*-
"""
Created on Thu Jan  7 11:02:00 2021

@author: Annika
"""


import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import scipy.io
from datetime import datetime, timedelta
import numpy as np
from read_log_files import *
from read_time_rides import *

myFmt = mdates.DateFormatter('%H:%M')
start_time = '2019-02-22 08:00:00'
end_time = '2019-02-22 10:00:00'
log_file = 'C:/melting_layer/Data/HoloGondel/190222_holimo_log.txt'
time_rides = "C:/melting_layer/Data/HoloGondel/190222_runs_gondola_up.txt"
#To be downloaded from http://dx.doi.org/10.16904/envidat.129
data_Klosters = 'C:/melting_layer/Data/weather_stations/raclets_weather_klosters.mat'

def datenum(d):
    return 366 + d.toordinal() + (d - datetime.fromordinal(d.toordinal())).total_seconds()/(24*60*60)

#Function to reverse datenum
def datestr(x, tz=None):
    dt = datetime.fromordinal(int(x)) + timedelta(days=x%1) - timedelta(days = 366)
    return dt

#Read in data from weather station in Klosters
mat = scipy.io.loadmat(data_Klosters)
data_KLA = mat['WS']
T_KLA = data_KLA['T']
T_KLA = T_KLA[0][0][0]
T_KLA = np.array(T_KLA,dtype=np.float)
RH_KLA = data_KLA['RH']
RH_KLA = RH_KLA[0][0][0]
RH_KLA = np.array(RH_KLA,dtype=np.float)
time_KLA = data_KLA['time']
time_KLA = time_KLA[0][0][0]
time_KLA = np.array([datestr(time_KLA[i]) for i in range(len(time_KLA))])
index_KLA = pd.DatetimeIndex(time_KLA)
T_KLA = pd.Series(T_KLA,index = index_KLA)
RH_KLA = pd.Series(RH_KLA,index=index_KLA)


#Read in log file from HOLIMO
log = read_log_file(start_time,end_time,log_file)
day_of_month = log['day_of_month'][0]
month = log['month'][0]
year = log['year'][0]
hour = log['hour'][0]
minute = log['minute'][0]
second = log['second'][0]
time_gondel = [str(day_of_month[i])+'/'+str(month[i])+'/'+str(year[i])+' ' +str(hour[i])+':'+str(minute[i])+':'+str(second[i]) for i in range(0,len(month))]
index_gondel = pd.DatetimeIndex(time_gondel)
T_gondel = pd.Series(log['temp'][0],index = index_gondel)
RH_gondel = pd.Series(log['rh'][0],index = index_gondel)
time_gondel = [datenum(index_gondel[i]) for i in range(0,len(index_gondel))]


#Read in time of gondola rides
[start_time_ride,end_time_ride] = read_time_rides(time_rides)


#Derive temperature at Gotschnaboden (Gondola at lowest point considered for measurements)
idx_gb = [np.argmin(np.abs(time_gondel-start_time_ride[i])) for i in range(0,len(start_time_ride))]
T_GB=T_gondel[idx_gb]
RH_GB=RH_gondel[idx_gb]
index_GB = index_gondel[idx_gb]
T_GB = pd.Series(T_GB,index=index_GB)
RH_GB = pd.Series(RH_GB,index=index_GB)
#Derive temperature at Gotschnagrat (Gondola at highest point considered for measurements)
idx_gg = [np.argmin(np.abs(time_gondel-end_time_ride[i])) for i in range(0,len(end_time_ride))]
T_GG=T_gondel[idx_gg]
RH_GG=RH_gondel[idx_gg]
index_GG = index_gondel[idx_gg]
T_GG = pd.Series(T_GG,index=index_GG)
RH_GG = pd.Series(RH_GG,index=index_GG)

time_gb = np.array([datestr(start_time_ride[i]) for i in range(len(start_time_ride))])
time_gg = np.array([datestr(end_time_ride[i]) for i in range(len(end_time_ride))])
x_gr = np.column_stack((time_gb,time_gg))
y_gr = np.column_stack((T_GB,T_GG))
y_gr_RH = np.column_stack((RH_GB,RH_GG))


#Melting layer
melting = [0,0]
time_melting = [start_time,end_time]
time_melting = pd.to_datetime(time_melting)
index_melting = pd.DatetimeIndex(time_melting)
melting = pd.Series(melting, index=index_melting)


#Lines for gondel rides
fs=25
f=1
plt.figure(f)
gr = plt.plot(x_gr.transpose(),y_gr.transpose(),color = [0.7, 0.7, 0.7])
gg, = plt.plot(T_GG[start_time:end_time].index,T_GG[start_time:end_time],label='Gotschnagrat 2300m',color = [0,0.447,0.741])
gb, = plt.plot(T_GB[start_time:end_time].index,T_GB[start_time:end_time],label='Gotschnaboden 1700m',color = [0.9290, 0.6940, 0.1250])
kla, = plt.plot(T_KLA[start_time:end_time].index,T_KLA[start_time:end_time],label='Klosters 1200m',color = [0, 0.5, 0])
m = plt.plot(melting[start_time:end_time].index,melting[start_time:end_time],'k')
plt.gcf().autofmt_xdate()
plt.gca().xaxis.set_major_formatter(myFmt)
plt.gca().invert_yaxis()
plt.xlim(start_time,end_time)
plt.ylim(4,-3)
plt.xlabel('Time (UTC)',fontsize=fs)
plt.ylabel('Temperature (°C)',fontsize=fs)
plt.tick_params(right=True)
plt.yticks(fontsize=fs)
plt.xticks(fontsize=fs)
plt.show()

f=2
plt.figure(f)
gr = plt.plot(x_gr.transpose(),y_gr_RH.transpose(),color = [0.7, 0.7, 0.7])
gg, = plt.plot(RH_GG[start_time:end_time].index,RH_GG[start_time:end_time],label='Gotschnagrat 2300m',color = [0,0.447,0.741])
gb, = plt.plot(RH_GB[start_time:end_time].index,RH_GB[start_time:end_time],label='Gotschnaboden 1700m',color = [0.9290, 0.6940, 0.1250])
kla, = plt.plot(RH_KLA[start_time:end_time].index,RH_KLA[start_time:end_time],label='Klosters 1200m',color = [0, 0.5, 0])
plt.gcf().autofmt_xdate()
plt.gca().xaxis.set_major_formatter(myFmt)
plt.xlim(start_time,end_time)
plt.ylim(75,100)
plt.xlabel('Time (UTC)',fontsize=fs)
plt.ylabel('RH (%)',fontsize=fs)
plt.tick_params(right=True)
plt.yticks(fontsize=fs)
plt.xticks(fontsize=fs)
plt.show()



