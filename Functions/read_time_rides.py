# -*- coding: utf-8 -*-
"""
Created on Thu Jan  7 11:16:08 2021

@author: Annika
"""


import numpy as np
import string
from datetime import datetime

# To get same time values as in Matlab
def datenum(d):
    return 366 + d.toordinal() + (d - datetime.fromordinal(d.toordinal())).total_seconds()/(24*60*60)

day = '2019-02-22'
def read_time_rides(time_rides):
    lines = [line.rstrip('\n') for line in open(time_rides)]
    start = lines[0:len(lines):3]
    end = lines[1:len(lines):3]
    start_time = np.zeros(len(start))
    end_time = np.zeros(len(start))
    ## Split time start and end vectors
    for x in range(0,len(start)):
        start[x] = start[x].translate({ord(c): None for c in string.whitespace})
        input_string = day+' '+start[x]
        time_string = datetime.strptime(input_string,'%Y-%m-%d %H:%M:%S')
        start_time[x] = datenum(time_string)
        end[x] = end[x].translate({ord(c): None for c in string.whitespace})
        input_string = day+' '+end[x]
        time_string = datetime.strptime(input_string,'%Y-%m-%d %H:%M:%S')
        end_time[x] = datenum(time_string)
    return start_time,end_time