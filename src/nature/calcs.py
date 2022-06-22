#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 13 16:56:01 2022

@author: robertjmcginness
"""

import math

from .nature_entities import GlobalPosition

def coordinate_to_dms(coordinate: float) -> tuple:
    degrees = int(coordinate)
    fractional_part = coordinate - degrees
    minutes = int(fractional_part * 60)
    fractional_part = (fractional_part * 60) - minutes
    seconds = fractional_part * 60
    
    return degrees, minutes, seconds

def coordinate_to_decimal(degrees: int, minutes: int, seconds: float) -> float:
    return degrees + (minutes + (seconds / 60)) / 60
    

def distance_between_coordinates(point1: GlobalPosition, point2: GlobalPosition) -> float:
    ''' Calculates the Great Circle (orthodromic) distance between two points on Earth 
        (or anything modeled as a sphere) in miles.
        
        Implements the Haversine Formula
        Reference: https://www.geeksforgeeks.org/program-distance-two-points-earth/
    '''
    
    lat1, lat2 = math.radians(point1.latitude), math.radians(point2.latitude)
    long1, long2 = math.radians(point1.longitude), math.radians(point2.longitude)
    
    # lat1, lat2 = lat1/math.pi, lat2/math.pi
    # long1, long2 = long1/math.pi, long2/math.pi
    
    return (3963.0 * math.acos(math.sin(lat1)*math.sin(lat2) +
                math.cos(lat1)*math.cos(lat2)*math.cos(long2-long1)))


if __name__ == '__main__':
    '''Test algorithm'''
    
    gp1 = GlobalPosition(42.8133, -70.8683)
    gp2 = GlobalPosition(43.0359, -70.9441)
    
    print(f'Miles: {distance_between_coordinates(gp1, gp2): .1f}')