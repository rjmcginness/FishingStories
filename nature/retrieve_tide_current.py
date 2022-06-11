# -*- coding: utf-8 -*-
"""
Created on Fri Jun 10 09:43:57 2022

@author: Robert J McGinness
"""

import requests
from scrapy.selector import Selector
from datetime import datetime
from datetime import date
from datetime import time
from typing import List
from dataclasses import dataclass


@dataclass
class WaterState:
    date_time: datetime
    current_flow: str
    incoming: bool = True
    slack: bool = True
    current_speed: float = 0.00

@dataclass
class MoonDetails:
    date: date
    phase: str = None
    rise_time: time = None
    set_time: time = None

@dataclass
class SunDetails:
    date: date
    rise_time: time = None
    set_time: time = None
    
@dataclass
class GlobalPosition:
    latitude: float
    longitude: float

class TideDataParser:
    def __init__(self, date: date, raw_data: str) -> None:
        self.__date = date
        
        self.__raw_data = [[part.strip().lower() for part in line.strip().split(' ') if part != '']
         for line in raw_data.split('\n') if not line.isspace() and line != '']
        
        print('>>>>>>>>>\n', self.__raw_data)
        
        self.coordinates = self.__parse_coordinates()
        self.water = self.__parse_water_data()
        self.sun, self.moon = self.__parse_sun_moon_data()
    
    def __parse_coordinates(self) -> GlobalPosition:
        coords = self.__raw_data[0]
        latitude = coords[0][:-1].strip()
        longitude = coords[2][:-1].strip()
        
        return GlobalPosition(latitude, longitude)
    
    def __parse_water_data(self) -> List[WaterState]:
        
        # a water data line has no reference to moon or sun
        raw_water_data = [data for data in self.__raw_data[1:]
                                  if 'moon' not in data and 'sun' not in data]
        
        water_states = []
        for water_data in raw_water_data:
            
            current_flow = 'slack'
            incoming = True
            slack = False
            if 'slack,' in water_data:
                slack = True
            else:
                if 'ebb' in water_data:
                    current_flow = 'ebb'
                    incoming = False
                else:
                    current_flow = 'flood'
            
            dt_str = ' '.join(water_data[:3])
                    
            date_time = datetime.strptime(dt_str, '%Y-%m-%d %H:%M %Z')
            
            water_state = WaterState(date_time,
                                     current_flow,
                                     incoming=incoming,
                                     slack=slack)
            try:
                # get float current_speed
                water_state.current_speed = [float(part.strip()) for part in water_data
                                                     if '.' in water_data][0]
            except:
                pass
            
            water_states.append(water_state)
        
        return water_states
    
    def __parse_sun_moon_data(self) -> tuple:
        # get only lines with moon or sun data
        sm_raw_data = [part for part in self.__raw_data[1:]
                                           if 'moon' in part or 'sun' in part]
        
        sun = SunDetails(self.__date)
        moon = MoonDetails(self.__date)
        for sm_data in sm_raw_data:
            
            t_str = ' '.join(sm_data[1:3])
                    
            sm_time = time.strptime(t_str, '%H:%M %Z')
            
            # moon phase line has 5 parts in raw data
            if len(sm_data) == 5:
                moon.phase = ' '.join(sm_data[-2:])
                continue
            
            sm_obj = moon
            if 'sun' in sm_data:
                sm_obj = sun
            
            # set sun/moon rise or set time
            if 'rise' in sm_data:
                sm_obj.rise_time = sm_time
            else:
                sm_obj.set_time = sm_time
        
        return sun, moon
                
        
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
    
    

        
    
    # def __parse_tc_data(self, data: List[str]) -> None:
    #     ''' Receives data from scrapy.Spider subclass for
    #         tide and current data.  Parses pertinent data
    #         and creates a TideRelatedEvent object.  Data
    #         are parses for date, WaterStates, MoonDetails,
    #         SunDetails, and GlobalCoordinates.
            
    #         Returns: None (TideRelatedEvents are stored as
    #                  elements of list attribute)
    #     '''
    #     dates = {}
        
    #     # parse each line in tide/current data
    #     for line in data:
    #         parts = [part for part in line.split(' ') if
    #                                          not part.isspace() and part != '']
            
    #         date_time = datetime.fromisoformat(' '.join(parts[:2]))
            
    #         if parts[0] not in dates: # check if the date, parts[0], in dates
    #             dates[parts[0]] = TideRelatedEvents(date_time.date(),
    #                                                 *self.__coordinates)
                
    #         self.__parse_date_events(parts, date_time, dates)
        
    #     # add the TideRelatedEvents to the self.__tc_data list
    #     for tc_events in dates.values():
    #         self.__tc_data.append(tc_events)
                    
    # def __parse_date_events(self, dated_data: List[str],
    #                                                   date_time: datetime,
    #                                                   dates_map: dict) -> None:
    #     ''' Arguments:
    #         - dated_data is a list of strings derived from each line
    #           of tide/current data.
    #         - date_time is the time stamp for the tide/current data.
    #         - dates_map is a dictionary with date strings as keys
    #           and a TideRelatedEvents object as the value
    #     '''
        
    #     # dated_data[0] is the date 
    #     data_tuple = dated_data, dates_map[dated_data[0]]
                
    #     # if 4 elements, it is moon or sun data 
    #     if len(dated_data) == 4:
    #         # last element contains reference to moon or sun
    #         if 'moon' in dated_data:  
    #             self.__parse_details(*data_tuple, date_time)
    #             return 
    #         self.__parse_details(*data_tuple, date_time, is_moon=False)
    #         return
        
    #     # if lengths is 5, this is a moon phase
    #     if len(dated_data) == 5:
    #         # data_tuple[1] is the TideRelatedEvents object for this date
    #         data_tuple[1].moon.phase = ' '.join(dated_data[-2:-1])
    #         return
        
    #     self.__parse_water_state(*data_tuple, date_time)
                    
    # def __parse_details(self, details: List[str],
    #                                tide_events: TideRelatedEvents,
    #                                date_time: datetime,
    #                                is_moon=True) -> None:
        
    #     detail_obj = tide_events.moon if is_moon else tide_events.sun
        
    #     if 'rise' in details[-1]:
    #         detail_obj.rise_time = date_time.time()
    #         return
        
    #     detail_obj.set_time = date_time.time()
        
    
    # def __parse_water_state(self, details: List[str],
    #                                 tide_events: TideRelatedEvents,
    #                                 date_time: datetime) -> None:
        
    #     current_flow = 'slack'
    #     incoming = True
    #     slack = False
    #     if 'slack' in details:
    #         slack = True
    #     else:
    #         if 'ebb' in details:
    #             current_flow = 'ebb'
    #             incoming = False
    #         else:
    #             current_flow = 'flood'
        
    #     water_state = WaterState(date_time,
    #                              current_flow,
    #                              incoming=incoming,
    #                              slack=slack)
        
    #     for part in details:
    #         try:
    #             water_state.current_speed = float(part)
    #             break
    #         except:
    #             pass
        
    #     tide_events.add_water_state(water_state)

def retrieve_tide_currents(url: str, date_time: datetime, site: str) -> TideData:
    formdata={
                'sitesave': site,
                'glen': '1',
                'year': str(date_time.year),
                'month': str(date_time.month),
                'day': str(date_time.day)}

    r = requests.post(url, data=formdata)


    selector = Selector(text=r.content)

    body = selector.xpath('//pre/text()').get()
    
    # # body = body[start_idx:end_idx].split('\n'.encode('utf-8'))
    # body = body.split('\n')
    # body = [part for part in body if not part.isspace() and part != '']
    
    # for part in body:
    #     print(part)
    
    # coords = body[0].split(',')
    # latitude = coords[0][:-3].strip()
    # longitude = coords[1][:-3].strip()
    
    # print(latitude, longitude)
    
    return TideData(date_time.date(), body)
    
if __name__ == '__main__':
    # exit()
    url = 'http://tbone.biol.sc.edu/tide/tideshow.cgi?'

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
    tc_data = retrieve_tide_currents(url, date_time,'Newburyport (Merrimack River), Massachusetts Current')
    print(tc_data.coordinates)
    print(tc_data.moon)
    print(tc_data.sun)
    for water_state in tc_data.water:
        print(water_state)
    