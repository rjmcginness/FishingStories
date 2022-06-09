# -*- coding: utf-8 -*-
"""
Created on Wed Jun  8 22:59:37 2022

@author: Robert J McGinness
"""

from flask import Blueprint
from flask import current_app
from flask import render_template
from flask import flash
from flask import get_flashed_messages
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

from .forms import AddFishingSpotForm
from .forms import FishingSpotViewForm
from . import models



bp = Blueprint('fishing_spots', __name__)



@bp.route('/fishing-spots')
def fishing_spots():
    get_flashed_messages().clear()
    
    return render_template('fishing_spots/main.html')

@bp.route('/myspots', methods = ['GET', 'POST'])
def my_spots():
    add_form = AddFishingSpotForm()
    view_form = FishingSpotViewForm()
    
    if not view_form.spot_name.label == 'spot_name':
        flash(view_form.spot_name.label)
        return render_template('fishing_spots/spot-view.html',
                               spot_name=view_form.spot_name.label)
    
    if add_form.validate_on_submit():
        fishing_spot = models.FishingSpot(name=add_form.name.data,
                                          latitude=add_form.latitude.data,
                                          longitude=add_form.longitude.data,
                                          description=add_form.description.data)
        
        try:
            current_app.session.add(fishing_spot)
            current_app.session.commit()
        except IntegrityError:
            flash('Duplicate Spot: latitude {}, longitude {} already exists'.
                  format(add_form.latitude, add_form.longitude))
            
    spots = current_app.session.execute(select(models.FishingSpot))
    spots = [spot[0] for spot in spots]
    
    return render_template('fishing_spots/user-spots.html',
                           add_form=add_form,
                           view_form=view_form,
                           spots=spots)
        

@bp.route('/public-spots')
def public_spots():
    return render_template('fishing_spots/public-spots.html')

@bp.route('/group-spots')
def group_spots():
    flash('RESTRICTED')
    
    return render_template('fishing_spots/main.html')