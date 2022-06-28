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
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError
from sqlalchemy.exc import OperationalError

from functools import wraps
import math

from src.db import models
from src.nature.current_stations import current_sites
from src.nature.retrieve_weather import tide_weather_locations
from src.nature.retrieve_weather import map_site_coordinates
from src.nature.utilities import google_maps_url2022
from .forms import RankForm
from .forms import CreateAccountTypeForm
from .forms import CreatePrivilegeForm
from .forms import AddBaitForm
from .forms import AddGearForm
from .forms import AnglerForm
from .forms import AnglerEditForm
from .forms import EditPasswordForm


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


@bp.route('/current_stations/load', methods=['GET'])
@login_required
@admin_required(forbidden)
def load_current_stations():
    ######HARD CODED FOR NOW
    current_stations = current_sites('http://tbone.biol.sc.edu/tide/sites_allcurrent.html')
    
    for station in current_stations:
        # create global position with lat an dlong in radians
        global_position = models.GlobalPosition(
                                    latitude=math.radians(station.latitude),
                                    longitude=math.radians(station.longitude))
        
        # instantiate DataUrls for urls for the station
        current_url = models.DataUrl(url=station.url, data_type='current')
        map_url = models.DataUrl(url=station.map_url, data_type='map')
        
        # back_populate GlobalPosition
        current_url.global_position = global_position
        map_url.global_position = global_position
        
        # instantiate CurrentStation and set foreign key
        current_station = models.CurrentStation(name=station.name)
        current_station.global_position = global_position
        
        current_app.session.add(current_station)
    
    # current_app.session.commit()
    try:
        current_app.session.commit()
    except (IntegrityError, OperationalError) as e:
        print(e)
        current_app.logger.info(e)
        flash('Data may already exist')
    
    return render_template('admin/current-stations.html', stations=current_stations, authenticated=True)
    
    
@bp.route('/sea_condition_sites/load', methods=['GET'])
@login_required
@admin_required(forbidden)
def load_sea_condition_sites():
    ''' Scrapes sea condition site urls and separately global position coordinates.
        Stores urls as DataUrl in the data_urls table and by foreign key
        constrain back_populates the GlobalPosition to global_positions.
        Does the same with a google_maps url created from the global position
        coordinates.
        
        Watch the lights dim on this one!!!
    '''
    ######HARD CODED FOR NOW
    weather_locations = tide_weather_locations('https://www.tide-forecast.com')
    
    weather_base_url = 'https://www.tide-forecast.com/locations/'
    weather_url_path = '/forecasts/latest'
    
    # dictionary comprehension creates full weather urls as keys and
    # src.nature.nature_entities.GlobalPosition as value
    # internally scrapes coordinates from google maps from the site name
    weather_urls = {weather_base_url + location_name + weather_url_path: 
                                        map_site_coordinates(location_name) 
                                        for location_name in weather_locations}
    
                
    current_app.logger.info(weather_urls)
    flash(weather_urls)
    
    map_url_list = []
    for url, position in weather_urls.items():
        weather_data_url = models.DataUrl(url=url, data_type='sea')
        global_position = models.GlobalPosition(latitude=math.radians(position.latitude),
                                                longitude=math.radians(position.longitude))
        
        # make a google maps url from global_position, add to list
        map_url_list.append(google_maps_url2022(position.latitude,position.longitude))
        # instantiate a DataUrl for the map url
        map_url = models.DataUrl(url=map_url_list[-1], data_type='map')
        
        global_position.data_urls.append(weather_data_url)
        global_position.data_urls.append(map_url)
        
        current_app.session.add(global_position)

    try:
        current_app.session.commit()
    except (IntegrityError, OperationalError) as e:
        print(e)
        current_app.logger.info(e)
        
    display_data = list(zip(weather_locations,
                            weather_urls.values(), # gp coords
                            weather_urls.keys(), # urls
                            map_url_list))
        
    return render_template('admin/sea-conditions-sites.html', sites=display_data, authenticated=True)

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

        
@bp.route('/admin/statistics', methods=['GET'])
@login_required
@admin_required(forbidden)
def statistics():
    # number of each species caught
    stmt = text('''
                SELECT species, COUNT(f.id) FROM fishes f
                GROUP BY species
                ORDER BY COUNT(f.id) DESC;
                ''')
                
    fish_by_species = list(current_app.session.execute(stmt))
    
    stmt = text('''
                SELECT a.name, COUNT(f.id) FROM fishes f
                INNER JOIN anglers a
                ON f.angler_id = a.id
                GROUP BY a.name
                ORDER BY COUNT(f.id) DESC;
                ''')
                
    angler_fish_counts = list(current_app.session.execute(stmt))
    
    stmt = text('''
                SELECT fs.name, COUNT(f.id) FROM fishes f
                INNER JOIN fishing_spots fs
                ON f.fishing_spot_id = fs.id
                GROUP BY fs.name
                ORDER BY COUNT(f.id) DESC;
                ''')
                
    fish_by_spot = list(current_app.session.execute(stmt))
    
    stmt = text('''
                SELECT b.name, b.size, b.color, COUNT(f.id) FROM fishes f
                INNER JOIN baits b
                ON f.bait_id = b.id
                GROUP BY b.name, b.size, b.color
                ORDER BY COUNT(f.id) DESC;
                ''')
    
    fish_by_bait = list(current_app.session.execute(stmt))
    
    return render_template('admin/statistics.html',
                           by_species=fish_by_species,
                           by_angler=angler_fish_counts,
                           by_spot=fish_by_spot,
                           by_bait=fish_by_bait,
                           top_species=fish_by_species[0],
                           top_angler=angler_fish_counts[0],
                           top_spot=fish_by_spot[0],
                           top_bait=fish_by_bait[0],
                           authenticated=True)


@bp.route('/users', methods=['GET'])
@login_required
@admin_required(forbidden)
def users():
    users = current_app.session.scalars(select(models.UserAccount).
                                        order_by(models.UserAccount.account_type_id))
    
    return render_template('admin/users.html', users=users, authenticated=True)

@bp.route('/baits')
@login_required
def baits():
    
    baits = current_app.session.execute(select(models.Bait))
    
    baits = [bait[0] for bait in baits]
    
    return render_template('fishingstories/baits.html', baits=list(baits), authenticated=True)

@bp.route('/gear')
@login_required
def gear():
    gear_combos = current_app.session.execute(select(models.FishingGear))
    
    # take the first element in the returned tuple
    gear_combos = [gear[0] for gear in gear_combos]
    
    return render_template('fishingstories/gear.html', gear_list=gear_combos, authenticated=True)

@bp.route('/admin/change_password', methods=['GET', 'PATCH'])
@login_required
@admin_required(forbidden)
def change_password():
    
    
    form = EditPasswordForm()
    user_account = current_user
    
    if request.method == 'PATCH':
        
        if form.validate():
            if not user_account.check_password(form.old_password.data):
                flash('Invalid password')
                return redirect(url_for('admin.change_password', account_id=user_account.id))
            
            user_account.set_password(form.password.data)
            
            try:
                current_app.session.commit()
            except (IntegrityError, OperationalError) as e:
                current_app.logger.info(e)
                current_app.session.rollback()
        
        return redirect('fishingstories_admin.index')
    
    form.username.data = user_account.username
    
    return render_template('admin/password-change.html', form=form, authenticated=True)