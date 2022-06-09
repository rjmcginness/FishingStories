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
        
        times = response.xpath('//td[@class="cell"]/text()').getall()
        times = [time.strip() for time in times if not time.isspace()]
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

if __name__ == '__main__':
    process = CrawlerProcess()
    process.crawl(WeatherArachnid)
    process.start()
        