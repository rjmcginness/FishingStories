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

from datetime import timedelta

from fishingstories import login_manager



bp = Blueprint('fishingstories', __name__)

@bp.route('/')
@bp.route('/index')
def index():
    if not current_user.is_authenticated:
        
        return redirect(url_for('auth'))
    
    
    if current_user.account_type.name == 'Admin':
        return redirect(url_for('admin/index'))
    
    # if here must be an angler
    
    angler_id = current_user.angler_id
    
    return redirect(url_for('angler.angler_home', angler_id=angler_id))
   
    # return render_template('fishingstories/index.html', angler_id=angler_id, authenticated=True)

@bp.before_request
def before_request():
    current_app.session.permanent = True
    current_app.session.modified = True
    current_app.permanent_session_lifetime = timedelta(minutes=4)
    login_manager.login_view = url_for('auth')