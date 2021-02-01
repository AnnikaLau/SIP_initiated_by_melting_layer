# -*- coding: utf-8 -*-
"""
Created on Mon Aug 19 12:22:49 2019

@author: Annika
"""

import numpy as np
import pandas as pd

def datetime_range(start, end, delta):
    current = start
    while current < end:
        yield current
        current += delta
    

#path = 'C:/melting_layer/Data/IDAWEB/order_80401_data.txt'
def get_wind_IDAWEB(path):

    
    f = open(path,'r')
    all_data = [line.strip() for line in f.readlines()]
    datasets = {}
    x=0
    
    while x<len(all_data):
        header = all_data[x]
        header = header.split(';')
        dataset = {}
        data_new =[]
        x=x+1
        while all_data[x]: #end of first data entry
            datapoints = all_data[x]
            datapoints = datapoints.split(';')
            data_new.append(datapoints)
            #station.append(data[0])
            x = x+1
        data = np.array(data_new)
        for y in range(0,len(header)):
            dataset[header[y]] = data[:,y]
        data_name = dataset['stn'][0]
        datasets[data_name] = dataset
        # print(data_name)
        x=x+1
        
    
    start_time = '2019-02-22 08:00:00'
    end_time = '2019-02-22 10:00:00'
    winddir = {}
    windspeed = {}
    for station in datasets.keys():
        if 'dkl010z0' in datasets[station].keys():
            winddir[station] = datasets[station]['dkl010z0']
        elif 'dkl000i0' in datasets[station].keys():
            winddir[station] = datasets[station]['dkl000i0']   
        if station in winddir.keys():
            emp = [i for i,x in enumerate(winddir[station]) if x =='-']
            winddir[station] = np.delete(winddir[station],emp)
            winddir[station]= list(map(int,winddir[station]))
            winddir[station] = np.array(winddir[station])
            time = datasets[station]['time']
            time = np.delete(time,emp)
            time = list(map(int,time))
            time = np.array(time)
            date=pd.to_datetime(time,format='%Y%m%d%H%M')
            index = pd.DatetimeIndex(date)
            winddir[station] = pd.Series(winddir[station],index = index)
        if 'fkl010z0' in datasets[station].keys():
            windspeed[station] = datasets[station]['fkl010z0']
        elif 'fkl000i0' in datasets[station].keys():
            windspeed[station] = datasets[station]['fkl000i0']
        elif 'fu3000i0' in datasets[station].keys():
            windspeed[station] = datasets[station]['fu3000i0']
            emp = [i for i,x in enumerate(windspeed[station]) if x =='-']
            windspeed[station] = np.delete(windspeed[station],emp)
            windspeed[station]= list(map(float,windspeed[station]))
            windspeed[station] = np.array(windspeed[station])
            windspeed[station] = windspeed[station]*(10/36)
        if station in windspeed.keys():
            emp = [i for i,x in enumerate(windspeed[station]) if x =='-']
            windspeed[station] = np.delete(windspeed[station],emp)
            windspeed[station]= list(map(float,windspeed[station]))
            windspeed[station] = np.array(windspeed[station])
            time = datasets[station]['time']
            time = np.delete(time,emp)
            time = list(map(int,time))
            time = np.array(time)
            date=pd.to_datetime(time,format='%Y%m%d%H%M')
            index = pd.DatetimeIndex(date)
            windspeed[station] = pd.Series(windspeed[station],index = index)
    
    
    
    winddir_mean = {}
    #Get mean winddir
    for station in winddir.keys():
        # east=[]
        # east = np.where(winddir[station][start_time:end_time]>45) and np.where(winddir[station][start_time:end_time]<135)
        east = [(winddir[station][start_time:end_time]>45) & (winddir[station][start_time:end_time]<135)]
        e=sum(sum(east))
        #south = np.where(winddir[station][start_time:end_time]>135) and np.where(winddir[station][start_time:end_time]<225)
        south = [(winddir[station][start_time:end_time]>135) & (winddir[station][start_time:end_time]<225)]
        s=sum(sum(south))
        west = [(winddir[station][start_time:end_time]>225) & (winddir[station][start_time:end_time]<315)]
        w=sum(sum(west))
        north = [(winddir[station][start_time:end_time]>315) | (winddir[station][start_time:end_time]<45)]
        n=sum(sum(north))
        m=max(e,s,w,n)
        if e == m:
            #West at 0
            wd = 90 + winddir[station][start_time:end_time]
            pos = np.argwhere(wd>360)
            wd[pos] = wd[pos]-360
            winddir_mean[station] = np.nanmean(wd)
            winddir_mean[station] = winddir_mean[station]-90
        elif s==m:
            winddir_mean[station] = np.nanmean(winddir[station][start_time:end_time])
        elif w==m:
            #East at 0
            wd = -90 + winddir[station][start_time:end_time]
            pos = np.argwhere(wd<0)
            wd[pos] = wd[pos]+360
            winddir_mean[station] = np.nanmean(wd)
            winddir_mean[station] = winddir_mean[station]+90
        elif n==m:
            #South at 0
            wd = 180 + winddir[station][start_time:end_time]
            pos = np.argwhere(wd>360)
            wd[pos] = wd[pos]-360
            winddir_mean[station] = np.nanmean(wd)
            winddir_mean[station] = winddir_mean[station]-180
            if winddir_mean[station]<0:
                winddir_mean[station] = winddir_mean[station]+360    
    
    windspeed_mean = {}            
    for station in windspeed.keys():
        windspeed_mean[station] = np.mean(windspeed[station][start_time:end_time])
        
        
    return winddir_mean, windspeed_mean



