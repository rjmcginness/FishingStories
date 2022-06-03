# -*- coding: utf-8 -*-
"""
Created on Thu Jun  2 23:13:25 2022

@author: Robert J McGinness
"""

import sqlite3
from flask import current_app
from flask import g
from sqlalchemy import create_engine

from . import models

def get_db():
    if 'db' not in g:
        # g.db = sqlite3.connect(current_app.config['DATABASE'].
        #                        detect_types=sqlite3.PARSE_DECLTYPES)
        # g.db.row_factory = sqlite3.Row
        g.db = create_engine('sqlite+pysqlite:///:memory:', echo=True, future=True)
        models.Base.metadata.create_all(g.db)
    
    return g.db

def close_db():
    db = g.pop('db', None)
    
    if db is not None:
        db.close()


