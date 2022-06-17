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
from flask import url_for
from flask_login import login_required
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

from src.db import models
from .forms import RankForm
from .forms import CreateAnglerForm
from .forms import CreateAccountTypeForm
from .forms import CreatePrivilegeForm


bp = Blueprint('admin', __name__)#, url_prefix='/admin')


# @bp.route('/')
# @login_required
# def admin():
#     return render_template('admin/index.html', authenticated=True)






@bp.route('/ranks/create', methods = ['GET', 'POST'])
@login_required
def ranks_create():
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

@bp.route('/manage_account_types', methods=['GET'])
@login_required
def manage_account_types():
    return render_template('admin/account-types-menu.html', authenticated=True)

@bp.route('/account_types/create', methods=['GET', 'POST'])
@login_required
def account_type_create():
    form = CreateAccountTypeForm()
    
    # pull available priviledges from db as selections for new account_type
    # EXCEPT Administrator
    privileges = current_app.session.execute(select(models.Privilege).
                                              order_by(models.Privilege.name))
    
    form.privileges.choices = [privilege[0].name for privilege in privileges]
    if form.validate_on_submit():
        # create new account_type
        account_type = models.AccountType(name=form.name.data,
                                          price=form.price.data,
                                          )
        
        #get priviledges
        selected_privileges = form.privileges.data
        
        # have to hit db to get selected priviledges again :(
        privileges = current_app.session.execute(select(models.Privilege).
                                                  where(models.Privilege.name.in_(selected_privileges)))
        
        # create relationship between account_type and priviledges     
        for privilege in privileges:
            account_type.privileges.append(privilege[0])
        
        # try to add to the database, if fails rollback
        try:
            current_app.session.add(account_type)
            current_app.session.commit()
        except IntegrityError as e:    
            flash(f'Unable to create Account Type {account_type.name}')
            current_app.logger.info(e)
            current_app.session.rollback()
        else:
            return redirect(url_for('admin.account_types'))
    
    return render_template('admin/create-account-type.html', form=form, authenticated=True)

@bp.route('/account_types', methods=['GET'])
@login_required
def account_types():
    account_types = current_app.session.execute(select(models.AccountType).
                                                order_by(models.AccountType.price))
    
    account_types = [account_type[0] for account_type in account_types]
    
    return render_template('admin/account-types.html', account_types=account_types, authenticated=True)

@bp.route('/manage_privileges', methods=['GET'])
@login_required
def manage_privileges():
    return render_template('admin/privileges-menu.html', authenticated=True)

@bp.route('/privileges/create', methods=['GET', 'POST'])
@login_required
def privilege_create():
    form = CreatePrivilegeForm()
    if form.validate_on_submit():
        
        # cate new Priviledge object
        privilege = models.Privilege(name=form.name.data)
        
        # attempt to add to database
        try:
            current_app.session.add(privilege)
            current_app.session.commit()
        except IntegrityError:
            flash(f'Privilege name {form.name.data} already exists')
            current_app.session.rollback()
        else:
            return redirect(url_for('admin.privileges'))
    
    
    return render_template('admin/create-privilege.html', form=form, authenticated=True)

@bp.route('/privileges', methods=['GET'])
@login_required
def privileges():
    privileges = current_app.session.execute(select(models.Privilege))
    
    
    privilege_names = [privilege[0].serialize() for privilege in privileges]
    
    return render_template('admin/privileges.html', privileges=privilege_names, authenticated=True)

@bp.route('/manage_anglers')
@login_required
def manage_anglers():
    return render_template('admin/anglermenu.html', authenticated=True)

@bp.route('/anglers', methods=['GET'])
@login_required
def anglers():
    anglers = models.Angler.query.all()
    
    anglers = [angler[0] for angler in anglers]
    
    render_template('/admin/anglers.html', anglers=anglers, authenticated=True)

@bp.route('/angler/edit', methods=['PATCH'])
@login_required
def angler_edit():
    form = CreateAnglerForm()
    if form.validate_on_submit():
        
        angler = models.Angler()

@bp.route('/angler/<int:id>', methods=['GET'])
@login_required
def angler(id: int):
    angler = models.Angler.query.get(id)


# <div>
#      <a href="{{ url_for('admin.angler_edit') }}">edit angler</a>
#  </div>
#  <div>
#      <a href="{{ url_for('admin.angler_delete') }}">delete angler</a>
#  </div> 
        
@bp.route('/statistics', methods=['GET'])
@login_required
def statistics():
    return render_template('admin/statistics.html', authenticated=True)

