# -*- coding: utf-8 -*-
"""
Created on Wed Jun  1 15:12:01 2022

@author: Robert J McGinness
"""

from flask import Blueprint
from flask import render_template
from flask import redirect
from flask import url_for
from flask_login import current_user


bp = Blueprint('fishingstories', __name__)

@bp.route('/')
@bp.route('/index')
def index():
    if not current_user.is_authenticated:
        
        return redirect(url_for('auth'))
    
    # user is autheticated
   
    
    
    return render_template('fishingstories/index.html', authenticated=True)

