# -*- coding: utf-8 -*-
"""
Created on Thu Jun  2 23:13:25 2022

@author: Robert J McGinness
"""

import sqlite3
from flask import current_app
from flask import g
from sqlalchemy import create_engine
import click
from flask.cli import with_appcontext

from . import models
from . import config

def get_db():
    if 'db' not in g:
        g.db = create_engine(config.Config.DATABASE, echo=True, future=True)
        
        # faked for now with sqlite:///:memory:
        # cannot get a connection to this db in another thread like in 
        # Flask tutorial
        models.Base.metadata.create_all(g.db)
    
    return g.db

def close_db(e=None):
    db = g.pop('db', None)
    
    if db is not None:
        db.dispose()


def init_app(app):
    app.teardown_appcontext(close_db)