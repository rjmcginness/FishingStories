# -*- coding: utf-8 -*-
"""
Created on Wed Jun  1 14:53:05 2022

@author: Robert J McGinness
"""
from flask import render_template
from flask import flash
from flask import redirect
from flask import url_for
from sqlalchemy import select
# from sqlalchemy import create_engine
from sqlalchemy import inspect
from sqlalchemy import text
from sqlalchemy.orm import Session

#from db import fishingstories_core_db as db

from app import app
from app import db
from app import models
from app.forms import LoginForm

@app.route('/')
@app.route('/index')
def index():
    return render_template('index.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        flash('Login requested for user {}, remember_me={}'.format(
                form.username.data, form.remember_me.data))
        return redirect(url_for('index'))
    return render_template('login.html', title='Sign In', form=form)

@app.route('/baits')
def baits():
    # stmt = select(models.baits).order_by(models.baits.c.name)
    # insp = inspect(db)
    # print('#########>>>>>>', insp.get_table_names())
    # print("#####>>>>>####", [c.name for c in db.baits.columns])
    # # rows = None
    # with db.engine.begin() as conn:
    #     rows = conn.execute(stmt)
    #     print('##############', rows)
    session = Session(db)
    
    with db.connect() as conn:
        result = conn.execute(text('SELECT sqlite_version()'))
        print('>>>###>>>>>', result)
    
    bait = models.Bait(name='Tsunami Swimshad', artificial=True, size=6.0, color='black back', description='soft plastic')
    session.add(bait)
    session.flush()
    session.commit()
    
    bait2 = session.get(models.Bait, 1)
    
    baits = [
                {
                    'name': 'Tsunami Swimshad',
                    'artificial': True,
                    'size': 6.0,
                    'color': 'black back',
                    'description': 'soft plastic'
                }
            ]
    
    return render_template('baits.html', baits=[bait2])
            