# -*- coding: utf-8 -*-
"""
Created on Wed Jun  1 14:48:24 2022

@author: Robert J McGinness
"""

import os
from flask import Flask
from flask_migrate import Migrate
from flask_login import LoginManager

from config import Config

migrate = Migrate()
login_manager = LoginManager()


def create_app(test_config=None):
    app_name = 'fishingstories'
    print(f'{app_name=}')
    
    # create flask app
    app = Flask(__name__,
                instance_relative_config=True,
                static_folder='/src/fishingstories/src/static')
    
    ###### THIS IS TEMPORARY
    app.config.from_object(Config())
    
    login_manager.init_app(app)
    
    app.login_manager = login_manager

    from src.db.db import db_session
    from src.db.db import init_db
    
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
    
    ######this has to be moved to a separate app on the same db.
    # from src.db.db import init_admin
    # init_admin()
    
    from . import fishingstories
    app.register_blueprint(fishingstories.bp)
    app.add_url_rule('/', endpoint='index')
    
    from .api import fishing_spots
    app.register_blueprint(fishing_spots.bp)
    
    from .api import auth
    app.register_blueprint(auth.bp)
    app.add_url_rule('/auth', 'auth')
    app.add_url_rule('/register', 'register')
    app.add_url_rule('/admin', 'admin/index')
    
    from .api import angler
    app.register_blueprint(angler.bp)
    
    from .api import fish
    app.register_blueprint(fish.bp)
    

    return app


        