# -*- coding: utf-8 -*-
"""
Created on Mon Jun 26 19:30:22 2022

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




bp = Blueprint('statistics', __name__)




@bp.route('/<int:angler_id>/statistics/menu', methods=['GET'])
@login_required
def statistics_menu(angler_id: int):
    return render_template('fishingstories/statistics/statistics-menu.html', angler_id=angler_id, authenticated=True)
