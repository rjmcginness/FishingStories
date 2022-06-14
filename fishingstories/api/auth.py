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
from flask_login import login_user
from flask_login import logout_user
from sqlalchemy import select

from fishingstories.db import models
from .login_form import LoginForm
from .login_form import RegistrationForm


from fishingstories import login_manager


bp = Blueprint('/auth', __name__)



@bp.route('/auth', methods=['GET', 'POST'])
def authenticate():
    form = LoginForm()
    if form.validate_on_submit():
        
        query = select(models.UserAccount).where(models.UserAccount.username == form.username.data)
        
        results = current_app.session.scalars(query) # should be only one
        current_app.logger.info(results)
        
        user = results.all()
        if not user:
            flash('Login requested for username {} not found'.format(form.username.data))
        elif not user[0].check_password(form.password.data):
            flash('Password incorrect')
        else:
            login_user(user[0], remember=form.remember_me.data)
        
        return redirect(url_for('index'))
    return render_template('auth/login.html', title='Sign In', form=form)

@bp.route('/register', methods=['GET', 'POST'])
def register():
    
    ###### List faked for now (NEED TO HIT DB FOR THIS)
    form = RegistrationForm()
    form.account_types.choices=['Casual Angler', 'Love Fishing', 'Live Fishing', 'Advanced']
    if form.validate_on_submit():
        
        # user_account = 
        # if successful registration go to login
        return redirect(url_for('auth'))
    
    return render_template('auth/register.html', form=form)

@bp.route('/logout')
def logout():
    logout_user()
    return redirect(url_for('index'))
    
@login_manager.user_loader
def load_user(user_id):
    ###### NOT SURE THIS WORKS
    return current_app.session.query(models.UserAccount).get(int(user_id))


