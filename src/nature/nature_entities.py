# -*- coding: utf-8 -*-
"""
Created on Wed Jun 22 12:09:40 2022

@author: Robert J McGinness
"""

from typing import Optional
from dataclasses import dataclass
from datetime import datetime
from datetime import date
from datetime import time


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

