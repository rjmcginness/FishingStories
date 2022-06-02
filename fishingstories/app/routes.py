# -*- coding: utf-8 -*-
"""
Created on Wed Jun  1 14:53:05 2022

@author: Robert J McGinness
"""
from flask import render_template
from sqlalchemy import select
from sqlalchemy import create_engine
from sqlalchemy import inspect

from db import fishingstories_core_db as db

from app import app

@app.route('/')
@app.route('/index')
def index():
    return render_template('index.html')

@app.route('/baits')
def baits():
    stmt = select(db.baits).order_by(db.baits.c.name)
    insp = inspect(db.engine)
    print('#########>>>>>>', insp.get_table_names())
    print("#####>>>>>####", [c.name for c in db.baits.columns])
    rows = None
    # with db.engine.begin() as conn:
    #     rows = conn.execute(stmt)
    #     print('##############', rows)
    
    return render_template('baits.html', baits=rows)
            