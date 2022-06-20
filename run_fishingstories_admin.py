# -*- coding: utf-8 -*-
"""
Created on Wed Jun 15 21:33:13 2022

@author: Robert J McGinness
"""



from fishingstories_admin import create_app as admin_create_app

admin = admin_create_app()

if __name__ == '__main__':

    admin.run(host='0.0.0.0')

