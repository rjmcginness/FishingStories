# -*- coding: utf-8 -*-
"""
Created on Thu Jun  9 09:44:04 2022

@author: Robert J McGinness
"""

from scrapy import Spider
from scrapy import Request
from scrapy.crawler import CrawlerProcess
from scrapy.selector import Selector
from dataclasses import dataclass
from datetime import datetime
from typing import List
from calendar import isleap

@dataclass
class SeaConditions:
    date_time: datetime
    high_tide_height: float
    low_tide_height: float
    swell_height: float
    swell_direction: str
    wave_height: int
    wave_period: int
    wind_speed: int
    wind_direction: str
    water_temperature: int
    weather_state: str
    temperature: int
    wind_chill: int
    


class WeatherArachnid(Spider):
    name = 'weather'
    
    
    def start_requests(self) -> Request:
        urls = [
                'https://www.tide-forecast.com/locations/Merrimack-River-Entrance-Massachusetts/forecasts/latest'
               ]
        
        for url in urls:
            yield Request(url=url, callback=self.parse)
    
    
    def parse(self, response) -> None:
        
        date_time_row = response.xpath('//span[contains(.,"Issued (local time)")]').get()
        date = Selector(text=date_time_row).xpath('//nobr/text()').get()
        date = ' '.join([dt.strip() for dt in date.split('\n')])
        date = '-'.join(date.split(' ')[-1:-4:-1])
        
        times = response.xpath('//td[@class="cell"]/text()').getall()
        times = [time.strip() for time in times if not time.isspace()]
        
        am_pms = response.xpath('//td[@class="cell"]/span/text()').getall()
        
        date_times = self.__make_date_time(date, times, am_pms)
        
        swell = response.xpath('//text[@class="swell-icon__val"]/text()').getall()
        swell_dir = response.xpath('//div[@class="swell-icon__letters"]/text()').getall()
        wave_heights = response.xpath('//span[@class="height"]/text()').getall()
        period_row = response.xpath('//tr[contains(.,"Period (s)")]').get()
        periods = Selector(text=period_row).xpath('//td/text()').getall()
        wind_speeds = response.xpath('//text[@class="wind-icon__val"]/text()').getall()
        wind_directions = response.xpath('//div[@class="wind-icon__letters"]/text()').getall()
        
        water_temp_row = response.xpath('//b[contains(., "sea temperature")]').get()
        water_temp = Selector(text=water_temp_row).xpath('//span[@class="temp"]/text()').get()
        water_temp_units = Selector(text=water_temp_row).xpath('//span[@class="tempu"]/text()').get()
        
        weather_states_td = response.xpath('//tr[@class="med"]/td').getall()
        
        weather_states_td = [state.replace('<br>', ' ') for state in weather_states_td]
        
        weather_states = Selector(text=''.join(weather_states_td)).xpath('//td/text()').getall()
        weather_states = [state.strip('\n').strip() for state in weather_states]
        
        air_temps = response.xpath('//td[@class="dark"]/span[@class="temp"]/text()').getall()
        
        wind_chill_row = response.xpath('//tr[contains(., "Chill")]').get()
        wind_chills = Selector(text=wind_chill_row).xpath('//span[@class="temp"]/text()').getall()
        
        
        print('TIMES', times)
        print('AM PMS', am_pms)
        print('SWELL', swell)
        print('SWELL DIRS', swell_dir)
        print('WAVE', wave_heights)
        print('PERIODS', periods)
        print('WIND SPEEDS', wind_speeds)
        print('WIND DIRS', wind_directions)
        print('WATER TEMP', water_temp)
        print('WATER TEMP UNITS', water_temp_units)
        print('WEATHER STATES', weather_states)
        print('AIR TEMPS', air_temps)
        print('WIND CHILLS', wind_chills)
        print("DATE", date)
        print("DATE TIMES", date_times)
        
    def __make_date_time(date: str,
                         times: List[str],
                         am_pms: List[str]) -> List[datetime]:
        
        year, month, day = date.split('-')
        
        time_tups = tuple(zip(times, am_pms))
        twenty_four_hour_times = [time[0] if time[1] == 'AM' 
                              else str(int(time[0]+ 12)) for time in time_tups]
        
        last_am_pm = am_pms[0]
        for am_pm in am_pms[1:]:
            if last_am_pm == 'PM' and am_pm == 'AM':
                divisor = 31
                if month in ['Apr', 'Jun', 'Sep', 'Nov']:
                    divisor = 30
                elif month == 'Feb':
                    if isleap(year):
                        divisor = 29
                    else:
                        divisor = 28
                        
                day = (day + 1) // divisor + (day + 1) % divisor 
        
        

if __name__ == '__main__':
    process = CrawlerProcess()
    process.crawl(WeatherArachnid)
    process.start()
        