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
from flask_login import login_required
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

from src.db import models
from .login_form import LoginForm
from .login_form import RegistrationForm


from fishingstories_admin import login_manager


# bp = Blueprint('/auth', __name__)
bp = Blueprint('auth', __name__)#, url_prefix='/admin')


@login_manager.user_loader
def load_user(user_id):
    ###### NOT SURE THIS WORKS
    return current_app.session.query(models.UserAccount).get(int(user_id))

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
    return render_template('/auth/login.html', title='Sign In', form=form)

@bp.route('/register', methods=['GET', 'POST'])
def register():
    
    form = RegistrationForm()
    
    # get list of account types except Administrator (use separate app) for form
    account_types = current_app.session.scalars(select(models.AccountType).
                                                where(models.AccountType.name != 'Admin').
                                                order_by(models.AccountType.price))
    
    ######FIX THIS TO USE A TUPLE OF ID AND LABEL
    
    form.account_types.choices = [(acct_type.id, acct_type.name + ' $' + str(acct_type.price))
                                                for acct_type in account_types]
    
    if form.validate_on_submit():
        # get account type selected on form
        account_type_id = form.account_types.data
        
        # get this account type from db again (reuse account_type variable)
        account_type = current_app.session.scalar(select(
                                models.AccountType).where(
                                models.AccountType.id == account_type_id))
        
        # create new user account
        user_account = models.UserAccount(username=form.username.data)
        user_account.set_password(form.password.data)
        user_account.email = form.email.data
        user_account.account_type = account_type
        
        # since not admin, create new angler
        angler = models.Angler(name=user_account.username)
        
        # set relationship of angler and user_account
        angler.user_accounts = user_account
        
        #new accounts start with this rank.  Admin can change based on request
        starting_rank = current_app.session.scalar(select(models.Rank).where(
                                            models.Rank.name == 'Bait Fish'))
        
        starting_rank.anglers.append(angler)
        
        try:
            current_app.session.add(user_account)
            current_app.session.commit()
        except IntegrityError as e:
            flash('Account not created. Check if account exists')
            current_app.logger.info(e)
            current_app.session.rollback()
        else:
            # if successful registration go to login
            return redirect(url_for('index'))
    
    return render_template('auth/register.html', form=form)

@bp.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect('/auth')
    



