# -*- coding: utf-8 -*-
"""
Created on Thu Jun 16 00:59:44 2022

@author: Robert J McGinness
"""

from werkzeug.middleware.dispatcher import DispatcherMiddleware
from werkzeug.serving import run_simple

from fishingstories import create_app as frontend_create_app
from fishingstories_admin import create_app as admin_create_app

admin = admin_create_app()
frontend = frontend_create_app()

application = DispatcherMiddleware(frontend, {'/admin': admin})


if __name__ == '__main__':
    run_simple(hostname='localhost',
               port=5000,
               application=application,
               use_reloader=True,
               use_debugger=True,
               use_evalex=True)



