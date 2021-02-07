# -*- coding: utf-8 -*-
"""
Created on Wed Jul  1 12:07:43 2020

@author: Annika
"""


import numpy as np
from numpy import pi
import math



#Constants:
T0 = 273.15 # K 
p0 = 101325 # Pa
M_air =(0.21*0.031998+0.79*0.0280134) # kg/mol, molar mass of dry air
R = 8.3144598 # J/(mol K) gas constant
Ra = R/M_air #J/(kgK), specific gas constant for dry air
cv = 718# J/kgK specific heat of air at constant volume from Lohmann et al. 2016 "An Introduction to Clouds: From the Microscale to Climate"
M_H2O = 0.01801528 # kg/mol, molar mass of water
Rv = R/M_H2O # specific gas constant of water vapor
alp = 0.5 #Lohmann et al. 2016 "An Introduction to Clouds: From the Microscale to Climate" (p.240): Rogers & Yau 1989
lam = 0.01 #deposition coefficient from Fukuta and Walter 1970, estimated from Fig. 2


#Variables
def e_sw(T): # Pa, from Murphy and Koop (2005)
    return np.exp(54.842763 - 6763.22/T - 4.210*np.log(T) + 0.000367*T + np.tanh(0.0415*(T-218.8))*(53.878-1331.22/T - 9.44523*np.log(T) + 0.014025*T))
 	
def e_si(T): # Pa, from Murphy and Koop (2005)
 	return np.exp(9.550426-5723.265/T + 3.53068*np.log(T)-0.00728332*T)

def rhoWater(T): # kg/m^3 Marcolli 2016, ACP, valid 50 - 393 K
 	return 1000.*(1.8643535 - 0.0725821489 * T + 2.5194368 * 10.**(-3.) * T**2. -4.9000203 * 10.**(-5.) * T**3. + 5.860253 * 10.**(-7.) * T**4. -4.5055151 * 10.**(-9.) * T**5. + 2.2616353 * 10.**(-11.) * T**6. -7.3484974 * 10.**(-14.) * T**7. + 1.4862784 * 10.**(-16.) * T**8. -1.6984748 * 10.**(-19.) * T**9. + 8.3699379 * 10.**(-23.) * T**10.)
 	
def rhoIce(T):
 	return 1000*(-1*0.0000000194*(T**3) + 0.0000134369*(T**2) - 0.0032100567*T + 1.1872383345)
 
def rhoAir(T,p): #Density of dry air
    return(p/(Ra*T))

def rhoSat(T): #The saturated vapor density at T
    return(e_si(T)/(Rv*T))  

def Lv(T): # J/(kg), from Murphy and Koop (2005)
 	return (56579-42.212*T+np.exp(0.1149*(281.6-T)))/0.01801528
 	
def Ls(T): # J/(kg), from Murphy and Koop (2005)
 	return (46782.5+35.8925*T-0.07414*T**2+541.5*np.exp(-1*(T/123.75))**2)/0.01801528
 	
def nu(T, p, M_air, R): # m^2/s, kinematic viscosity, Sutherland Equation
 	return(0.000001458*T**(3./2.)/(T+110.4))/rhoAir(T,p)

def mu(T): # kg/(m*s), dynamic viscosity, Sutherland Equation
 	return(0.000001458*T**(3./2.)/(T+110.4))
 
def baselength(m,ar,T): #Baselength of hexagonal plate with mass m and the aspect ratio 2a/h=ar with a being the baselength and h the thickness of a plate
    # rho = 900 # Density of hexagonal plate: Mitchell et al 1990    
    a = (m*ar/(rhoIce(T)*3*math.sqrt(3)))**(1/3)
    h = 2*a/ar
    return a, h

def radius(m,T): #Calculate radius of spherical ice with mass m
    return((3*m/(rhoIce(T)*4*pi))**(1/3))

def mass_sphere(r): #Calculate the mass of a sphere with the radius r
    if r<35e-6: #Effective radius of small ice crystals by Cotton et al 2013
        rho = 700
        m = rho*4*pi*(r**3)/3
    else:
        m = 0.0257*((2*r)**2)
    return(m)

def mass_hexagon_shape(a,ar,T): #Mass of a hexagonal plate with the baselength a and the thickness h
    # rho = 900 #Density of hexagonal plate: Mitchell et al. 1990
    h = 2*a/ar
    return(3*math.sqrt(3)*a**2*h*rhoIce(T)/2)

def mass_hexagon(r): #Mass of a hexagonal plate with the maximum dimension of 2*r
    # rho = 900 #Density of hexagonal plate: Mitchell et al. 1990, table 3
    return((0.032*(2*r*1e3)**2.5)*1e-6)

def mass_column_short(r): #Mass of column short as in Mitchell et al. 1990
    return((0.064*(2*r*1e3)**2.6)*1e-6)

def mass_column_long(r): #Mass of column short as in Mitchell et al. 1990
    return((0.012*(2*r*1e3)**1.8)*1e-6)

def ff(nd,rd,r): #Fog factor (Marshall and Langleben 1954), Fuktua & Takahashi 1999, eq. 3
    k = math.sqrt(4*pi*nd*rd) #Fuktua & Takahashi 1999, eq. 4
    return(1+k*r)

def C0_plate(r): #Capacitance of circular disk of radius r as idealization of simple thin hexagonal ice plate, Pruppacher & Klett 1998, eq. 13-77
    return(2*r/pi)

def C0_column(r,ar): #Capacitance of circular disk of radius r as idealization of simple thin hexagonal ice plate, Pruppacher & Klett 1998, eq. 13-77
    ac = 2*r
    bc = ac/ar
    A = math.sqrt(ac**2-bc**2)    
    return(A/math.log((ac+A)/bc))

def K(T): # W/(m K), thermal conductivity coefficient air, Beard and Pruppacher 1971
    return(4.1868E-3 * (5.69 + 0.017 * (T- T0)))

def Si(Sw,T): #Saturation with respect to ice at saturation with respect to water Sw at temperature T
    return(Sw*e_sw(T)/e_si(T))

def Dv(T,p): # m^2/s, water vapor diffusion coefficient in air, Hall and Pruppacher, 1976
    return(2.11E-5 * (T/T0)**1.94 * (p0/p))

def fy(m,T,p): #Effect deposition, Fukuta & Takahashi 1999, Eq. 8
    ly = ((2-lam)*Dv(T,p)/(2*lam))*math.sqrt(2*pi/(Rv*T)) #Fukuta & Takahashi 1999, Eq. 9 
    return(radius(m,T)/(radius(m,T)+ly))

def fa(m,T,p): #Effect thermal accomodation, Fukuta & Takahashi 1999, Eq. 8
    la = ((2-alp)*K(T)*math.sqrt(2*pi*Ra*T))/(2*alp*p*(cv+0.5*Ra)) #Fukuta & Takahashi 1999, Eq. 9 
    return(radius(m,T)/(radius(m,T)+la))

def Sc(T,p): #Schmidt number
    v = mu(T)/rhoAir(T,p)
    return(v/Dv(T,p))

def Re(w,d,T,p): #Reynolds number
    return(w*d/nu(T, p, M_air, R))

def fv(w,d,T,p): #ventilation factor for mass transfer, Pruppacher & Klett 1978, Fukuta & Takahashi 1999, eq. 5
    X = Sc(T,p)**(1/3)*math.sqrt(Re(w,d,T,p)) #Fukuta & Takahashi 1999, eq. 5
    if X<1:
        fv = 1+0.14*X**2
    else:
        fv = 0.86+0.28*X
    return(fv)

def diam_hexagon(m): #From Mitchell et al. 1990, Table 3
    d = ((m*1e6/0.032)**(1/2.5))*1e-3
    return(d)

def diam_column_long(m): #From Mitchell et al. 1990, Table 3
    d = ((m*1e6/0.012)**(1/1.8))*1e-3
    return(d)

def diam_column_short(m): #From Mitchell et al. 1990, Table 3
    d = ((m*1e6/0.064)**(1/2.6))*1e-3
    return(d)

def width_hexagon(r): #From Mitchell et al. 1990, Table 3
    return((0.0449*((2*r*1e3)**0.449))*1e-3)

def find_min(dia,siz): #Find position in diameter array, which is the closest to the given diameter
    temp = min(abs(dia-siz)) 
    res = [i for i, j in enumerate(abs(dia-siz)) if j == temp]   
    return(res)


def diffusional_growth_plates(T,d_max):
    #Conditions/Assumptions:
    p = 78000. # Pa, Pressure at gondola   
    Sw = 1.00 # Saturation with respect to water
    r_0 = 2.5e-6 # m size of splinter
    nd = 156*1e6 #m^-3, CDNC 
    rd = 8*1e-6 #m, average droplet radii
    d = 100e-6#particular characteristic, size of plate
    #Terminal fall velocity of plate from Purppacher and Klett 2010 (Table 10.3a P1a)
    w = (297*(d*1e2)**0.86)*1e-2
    # w = w*1.5 #Due to turbulence, Pinsky & Khain fig. 12, 3 times greater for strong turbulence
    ar = 1/10 #expected aspect ratio of plates 2*baselength/thickness
    #d_max = 93e-6 #Maximum size a plate should reach
    
    Fk = (Ls(T)/(Rv*T))*(Ls(T)/(K(T)*T)) #-1 in first bracket to make equal as in book
    Fd = (Rv*T)/(Dv(T,p)*e_si(T))
    t1 = 4*pi*(Si(Sw,T)-1)
    
    print('Time of ice particle to grow to',round(d_max*1e6),'mum at a temperature of ',T,'°C with the following assumptions:')
    dt = 0.1
    
    r=r_0
    m = mass_sphere(r)
    # a,h = baselength(m,ar,T)
    # d_hex = 2*a
    d_hex = diam_hexagon(m)
    t = 0
    #Diffusional growth of a maxwellian spherical stationary ice crystal in an infinite atmosphere
    #Fukuta & Takahashi 1999: a. 1)
    while d_hex <d_max:
        dm = ((t1*radius(m,T))/(Fk + Fd))*dt #alpha added as in book
        # a,h = baselength(m,ar,T)
        # d_hex = 2*a
        m = m + dm
        d_hex = diam_hexagon(m)
        t = t+dt
        
    print('Diffusional growth of stationary spherical ice crystal, using mass for calculation of plate size:',round(t),'s')
    
    
    r=r_0
    m = mass_sphere(r)
    t = 0
    d_drop = 2*radius(m,T)
    # a,h = baselength(m,ar,T)
    # d_hex = 2*a
    #Diffusional growth of a maxwellian spherical stationary ice crystal in an infinite atmosphere
    #Fukuta & Takahashi 1999: a. 1)
    while d_drop <d_max:
        dm = (alp*4*(Si(Sw,T)-1)*pi*radius(m,T)/(Fk+Fd))*dt #alpha added as in book
        m = m + dm
        t = t+dt
        d_drop = 2*radius(m,T)
        # a,h = baselength(m,ar,T)
        # d_hex = 2*a
    
    print('Diffusional growth of stationary spherical ice crystal:',round(t),'s')
    
    
    r=r_0
    m = mass_hexagon(r)
    # a,h = baselength(m,ar)
    # d_hex = 2*a
    d_hex = diam_hexagon(m)
    t = 0  
    # Add capacitance of a plate
    while d_hex <d_max:
        # a,h = baselength(m,ar)
        r = d_hex/2
        dm = alp*((t1*C0_plate(r))/(Fk + Fd))*dt
        # d_hex = 2*a
        m = m + dm
        d_hex = diam_hexagon(m)
        t = t+dt
        
    print('Diffusional growth of stationary plate:',round(t),'s')
    
    r=r_0
    m = mass_hexagon(r)
    # a,h = baselength(m,ar,T)
    # d_hex = 2*a
    d_hex = diam_hexagon(m)
    t = 0  
    #Corrections due to shape, coexisting cloud droplets and crystal fall
    while d_hex <d_max:
        # a,h = baselength(m,ar,T)
        r = d_hex/2
        dm = ((t1*C0_plate(r)*ff(nd,rd,r)*fv(w,d,T,p))/(Fk+Fd))*dt
        # d_hex = 2*a
        m = m + dm
        d_hex = diam_hexagon(m)
        t = t+dt
    
    print('Diffusional growth of falling plate with coexistant cloud droplets:',round(t),'s')
    
    
    
    r=r_0
    m = mass_hexagon_shape(r*ar,ar,T)
    a,h = baselength(m,ar,T)
    d_hex = h
    # d_hex = diam_hexagon(m)
    t = 0  
    # Add capacitance of a plate
    while d_hex <d_max:
        dm = ((t1*C0_column(r,1/ar))/(Fk + Fd))*dt
        m = m + dm
        a,h = baselength(m,ar,T)
        d_hex = h
        r = d_hex/2
        # d_hex = diam_hexagon(m)
        t = t+dt
    
    print('Diffusional growth of stationary column with an aspect ratio of',round(1/ar),':',round(t),'s')
    
    r=r_0
    m = mass_hexagon(r)
    d_hex = diam_hexagon(m)
    t = 0  
    dia = np.array([2*r])
    t = np.array([t])
    i = 0
    #Effects of thermal accommodation and deposition coefficients on the growth of small crystals
    while d_hex <d_max:
        dm = ((t1*C0_plate(r)*ff(nd,rd,r)*fv(w,d,T,p))/(Fk/fa(m,T,p) + Fd/fy(m,T,p)))*dt
        m = m + dm
        d_hex = diam_hexagon(m)
        r = d_hex/2
        dia = np.append(dia,d_hex)
        t = np.append(t,t[i]+dt)
        i = i+1
    
    print('Diffusional growth of falling plate with coexistant cloud droplets including heat and vapor exchange:',round(t[-1]),'s')
    
    
    
      
    # Minimum element indices in list 
    # Using list comprehension + min() + enumerate()
    t93 = t[find_min(dia,93e-6)]
    t60 = t[find_min(dia,60e-6)]
    t39 = t[find_min(dia,39e-6)]
    
    print('Time span crystals with a diameter between 60 and 93mum formed:',(t93-t60)/60,'minutes at a temperature of',T,'°C')
    print('Time span crystals with a diameter between 39 and 93mum formed:',(t93-t39)/60,'minutes at a temperature of',T,'°C')

    return t93, t60, t39

