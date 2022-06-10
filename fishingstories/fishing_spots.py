# -*- coding: utf-8 -*-
"""
Created on Wed Jun  8 22:59:37 2022

@author: Robert J McGinness
"""

from flask import Blueprint
from flask import current_app
from flask import render_template
from flask import flash
from flask import get_flashed_messages
from flask import request
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.exc import PendingRollbackError

import crochet
crochet.setup()

from .forms import AddFishingSpotForm
from .forms import ViewFishingSpotForm
from . import models
from nature.retrieve_weather import retrieve_weather



bp = Blueprint('fishing_spots', __name__)



@bp.route('/fishing-spots')
def fishing_spots():
    get_flashed_messages().clear()
    
    return render_template('fishing_spots/main.html')

@bp.route('/myspots', methods = ['GET', 'POST'])
def my_spots():
    add_form = AddFishingSpotForm()
    view_form = ViewFishingSpotForm()
    
    if view_form.spot_name.data:
        weather = retrieve_weather('https://www.tide-forecast.com/locations/Merrimack-River-Entrance-Massachusetts/forecasts/latest')
        flash(weather)
        return render_template('fishing_spots/spot-view.html',
                               spot_name=view_form.spot_name.data,
                               weather_conditions=weather)
    
    if add_form.validate_on_submit():
        fishing_spot = models.FishingSpot(name=add_form.name.data,
                                          latitude=add_form.latitude.data,
                                          longitude=add_form.longitude.data,
                                          description=add_form.description.data)
        
        try:
            current_app.session.add(fishing_spot)
            current_app.session.commit()
        except IntegrityError:
            flash('Duplicate Spot: latitude {}, longitude {} already exists'.
                  format(add_form.latitude, add_form.longitude))
            current_app.session.rollback()
    
    spots = []
    try:
        spots = current_app.session.execute(select(models.FishingSpot))
        spots = [spot[0] for spot in spots]
    except PendingRollbackError as e:
        flash(e)
        
    return render_template('fishing_spots/user-spots.html',
                           add_form=add_form,
                           view_form=view_form,
                           spots=spots)
        

@bp.route('/public-spots')
def public_spots():
    return render_template('fishing_spots/public-spots.html')

@bp.route('/group-spots')
def group_spots():
    flash('RESTRICTED')
    
    return render_template('fishing_spots/main.html')

@crochet.wait_for(timeout=60.0)
def scrape_with_crochet():
    return retrieve_weather()