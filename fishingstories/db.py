# -*- coding: utf-8 -*-
"""
Created on Thu Jun  2 23:13:25 2022

@author: Robert J McGinness
"""

from flask import g
from sqlalchemy import create_engine
from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import declarative_base


from . import config

engine = create_engine(config.Config.DATABASE, echo=True, future=True)
db_session = scoped_session(sessionmaker(autocommit=False,
                                         autoflush=False,
                                         bind=engine))
Base = declarative_base()

def init_db():
    Base.metadata.create_all(engine)

# def get_db():
#     if 'db' not in g:
#         ########FIX THIS NEED ONLY ONE CONNECTION TO DB.
        
#         g.db = db
        
#     return g.db

# def close_db(e=None):
#     db = g.pop('db', None)
    
#     if db is not None:
#         db.dispose()

# def init_db():
#     models.Base.metadata.create_all(engine)

# def init_app(app):
#     app.teardown_appcontext(close_db)