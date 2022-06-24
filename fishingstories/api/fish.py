# -*- coding: utf-8 -*-
"""
Created on Thu Jun 23 00:44:48 2022

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

from src.db import models
from .forms import SearchBasicForm
from .forms import AddFishForm


bp = Blueprint('fish', __name__)



@bp.route('/angler/<int:angler_id>/fish/menu', methods=['GET'])
@login_required
def fish_menu(angler_id: int):
    return render_template('fishingstories/fish/fish-menu.html', angler_id=angler_id, authenticated=True)

@bp.route('/angler/<int:angler_id>/fish', methods=['GET'])
@login_required
def my_fish(angler_id: int):
    return abort(404)

@bp.route('/angler/<int:angler_id>/fish/create', methods=['GET', 'POST'])
@login_required
def add_fish(angler_id: int):
    angler = current_app.session.scalar(select(models.Angler).where(
                                                models.Angler.id == angler_id))
    baits = current_app.session.scalars(select(models.Bait))
    gear = current_app.session.scalars(select(models.FishingGear))
    
    form = AddFishForm()
    form.bait.choices = [bait.name for bait in baits]
    form.gear.choices = [gr.name for gr in gear]
    form.fishing_spot.choices = [spot.name for spot in angler.fishing_spots]
    
    
    ###########################################################################
    ######IMPLEMENT FORM SUBMISSION HERE
    
    
    return render_template('fishingstories/fish/add-fish.html', form=form, authenticated=True)

@bp.route('/angler/<int:angler_id>/fish/search', methods=['GET'])
@login_required
def fish_search(angler_id: int, fish_id: int):
    return abort(404)

@bp.route('/angler/<int:angler_id>/fish/<int:fish_id>', methods=['GET'])
@login_required
def fish(angler_id: int, fish_id: int):
    return abort(404)

