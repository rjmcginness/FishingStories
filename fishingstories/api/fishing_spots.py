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
from sqlalchemy.exc import PendingRollbackError
from datetime import datetime


from .forms import AddFishingSpotForm
from .forms import ViewFishingSpotForm
from src.db import models
from src.nature.retrieve_weather import retrieve_weather
from src.nature.retrieve_tide_current import retrieve_tide_currents




bp = Blueprint('fishing_spots', __name__, url_prefix='/fishing_spots')

@bp.route('/', methods=['GET'])
@login_required
def fishing_spots_menu():
    
    return abort(400)


@bp.route('/<int:spot_id>', methods=['GET'])
@login_required
def spot(spot_id: int):
    spot = current_app.session.scalar(select(models.FishingSpot).where(
                                            models.FishingSpot.id == spot_id)).first()
    
    # 'https://www.tide-forecast.com/locations/Merrimack-River-Entrance-Massachusetts/forecasts/latest'
    # 'http://tbone.biol.sc.edu/tide/tideshow.cgi?'
    # 'Newburyport (Merrimack River), Massachusetts Current'
    if spot is None:
        flash('Error loading spot')
        return redirect(request.referrer)
    
    weather = []
    try:
        weather = retrieve_weather(spot.weather_url)
    except:
        pass
    
    tide_currents = None
    try:
        tide_currents = retrieve_tide_currents(spot.current_url, datetime.now(),spot.current_ref_name)
    except:
        pass

    return render_template('fishing_spots/spot-view.html',
                                spot_name=spot.name,
                                weather=weather,
                                tide_currents=tide_currents)
    

# @bp.route('/myspots', methods = ['GET', 'POST'])
# @login_required
# def my_spots():
#     add_form = AddFishingSpotForm()
#     view_form = ViewFishingSpotForm()
    
#     if view_form.spot_name.data:
#         weather = retrieve_weather('https://www.tide-forecast.com/locations/Merrimack-River-Entrance-Massachusetts/forecasts/latest')
        
#         tc_url = 'http://tbone.biol.sc.edu/tide/tideshow.cgi?'
#         tide_currents = retrieve_tide_currents(tc_url, datetime.now(),'Newburyport (Merrimack River), Massachusetts Current')
#         # flash(weather)
#         # flash(tide_currents.water)
#         return render_template('fishing_spots/spot-view.html',
#                                spot_name=view_form.spot_name.data,
#                                weather=weather,
#                                tide_currents=tide_currents)
    
#     if add_form.validate_on_submit():
#         fishing_spot = models.FishingSpot(name=add_form.name.data,
#                                           latitude=add_form.latitude.data,
#                                           longitude=add_form.longitude.data,
#                                           description=add_form.description.data)
        
#         try:
#             current_app.session.add(fishing_spot)
#             current_app.session.commit()
#         except IntegrityError:
#             flash('Duplicate Spot: latitude {}, longitude {} already exists'.
#                   format(add_form.latitude, add_form.longitude))
#             current_app.session.rollback()
    
#     spots = []
#     try:
#         spots = current_app.session.execute(select(models.FishingSpot))
#         spots = [spot[0] for spot in spots]
#     except PendingRollbackError as e:
#         flash(e)
        
#     return render_template('fishing_spots/user-spots.html',
#                            add_form=add_form,
#                            view_form=view_form,
#                            spots=spots,
#                            authenticated=True)
        

@bp.route('/public-spots')
@login_required
def public_spots():
    return render_template('fishing_spots/public-spots.html', authenticated=True)

@bp.route('/group-spots')
@login_required
def group_spots():
    flash('RESTRICTED')
    
    return render_template('fishing_spots/main.html', authenticated=True)
