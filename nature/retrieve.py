# -*- coding: utf-8 -*-
"""
Created on Mon Jun  6 13:23:26 2022

@author: Robert J McGinness
"""

import scrapy
from scrapy.crawler import CrawlerProcess
from datetime import datetime
from typing import List

class TideDataSack:
    def __init__(self) -> None:
        self.__coordinates = None
        self.__data: List[str] = None
        
    @property
    def coordinates(self) -> tuple:
        return self.__coordinates
    
    @coordinates.setter
    def coordinates(self, coords: tuple) -> None:
        self.__coordinates = coords
    
    @property
    def data(self) -> List[str]:
        return self.__data
    
    @data.setter
    def data(self, tc_data: List[str]) -> None:
        self.__data = tc_data

class CurrentArachnid(scrapy.Spider):
    name = 'currents'
    
    def __init__(self, data_sack: TideDataSack) -> None:
        super().__init__()
        self.__data_sack = data_sack
    
    def start_requests(self) -> scrapy.Request:
        urls = [
                #'http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Newburyport+%28Merrimack+River%29%2C+Massachusetts+Current'
                'http://tbone.biol.sc.edu/tide/tideshow.cgi?site=Newburyport+%28Merrimack+River%29%2C+Massachusetts+Current'
               ]
        
        for url in urls:
            yield scrapy.Request(url=url, callback=self.parse)
    
    def parse(self, response) -> None:
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
        self.__data_sack.data = body[1:]
        
class TideCurrentData:
    def __init__(self, location: str, scraper_class: CurrentArachnid) -> None:
        self.__location = location
        self.__scraper_class = scraper_class
        self.__tc_data = TideDataSack()
        
    def get_data(self, date_time: datetime) -> tuple:
        process = CrawlerProcess()
        process.crawl(self.__scraper_class, data_sack=self.__tc_data)
        process.start()
        
        return self.__tc_data.coordinates, self.__tc_data.data


if __name__ == '__main__':
    tc_data = TideCurrentData(None, CurrentArachnid)
    
    data = tc_data.get_data(datetime.now())
    
    print(data[0])
    for d in data[1]:
        print(d.decode())