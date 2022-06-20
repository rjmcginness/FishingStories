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
from flask import request
from flask_login import login_required
from flask_login import current_user
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.exc import OperationalError

from functools import wraps

from src.db import models
from .forms import RankForm
from .forms import CreateAccountTypeForm
from .forms import CreatePrivilegeForm
from .forms import AddBaitForm
from .forms import AddGearForm
from .forms import AnglerForm
from .forms import AnglerEditForm


bp = Blueprint('admin', __name__)#, url_prefix='/admin')


######Does not have to be an endpoint, could be a function
# @bp.route('/forbidden')
def forbidden(redirect_url):
    flash('Access forbiden')
    return redirect(redirect_url)

def admin_required(forbidden):
    def wrapper(endpoint_handler):
        @wraps(endpoint_handler)
        def decorates(*args, **kwargs):
            # attempt to check account_type name against admin
            try:
                if current_user.account_type.name != 'Admin':
                    raise ValueError('NOT an ADMIN')
            except (AttributeError, KeyError, ValueError):
                # check if logged in, if so, send to forbidden
                # if current_user.is_authorized:
                return forbidden(request.referrer)
            # otherwise 1. not logged in (for case of login credentials fail)
            # or is admin
            return endpoint_handler(*args, **kwargs)
        return decorates
    return wrapper




@bp.route('/ranks/create', methods = ['GET', 'POST'])
@login_required
@admin_required(forbidden)
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
@admin_required(forbidden)
def manage_account_types():
    return render_template('admin/account-types-menu.html', authenticated=True)

@bp.route('/account_types/create', methods=['GET', 'POST'])
@login_required
@admin_required(forbidden)
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
@admin_required(forbidden)
def account_types():
    account_types = current_app.session.execute(select(models.AccountType).
                                                order_by(models.AccountType.price))
    
    account_types = [account_type[0] for account_type in account_types]
    
    return render_template('admin/account-types.html', account_types=account_types, authenticated=True)

@bp.route('/manage_privileges', methods=['GET'])
@login_required
@admin_required(forbidden)
def manage_privileges():
    return render_template('admin/privileges-menu.html', authenticated=True)

@bp.route('/privileges/create', methods=['GET', 'POST'])
@login_required
@admin_required(forbidden)
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
@admin_required(forbidden)
def privileges():
    privileges = current_app.session.execute(select(models.Privilege))
    
    
    privilege_names = [privilege[0].serialize() for privilege in privileges]
    
    return render_template('admin/privileges.html', privileges=privilege_names, authenticated=True)

@bp.route('/manage_anglers')
@login_required
@admin_required(forbidden)
def manage_anglers():
    return render_template('admin/anglermenu.html', authenticated=True)

@bp.route('/anglers', methods=['GET'])
@login_required
@admin_required(forbidden)
def anglers():
    anglers = current_app.session.execute(select(models.Angler))
    
    anglers = [angler[0] for angler in anglers]
    
    return render_template('admin/anglers.html', anglers=anglers, authenticated=True)

@bp.route('/anglers/<int:angler_id>/edit', methods=['GET', 'PATCH'])
@login_required
@admin_required(forbidden)
def angler_edit(angler_id: int):
    form = AnglerEditForm()
    
    # update the rank field
    if request.method == 'PATCH':
        # get new rank from database
        # rank = current_app.session.query(models.Rank).filter(name=form.rank.data)
        rank = current_app.session.scalar(select(models.Rank).
                                            where(models.Rank.name == form.ranks.data))
        
        # select angler from database again
        angler = current_app.session.scalar(select(models.Angler).
                                             where(models.Angler.id == angler_id))
        
        angler.rank_id = rank.id
        
        try:
            current_app.session.commit()
        except (IntegrityError, OperationalError):
            current_app.session.rollback()
        
        return redirect(url_for('admin.angler', angler_id=angler_id))
        
        
    # initial GET on form
    angler = current_app.session.scalar(select(models.Angler).
                                          where(models.Angler.id==angler_id))
    
    form.angler_id.data = angler.id
    form.name.data = angler.name
    form.account_type.data = angler.user_accounts.account_type.name
    privileges = angler.user_accounts.account_type.privileges
    form.privileges.choices = [privilege.name for privilege in privileges]
    
    ranks = current_app.session.execute(select(models.Rank).
                                        order_by(models.Rank.rank_number))
    form.ranks.choices = [rank[0].name for rank in ranks]
    form.ranks.data = angler.rank.name
        
    return render_template('admin/angler-edit.html', title=angler.name, form=form, target_url='', authenticated=True)

@bp.route('/anglers/<int:angler_id>', methods=['GET'])
@login_required
@admin_required(forbidden)
def angler(angler_id: int):
    form = AnglerForm()
    form.is_editable = False
    angler = current_app.session.scalar(select(models.Angler).
                                          where(models.Angler.id==angler_id))

    form.angler_id.data = angler.id
    form.name.data = angler.name
    form.rank.data = angler.rank.name
    form.account_type.data = angler.user_accounts.account_type.name
    privileges = angler.user_accounts.account_type.privileges
    form.privileges.choices = [privilege.name for privilege in privileges]
    
    return render_template('admin/angler.html',
                           title='Fishing Stories - ' + angler.name,
                           form=form,
                           authenticated=True)

# <div>
#      <a href="{{ url_for('admin.angler_edit') }}">edit angler</a>
#  </div>
#  <div>
#      <a href="{{ url_for('admin.angler_delete') }}">delete angler</a>
#  </div> 
        
@bp.route('/statistics', methods=['GET'])
@login_required
@admin_required(forbidden)
def statistics():
    return render_template('admin/statistics.html', authenticated=True)

# @bp.route('/manage-users', methods=['GET'])
# @login_required
# @admin_required(forbidden)
# def manage_users():
#     return render_template('admin/usermenu.html', authenticated=True)

@bp.route('/users', methods=['GET'])
@login_required
@admin_required(forbidden)
def users():
    users = current_app.session.scalars(select(models.UserAccount).
                                        order_by(models.UserAccount.account_type_id))
    
    return render_template('admin/users.html', users=users, authenticated=True)

@bp.route('/users/<int:user_id>', methods=['GET'])
@login_required
@admin_required(forbidden)
def user(user_id: int):
    user = current_app.session.scalar(select(models.UserAccount).
                                       where(models.UserAccount.id == user_id))
    
    # user = user[0][0]
    
    return render_template('admin/user.html', user=user, authenticated=True)

@bp.route('/users/<int:user_id>/edit', methods=['GET'])
@login_required
@admin_required(forbidden)
def user_edit(user_id: int):
    user = current_app.session.execute(select(models.UserAccount).
                                       where(models.UserAccount.id == user_id))
    
    user = user[0][0]
    
    return render_template('admin/edit_user.html', user=user, authenticated=True)


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