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
from sqlalchemy import select

#from db import fishingstories_core_db as db

from . import models
from . import db
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
        dbase = db.get_db()
        with Session(dbase) as session:
            session.add(bait)
            print('#########>>>>>>>>>>', session.new)
            session.flush()
            session.commit()
            
        flash('Added bait {}, size={}, color={}'.format(form.name.data,
                                                      form.size.data,
                                                      form.color.data))
        return redirect('/baitsmenu')
    
    return render_template('fishingstories/addbait.html', title='Add Bait', form=form)

@bp.route('/baits')
def baits():
    
    dbase = db.get_db()
    
    baits = None
    with Session(dbase) as session:
        baits = session.execute(select(models.Bait))
    
    return render_template('fishingstories/baits.html', baits=baits)