# -*- coding: utf-8 -*-
"""
Created on Wed Jun 22 12:16:11 2022

@author: Robert J McGinness
"""

from .calcs import coordinate_to_dms

def google_maps_url2022(latitude: float, longitude: float) -> str:
    lat_hemisphere = 'N' if latitude > 0 else 'S'
    lat_d, lat_m, lat_s = coordinate_to_dms(abs(latitude))
    lat_dms_str = str(lat_d) + '°' + \
                  str(lat_m) + '\'' + \
                  str(int(lat_s)) + '.0"' + \
                  lat_hemisphere
                  
    long_d, long_m, long_s = coordinate_to_dms(abs(longitude))
    
    long_hemisphere = 'W' if longitude < 0 else 'E'
    long_dms_str = str(long_d) + '°' + \
                   str(long_m) + '\'' + \
                   str(int(long_s)) + '.0"' + \
                   long_hemisphere
    
    map_url = 'https://www.google.com/maps/place/'
    map_url += lat_dms_str + '+' + long_dms_str
    map_url += '/@' + str(latitude) + ',' + str(longitude)
    
    return map_url

