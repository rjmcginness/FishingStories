# -*- coding: utf-8 -*-
"""
Created on Wed Jun  1 14:48:24 2022

@author: Robert J McGinness
"""

from flask import Flask
from config import Config
# from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base
from flask_migrate import Migrate

app = Flask(__name__)
app.config.from_object(Config)
# db = SQLAlchemy(app)
# migrate = Migrate(app, db)

from app import models
db = create_engine('sqlite+pysqlite:///:memory:', echo=True, future=True)
models.Base.metadata.create_all(db)

from app import routes



