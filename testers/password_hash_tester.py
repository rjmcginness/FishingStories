# -*- coding: utf-8 -*-
"""
Created on Wed Jun  8 15:23:49 2022

@author: rmcginness
"""

from werkzeug.security import generate_password_hash

hash_ = generate_password_hash('bronwyn')

print(hash_)