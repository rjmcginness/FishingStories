# -*- coding: utf-8 -*-
"""
Created on Wed Jun  1 15:12:01 2022

@author: Robert J McGinness
"""
from flask import Blueprint
from flask import render_template
from flask import flash
from flask import redirect
from flask import url_for
from sqlalchemy.orm import Session

#from db import fishingstories_core_db as db

from . import models
from . import db
from .forms import LoginForm

bp = Blueprint('fishingstories', __name__)


@bp.route('/')
@bp.route('/index')
def index():
    return render_template('fishingstories/index.html')

@bp.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        flash('Login requested for user {}, remember_me={}'.format(
                form.username.data, form.remember_me.data))
        return redirect(url_for('index'))
    return render_template('fishingstories/login.html', title='Sign In', form=form)

@bp.route('/baitsmenu')
def baits_menu():
    return render_template('fishingstories/baitsmenu.html')

@bp.route('/baits')
def baits():
    
    bait = models.Bait(name='Tsunami Swimshad', artificial=True, size=6.0, color='black back', description='soft plastic')

    
    dbase = db.get_db()
    
    bait2 = None
    with Session(dbase) as session:
        session.add(bait)
        session.flush()
        bait2 = session.get(models.Bait, 1)
    
    
    return render_template('fishingstories/baits.html', baits=[bait2])