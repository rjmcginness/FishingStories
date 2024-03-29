# -*- coding: utf-8 -*-
"""
Created on Fri Jun 10 02:18:34 2022

@author: Robert J McGinness
"""

import requests
from scrapy.selector import Selector
from typing import List
from typing import Optional
from dataclasses import dataclass
from datetime import datetime
from calendar import isleap
from calendar import month_abbr


@dataclass
class SeaConditions:
    date_time: datetime
    swell_height: float
    swell_direction: str
    wave_height: int
    wave_period: int
    wind_speed: int
    wind_direction: str
    weather_state: str
    temperature: int
    wind_chill: int
    water_temperature: int
    water_temp_units: str
    high_tide_height: Optional[float] = None
    low_tide_height: Optional[float] = None


def retrieve_weather(url: str) -> List[SeaConditions]:
    
    r = requests.get(url)
    response = Selector(text=r.content)
    date_time_row = response.xpath('//span[contains(.,"Issued (local time)")]').get()
    date = Selector(text=date_time_row).xpath('//nobr/text()').get()
    date = ' '.join([dt.strip() for dt in date.split('\n')])
    date = '-'.join(date.split(' ')[-1:-4:-1])
    
    times = response.xpath('//td[@class="cell"]/text()').getall()
    times = [time.strip() for time in times if not time.isspace()]
    
    am_pms = response.xpath('//td[@class="cell"]/span/text()').getall()
    
    date_times = make_date_time(date, times, am_pms)
    
    swells = response.xpath('//text[@class="swell-icon__val"]/text()').getall()
    swell_directions = response.xpath('//div[@class="swell-icon__letters"]/text()').getall()
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
    
    return [SeaConditions(*args,
                          water_temperature=water_temp,
                          water_temp_units=water_temp_units) for args in 
                                                    zip(date_times,
                                                        swells,
                                                        swell_directions,
                                                        wave_heights,
                                                        periods,
                                                        wind_speeds,
                                                        wind_directions,
                                                        weather_states,
                                                        air_temps,
                                                        wind_chills
                                                        )]
    
def make_date_time(date: str,
                           times: List[str],
                           am_pms: List[str]) -> List[datetime]:
    
    year, month, day = date.split('-')
    
    year, day = int(year), int(day) # convert to int for processing below
    
    times_24 = [time[0] if time[1] == 'AM' 
                        else str(int(time[0])+ 12)
                              for time in zip(times, am_pms)]
    
    date_time_list = []
    
    # first date (does not need to check if next day)
    date_time_list.append(datetime.strptime(date + '-' + str(times_24[0]),
                                                            '%Y-%b-%d-%H'))
    
    last_am_pm = am_pms[0]
    time24_idx = 1 # to get 24 hour time 
    
    # adjust for change of day in loop (compare when am_pm changes
    # from PM to AM)
    for am_pm in am_pms[1:]:
        # divisors are one higher than days in month (for modulus calc)
        if last_am_pm == 'PM' and am_pm == 'AM':
            divisor = 32
            if month in ['Apr', 'Jun', 'Sep', 'Nov']:
                divisor = 31
            elif month == 'Feb':
                if isleap(year):
                    divisor = 30
                else:
                    divisor = 29
            
            # day modulus divisor for month length
            day = (day + 1) % divisor
            if day == 1:
                month = month_abbr[(month_abbr.find(month) + 1) % 12]
                if month == 'Jan':
                    year += 1
        
        # create and append an adjusted datetime object
        date_time_list.append(datetime.strptime(str(year) +
                                                '-' + 
                                                month + 
                                                '-' +
                                                str(day) +
                                                '-' +
                                                times_24[time24_idx],
                                                '%Y-%b-%d-%H'))
        
        time24_idx += 1 # increment to next time
        last_am_pm = am_pm # set last_am_pm to this one
    
    return date_time_list

if __name__ == '__main__':
    print(retrieve_weather('https://www.tide-forecast.com/locations/Merrimack-River-Entrance-Massachusetts/forecasts/latest'))