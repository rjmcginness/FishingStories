# -*- coding: utf-8 -*-
"""
Created on Wed Jun  8 15:23:49 2022

@author: rmcginness
"""

from werkzeug.security import generate_password_hash
from werkzeug.security import check_password_hash

hash_ = generate_password_hash('bronwyn')

print(hash_)

print('CHECK PASSWORD:', check_password_hash(hash_, 'bronwyn'))
print('CHECK PASSWORD:', check_password_hash(hash_, 'Bronwyn'))