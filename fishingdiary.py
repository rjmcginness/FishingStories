#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed May 25 22:10:42 2022

@author: robertjmcginness
"""

from sqlalchemy import Table
from sqlalchemy import Column
from sqlalchemy import ForeignKey
from sqlalchemy import String
from sqlalchemy import Integer
from sqlalchemy import Numeric
from sqlalchemy import Boolean
from sqlalchemy import create_engine
from sqlalchemy import MetaData


engine = create_engine('sqlite+pysqlite:///:memory:', echo=True, future=True)

metadata_obj = MetaData()



priviledges = Table('priviledge',
                   metadata_obj,
                   Column('id', Integer, primary_key=True, nullable=False),
                   Column('name', String, nullable=False)
                   )

account_types = Table('account_type',
                      metadata_obj,
                      Column('id', Integer, primary_key=True, nullable=False),
                      Column('name', String, nullable=False, unique=True),
                      Column('price', Numeric, nullable=False)
                      )