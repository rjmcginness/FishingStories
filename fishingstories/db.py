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

# need to declare this before models is imported
Base = declarative_base()

def init_db():
    # need to import models so that tables will be created
    from . import models
    Base.metadata.create_all(engine)
