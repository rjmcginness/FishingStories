# -*- coding: utf-8 -*-
"""
Created on Wed Jun  1 14:48:24 2022

@author: Robert J McGinness
"""

import os
from flask import Flask
from flask_migrate import Migrate
from flask_login import LoginManager

migrate = Migrate()
login_manager = LoginManager()


def create_app(test_config=None):
    
    app = Flask(__name__, instance_relative_config=True)
    
    ###### THIS IS TEMPORARY
    app.config.from_mapping(SECRET_KEY='bron_girl',
                            DATABASE=os.path.join(app.instance_path, 'fishingstories.sqlite'))
    
    
    
    app.login_manager = login_manager

    from .db.db import db_session
    from .db.db import init_db
    
    app.session = db_session
    fake_flask_sqlalchemy = init_db()
    
    # hacked so that I do not have to depend on Flask-SQLAlchemy
    # to use Flask-migrate (thank you , informative traceback!)
    migrate.init_app(app, fake_flask_sqlalchemy)


    if test_config is None:
        app.config.from_pyfile('config.py', silent=True)
    else:
        app.config.from_mapping(test_config)
    
    
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass
    
    from . import fishingstories
    app.register_blueprint(fishingstories.bp)
    app.add_url_rule('/', endpoint='index')
    
    from .api import admin
    app.register_blueprint(admin.bp)
    
    from .api import fishing_spots
    app.register_blueprint(fishing_spots.bp)
    
    from .api.auth import auth
    app.register_blueprint(auth.bp)
    app.add_url_rule('/auth', 'auth')
    app.add_url_rule('/register', 'register')

    return app


        