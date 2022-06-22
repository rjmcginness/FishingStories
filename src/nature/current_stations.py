# -*- coding: utf-8 -*-
"""
Created on Tue Jun 21 09:09:33 2022

@author: Robert J McGinness
"""

import requests
from scrapy.selector import Selector
from typing import List
import urllib
from .utilities import google_maps_url2022
from .calcs import coordinate_to_dms

# http://tbone.biol.sc.edu/tide/
# http://tbone.biol.sc.edu/tide/sites_allcurrent.html
# https://www.google.com/maps/place/41%C2%B031'12.0%22N+70%C2%B041'06.0%22W/@41.52,-70.685

class CurrentStation:
    def __init__(self, **kwargs) -> None:#name: str, url: str, map_url='') -> None:
        self.name:str = kwargs['name']
        self.url:str = kwargs['url']
        self.latitude:float = 0.0
        self.longitude:float = 0.0
        self.map_url:str = ''
        
        if kwargs['map'] != '':
            query_string = urllib.parse.parse_qs(kwargs['map'])
            
            self.latitude, self.longitude = (float(item[0]) for item in 
                                                         query_string.values())
            # lat_hemisphere = 'N' if self.latitude > 0 else 'S'
            # lat_d, lat_m, lat_s = coordinate_to_dms(abs(self.latitude))
            # lat_dms_str = str(lat_d) + '°' + \
            #               str(lat_m) + '\'' + \
            #               str(int(lat_s)) + '.0"' + \
            #               lat_hemisphere
                          
            # long_d, long_m, long_s = coordinate_to_dms(abs(self.longitude))
            
            # long_hemisphere = 'W' if self.longitude < 0 else 'E'
            # long_dms_str = str(long_d) + '°' + \
            #                str(long_m) + '\'' + \
            #                str(int(long_s)) + '.0"' + \
            #                long_hemisphere
            
            # self.map_url = 'https://www.google.com/maps/place/'
            # self.map_url += lat_dms_str + '+' + long_dms_str
            # self.map_url += '/@' + str(self.latitude) + ',' + str(self.longitude)
            self.map_url = google_maps_url2022(self.latitude, self.longitude)
            
    def serialize(self) -> dict:
        return (
                {
                    'name': self.name,
                    'url': self.url,
                    'latitude': self.latitude,
                    'longitude': self.longitude,
                    'map_url': self.map_url
                }
               )

def current_sites(url: str) -> List[CurrentStation]:
    response = requests.get(url)
    
    
    content_sections = response.content.split('</dl>'.encode('utf-8'))
    
    
    data_content = content_sections[1].split('<hr>'.encode('utf-8'))[0].strip()
    
    site_rows = data_content.split('\n'.encode('utf-8'))
    
    site_rows = [Selector(text=row).xpath('//a').getall() for row in site_rows]
    
    domain = 'http://tbone.biol.sc.edu/tide/'
    
    site_data_list = [
                       {'map': Selector(text=row[0]).xpath('//a/@href').get(),
                       'url': domain + Selector(text=row[1]).xpath('//a/@href').get(),
                       'name': Selector(text=row[1]).xpath('//a/text()').get()}
                     for row in site_rows if len(row) == 2
                     ]
    
    current_stations = [CurrentStation(**site) for site in site_data_list]
    
    return current_stations


# def google_maps_url2022(latitude: float, longitude: float) -> str:
#     lat_hemisphere = 'N' if latitude > 0 else 'S'
#     lat_d, lat_m, lat_s = coordinate_to_dms(abs(latitude))
#     lat_dms_str = str(lat_d) + '°' + \
#                   str(lat_m) + '\'' + \
#                   str(int(lat_s)) + '.0"' + \
#                   lat_hemisphere
                  
#     long_d, long_m, long_s = coordinate_to_dms(abs(longitude))
    
#     long_hemisphere = 'W' if longitude < 0 else 'E'
#     long_dms_str = str(long_d) + '°' + \
#                    str(long_m) + '\'' + \
#                    str(int(long_s)) + '.0"' + \
#                    long_hemisphere
    
#     map_url = 'https://www.google.com/maps/place/'
#     map_url += lat_dms_str + '+' + long_dms_str
#     map_url += '/@' + str(latitude) + ',' + str(longitude)
    
#     return map_url

# def coordinate_from_dmsstr(coordinate: str) -> float:
#     """ Expects a string of format (-)XX°XX'XX  or
        
#     """

# def coordinate_fromstr(coordinate: str) -> float:
#     if "'" in coordinate or '"' in coordinate:
#         return coordinate_from_dmsstr(coordinate)
    
#     return float(coordinate)
    
    

if __name__ == '__main__':
    current_stations = current_sites('http://tbone.biol.sc.edu/tide/sites_allcurrent.html')
    
    error_file = open('current_data_errors.txt', 'wt')
    
    
    with open('current_sites.txt', 'wt') as f:
        for station in current_stations:
            try:
                f.write(str(station.serialize()) + '\n')
            except Exception as e:
                error_file.write(station.url + '>>' + str(e) + '\n')
    
    
    error_file.close()