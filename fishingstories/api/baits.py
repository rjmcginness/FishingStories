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




bp = Blueprint('bait', __name__)



@bp.route('/angler/<int:angler_id>/baitsmenu')
@login_required
def baits_menu(angler_id: int):
    return render_template('fishingstories/baits/baitsmenu.html', authenticated=True)

@bp.route('/angler/<int:angler_id>/bait/create', methods=['GET', 'POST'])
@login_required
def bait_create(angler_id: int):
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

@bp.route('/angler/<int:angler_id>/baits')
@login_required
def baits(angler_id: int):
    
    baits = current_app.session.execute(select(models.Bait))
    
    baits = [bait[0] for bait in baits]
    
    return render_template('fishingstories//baits/baits.html', baits=list(baits), authenticated=True)

@bp.route('/angler/<int:angler_id>/baits/<int:bait_id>', methods=['GET'])
@login_required
def bait(angler_id: int, bait_id: int):
    bait = current_app.session.scalar(select(models.Bait).where(
                                                    models.Bait.id == bait_id))
    
    form = BaitForm(bait)
    form.readonly()
    
    return render_template('fishingstories/baits/bait.html', form=form, authenticated=True)

@bp.route('/angler/<int:angler_id>/baits/search', methods=['GET'])
@login_required
def bait_search(angler_id: int):
    form = SearchBasicForm(search_name='Bait Name')
    
    try:
        search_query = request.args['search']
        baits = current_app.session.scalars(select(models.Bait).where(
                                models.Bait.angler_id == angler_id).where(
                                models.Bait.name.ilike(search_query + '%')))
    
        # ScalarResult is a generator that yields Bait
        # can only iterate over it once, so convert to list
        baits = list(baits)
        assert len(baits) > 0
    
        return render_template('fishingstories/baits/baits.html', baits=baits, authenticated=True)
    except KeyError:
        pass
    except AssertionError:
        flash('No results found.')
    
    return render_template('/search.html', angler_id=angler_id, form=form, search_endpoint=url_for('angler.bait_search'))

@bp.route('/angler/<int:angler_id/baits/<int:bait_id>/edit', methods=['GET', 'PATCH'])
@login_required
def bait_edit(angler_id: int, bait_id: int):
    bait = current_app.session.scalar(select(models.Bait).where(
                                                    models.Bait.id == bait_id))
    
    
    if request.method == 'PATCH':
        if form.validate():
            return abort(404)
    
    form = BaitForm(bait)
    form.readonly(False)
    
    return render_template('fishingstories/baits/bait_edit.html', form=form, authenticated=True)

@bp.route('/angler/<int:angler_id/baits/<int:bait_id>/delete', methods=['GET', 'DELETE'])
@login_required
def bait_edit(angler_id: int, bait_id: int):
    bait = current_app.session.scalar(select(models.Bait).where(
                                                    models.Bait.id == bait_id))
    
    
    if request.method == 'DELETE':
        if form.validate():
            return abort(404)
    
    form = BaitForm(bait)
    form.readonly(False)
    
    return render_template('fishingstories/baits/bait_edit.html', form=form, authenticated=True)

