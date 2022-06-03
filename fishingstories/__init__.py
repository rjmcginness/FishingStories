# -*- coding: utf-8 -*-
"""
Created on Wed Jun  1 14:48:24 2022

@author: Robert J McGinness
"""

import os

from flask import Flask

def create_app(test_config=None):
    
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(SECRET_KEY='bron_girl',
                            DATABASE=os.path.join(app.instance_path, 'fishingstories.sqlite'))



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

    return app
        