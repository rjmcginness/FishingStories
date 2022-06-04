# -*- coding: utf-8 -*-
"""
Created on Thu Jun  2 13:32:32 2022

@author: Robert J McGinness
"""

import os
basedir = os.path.abspath(os.path.dirname(__file__))

class Config(object):
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'bron-girl'
    DATABASE = 'postgresql+psycopg2://fishing_stories:trust@localhost:5432/fishing_stories'#'postgresql+psycopg2://postgres:trust@192.168.65.0/28/fishing_stories?port=5432'#'sqlite+pysqlite:///:memory:'
    # SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
    #     'sqlite:///' + os.path.join(basedir, 'app.db')
    # SQLALCHEMY_TRACK_MODIFICATIONS = False
