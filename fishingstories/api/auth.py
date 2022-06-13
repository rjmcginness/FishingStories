# -*- coding: utf-8 -*-
"""
Created on Sun Jun 12 22:19:41 2022

@author: Robert J McGinness
"""

from flask import Blueprint
from flask import current_app
from flask import render_template
from flask import flash
from flask import redirect
from flask import url_for

from fishingstories.db import models
from .login_form import LoginForm
from .login_form import RegistrationForm


from fishingstories import login_manager


bp = Blueprint('/auth', __name__)

@bp.route('/auth', methods=['GET', 'POST'])
def authenticate():
    form = LoginForm()
    if form.validate_on_submit():
        flash('Login requested for user {}, remember_me={}'.format(
                form.username.data, form.remember_me.data))
        return redirect(url_for('index'))
    return render_template('auth/login.html', title='Sign In', form=form)

@bp.route('/register', methods=['GET', 'POST'])
def register():
    
    ###### List faked for now (NEED TO HIT DB FOR THIS)
    form = RegistrationForm()
    form.account_types.choices=['Casual Angler', 'Love Fishing', 'Live Fishing', 'Advanced']
    if form.validate_on_submit():
        
        # if successful registration go to login
        return redirect(url_for('auth'))
    
    return render_template('auth/register.html', form=form)
    

@login_manager.user_loader
def load_user(user_id):
    ###### NOT SURE THIS WORKS
    return models.UserAccount(user_id)
    




