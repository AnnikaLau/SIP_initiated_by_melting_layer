# -*- coding: utf-8 -*-
"""
Created on Thu Jan 14 15:18:19 2021

@author: Annika
"""


from diffusional_growth_plates import*

t93_271,t60_271,t39_271 = diffusional_growth_plates(271,93e-6)
t93_272,t60_272,t39_272 = diffusional_growth_plates(272,93e-6)

conc_60_93 = 0.9
conc_60_93_unc = 0.3
conc_39_93 = 2.1
conc_39_93_unc = 0.5

t93_60_271 = t93_271-t60_271
t93_60_272 = t93_272-t60_272

t93_39_271 = t93_271-t39_271
t93_39_272 = t93_272-t39_272


min_Gsp_60_93 = 60*(conc_60_93-conc_60_93_unc)/t93_60_272
max_Gsp_60_93 = 60*(conc_60_93+conc_60_93_unc)/t93_60_271

min_Gsp_39_93 = 60*(conc_39_93-conc_39_93_unc)/t93_39_272
max_Gsp_39_93 = 60*(conc_39_93+conc_39_93_unc)/t93_39_271

min_Gsp = max(min_Gsp_39_93,min_Gsp_60_93)
max_Gsp = min(max_Gsp_39_93,max_Gsp_60_93)

mean_Gsp = (min_Gsp+max_Gsp)/2
unc_Gsp = (max_Gsp-min_Gsp)/2