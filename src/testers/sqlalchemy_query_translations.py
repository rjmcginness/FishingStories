# -*- coding: utf-8 -*-
"""
Created on Sat Jun 25 20:50:35 2022

@author: Robert J McGinness
"""

import sqlalchemy as sa


import models




stmt = sa.select(models.Fish, models.Fish.species).where(models.Angler.id == 1)

print(stmt)

