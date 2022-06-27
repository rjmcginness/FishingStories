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
from sqlalchemy import delete
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
from .forms import DeleteBaitForm

from src.nature.retrieve_weather import retrieve_weather
from src.nature.retrieve_tide_current import retrieve_tide_currents
from src.nature.current_stations import google_maps_url2022




bp = Blueprint('bait', __name__)




@bp.route('/angler/<int:angler_id>/baitsmenu')
@login_required
def baits_menu(angler_id: int):
    return render_template('fishingstories/baits/baitsmenu.html', angler_id=angler_id, authenticated=True)

@bp.route('/angler/<int:angler_id>/baits')
@login_required
def baits(angler_id: int):
    
    # all_baits = current_app.session.scalars(select(models.Bait))
    # angler = current_app.session.scalar(select(models.Angler).where(
    #                                         models.Angler.id == angler_id))
    
    # my_baits = angler.baits
    
    
    # This approach controls prevents the user from adding duplicate baits
    # to their list of baits in use_bait endpoint
    # baits = [bait for bait in all_baits if bait.id not in [my_bait.id for my_bait in my_baits]]
    baits = current_app.session.scalars(select(models.Bait))
    return render_template('fishingstories/baits/baits.html', title='My Baits', angler_id=angler_id, baits=baits, authenticated=True)

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
        
        angler = current_app.session.scalar(select(models.Angler).where(
                                                models.Angler.id == angler_id))
        
        bait.anglers.append(angler)
        
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
        return redirect(url_for('bait.baits'))
    
    return render_template('fishingstories/baits/addbait.html', title='Add Bait', angler_id=angler_id, form=form, authenticated=True)

@bp.route('/angler/<int:angler_id>/my_baits')
@login_required
def my_baits(angler_id: int):
    
    angler = current_app.session.scalar(select(models.Angler).where(
                                                models.Angler.id == angler_id))
    
    baits = angler.baits
    
    return render_template('fishingstories/baits/my-baits.html', title='My Baits', angler_id=angler_id, baits=baits, authenticated=True)

@bp.route('/angler/<int:angler_id>/baits/<int:bait_id>', methods=['GET'])
@login_required
def bait(angler_id: int, bait_id: int):
    bait = current_app.session.scalar(select(models.Bait).where(
                                                    models.Bait.id == bait_id))
    
    form = BaitForm(bait)
    form.readonly()
    
    return render_template('fishingstories/baits/bait.html', angler_id=angler_id, bait_id=bait_id, form=form, authenticated=True)

@bp.route('/angler/<int:angler_id>/bait/<int:bait_id>/use_bait', methods=['GET'])
@login_required
def use_bait(angler_id: int, bait_id: int):
    
    angler = current_app.session.scalar(select(models.Angler).where(
                                                models.Angler.id == angler_id))
    
    bait = current_app.session.scalar(select(models.Bait).where(
                                                    models.Bait.id == bait_id))
    
    angler.baits.append(bait)
    
    try:
        current_app.session.commit()
    except (IntegrityError, OperationalError) as e:
        current_app.logger.info(e)
        current_app.session.rollback()
        
    return redirect(url_for('bait.my_baits', angler_id=angler_id))

@bp.route('/angler/<int:angler_id>/baits/search', methods=['GET'])
@login_required
def my_bait_search(angler_id: int):
    form = SearchBasicForm(search_name='Bait Name')
    
    try:
        search_query = request.args['search']
        
        # NEED A JOIN HERE TO GET THIS ANGLER'S MATCHING BAITS
        '''
            SELECT * FROM baits b
            INNER JOIN angler_baits ab
            ON ab.bait_id = b.id
            INNER JOIN anglers a
            ON a.id = ab.angler_id
            WHERE a.id = angler_id AND b.name ILIKE '%search_query%';
        '''
        results = current_app.session.query(models.Bait).join(
                    models.angler_baits, models.angler_baits.c.bait_id == models.Bait.id).join(
                        models.Angler, models.angler_baits.c.angler_id == models.Angler.id).filter(
                            models.Angler.id == angler_id).filter(
                            models.Bait.name.ilike('%' + search_query + '%'))
                                
        baits = list(results) #convert to a list generator has no __len__
        assert len(baits) > 0
    
        return render_template('fishingstories/baits/my-baits.html', angler_id=angler_id, baits=baits, authenticated=True)
    except KeyError:
        pass
    except AssertionError:
        flash('No results found.')
    
    return render_template('/search.html', angler_id=angler_id, form=form,
                           search_endpoint=url_for('bait.my_bait_search',
                                                   angler_id=angler_id),
                           authenticated=True)

@bp.route('/angler/<int:angler_id>/baits/search_all', methods=['GET'])
@login_required
def bait_search(angler_id: int):
    form = SearchBasicForm(search_name='Bait Name')
    
    try:
        search_query = request.args['search']
        '''
            SELECT * FROM baits b
            WHERE b.name ILIKE '%search_query%';
        '''
        baits = current_app.session.scalars(models.Bait).where(
                            models.Bait.name.ilike('%' + search_query + '%'))
                                
    #     # ScalarResult is a generator that yields Bait
    #     # can only iterate over it once, so convert to list
        baits = list(baits)
        assert len(baits) > 0
    
        return render_template('fishingstories/baits/baits.html', angler_id=angler_id, baits=baits, authenticated=True)
    except KeyError:
        pass
    except AssertionError:
        flash('No results found.')
    
    return render_template('/search.html', angler_id=angler_id, form=form, search_endpoint=url_for('bait.my_bait_search', angler_id=angler_id), authenticated=True)

# @bp.route('/angler/<int:angler_id>/baits/<int:bait_id>/edit', methods=['GET', 'PATCH'])
# @login_required
# def bait_edit(angler_id: int, bait_id: int):
#     bait = current_app.session.scalar(select(models.Bait).where(
#                                                     models.Bait.id == bait_id))
#     form = BaitForm(bait)
#     form.readonly(False)
    
#     if request.method == 'PATCH':
#         if form.validate():
#             return abort(404)
    
    
    
#     return render_template('fishingstories/baits/bait-edit.html', angler_id=angler_id, bait_id=bait_id, form=form, authenticated=True)

@bp.route('/angler/<int:angler_id>/baits/<int:bait_id>/delete', methods=['GET', 'DELETE'])
@login_required
def my_bait_delete(angler_id: int, bait_id: int):
    ''' Does not delete the bait, but deletes the association with
        this angler.
    '''
    bait = current_app.session.scalar(select(models.Bait).where(
                                                    models.Bait.id == bait_id))
    form = DeleteBaitForm(name=bait.name,
                          size=bait.size,
                          color=bait.color)
    
    if request.method == 'DELETE':
        if form.validate():
            current_app.session.execute(delete(models.angler_baits).where(
                                models.angler_baits.c.angler_id == angler_id).where(
                                models.angler_baits.c.bait_id == bait_id))
            try:
                current_app.session.commit()
            except (IntegrityError, OperationalError) as e:
                current_app.logger.info(e)
                current_app.session.rollback()
            
        return redirect(url_for('bait.my_baits', angler_id=angler_id))

    return render_template('fishingstories/baits/my-bait-delete.html', angler_id=angler_id, bait_id=bait_id, form=form, authenticated=True)