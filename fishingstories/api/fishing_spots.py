# -*- coding: utf-8 -*-
"""
Created on Wed Jun  8 22:59:37 2022

@author: Robert J McGinness
"""

from flask import Blueprint
from flask import current_app
from flask import render_template
from flask import flash
from flask import redirect
from flask import request
from flask import abort
# from flask import get_flashed_messages
from flask_login import login_required
from flask_login import current_user
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.exc import OperationalError
from datetime import datetime
import math


from .forms import AddFishingSpotForm
from .forms import ViewFishingSpotForm
from src.db import models
from src.nature.retrieve_weather import retrieve_weather
from src.nature.retrieve_tide_current import retrieve_tide_currents
from src.nature.current_stations import google_maps_url2022





bp = Blueprint('fishing_spots', __name__)

# @bp.route('/', methods=['GET'])
# @login_required
# def fishing_spots_menu():
    
#     return abort(400)



@bp.route('/angler/<int:angler_id>/fishing_spots/menu', methods=['GET'])
@login_required
def angler_spots_menu(angler_id: int):
    return render_template('fishing_spots/main.html', angler_id=angler_id, authenticated=True)

@bp.route('/angler/<int:angler_id>/fishing_spots/create', methods=['GET', 'POST'])
@login_required
def fishing_spot_create(angler_id: int):
    # spots = current_app.session.scalars(select(models.FishingSpot).where(
    #                                     models.FishingSpot.is_public == True))
    
    angler = current_app.session.scalar(select(models.Angler).where(
                                                models.Angler.id == angler_id))
    
    spots = angler.fishing_spots
    
    form = AddFishingSpotForm()
    
    if form.validate_on_submit():
        
        # instantiate new spot
        fishing_spot = models.FishingSpot(name=form.name.data,
                                          nickname=form.nickname.data,
                                          description=form.description.data,
                                          is_public=form.is_public.data)
        
        # instantiate global position
        # store the lat and long as radians
        global_position = models.GlobalPosition(latitude=math.radians(float(form.latitude.data)),
                                                longitude=math.radians(float(form.longitude.data)))
        
        # setup foreign key on fishing_spot to global_position
        fishing_spot.global_position = global_position
        
        # generate url to google maps for this spot
        map_url = models.DataUrl(url=google_maps_url2022(
                                                    global_position.latitude,
                                                    global_position.longitude),
                                 data_type='map')
        
        # setup foreign key on map_url to global_position
        map_url.global_position = global_position
        
        # Trigger fires on database to set current_url_id :) 
        
        # get the angler to make establish association
        angler = current_app.session.scalar(select(models.Angler).where(
                                                models.Angler.id == angler_id))
        
        fishing_spot.anglers.append(angler)
        
        current_app.session.add(fishing_spot)
        try:
            current_app.session.commit()
            
            # add new spot to list to display
            spots.insert(0, fishing_spot)
        except (IntegrityError, OperationalError) as e:
            current_app.logger.info(e)
    
    ################################################################
    ######MAY BE A BUG HERE.  SPOTS NOT LOADING, WHEN YOU GO BACK TO PAGE
    ######MIGHT NEED TO GET THEM FROM DB AGAIN
        
    
    return render_template('fishing_spots/fishing-spot-create.html',
                           form=form,
                           spots=spots,
                           angler_id=angler_id,
                           authenticated=True)

    
    

@bp.route('/angler/<int:angler_id>/fishing_spots', methods=['GET'])
@login_required
def my_spots(angler_id: int):
    angler = current_app.session.scalar(select(models.Angler).where(
                                                models.Angler.id == angler_id))
    
    fishing_spots = []
    if angler is not None:
        fishing_spots = angler.fishing_spots
    
    
    return render_template('fishing_spots/angler-spots.html', angler_id=angler_id, fishing_spots=fishing_spots, authenticated=True)

@bp.route('/angler/<int:angler_id>/fishing_spots/<int:spot_id>', methods = ['GET'])
@login_required
def fishing_spot(angler_id: int, spot_id: int):
    
    spot = current_app.session.scalar(select(models.FishingSpot).where(
                                            models.FishingSpot.id == spot_id))
    
    gp = spot.global_position
    
    form = ViewFishingSpotForm(name=spot.name,
                               latitude=math.degrees(gp.latitude),
                               longitude=math.degrees(gp.longitude),
                               is_public=spot.is_public,
                               nickname=spot.nickname,
                               description=spot.description)
    
    current_data_url = spot.current_url.url
    

        
    ####################################################################
    #######CANNOT DO WEATHER NOW.  GOOGLE WOULD NOT LETME SCAPE DATA
    ######CAN USE PLACES API LATER FOR THIS
    # weather = retrieve_weather('https://www.tide-forecast.com/locations/Merrimack-River-Entrance-Massachusetts/forecasts/latest')
    
    # tc_url = 'http://tbone.biol.sc.edu/tide/tideshow.cgi?'
    tide_currents = retrieve_tide_currents(current_data_url, datetime.now())

    # return render_template('fishing_spots/spot-view.html',
    #                         spot_name=view_form.spot_name.data,
    #                         weather=weather,
    #                         tide_currents=tide_currents)

    return render_template('fishing_spots/spot-view.html',
                            spot_name=spot.name,
                            tide_currents=tide_currents,
                            angler_id=angler_id,
                            map_url=google_maps_url2022(math.degrees(gp.latitude),
                                                        math.degrees(gp.longitude)),
                            form=form,
                            authenticated=True)


@bp.route('/public-spots')
@login_required
def public_spots():
    return abort(404)
    return render_template('fishing_spots/public-spots.html', authenticated=True)

@bp.route('/group-spots')
@login_required
def group_spots():
    return abort(404)
    flash('RESTRICTED')
    
    return render_template('fishing_spots/main.html', authenticated=True)
