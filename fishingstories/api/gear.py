# -*- coding: utf-8 -*-
"""
Created on Sun Jun 26 02:02:18 2022

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




bp = Blueprint('gear', __name__)



@bp.route('/angler/<int:angler_id>/gearmenu')
@login_required
def gear_menu(angler_id: int):
    return render_template('fishingstories/gear/gearmenu.html', authenticated=True)

@bp.route('/angler/<int:angler_id>/gear/ceate', methods=['GET', 'POST'])
@login_required
def add_gear(angler_id: int):
    form = AddGearForm()
    
    if form.validate_on_submit():
        gear_combo = models.FishingGear(rod=form.rod.data,
                                 reel=form.reel.data,
                                 line=form.line.data,
                                 leader=form.leader.data,
                                 hook=form.hook.data)
        current_app.session.add(gear_combo)
        current_app.session.commit()
        flash('Added Gear Combo')
        
        return redirect('/gear')

    return render_template('fishingstories/gear/addgear.html', title='Add Gear Combo', form=form, authenticated=True)

@bp.route('/angler/<int:angler_id>/gear')
@login_required
def gear(angler_id: int):
    gear_combos = current_app.session.execute(select(models.FishingGear))
    
    # take the first element in the returned tuple
    gear_combos = [gear[0] for gear in gear_combos]
    
    return render_template('fishingstories/gear/gear.html', gear_list=gear_combos, authenticated=True)



@bp.route('/angler/<int:angler_id>/gear/<int:gear_id>', methods=['GET'])
@login_required
def bait(angler_id: int, gear_id: int):
    gear = current_app.session.scalar(select(models.FishingGear).where(
                                            models.FishingGear.id == gear_id))
    
    form = GearForm(bait)
    form.readonly()
    
    return render_template('fishingstories/baits/bait.html', form=form, authenticated=True)



@bp.route('/angler/<int:angler_id>/gear/<int:gear_id>/edit', methods=['GET', 'PATCH'])
@login_required
def bait_edit(angler_id: int, gear_id: int):
    bait = current_app.session.scalar(select(models.Bait).where(
                                                    models.FishingGear.id == gear_id))
    
    
    if request.method == 'PATCH':
        if form.validate():
            return abort(404)
    
    form = BaitForm(bait)
    form.readonly(False)
    
    return render_template('fishingstories/baits/bait_edit.html', form=form, authenticated=True)

@bp.route('/angler/<int:angler_id>/gear/<int:gear_id>/delete', methods=['GET', 'DELETE'])
@login_required
def bait_edit(angler_id: int, gear_id: int):
    bait = current_app.session.scalar(select(models.Bait).where(
                                                    models.FishingGear.id == gear_id))
    
    
    if request.method == 'DELETE':
        if form.validate():
            return abort(404)
    
    form = BaitForm(bait)
    form.readonly(False)
    
    return render_template('fishingstories/baits/bait_edit.html', form=form, authenticated=True)

