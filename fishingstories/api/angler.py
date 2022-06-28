# -*- coding: utf-8 -*-
"""
Created on Mon Jun 20 08:41:22 2022

@author: Robert J McGinness
"""

from flask import Blueprint
from flask import current_app
from flask import render_template
from flask import redirect
from flask import flash
from flask import url_for
from flask import request
from flask import abort
from flask_login import login_required

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.exc import OperationalError

from datetime import datetime
import math

from src.db import models
from .forms import SearchBasicForm
from .forms import AddBaitForm
from .forms import BaitForm
from .forms import AddGearForm
from .forms import AddFishingSpotForm
from .forms import ViewFishingSpotForm

from src.nature.retrieve_weather import retrieve_weather
from src.nature.retrieve_tide_current import retrieve_tide_currents
from src.nature.current_stations import google_maps_url2022




bp = Blueprint('angler', __name__, url_prefix='/anglers')





# @bp.route('/<int:angler_id>/fishing-spots-menu', methods=['GET'])
# @login_required
# def fishing_spots_menu(angler_id: int):
#     # get_flashed_messages().clear()
    
#     return render_template('fishing_spots/main.html', angler_id=angler_id, authenticated=True)

@bp.route('/<int:angler_id>', methods=['GET'])
@login_required
def angler_home(angler_id: int):
    return render_template('fishingstories/index.html', angler_id=angler_id, authenticated=True)


@bp.route('/<int:angler_id>/manage_account', methods=['GET'])
@login_required
def manage_account(angler_id: int):
    
    angler = current_app.session.scalar(select(models.Angler).where(
                                                models.Angler.id == angler_id))
    
    account_id = angler.user_accounts.id
    
    return render_template('fishingstories/users/user-menu.html', angler_id=angler_id, account_id=account_id, authenticated=True)


# @bp.route('/<int:angler_id>/user_account/<int:account_id>', methods=['GET'])
# @login_required
# def user_account(angler_id: int, account_id: int):
#     # render user account view
#     return abort(404)

# @bp.route('/<int:angler_id>/user_account/<int:account_id>/edit', methods=['GET', 'PATCH'])
# @login_required
# def user_account_edit(angler_id: int, account_id: int):
#     # handle patch
#     return abort(404)


# @bp.route('/<int:angler_id>/user_account/<int:account_id>/cancel', methods=['GET', 'PATCH'])
# @login_required
# def user_account_cancel(angler_id: int, account_id: int):
#     # handle patch to inactivate account
#     return abort(404)

# @bp.route('/<int:angler_id>/fishing_spots/menu', methods=['GET'])
# @login_required
# def angler_spots_menu(angler_id: int):
#     return render_template('/fishing_spots/main.html', angler_id=angler_id, authenticated=True)

# @bp.route('/<int:angler_id>/fishing_spots/create', methods=['GET', 'POST'])
# @login_required
# def fishing_spot_create(angler_id: int):
#     spots = current_app.session.scalars(select(models.FishingSpot).where(
#                                         models.FishingSpot.is_public == True))
    
#     spots = list(spots)
    
#     form = AddFishingSpotForm()
    
#     if form.validate_on_submit():
        
#         # instantiate new spot
#         fishing_spot = models.FishingSpot(name=form.name.data,
#                                           nickname=form.nickname.data,
#                                           description=form.description.data,
#                                           is_public=form.is_public.data)
        
#         # instantiate global position
#         # store the lat and long as radians
#         global_position = models.GlobalPosition(latitude=math.radians(float(form.latitude.data)),
#                                                 longitude=math.radians(float(form.longitude.data)))
        
#         # setup foreign key on fishing_spot to global_position
#         fishing_spot.global_position = global_position
        
#         # generate url to google maps for this spot
#         map_url = models.DataUrl(url=google_maps_url2022(
#                                                     global_position.latitude,
#                                                     global_position.longitude),
#                                  data_type='map')
        
#         # setup foreign key on map_url to global_position
#         map_url.global_position = global_position
        
#         # Trigger fires on database to set current_url_id :) 
        
#         # get the angler to make establish association
#         angler = current_app.session.scalar(select(models.Angler).where(
#                                                 models.Angler.id == angler_id))
        
#         fishing_spot.anglers.append(angler)
        
#         current_app.session.add(fishing_spot)
#         try:
#             current_app.session.commit()
            
#             # add new spot to list to display
#             spots.insert(0, fishing_spot)
#         except (IntegrityError, OperationalError) as e:
#             current_app.logger.info(e)
    
#     ################################################################
#     ######MAY BE A BUG HERE.  SPOTS NOT LOADING, WHEN YOU GO BACK TO PAGE
#     ######MIGHT NEED TO GET THEM FROM DB AGAIN
        
    
#     return render_template('fishing_spots/fishing-spot-create.html',
#                            form=form,
#                            spots=spots,
#                            angler_id=angler_id,
#                            authenticated=True)

    
    

# @bp.route('/<int:angler_id>/fishing_spots', methods=['GET'])
# @login_required
# def my_spots(angler_id: int):
#     angler = current_app.session.scalar(select(models.Angler).where(
#                                                 models.Angler.id == angler_id))
    
#     fishing_spots = []
#     if angler is not None:
#         fishing_spots = angler.fishing_spots
    
    
#     return render_template('fishing_spots/angler-spots.html', fishing_spots=fishing_spots, authenticated=True)

# @bp.route('/<int:angler_id>/fishing-spots/<int:spot_id>', methods = ['GET', 'POST'])
# @login_required
# def fishing_spot(angler_id: int, spot_id: int):
#     add_form = AddFishingSpotForm()
#     view_form = ViewFishingSpotForm()
    
#     if view_form.spot_name.data:
#         weather = retrieve_weather('https://www.tide-forecast.com/locations/Merrimack-River-Entrance-Massachusetts/forecasts/latest')
        
#         tc_url = 'http://tbone.biol.sc.edu/tide/tideshow.cgi?'
#         tide_currents = retrieve_tide_currents(tc_url, datetime.now(),'Newburyport (Merrimack River), Massachusetts Current')
#         # flash(weather)
#         # flash(tide_currents.water)
#         return render_template('fishing_spots/spot-view.html',
#                                 spot_name=view_form.spot_name.data,
#                                 weather=weather,
#                                 tide_currents=tide_currents)
    
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
    
#     spots = current_app.session.execute(select(models.FishingSpot))
#     spots = [spot[0] for spot in spots]
        
#     return render_template('fishing_spots/user-spots.html',
#                             add_form=add_form,
#                             view_form=view_form,
#                             spots=spots,
#                             authenticated=True)
        

# @bp.route('/public-spots')
# @login_required
# def public_spots():
#     return render_template('fishing_spots/public-spots.html', authenticated=True)

# @bp.route('/group-spots')
# @login_required
# def group_spots():
#     flash('RESTRICTED')
    
#     return render_template('fishing_spots/main.html', authenticated=True)


# @bp.route('/baitsmenu')
# @login_required
# def baits_menu():
#     return render_template('fishingstories/baits/baitsmenu.html', authenticated=True)

# @bp.route('/bait/create', methods=['GET', 'POST'])
# @login_required
# def bait_create():
#     form = AddBaitForm()
#     if form.validate_on_submit():
        
#         ###### ADDRESS THE CONVERSION TO FLOAT (MAYBE ANOTHER TYPE OF FIELD)
#         bait = models.Bait(name=form.name.data,
#                            artificial=form.artificial.data,
#                            size=form.size.data,
#                            color=form.color.data,
#                            description=form.description.data)
        
#         # add new bait to database
#         ######IT WOULD BE GREAT TO KEEP name+size+color unique
#         try:
#             current_app.session.add(bait)
#             current_app.session.commit()
#         except IntegrityError:
#             ###### HOW DO I CLEAR THIS????? session.pop('_flashes', None)????
#             flash('Bait {} size={} color={} already exists'.format(form.name.data,
#                                                           form.size.data,
#                                                           form.color.data))
            
#             form.clear()
        
#         flash('Added bait {}, size={}, color={}'.format(form.name.data,
#                                                       form.size.data,
#                                                       form.color.data))
#         return redirect(url_for('angler.baits'))
    
#     return render_template('fishingstories/baits/addbait.html', title='Add Bait', form=form, authenticated=True)

# @bp.route('/baits')
# @login_required
# def baits():
    
#     baits = current_app.session.execute(select(models.Bait))
    
#     baits = [bait[0] for bait in baits]
    
#     return render_template('fishingstories//baits/baits.html', baits=list(baits), authenticated=True)

# @bp.route('/baits/<int:bait_id>', methods=['GET'])
# @login_required
# def bait(bait_id: int):
#     bait = current_app.session.scalar(select(models.Bait).where(
#                                                     models.Bait.id == bait_id))
    
#     form = BaitForm(bait)
#     form.readonly()
    
#     return render_template('fishingstories/baits/bait.html', form=form, authenticated=True)

# @bp.route('/baits/search', methods=['GET'])
# @login_required
# def bait_search():
#     form = SearchBasicForm(search_name='Bait Name')
    
#     try:
#         search_query = request.args['search']
#         baits = current_app.session.scalars(select(models.Bait).where(
#                                     models.Bait.name.ilike(search_query + '%')))
    
#         # ScalarResult is a generator that yields Bait
#         # can only iterate over it once, so convert to list
#         baits = list(baits)
#         assert len(baits) > 0
    
#         return render_template('fishingstories/baits/baits.html', baits=baits, authenticated=True)
#     except KeyError:
#         pass
#     except AssertionError:
#         flash('No results found.')
    
#     return render_template('/search.html', form=form, search_endpoint=url_for('angler.bait_search'))

# @bp.route('/baits/<int:bait_id>/edit', methods=['GET', 'PATCH'])
# @login_required
# def bait_edit(bait_id: int):
#     bait = current_app.session.scalar(select(models.Bait).where(
#                                                     models.Bait.id == bait_id))
    
    
#     if request.method == 'PATCH':
#         return abort(404)
    
#     form = BaitForm(bait)
#     form.readonly(False)
    
#     return render_template('fishingstories/baits/bait_edit.html', form=form, authenticated=True)

# @bp.route('/gearmenu')
# @login_required
# def gear_menu():
#     return render_template('fishingstories/gear/gearmenu.html', authenticated=True)

# @bp.route('/create-gear', methods=['GET', 'POST'])
# @login_required
# def add_gear():
#     form = AddGearForm()
    
#     if form.validate_on_submit():
#         gear_combo = models.FishingGear(rod=form.rod.data,
#                                  reel=form.reel.data,
#                                  line=form.line.data,
#                                  leader=form.leader.data,
#                                  hook=form.hook.data)
#         current_app.session.add(gear_combo)
#         current_app.session.commit()
#         flash('Added Gear Combo')
        
#         return redirect('/gear')

#     return render_template('fishingstories/gear/addgear.html', title='Add Gear Combo', form=form, authenticated=True)

# @bp.route('/gear')
# @login_required
# def gear():
#     gear_combos = current_app.session.execute(select(models.FishingGear))
    
#     # take the first element in the returned tuple
#     gear_combos = [gear[0] for gear in gear_combos]
    
#     return render_template('fishingstories/gear/gear.html', gear_list=gear_combos, authenticated=True)

