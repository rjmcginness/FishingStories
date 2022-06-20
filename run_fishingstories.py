# -*- coding: utf-8 -*-
"""
Created on Wed Jun 15 21:33:13 2022

@author: Robert J McGinness
"""



from fishingstories import create_app as frontend_create_app

frontend = frontend_create_app()

if __name__ == '__main__':

    frontend.run(host='0.0.0.0')

