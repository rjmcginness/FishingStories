# -*- coding: utf-8 -*-
"""
Created on Wed Jun  1 15:12:01 2022

@author: Robert J McGinness
"""
from flask import current_app
from flask import Blueprint
from flask import render_template
from flask import flash
from flask import redirect
from flask import url_for
from sqlalchemy.orm import Session
from sqlalchemy import select

#from db import fishingstories_core_db as db
from . import create_app
from . import models
from .db import Base
from .db import engine
from .db import db_session
from .forms import LoginForm
from .forms import AddBaitForm


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

@bp.route('/create-bait', methods=['GET', 'POST'])
def add_bait():
    form = AddBaitForm()
    if form.validate_on_submit():
        
        ###### ADDRESS THE CONVERSION TO FLOAT (MAYBE ANOTHER TYPE OF FIELD)
        bait = models.Bait(name=form.name.data,
                           artificial=form.artificial.data,
                           size=form.size.data,
                           color=form.color.data,
                           description=form.description.data)
        
        # add new bait to database
        ######IT WOULD BE GREAT TO KEEP name+size+color unique
        current_app.session.add(bait)
        print('#########>>>>>>>>>>', current_app.session.new)
        current_app.session.flush()
        current_app.session.commit()
        
        flash('Added bait {}, size={}, color={}'.format(form.name.data,
                                                      form.size.data,
                                                      form.color.data))
        return redirect('/baits')
    
    return render_template('fishingstories/addbait.html', title='Add Bait', form=form)

@bp.route('/baits')
def baits():
    
    baits = current_app.session.execute(select(models.Bait))
    
    baits = [bait[0] for bait in baits]
    
    return render_template('fishingstories/baits.html', baits=list(baits))