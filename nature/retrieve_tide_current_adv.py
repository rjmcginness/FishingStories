# -*- coding: utf-8 -*-
"""
Created on Mon Jun  6 13:23:26 2022

@author: Robert J McGinness
"""

import scrapy
import logging
from scrapy.crawler import CrawlerProcess
from datetime import datetime
from datetime import date
from datetime import time
from typing import List
from typing import Tuple
from typing import Optional
from dataclasses import dataclass
from scrapy.selector import Selector

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
    
class TideRelatedEvents:
    def __init__(self, date: date, latitude: float, longitude: float) -> None:
        self.__date = date
        self.__coordinates = GlobalPosition(latitude, longitude)
        self.__water_states: List[WaterState] = []
        self.__sun = SunDetails(date)
        self.__moon = MoonDetails(date)
    
    @property
    def date(self) -> date:
        return self.__date
    
    @property
    def sun(self) -> SunDetails:
        return self.__sun
    
    @property
    def moon(self) -> MoonDetails:
        return self.__moon
    
    @property
    def water(self) -> Tuple[WaterState]:
        return tuple(self.__water_events)
    
    def add_water_state(self, water_state: WaterState) -> None:
        self.__water_states.append(water_state)
    
    def __repr__(self) -> str:
        return ('Coordinates: {}, Moon Data: {}, Sun Data: {}, Water: {}'.
                format(self.__coordinates, self.__moon, self.__sun, self.__water_states))
                
    

class TideDataSack:
    def __init__(self) -> None:
        self.__coordinates = None
        self.__tc_data = []
        
    @property
    def coordinates(self) -> tuple:
        return self.__coordinates
    
    @coordinates.setter
    def coordinates(self, coords: tuple) -> None:
        
        latitude, longitude = coords
        
        latitude = self.__parse_coordinate(latitude)
        longitude = self.__parse_coordinate(longitude)
        
        self.__coordinates = latitude, longitude
    
    @property
    def data(self) -> List[TideRelatedEvents]:
        return self.__tc_data
    
    @data.setter
    def data(self, tc_data: List[str]) -> None:
        self.__parse_tc_data(tc_data)
        
    def __parse_coordinate(self, coordinate: str) -> Optional[float]:
        ''' Removes undecodeable parts of coordinate string
            and converts to float
            Returns: float representation of coordinate
        '''
        return float(coordinate[:-3].decode())
    
    def __parse_tc_data(self, data: List[str]) -> None:
        ''' Receives data from scrapy.Spider subclass for
            tide and current data.  Parses pertinent data
            and creates a TideRelatedEvent object.  Data
            are parses for date, WaterStates, MoonDetails,
            SunDetails, and GlobalCoordinates.
            
            Returns: None (TideRelatedEvents are stored as
                     elements of list attribute)
        '''
        dates = {}
        
        # parse each line in tide/current data
        for line in data:
            parts = [part for part in line.split(' ') if
                                             not part.isspace() and part != '']
            
            date_time = datetime.fromisoformat(' '.join(parts[:2]))
            
            if parts[0] not in dates: # check if the date, parts[0], in dates
                dates[parts[0]] = TideRelatedEvents(date_time.date(),
                                                    *self.__coordinates)
                
            self.__parse_date_events(parts, date_time, dates)
        
        # add the TideRelatedEvents to the self.__tc_data list
        for tc_events in dates.values():
            self.__tc_data.append(tc_events)
                    
    def __parse_date_events(self, dated_data: List[str],
                                                      date_time: datetime,
                                                      dates_map: dict) -> None:
        ''' Arguments:
            - dated_data is a list of strings derived from each line
              of tide/current data.
            - date_time is the time stamp for the tide/current data.
            - dates_map is a dictionary with date strings as keys
              and a TideRelatedEvents object as the value
        '''
        
        # dated_data[0] is the date 
        data_tuple = dated_data, dates_map[dated_data[0]]
                
        # if 4 elements, it is moon or sun data 
        if len(dated_data) == 4:
            # last element contains reference to moon or sun
            if 'moon' in dated_data:  
                self.__parse_details(*data_tuple, date_time)
                return 
            self.__parse_details(*data_tuple, date_time, is_moon=False)
            return
        
        # if lengths is 5, this is a moon phase
        if len(dated_data) == 5:
            # data_tuple[1] is the TideRelatedEvents object for this date
            data_tuple[1].moon.phase = ' '.join(dated_data[-2:-1])
            return
        
        self.__parse_water_state(*data_tuple, date_time)
                    
    def __parse_details(self, details: List[str],
                                   tide_events: TideRelatedEvents,
                                   date_time: datetime,
                                   is_moon=True) -> None:
        
        detail_obj = tide_events.moon if is_moon else tide_events.sun
        
        if 'rise' in details[-1]:
            detail_obj.rise_time = date_time.time()
            return
        
        detail_obj.set_time = date_time.time()
        
    
    def __parse_water_state(self, details: List[str],
                                    tide_events: TideRelatedEvents,
                                    date_time: datetime) -> None:
        
        current_flow = 'slack'
        incoming = True
        slack = False
        if 'slack' in details:
            slack = True
        else:
            if 'ebb' in details:
                current_flow = 'ebb'
                incoming = False
            else:
                current_flow = 'flood'
        
        water_state = WaterState(date_time,
                                 current_flow,
                                 incoming=incoming,
                                 slack=slack)
        
        for part in details:
            try:
                water_state.current_speed = float(part)
                break
            except:
                pass
        
        tide_events.add_water_state(water_state)
        
        
        

class CurrentArachnid(scrapy.Spider):
    name = 'currents'
    start_urls = [
                    'http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Newburyport+%28Merrimack+River%29%2C+Massachusetts+Current'
                  ]
    
    def __init__(self, data_sack: TideDataSack, date_time: datetime) -> None:
        super().__init__()
        self.__data_sack = data_sack
        self.__date_time = date_time
        logging.getLogger('scrapy').setLevel(logging.WARNING)
    
    # def start_requests(self) -> scrapy.Request:
    #     urls = [
    #                     'http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Newburyport+%28Merrimack+River%29%2C+Massachusetts+Current'
    #                  ]

    #     for url in urls:
    #         yield scrapy.FormRequest(url=url,
    #                                   formdata={
    #                                     'savesite': 'Newburyport (Merrimack River), Massachusetts Current',
    #                                     'glen': '1',
    #                                     'year': self.__date_time.year,
    #                                     'month': self.__date_time.month,
    #                                     'day': self.__date_time.day},
    #                                   callback=self.parse
    #                                   )#scrapy.Request(url=url, callback=self.parse)
    
    def parse(self, response):
        return scrapy.FormRequest.from_response(response,
                                                formdata={
                                                            'savesite': 'Newburyport (Merrimack River), Massachusetts Current',
                                                            'glen': '1',
                                                            'year': str(self.__date_time.year),
                                                            'month': str(self.__date_time.month),
                                                            'day': str(self.__date_time.day)},
                                                callback=self.date_submitted)
    
    def date_submitted(self, response) -> None:
        body = response.body
        
        start_idx = None
        end_idx = None
        try:
            start_idx = body.index('<pre>'.encode('utf-8')) + 5
            end_idx = body.index('</pre>'.encode('utf-8'))
        except ValueError:
            return
        
        body = body[start_idx:end_idx].split('\n'.encode('utf-8'))
        
        coords = body[0].split(','.encode('utf-8'))
        latitude = coords[0].strip()
        longitude = coords[1].strip()
        
        self.__data_sack.coordinates = latitude, longitude
        self.__data_sack.data = [line.decode().strip().lower() for line in body[1:]
                                                  if line != ''.encode('utf-8')]
        
    # def parse(self, response) -> None:
    #     body = response.body
        
    #     start_idx = None
    #     end_idx = None
    #     try:
    #         start_idx = body.index('<pre>'.encode('utf-8')) + 5
    #         end_idx = body.index('</pre>'.encode('utf-8'))
    #     except ValueError:
    #         return
        
    #     body = body[start_idx:end_idx].split('\n'.encode('utf-8'))
        
    #     coords = body[0].split(','.encode('utf-8'))
    #     latitude = coords[0].strip()
    #     longitude = coords[1].strip()
        
    #     self.__data_sack.coordinates = latitude, longitude
    #     self.__data_sack.data = [line.decode().strip().lower() for line in body[1:]
                                                 # if line != ''.encode('utf-8')]
        
class TideCurrentData:
    def __init__(self, location: str, scraper_class: CurrentArachnid) -> None:
        self.__location = location
        self.__scraper_class = scraper_class
        self.__tc_data = TideDataSack()
        
    def get_data(self, date_time: datetime) -> TideDataSack:
        process = CrawlerProcess()
        process.crawl(self.__scraper_class, data_sack=self.__tc_data, date_time=date_time)
        process.start()
        
        return self.__tc_data.data


if __name__ == '__main__':
    tc_data = TideCurrentData(None, CurrentArachnid)
    
    data = tc_data.get_data(datetime(year=2022, month=6, day=10))
    
    print(data)
    
    
    # print(data[0])
    # for d in data[1]:
    #     print(d.decode())