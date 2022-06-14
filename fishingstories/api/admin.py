# -*- coding: utf-8 -*-
"""
Created on Mon Jun  6 23:39:27 2022

@author: Robert J McGinness
"""

from flask import current_app
from flask import Blueprint
from flask import render_template
from flask import flash
from flask import redirect
from flask import jsonify
from flask_login import login_required
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

from ..db import models
from .forms import RankForm
from .forms import CreateAnglerForm
from .forms import CreateAccountTypeForm
from .forms import CreatePriviledgeForm


bp = Blueprint('admin', __name__)


@bp.route('/admin')
@login_required
def admin():
    return render_template('admin/index.html', authenticated=True)


@bp.route('/manage-anglers')
@login_required
def manage_anglers():
    return render_template('admin/anglermenu.html', authenticated=True)

@bp.route('/anglers')
@login_required
def anglers():
    anglers_list = current_app.session.execute(select(models.Angler))
    
    return render_template('admin/anglers.html', anglers=anglers_list, authenticated=True)

@bp.route('/ranks', methods = ['GET', 'POST'])
@login_required
def ranks():
    form = RankForm()
    ranks = current_app.session.execute(select(models.Rank))
    ranks = [rank[0] for rank in ranks]
    
    if form.validate_on_submit():
        
        rank = models.Rank(name=form.name.data,
                           rank_number=form.rank_number.data,
                           description=form.description.data)
        
        try:
            current_app.session.add(rank)
            current_app.session.commit()
            ranks.append(rank)
        except IntegrityError:
            
            flash('Invalid rank entry')
            
    form.clear()
            
    return render_template('admin/ranks.html', form=form, ranks=ranks, authenticated=True)

@bp.route('/account_types', methods=['GET', 'POST'])
@login_required
def account_types():
    form = CreateAccountTypeForm()
    priviledges = current_app.session.execute(select(models.Priviledge))
    form.priviledges.choices = [priviledge[0].name for priviledge in priviledges]
    if form.validate_on_submit():
        ######get priviledges
        ###### create account type
        ###### back populate
        flash('{} {}'.format(form.priviledges.data, form.name.data))
        redirect('admin/index.html')
    
    
    return render_template('admin/account-types.html', form=form, authenticated=True)

@bp.route('/manage-priviledges', methods=['GET'])
@login_required
def manage_priviledges():
    return render_template('admin/priviledges-menu.html')

@bp.route('/priviledges', methods=['GET', 'POST'])
@login_required
def create_priviledge():
    form = CreatePriviledgeForm()
    if form.validate_on_submit():
        
        ###### CONSIDER WRITING A VALIDATOR
        if not form.name.data or form.name.data.isspace() or form.name.data == '':
            flash('Blank Priviledge name entered')
        else:
        
            priviledge = models.Priviledge(name=form.name.data)
            try:
                current_app.session.add(priviledge)
                current_app.session.commit()
            except IntegrityError:
                flash(f'Priviledge name {form.name.data} already exists')
                current_app.session.rollback()
            else:
                return redirect('/priviledges-all')
    
    
    return render_template('admin/create-priviledge.html', form=form, authenticated=True)

@bp.route('/priviledges-all', methods=['GET'])
@login_required
def priviledges():
    priviledges = current_app.session.execute(select(models.Priviledge))
    
    
    priviledge_names = [priviledge[0].serialize() for priviledge in priviledges]
    
    return render_template('admin/priviledges.html', priviledges=priviledge_names, authenticated=True)

@bp.route('/create-anglers')
@login_required
def add_angler():
    form = CreateAnglerForm()
    if form.validate_on_submit():
        
        angler = models.Angler()

