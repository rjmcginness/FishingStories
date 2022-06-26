# -*- coding: utf-8 -*-
"""
Created on Thu Jun 23 00:44:48 2022

@author: Robert J McGinness
"""

from flask import Blueprint
from flask import current_app
from flask import render_template
from flask import redirect
from flask import flash
from flask import url_for
from flask import request
from flask_login import login_required

from werkzeug.datastructures import MultiDict

from sqlalchemy import select
from sqlalchemy import distinct
from sqlalchemy.exc import IntegrityError
from sqlalchemy.exc import OperationalError

from datetime import datetime
from typing import List

from src.db import models
from .forms import SearchBasicForm
from .forms import AddFishForm
from .forms import FishSearchForm
from .forms import FishViewOnlyForm
from .forms import EditFishForm
from .forms import DeleteFishForm


bp = Blueprint('fish', __name__)



@bp.route('/angler/<int:angler_id>/fish/menu', methods=['GET'])
@login_required
def fish_menu(angler_id: int):
    return render_template('fishingstories/fish/fish-menu.html', angler_id=angler_id, authenticated=True)

@bp.route('/angler/<int:angler_id>/fish', methods=['GET'])
@login_required
def my_fish(angler_id: int):
    fish = current_app.session.scalars(select(models.Fish).where(
                                           models.Fish.angler_id == angler_id))
    
    return render_template('fishingstories/fish/fish.html', fish=fish, angler_id=angler_id, authenticated=True)

@bp.route('/angler/<int:angler_id>/fish/create', methods=['GET', 'POST'])
@login_required
def add_fish(angler_id: int):
    angler = current_app.session.scalar(select(models.Angler).where(
                                                models.Angler.id == angler_id))
    
    # Join to get only baits for that angler
    baits = current_app.session.query(models.Bait).join(models.Angler, models.Bait.anglers).where(models.Angler.id == angler_id).all()
    # Join to get only gear for that angler
    gear = current_app.session.query(models.FishingGear).join(models.Angler, models.FishingGear.anglers).where(models.Angler.id == angler_id).all()
    
    form = AddFishForm()
    form.fishing_spot.choices = [(spot.id, spot.name) for spot in angler.fishing_spots]
    form.fishing_spot.choices.insert(0, (-1, 'Select Fishing Spot'))
    form.bait.choices = [(bait.id, bait.name + ' ' + str(bait.size) + ' ' + bait.color) for bait in baits]
    form.bait.choices.insert(0, (-1, 'Select Bait'))
    form.gear.choices = [(gr.id, gr.rod + ' ' + gr.reel) for gr in gear]
    form.gear.choices.insert(0, (-1, 'Select Gear'))
    
    if form.validate_on_submit():# or request.method == 'POST' and :
        spot = current_app.session.scalar(select(models.FishingSpot).where(
                         models.FishingSpot.id == form.fishing_spot.data))
        
        bait_id = form.bait.data # id id first element of tuple
        bait = current_app.session.scalar(select(models.Bait).where(
                                                    models.Bait.id == bait_id))
        gear_id = form.bait.data # id is first element of tuple
        gear = current_app.session.scalar(select(models.FishingGear).where(
                                            models.FishingGear.id == gear_id))
        
        angler = current_app.session.scalar(select(models.Angler).where(
                                                    models.Angler.id == angler_id))
        
        date_caught = form.date.data
        time_caught = form.time.data ###### IS THIS 24 HOUR TIME??
        
        fish = models.Fish(species=form.species.data,
                           date_time_caught=datetime.combine(date_caught, time_caught),
                           weight=form.weight.data,
                           length=form.length.data,
                           description=form.description.data)
        
        #####################################################################
        #######REMOVED IMAGE UPLOAD FOR NOW :(
        
        fish.angler = angler
        fish.fishing_spot = spot
        fish.bait = bait
        fish.fishing_gear = gear
        
        current_app.session.add(fish)
        
        try:
            current_app.session.commit()
        except (IntegrityError, OperationalError) as e:
            current_app.logger.info(str(e))
            current_app.session.rollback()
            flash("Unable to add fish.")
            return redirect(url_for('fish.add_fish', angler_id=angler_id))
        
        # successful add, show all fish
        return redirect(url_for('fish.my_fish', angler_id=angler_id))

    return render_template('fishingstories/fish/add-fish.html', form=form, angler_id=angler_id, authenticated=True)

def narrowed_fish_search_query(angler_id: int, query: MultiDict) -> str:
    ''' Build SQL statements to SELECT fish based on parts of 
        search query.  The intention is to make this more efficient
    '''
    query = dict(query)
    
    stmt = select(models.Fish).where(models.Fish.angler_id == angler_id)
    
    #######CONSIDER CREATING AN INDEX ON FISHES DATE_TIME_CAUGHT
    start_date = None
    end_date = None
    if query['start_date'] != '':
        start_date = datetime.fromisoformat(query['start_date'])
        if query['end_date'] != '':
            end_date = datetime.fromisoformat(query['end_date'])
            stmt = stmt.where(models.Fish.date_time_caught.between(start_date, end_date))
        else:
            stmt = stmt.where(models.Fish.date_time_caught >= start_date)
    else:
        if query['end_date'] != '':
            end_date = datetime.fromisoformat(query['end_date'])
            stmt = stmt.where(models.Fish.date_time_caught <= end_date)
    
    return stmt

def narrow_selected_fish(fish: List[models.Fish], query: MultiDict) -> List[models.Fish]:
    ''' Narrow down the initially selected fish by the remaining search 
        criteria not used in the db query
    '''
    query = dict(query)
    
    if query['species'] != 'Select Species': # this is the default
        fish = [f for f in fish if f.species == query['species']]
    
    if query['bait'] != '-1': # form returns as string
        # if here convert query['bait'] to in to compare to id
        fish = [f for f in fish if f.bait.id == int(query['bait'])]
    
    if query['fishing_spot'] != '-1': # see above if statement comment
        fish = [f for f in fish if f.fishing_spot.id == int(query['fishing_spot'])]
    
    return fish


@bp.route('/angler/<int:angler_id>/fish/search', methods=['GET'])
@login_required
def fish_search(angler_id: int):
    
    # User submitted a search
    if request.args:
        
        fish = current_app.session.scalars(
                            narrowed_fish_search_query(angler_id, request.args))
        
        # need to convert fish to list before passing to function, as 
        # originally it is a generator and cannopt be traversed more than once
        fish = narrow_selected_fish(list(fish), request.args)
        
        return render_template('fishingstories/fish/fish.html', angler_id=angler_id, fish=fish, authenticated=True)
    
    # if here, user navigated to search page
    form = FishSearchForm()
    
    # get this angler
    angler = current_app.session.scalar(select(models.Angler).where(
                                                models.Angler.id == angler_id))
    
    # get this anglers baits and pack in a form to display in dropdown
    baits = angler.baits
    bait_list = [(bait.id, bait.name + ' ' + str(bait.size) + ' ' + bait.color) for bait in baits]
    
    # select distinct species names of fish caught by this angler
    # better to do this queery than to get all fish and manually
    # make list of species names distinct
    species = current_app.session.scalars(select(distinct(models.Fish.species)).where(models.Angler.id == angler_id))
    # pack species names for display in dropdown
    species = list(species)
    
    # get all this angler's fish
    spots = angler.fishing_spots
    spot_list = [(spot.id, spot.name) for spot in spots]
    
    # load form with data for limited search criteria
    form.species.choices = species
    form.species.choices.insert(0, 'Select Species')
    
    form.bait.choices = bait_list
    form.bait.choices.insert(0, (-1, 'Select Bait'))
    
    form.fishing_spot.choices = spot_list
    form.fishing_spot.choices.insert(0, (-1, 'Select Fishing Spot'))
    
    
    return render_template('fishingstories/fish/fish-search.html', angler_id=angler_id, form=form, authenticated=True)

@bp.route('/angler/<int:angler_id>/fish/<int:fish_id>', methods=['GET'])
@login_required
def fish(angler_id: int, fish_id: int):
    form = FishViewOnlyForm()
    
    fish = current_app.session.scalar(select(models.Fish).where(
                                                    models.Fish.id == fish_id))
    
    form.species.data = fish.species
    form.date_time.data = fish.date_time_caught
    form.weight.data = fish.weight
    form.length.data = fish.length
    bait = fish.bait
    form.bait.choices = [bait.name + ' ' + str(bait.size) + ' '+ bait.color]
    form.fishing_spot.choices = [fish.fishing_spot.name]
    gear = fish.fishing_gear
    form.gear.choices = [gear.rod + ' with ' + gear.reel]
    form.description.data = fish.description
    
    return render_template('fishingstories/fish/fish-view.html', angler_id=angler_id, fish_id=fish_id, form=form, authenticated=True)

@bp.route('/angler/<int:angler_id>/fish/<int:fish_id>/edit', methods=['GET', 'PATCH'])
@login_required
def fish_edit(angler_id: int, fish_id: int):
    form = EditFishForm()
    
    # update editable fields
    if request.method == 'PATCH':
        
        if form.validate():
            fish = current_app.session.scalar(select(models.Fish).where(
                                                        models.Fish.id == fish_id))
            
            spot = current_app.session.scalar(select(models.FishingSpot).where(
                             models.FishingSpot.id == form.fishing_spot.data))
            
            bait_id = form.bait.data # id id first element of tuple
            bait = current_app.session.scalar(select(models.Bait).where(
                                                        models.Bait.id == bait_id))
            gear_id = form.bait.data # id is first element of tuple
            gear = current_app.session.scalar(select(models.FishingGear).where(
                                                models.FishingGear.id == gear_id))
            
            fish.species = form.species.data
            fish.weight = form.weight.data
            fish.length = form.length.data
            fish.fishing_spot = spot
            fish.bait = bait
            fish.fishing_gear = gear
            fish.description = form.description.data
            
            try:
                current_app.session.commit(fish)
            except (IntegrityError, OperationalError) as e:
                current_app.logger.info(e)
                current_app.session.rollback()
                
        return redirect(url_for('fish.fish', angler_id=angler_id, fish_id=fish_id))
        
    # FOR THE GET
    fish = current_app.session.scalar(select(models.Fish).where(
                                                    models.Fish.id == fish_id))
    angler = current_app.session.scalar(select(models.Angler).where(
                                                models.Angler.id == angler_id))
    
    form.species.data = fish.species
    form.date_time.data = fish.date_time_caught
    form.weight.data = fish.weight
    form.length.data = fish.length
    
    baits = angler.baits
    form.bait.choices = [(bait.id, bait.name + ' ' + str(bait.size) + ' '+ bait.color) for bait in baits]
    old_bait = fish.bait
    form.bait.data = (old_bait.id, old_bait.name + ' ' + str(old_bait.size) + ' '+ old_bait.color)
    
    spots = angler.fishing_spots
    form.fishing_spot.choices = [(spot.id, spot.name) for spot in spots]
    old_spot = fish.fishing_spot
    form.fishing_spot.data = (old_spot.id, old_spot.name)
    
    gear = angler.fishing_gear
    form.gear.choices = [(g.id, g.rod + ' with ' + g.reel) for g in gear]
    old_gear = fish.fishing_gear
    form.gear.data = (old_gear.id, old_gear.rod + ' with ' + old_gear.reel) if old_gear else (-1, 'Select Gear')
    
    form.description.data = fish.description
    
    return render_template('fishingstories/fish/fish-view.html', angler_id=angler_id, fish_id=fish_id, form=form, authenticated=True)

@bp.route('/angler/<int:angler_id>/fish/<int:fish_id>/delete', methods=['GET', 'DELETE'])
@login_required
def fish_delete(angler_id: int, fish_id: int):
    
    ######################################################################
    ######INSTEAD OF JUST DELETING ADD FUNCTIONALITY AND DB TABLE TO SAVE
    ######DATA BUT REMOVE ASSOCIATION WITH ANGLER
    
    
    form = DeleteFishForm()
    
    if request.method == 'DELETE':
        if form.validate():
            fish = current_app.session.scalar(select(models.Fish).where(
                                                    models.Fish.id == fish_id))
        
        current_app.session.delete(fish)
        try:
            current_app.session.commit(fish)
        except (IntegrityError, OperationalError) as e:
            current_app.logger.info(e)
            current_app.session.rollback()
        
        return redirect(url_for('fish.fish_menu', angler_id=angler_id))
            
    
    fish = current_app.session.scalar(select(models.Fish).where(
                                                    models.Fish.id == fish_id))
    
    form.species.data = fish.species
    form.date_time.data = fish.date_time_caught
    form.weight.data = fish.weight
    form.length.data = fish.length
    form.description.data = fish.description
    
    return render_template('fishingstories/fish/fish-delete.html', angler_id=angler_id, fish_id=fish_id, form=form, authenticated=True)