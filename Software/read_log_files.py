# -*- coding: utf-8 -*-
"""
Created on Thu May  9 12:06:32 2019

@author: Annika
"""
import numpy as np
import csv


def read_log_file(start_time,end_time,log_file):
    f = open(log_file,'r')
    #Add encoding='Latin' if necessary
    all_data = [line.strip() for line in f.readlines()]
    header = all_data[0]
    header = header.split(';')
    h = header.index(' Hour ')
    m = header.index(' Minute ')
    s = header.index(' Second ')
    p = header.index('Pressure ')
    t = header.index('Rotronic_Temp ')
    r = header.index(' Rotronic_RH ')
    dom = header.index(' Day_of_month ')
    d = header.index(' Day_of_Year ')
    mo = header.index(' Month ')
    y = header.index(' Year ')
    
    hour = []
    minute=[]
    second=[]
    pressure=[]
    temp=[]
    rh = []
    day_of_month = []
    day = []
    month = []
    year = []
    f.close()

    with open(log_file,'r') as csvfile:
        #Add encoding='Latin' if necessary
        x = csv.reader(csvfile,delimiter=';')
        for column in x:
            hour.append(column[h])
            minute.append(column[m])
            second.append(column[s])
            pressure.append(column[p])
            temp.append(column[t])
            rh.append(column[r])
            day.append(column[d])
            month.append(column[mo])
            year.append(column[y])
            day_of_month.append(column[dom])
    hour=np.asarray(hour[2:])
    minute=np.asarray(minute[2:])
    second=np.asarray(second[2:])
    pressure=np.asarray(pressure[2:])
    temp=np.asarray(temp[2:])
    rh=np.asarray(rh[2:])
    day=np.asarray(day[2:])
    month=np.asarray(month[2:])
    year =np.asarray(year[2:])
    day_of_month = np.asarray(day_of_month[2:])
    
    
    hour=hour.astype(np.int)
    minute=minute.astype(np.int)
    second=second.astype(np.int)
    pressure=pressure.astype(np.float)
    temp=temp.astype(np.float)
    rh=rh.astype(np.float)
    day=day.astype(np.int)
    month=month.astype(np.int)
    year = year.astype(np.int)
    day_of_month = day_of_month.astype(np.int)
    log = {'hour':[hour],'minute':[minute],'second':[second],'pressure':[pressure],
           'temp':[temp],'rh':[rh],'day':[day],'month':[month],'year':[year],
           'day_of_month':[day_of_month]}
    return log




