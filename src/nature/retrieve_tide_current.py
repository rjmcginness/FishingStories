# -*- coding: utf-8 -*-
"""
Created on Fri Jun 10 09:43:57 2022

@author: Robert J McGinness
"""

import requests
from scrapy.selector import Selector
from datetime import datetime
from datetime import date
from typing import List
import urllib

from .nature_entities import WaterState
from .nature_entities import MoonDetails
from .nature_entities import SunDetails
from .nature_entities import GlobalPosition

# from nature_entities import WaterState
# from nature_entities import MoonDetails
# from nature_entities import SunDetails
# from nature_entities import GlobalPosition


class TideDataParser:
    def __init__(self, date: date, raw_data: str) -> None:
        self.__date = date
        
        # rows = body.split('\n\n')
        date_substr = date_time.strftime('%Y-%m-%d')
        
        # get all the rows of data
        rows = raw_data.splitlines()
        
        # get only rows containing dates (these have the actual data)
        # as lists of the non-empty substrings in the data
        self.__raw_data = [list(filter(lambda s: s != '', part.split(' ')))
                                        for part in[row.strip().lower()
                                        for row in rows if date_substr in row]]
        
        # first row contains coordinates
        self.coordinates = self.__parse_coordinates(rows[0])
    
        self.water = self.__parse_water_data()
        self.sun, self.moon = self.__parse_sun_moon_data()
    
    def __parse_coordinates(self, coord_str: str) -> GlobalPosition:
        ''' Parse latitude and longitude from string argument'''
        coords =  coord_str.strip().split(',')
        
        latitude, longitude = (coord.strip().split(' ') for coord in coords)
        
        # latitude = coords[0].strip().split(' ')
        # longitude = coords[1].strip().split(' ')
        
        # with open('current_errors.txt', 'wb') as f:
        #     f.write(str(len(longitude[0])).encode())
        #     f.write((longitude[1] + '\n').encode())
        
        # make negative if necessary and remove degree sign
        latitude = ('-' if latitude[1] == 'S' else '') + latitude[0].strip()[:-1]
        longitude = ('-' if longitude[1] == 'W' else '') + longitude[0].strip()[:-1]
               
        return GlobalPosition(float(latitude), float(longitude))
    
    def __parse_water_data(self) -> List[WaterState]:
        
        # If 'moon' or 'sun' is a substring of any strings in a line, we do not
        # that line (filter for those lines, then choose not to include those
        # lines in the list comprehension)
        water_raw_data = [line for line in self.__raw_data
                          if not list(filter(lambda part: 'moon' in part or
                                                           'sun' in part, line))]
        print(water_raw_data)
        # parse each line of water data
        water_states = []
        for water_data in water_raw_data:
            
            print(water_data)
            
            current_flow = 'slack'
            incoming = True
            slack = False
            if 'slack,' in water_data: # parse for slack tide (data includes the ,)
                slack = True
            else:
                if 'ebb' in water_data:
                    current_flow = 'ebb'
                    incoming = False
                else:
                    current_flow = 'flood'
            
            # parse time from water data line
            dt_str = ' '.join(water_data[:2])
            print(dt_str)
            date_time = datetime.strptime(dt_str, '%Y-%m-%d %H:%M')
            
            # create WaterState object
            water_state = WaterState(date_time,
                                     current_flow,
                                     incoming=incoming,
                                     slack=slack)
            try:
                # get float current_speed (a little hard codey, but
                # would need list comprehension or string manipulation)
                ######BIT OF A POTENTIAL FAILURE POINT
                water_state.current_speed = float(water_data[3])
            except:
                pass
            
            water_states.append(water_state)
        
        return water_states
    
    def __parse_sun_moon_data(self) -> tuple:
        ''' Builds both the Moon and Sun details objects by 
            parsing raw data
        '''
        
        # get only lines with moon or sun data (used similar approach above
        # for water data lines)
        # This is one way to do it, could also join the parts and search for
        # 'moon' or 'sun'
        # sm_raw_data = [line for line in self.__raw_data[1:]
        #                   if list(filter(lambda part: 'moon' in part or 'sun' in part, line))]
        
        
        moon_lines = [line for line in self.__raw_data
                          if list(filter(lambda part: 'moon' in part, line))]
        
        sun_lines = [line for line in self.__raw_data
                          if list(filter(lambda part: 'sun' in part, line))]
        
        return (self.__parse_celestial_body(SunDetails, sun_lines),
                        self.__parse_celestial_body(MoonDetails, moon_lines))
    
    def __parse_celestial_body(self, *args: tuple) -> object:
        orb_cls = args[0] # contains the class for MoonDetails or SunDetails
        sm_raw_data = args[1] # contains the data lines for moon or sun
        
        sm_obj = orb_cls(self.__date) # create moon or sun
        
        for sm_data in sm_raw_data:
            
            ###### NEED MORE DATA TO VERIFY THIS
            # last two parts in a line of 5 parts is moon phase
            if len(sm_data) == 5:
                # using duck typing, as is has to be the moon
                sm_obj.moon_phase = ' '.join(sm_data[-2:])
                continue
    
            # parse and format time
            t_str = ' '.join(sm_data[:2])
            sm_time = datetime.strptime(t_str, '%Y-%m-%d %H:%M').time().strftime('%H:%M %p')
            
            # set sun/moon rise or set time
            # look for 'rise' in joined parts of data
            if 'rise' in ''.join(sm_data): 
                sm_obj.rise_time = sm_time
            else:
                sm_obj.set_time = sm_time
            
        return sm_obj
                
        
class TideData:
    def __init__(self, date: date, raw_data: str) -> None:
        self.__date = date
        self.__raw_data = raw_data
        
        parser = TideDataParser(date, raw_data)
        self.__coordinates = parser.coordinates
        self.__water_data = parser.water
        self.__sun = parser.sun
        self.__moon = parser.moon
    
    @property
    def date(self) -> date:
        return self.__date
    
    @property
    def water(self) -> List[WaterState]:
        return self.__water_data
    
    @property
    def sun(self) -> SunDetails:
        return self.__sun
    
    @property
    def moon(self) -> MoonDetails:
        return self.__moon
    
    @property
    def coordinates(self) -> GlobalPosition:
        return self.__coordinates
    
    @property
    def raw_data(self) -> str:
        return self.__raw_data
    

def retrieve_tide_currents(url: str, date_time: datetime) -> TideData:
    
    site = list(urllib.parse.parse_qs(url).values())[0][0]
    print(site)
    formdata={
                'sitesave': site,
                'glen': '1',
                'year': str(date_time.year),
                'month': str(date_time.month),
                'day': str(date_time.day)}

    r = requests.post(url, data=formdata)

    selector = Selector(text=r.content)

    body = selector.xpath('//pre/text()').get()
    
    return TideData(date_time.date(), body)
    
if __name__ == '__main__':
    # exit()
    url = 'http://tbone.biol.sc.edu/tide/tideshow.cgi?site=0%2E1+mile+east+of+Point+Evans%2C+The+Narrows%2C+Washington+Current'
    url = 'http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Little+Card+Sound+bridge%2C+Florida&units=f'

    date_time = datetime(year=2022, month=6, day=11)


    # formdata={
    #             'sitesave': 'Newburyport (Merrimack River), Massachusetts Current',
    #             'glen': '1',
    #             'year': str(date_time.year),
    #             'month': str(date_time.month),
    #             'day': str(date_time.day)}
    
    '''Preliminary test to send form data to site'''
    # r = requests.post(url, data=formdata)


    # selector = Selector(text=r.content)

    # data = selector.xpath('//pre/text()').get()

    # print(data)
    
    '''Test retrieve_tide_currents function'''
    tc_data = retrieve_tide_currents(url, date_time)
    print(tc_data.coordinates)
    print(tc_data.moon)
    print(tc_data.sun)
    for water_state in tc_data.water:
        print(water_state)
    