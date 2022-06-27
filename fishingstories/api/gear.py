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
from flask_login import login_required

from sqlalchemy import select
from sqlalchemy import delete
from sqlalchemy.exc import IntegrityError
from sqlalchemy.exc import OperationalError



from src.db import models

from .forms import AddGearForm
from .forms import GearViewOnlyForm







bp = Blueprint('gear', __name__)



@bp.route('/angler/<int:angler_id>/gearmenu')
@login_required
def gear_menu(angler_id: int):
    return render_template('fishingstories/gear/gearmenu.html', angler_id=angler_id, authenticated=True)

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
        
        angler = current_app.session.scalar(select(models.Angler).where(
                                                models.Angler.id == angler_id))
        
        gear_combo.anglers.append(angler)
        
        current_app.session.add(gear_combo)
        current_app.session.commit()
        flash('Added Gear Combo')
        
        return redirect(url_for('gear.my_gear', angler_id=angler_id))

    return render_template('fishingstories/gear/addgear.html', title='Add Gear Combo', angler_id=angler_id, form=form, authenticated=True)

@bp.route('/angler/<int:angler_id>/gear')
@login_required
def my_gear(angler_id: int):
    angler = current_app.session.scalar(select(models.Angler).where(
                                            models.Angler.id == angler_id))
    
    # take the first element in the returned tuple
    gear_combos = angler.gear
    
    return render_template('fishingstories/gear/gear.html', angler_id=angler_id, gear_list=gear_combos, authenticated=True)



@bp.route('/angler/<int:angler_id>/gear/<int:gear_id>', methods=['GET'])
@login_required
def gear_combo(angler_id: int, gear_id: int):
    
    form = GearViewOnlyForm()
    
    gear = current_app.session.scalar(select(models.FishingGear).where(
                                            models.FishingGear.id == gear_id))
    
    form.rod.data = gear.rod
    form.reel.data = gear.reel
    form.line.data = gear.line
    form.hook.data = gear.hook
    form.leader.data = gear.leader
    
    return render_template('fishingstories/gear/gear-view.html', angler_id=angler_id, gear_id=gear_id, form=form, authenticated=True)



@bp.route('/angler/<int:angler_id>/gear/<int:gear_id>/edit', methods=['GET', 'PATCH'])
@login_required
def gear_edit(angler_id: int, gear_id: int):
    form = AddGearForm() # reuse this for editing
    
    gear_combo = current_app.session.scalar(select(models.FishingGear).where(
                                            models.FishingGear.id == gear_id))
    
    if request.method == 'PATCH':
        if form.validate():
            
            gear_combo.rod = form.rod.data
            gear_combo.reel = form.reel.data
            gear_combo.line = form.line.data
            gear_combo.hook = form.hook.data
            gear_combo.leader = form.leader.data
            
            try:
                current_app.session.commit()
            except (IntegrityError, OperationalError) as e:
                current_app.logger.info(e)
                current_app.session.rollback()
        
        return redirect(url_for('gear.my_gear', angler_id=angler_id))
    
    form.rod.data = gear_combo.rod
    form.reel.data = gear_combo.reel
    form.line.data = gear_combo.line
    form.hook.data = gear_combo.hook
    form.leader.data = gear_combo.leader
    
    return render_template('fishingstories/gear/gear-edit.html', angler_id=angler_id, gear_id=gear_id, form=form, authenticated=True)

@bp.route('/angler/<int:angler_id>/gear/<int:gear_id>/delete', methods=['GET', 'DELETE'])
@login_required
def gear_delete(angler_id: int, gear_id: int):
    ''' Does not delete the gear, but deletes the association with
        this angler.
    '''
    gear_combo = current_app.session.scalar(select(models.FishingGear).where(
                                            models.FishingGear.id == gear_id))
    form = GearViewOnlyForm()
    
    if request.method == 'DELETE':
        if form.validate():
            current_app.session.execute(delete(models.angler_gear).where(
                                models.angler_gear.c.angler_id == angler_id).where(
                                models.angler_gear.c.gear_id == gear_id))
            try:
                current_app.session.commit()
            except (IntegrityError, OperationalError) as e:
                current_app.logger.info(e)
                current_app.session.rollback()
            
        return redirect(url_for('gear.my_gear', angler_id=angler_id))

    return render_template('fishingstories/baits/gear-delete.html', angler_id=angler_id, gear_id=gear_id, form=form, authenticated=True)

