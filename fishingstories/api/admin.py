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

@bp.route('/manage-account-types', methods=['GET'])
@login_required
def manage_account_types():
    return render_template('admin/account-types-menu.html')

@bp.route('/account-types', methods=['GET', 'POST'])
@login_required
def create_account_type():
    form = CreateAccountTypeForm()
    
    # pull available priviledges from db as selections for new account_type
    # EXCEPT Administrator
    priviledges = current_app.session.execute(select(models.Priviledge).
                                              where(models.Priviledge.name != 'Administrator'))
    
    form.priviledges.choices = [priviledge[0].name for priviledge in priviledges]
    if form.validate_on_submit():
        # create new account_type
        account_type = models.AccountType(name=form.name.data,
                                          price=form.price.data,
                                          )
        
        #get priviledges
        selected_priviledges = form.priviledges.data
        
        # have to hit db to get selected priviledges again :(
        priviledges = current_app.session.execute(select(models.Priviledge).
                                                  where(models.Priviledge.name.in_(selected_priviledges)))
        
        # create relationship between account_type and priviledges     
        for priviledge in priviledges:
            account_type.priviledges.append(priviledge[0])
        
        # try to add to the database, if fails rollback
        try:
            current_app.session.add(account_type)
            current_app.session.commit()
        except IntegrityError as e:    
            flash(f'Unable to create Account Type {account_type.name}')
            current_app.logger.info(e)
            current_app.session.rollback()
        else:
            return redirect('/account-types-all')
    
    return render_template('admin/create-account-type.html', form=form, authenticated=True)

@bp.route('/account-types-all', methods=['GET'])
@login_required
def account_types():
    account_types = current_app.session.execute(select(models.AccountType).
                                                where(models.AccountType.name != 'Admin').
                                                order_by(models.AccountType.price))
    
    account_types = [account_type[0] for account_type in account_types]
    
    return render_template('admin/account-types.html', account_types=account_types, authenticated=True)

@bp.route('/manage-priviledges', methods=['GET'])
@login_required
def manage_priviledges():
    return render_template('admin/priviledges-menu.html', authenticated=True)

@bp.route('/priviledges', methods=['GET', 'POST'])
@login_required
def create_priviledge():
    form = CreatePriviledgeForm()
    if form.validate_on_submit():
        
        # cate new Priviledge object
        priviledge = models.Priviledge(name=form.name.data)
        
        # attempt to add to database
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

