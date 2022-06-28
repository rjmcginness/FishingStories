# -*- coding: utf-8 -*-
"""
Created on Mon Jun 20 08:56:52 2022

@author: Robert J McGinness
"""

from flask import Blueprint
from flask import current_app
from flask import render_template
from flask import redirect
from flask import flash
from flask import url_for
from flask import request
from flask_login import login_required

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.exc import OperationalError

from src.db import models

from .forms import AccountViewOnlyForm
from .forms import EditEmailForm
from .forms import EditPasswordForm


bp = Blueprint('user_interface', __name__)



@bp.route('/admin/user_account/<int:account_id>', methods=['GET'])
@login_required
def admin_account(angler_id: int, account_id: int):
    form = AccountViewOnlyForm()
    
    user_account = current_app.session.scalar(select(models.UserAccount).where(
                                        models.UserAccount.id == account_id))
    
    form.username.data = user_account.username
    form.account_type.data = user_account.account_type.name
    form.privileges.data = user_account.privileges
    form.email.data = user_account.email
    
    return render_template('fishingstories/users/user.html', angler_id=angler_id, account_id=account_id, form=form, authenticated=True)




@bp.route('/admin/user_account/<int:account_id>/amail/edit', methods=['GET', 'PATCH'])
@login_required
def admin_email_edit(angler_id: int, account_id: int):
    form = EditEmailForm()
    user_account = current_app.session.scalar(select(models.UserAccount).where(
                                        models.UserAccount.id == account_id))
    
    if request.method == 'PATCH':
        if form.validate():
            if not user_account.check_password(form.password.data):
                flash('Invalid password')
                return redirect(url_for('users.user_email_edit', angler_id=angler_id, account_id=account_id))
            
            user_account.email = form.email.data
            
            try:
                current_app.session.commit()
            except (IntegrityError, OperationalError) as e:
                current_app.logger.info(e)
                current_app.session.rollback()
        
        return redirect('users.user_account', angler_id=angler_id, account_id=account_id)
    
    form.username.data = user_account.username
    
    return render_template('fishingstories/users/email-edit.html', angler_id=angler_id, account_id=account_id, form=form, authenticated=True)


@bp.route('/admin/user_account/<int:account_id>/password/edit', methods=['GET', 'PATCH'])
@login_required
def admin_password_edit(angler_id: int, account_id: int):
    form = EditPasswordForm()
    user_account = current_app.session.scalar(select(models.UserAccount).where(
                                        models.UserAccount.id == account_id))
    
    if request.method == 'PATCH':
        if form.validate():
            if not user_account.check_password(form.old_password.data):
                flash('Invalid password')
                return redirect(url_for('users.user_password_edit', angler_id=angler_id, account_id=account_id))
            
            user_account.set_password(form.password.data)
            
            try:
                current_app.session.commit()
            except (IntegrityError, OperationalError) as e:
                current_app.logger.info(e)
                current_app.session.rollback()
        
        return redirect('users.user_account', angler_id=angler_id, account_id=account_id)
    
    form.username.data = user_account.username
    
    return render_template('fishingstories/users/password-edit.html', angler_id=angler_id, account_id=account_id, form=form, authenticated=True)