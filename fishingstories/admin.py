# -*- coding: utf-8 -*-
"""
Created on Mon Jun  6 23:39:27 2022

@author: Robert J McGinness
"""

from flask import current_app
from flask import Blueprint
from flask import render_template
from sqlalchemy import select

from . import models


bp = Blueprint('admin', __name__)


@bp.route('/admin')
def admin():
    return render_template('admin/index.html')


@bp.route('/manage-anglers')
def manage_anglers():
    return render_template('admin/anglermenu.html')

@bp.route('/anglers')
def anglers():
    anglers_list = current_app.session.execute(select(models.Angler))
    
    return render_template('admin/anglers.html', anglers=anglers_list)

