# -*- coding: utf-8 -*-
"""
Created on Wed Jun  1 15:12:01 2022

@author: Robert J McGinness
"""


from flask import Blueprint
from flask import render_template
from flask import redirect
from flask import url_for
from flask import current_app
from flask_login import current_user
from flask_login import login_required
from datetime import timedelta


from fishingstories_admin import login_manager
from .api.admin import admin_required
from .api.admin import forbidden


bp = Blueprint('fishingstories_admin', __name__)#, url_prefix='/admin')

@bp.route('/')
@bp.route('/index')
@login_required
@admin_required(forbidden)
def index():
    if not current_user.is_authenticated:
        return redirect(url_for('auth'))
    
    return render_template('admin/index.html', authenticated=True)

@bp.before_request
def before_request():
    current_app.session.permanent = True
    current_app.session.modified = True
    current_app.permanent_session_lifetime = timedelta(minutes=4)
    login_manager.login_view = url_for('auth')
