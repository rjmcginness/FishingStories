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
from flask import abort
from flask_login import login_required

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.exc import OperationalError

from datetime import datetime

from src.db import models
from .forms import SearchBasicForm
from .forms import AddFishForm
from .forms import FishSearchForm


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
    form.fishing_spot.choices.insert(0, (-1, ''))
    form.bait.choices = [(bait.id, bait.name + ' ' + str(bait.size) + ' ' + bait.color) for bait in baits]
    form.bait.choices.insert(0, (-1, ''))
    form.gear.choices = [(gr.id, gr.rod + ' ' + gr.reel) for gr in gear]
    form.gear.choices.insert(0, (-1, ''))
    
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

@bp.route('/angler/<int:angler_id>/fish/search', methods=['GET'])
@login_required
def fish_search(angler_id: int):
    form = FishSearchForm()
    
    
    ##########################################################################
    ######FIX THIS Join on at least angler, if not fish caught by angler
    
    
    # get THIS angler's baits
    baits = current_app.session.query(models.Bait).join(models.Angler, models.Bait.anglers).where(models.Angler.id == angler_id).all()
    species = current_app.session.query(models.Fish.species).group_by(models.Fish.species).all()
    
    form.species.choices = [(i, spec[0]) for i, spec in enumerate(species)]
    form.species.choices.insert(0, (-1, 'Select Species'))
    
    spots = current_app.session.query(models.FishingSpot.id, models.FishingSpot.name).group_by(models.FishingSpot.id).all()
    form.fishing_spot.choices = spots
    form.fishing_spot.choices.insert(0, (-1, 'Select Fishing Spot'))
    
    return render_template('fishingstories/fish/fish-search.html', angler_id=angler_id, form=form, authenticated=True)

@bp.route('/angler/<int:angler_id>/fish/<int:fish_id>', methods=['GET'])
@login_required
def fish(angler_id: int, fish_id: int):
    return abort(404)

