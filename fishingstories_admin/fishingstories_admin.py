# -*- coding: utf-8 -*-
"""
Created on Wed Jun  1 15:12:01 2022

@author: Robert J McGinness
"""


from flask import current_app
from flask import Blueprint
from flask import render_template
from flask import flash
from flask import redirect
from flask import url_for
from flask_login import current_user
from flask_login import login_required
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

from src.db import models
from .api.forms import AddBaitForm
from .api.forms import AddGearForm


bp = Blueprint('fishingstories_admin', __name__)#, url_prefix='/admin')


@bp.route('/')
@bp.route('/index')
def index():
    if not current_user.is_authenticated:
        return redirect(url_for('auth'))
    
    return render_template('admin/index.html', authenticated=True)

@bp.route('/baitsmenu')
@login_required
def baits_menu():
    return render_template('fishingstories_admin/baitsmenu.html', authenticated=True)

@bp.route('/baits/create', methods=['GET', 'POST'])
@login_required
def add_bait():
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
            
            return render_template('fishingstories/addbait.html', title='Add Bait', form=form, authenticated=True)
        
        flash('Added bait {}, size={}, color={}'.format(form.name.data,
                                                      form.size.data,
                                                      form.color.data))
        return redirect('/baits')
    
    return render_template('fishingstories/addbait.html', title='Add Bait', form=form, authenticated=True)

@bp.route('/baits')
@login_required
def baits():
    
    baits = current_app.session.execute(select(models.Bait))
    
    baits = [bait[0] for bait in baits]
    
    return render_template('fishingstories/baits.html', baits=list(baits), authenticated=True)

@bp.route('/gearmenu')
@login_required
def gear_menu():
    return render_template('fishingstories/gearmenu.html', authenticated=True)

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

    return render_template('fishingstories/addgear.html', title='Add Gear Combo', form=form, authenticated=True)

@bp.route('/gear')
@login_required
def gear():
    gear_combos = current_app.session.execute(select(models.FishingGear))
    
    # take the first element in the returned tuple
    gear_combos = [gear[0] for gear in gear_combos]
    
    return render_template('fishingstories/gear.html', gear_list=gear_combos, authenticated=True)