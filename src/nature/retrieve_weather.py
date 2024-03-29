# -*- coding: utf-8 -*-
"""
Created on Fri Jun 10 02:18:34 2022

@author: Robert J McGinness
"""

import requests
import urllib
from scrapy.selector import Selector
from typing import List
from datetime import datetime
from calendar import isleap
from calendar import month_abbr

from .nature_entities import SeaConditions
from .nature_entities import GlobalPosition
# from nature_entities import SeaConditions
# from nature_entities import GlobalPosition

# @dataclass
# class SeaConditions:
#     date_time: datetime
#     swell_height: float
#     swell_direction: str
#     wave_height: int
#     wave_period: int
#     wind_speed: int
#     wind_direction: str
#     weather_state: str
#     temperature: int
#     wind_chill: int
#     water_temperature: int
#     water_temp_units: str
#     high_tide_height: Optional[float] = None
#     low_tide_height: Optional[float] = None


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
            day = (day + 1) % divisor + (day + 1) // divisor
            if day == 1:
                month_num = month_abbr.find(month)
                month = month_abbr[(month_num + 1) % 13 + (month_num + 1) // 13]
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

# https://www.tide-forecast.com/countries/United-States/regions


def state_weather_locations(url: str) -> List[str]:
    response = requests.get(url)
    
    location_list = Selector(text=response.content).xpath('//select[@name="location_filename_part"]').get()
    
    return Selector(text=location_list).xpath('//option/@value').getall()
    
def tide_weather_locations(url: str) -> List[str]:
    # response = requests.get('https://www.tide-forecast.com/regions/New-Hampshire')
    # response = requests.get('https://www.tide-forecast.com/countries/United-States/regions')
    
    response = requests.get(url)
    
    regions_list = Selector(text=response.content).xpath('//select[@name="region_id"]').get()
    states = Selector(text=regions_list).xpath('//option/text()').getall()
    states = [state.replace(' ', '-') for state in states]
    
    state_base_url = 'https://www.tide-forecast.com/regions/'
    
    site_names = []
    for state in states:
        state_sites = state_weather_locations(state_base_url + state)
        site_names += state_sites
          
    return site_names

# action="https://www.google.com/maps/search/?api=1"
#     <input type="text" name="q" id="search" placeholder="Search Google Maps"/>    

def map_site_coordinates(site_name: str) -> GlobalPosition:
    google_maps_url = 'https://www.google.com/maps/search/?api=1'
    
    site_name = site_name.replace(' ', '+')
    site_name = site_name.replace('-', '+')
    
    response = requests.get(google_maps_url + "&q=" + site_name, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:101.0) Gecko/20100101 Firefox/101.0'})
    print(response.text)
    
    url = Selector(text=response.text).xpath('//meta/@content[contains(.,"maps.google.com")]').get()
    
    query_parts = urllib.parse.parse_qs(url)
    coords_key = [key for key in query_parts if 'maps.google.com' in key][0]
    latitude, longitude = query_parts[coords_key][0].split(',')
    
    return GlobalPosition(latitude=float(latitude.strip()),
                          longitude=float(longitude.strip()))
    

if __name__ == '__main__':
    # exit()
    # global_position = map_site_coordinates('Weeks-Bay-Vermilion-Bay-Louisiana')
    
    # print(global_position)
    
    
    error_file = open('../../logs/sea_site_errors.txt', 'wt')
    
    weather_locations = tide_weather_locations('https://www.tide-forecast.com')
    
    base_url = 'https://www.tide-forecast.com/locations/'
    url_path = '/forecasts/latest'
    
    with open('tide_weather_site_names.txt', 'wt') as f:
        for location_name in weather_locations:
            try:
                # position = map_site_coordinates(location_name)
                f.write(str({'name':location_name.replace('-', ' '),
                             'url': base_url + location_name + url_path}) + '\n')
                
                # f.write(str({'url': base_url + location_name + url_path,
                #              'latitude': position.latitude,
                #              'longitude': position.longitude}) + '\n')
            except:
                error_file.write(location_name + '\n')
    
    error_file.close()
    
            
    
    # weather_locations = tide_weather_locations('https://www.tide-forecast.com')
    
    # print(weather_locations)
    
    # base_url = 'https://www.tide-forecast.com/locations/'
    # url_path = '/forecasts/latest'
    
    # with open('tide_weather_site_names.txt', 'wt') as f:
    #     for location_name in weather_locations:
    #         f.write(str({'url': base_url + location_name + url_path}) + '\n')
            

            
    
    '''TEST DATE MODULUS ALGORITHM'''
    # days28 = list(range(1, 29))
    # days29 = list(range(1, 30))
    # days30 = list(range(1, 31))
    # days31 = list(range(1, 32))
    # month_numbers = list(range(1,13))
    
    # print('28 Days:', [(day + 1) % 29 + (day + 1) // 29 for day in days28])
    # print('29 Days:', [(day + 1) % 30 + (day + 1) // 30 for day in days29])
    # print('30 Days:', [(day + 1) % 31 + (day + 1) // 31 for day in days30])
    # print('31 Days:', [(day + 1) % 32 + (day + 1) // 32 for day in days31])
    # print('Months:', [(month_num + 1) % 13 + (month_num + 1) // 13 for month_num in month_numbers])
    
    '''TEST SCRAPE'''
    # print(retrieve_weather('https://www.tide-forecast.com/locations/Merrimack-River-Entrance-Massachusetts/forecasts/latest'))