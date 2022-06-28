# -*- coding: utf-8 -*-
"""
Created on Mon Jun 26 19:30:22 2022

@author: Robert J McGinness
"""

from flask import Blueprint
from flask import current_app
from flask import render_template
from flask import flash
from flask_login import login_required

from sqlalchemy import select
from sqlalchemy import text


from dataclasses import dataclass
from typing import List


from src.db import models





bp = Blueprint('statistics', __name__)

@dataclass
class StatsBundle:
    total_fish: int
    catch_count_by_species: List[tuple]
    species_avg_weight_length: List[tuple]
    fish_at_spots: List[tuple]
    best_spots: List[tuple]
    percent_at_best_spot: float


@bp.route('/<int:angler_id>/statistics', methods=['GET'])
@login_required
def statistics(angler_id: int):
    

    sb = StatsBundle(None, None, None, None, None, None) # beacuse it is a dataclass
    
    # Get total count of fish caught by this angler
    stmt = f'SELECT COUNT(*) FROM fishes WHERE angler_id = {str(angler_id)};'
    
    sb.total_fish = list(current_app.session.execute(stmt).scalars())[0]
    
    # number of each species caught
    stmt = text(f'''
                SELECT species, COUNT(*) FROM fishes
                WHERE angler_id = {angler_id}
                GROUP BY species
                ORDER BY COUNT(*) DESC;
                ''')
           
    sb.catch_count_by_species = list(current_app.session.execute(stmt))
    
    # Get Average Weight and Length of fish by species
    stmt = text(f'''
                SELECT species, AVG(weight), AVG(length) FROM fishes
                WHERE angler_id = {angler_id}
                GROUP BY species;
                ''')
           
    # sb.species_avg_weight_length = list(current_app.session.execute(stmt))
    sb.species_avg_weight_length = list(current_app.session.execute(stmt))
    sb.species_avg_weight_length = [(s[0], '{: .2f} lbs'.format(s[1]) if s[1] is not None else '0.0lb',
                                     '{: .2f}"'.format(s[2]) if s[2] is not None else '0.0"') for s in sb.species_avg_weight_length]
    
    
    # number of fish caught at each spot
    stmt = text(f'''
                SELECT s.name as spot_name, COUNT(f.id) FROM fishes f
                INNER JOIN fishing_spots s
                ON f.fishing_spot_id = s.id
                WHERE f.angler_id = {angler_id}
                GROUP BY s.name;
                ''')
    
    sb.fish_at_spots = list(current_app.session.execute(stmt))
    
    stmt = text(f'''
                WITH fish_counts as (
                SELECT s.name as spot_name, COUNT(f.id) as fish_count FROM fishes f
                INNER JOIN fishing_spots s
                ON f.fishing_spot_id = s.id
                WHERE angler_id = {angler_id}
                GROUP BY s.name
                ) SELECT spot_name, MAX(fish_count) FROM fish_counts
                GROUP BY spot_name;
                ''')
            
    sb.best_spots = list(current_app.session.execute(stmt))
    
    highest_catch_count = sb.best_spots[0][1]
    
    sb.percent_at_best_spot = 100 * highest_catch_count / sb.total_fish
    
    sb.percent_at_best_spot = f'{sb.percent_at_best_spot: .1f}%'
    
    return render_template('fishingstories/my_statistics.html', results=sb, angler_id=angler_id, authenticated=True)
