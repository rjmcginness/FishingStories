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

from src.db import models
from .forms import AddBaitForm
from .forms import BaitForm
from .forms import AddGearForm
from .forms import SearchBasicForm



bp = Blueprint('angler', __name__, url_prefix='/angler')


@bp.route('/baitsmenu')
@login_required
def baits_menu():
    return render_template('fishingstories/baits/baitsmenu.html', authenticated=True)

@bp.route('/bait/create', methods=['GET', 'POST'])
@login_required
def bait_create():
    form = AddBaitForm()
    if form.validate_on_submit():
        
        ###### ADDRESS THE CONVERSION TO FLOAT (MAYBE ANOTHER TYPE OF FIELD)
        bait = models.Bait(name=form.name.data,
                           artificial=form.artificial.data,
                           size=form.size.data,
                           color=form.color.data,
                           description=form.description.data)
        
        # add new bait to database
        ######IT WOULD BE GREAT TO KEEP name+size+color unique
        try:
            current_app.session.add(bait)
            current_app.session.commit()
        except IntegrityError:
            ###### HOW DO I CLEAR THIS????? session.pop('_flashes', None)????
            flash('Bait {} size={} color={} already exists'.format(form.name.data,
                                                          form.size.data,
                                                          form.color.data))
            
            form.clear()
        
        flash('Added bait {}, size={}, color={}'.format(form.name.data,
                                                      form.size.data,
                                                      form.color.data))
        return redirect(url_for('angler.baits'))
    
    return render_template('fishingstories/baits/addbait.html', title='Add Bait', form=form, authenticated=True)

@bp.route('/baits')
@login_required
def baits():
    
    baits = current_app.session.execute(select(models.Bait))
    
    baits = [bait[0] for bait in baits]
    
    return render_template('fishingstories//baits/baits.html', baits=list(baits), authenticated=True)

@bp.route('/baits/<int:bait_id>', methods=['GET'])
@login_required
def bait(bait_id: int):
    bait = current_app.session.scalar(select(models.Bait).where(
                                                    models.Bait.id == bait_id))
    
    form = BaitForm(bait)
    form.readonly()
    
    return render_template('fishingstories/baits/bait.html', form=form, authenticated=True)

@bp.route('/baits/search', methods=['GET'])
@login_required
def bait_search():
    form = SearchBasicForm(search_name='Bait Name')
    
    if len(request.args) > 0:
        flash(request.args)
    
        return render_template('fishingstories/baits/baits.html', baits=baits, authenticated=True)
    
    return render_template('/search.html', form=form, search_endpoint=url_for('angler.bait_search'))

@bp.route('/baits/<int:bait_id>/edit', methods=['GET', 'PATCH'])
@login_required
def bait_edit(bait_id: int):
    bait = current_app.session.scalar(select(models.Bait).where(
                                                    models.Bait.id == bait_id))
    
    
    if request.method == 'PATCH':
        return abort(404)
    
    form = BaitForm(bait)
    form.readonly(False)
    
    return render_template('fishingstories/baits/bait_edit.html', form=form, authenticated=True)

@bp.route('/gearmenu')
@login_required
def gear_menu():
    return render_template('fishingstories/gear/gearmenu.html', authenticated=True)

@bp.route('/create-gear', methods=['GET', 'POST'])
@login_required
def add_gear():
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

@bp.route('/gear')
@login_required
def gear():
    gear_combos = current_app.session.execute(select(models.FishingGear))
    
    # take the first element in the returned tuple
    gear_combos = [gear[0] for gear in gear_combos]
    
    return render_template('fishingstories/gear/gear.html', gear_list=gear_combos, authenticated=True)

