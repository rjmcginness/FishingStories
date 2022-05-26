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
from sqlalchemy import DateTime
from sqlalchemy import Date
from sqlalchemy import create_engine
from sqlalchemy import MetaData


engine = create_engine('sqlite+pysqlite:///:memory:', echo=True, future=True)

metadata_obj = MetaData()



priviledges = Table('priviledge',
                   metadata_obj,
                   Column('id', Integer, primary_key=True),
                   Column('name', String, nullable=False)
                   )

account_types = Table('account_type',
                      metadata_obj,
                      Column('id', Integer, primary_key=True),
                      Column('name', String, nullable=False, unique=True),
                      Column('price', Numeric, nullable=False)
                      )

# bridge table: account_type and priviledges
account_priviledges = Table('account_priviledges',
                            metadata_obj,
                            Column('priviledge_id',
                                   ForeignKey('priviledge.id'),
                                   primary_key=True,
                                   nullable=False),
                            Column('account_type_id',
                                   ForeignKey('account_type.id'),
                                   primary_key=True,
                                   nullable=False),
                            )

anglers = Table('angler',
                metadata_obj,
                Column('id', Integer, primary_key=True),
                Column('name', String(30), nullable=False, unique=True),
                Column('rank', String(40))
                )

user_accounts = Table('user_account',
                      metadata_obj,
                      Column('id', Integer, primary_key=True),
                      Column('username',
                             String(30),
                             nullable=False,
                             unique=True),
                      Column('password', String(20), nullable=False),
                      Column('account_type_id',
                             ForeignKey('account_type.id'),
                             nullable=False),
                      Column('angler_id',
                             ForeignKey('angler.id'),
                             nullable=False)
                      )

baits = Table('bait',
              metadata_obj,
              Column('id', Integer, primary_key=True),
              Column('name', String, nullable=False),
              Column('artificial', Boolean, nullable=False),
              Column('size', Numeric),
              Column('color', String),
              Column('description', String)
              )

fishing_gear = Table('fishing_gear',
                     metadata_obj,
                     Column('id', Integer, primary_key=True),
                     Column('rod', String, nullable=False),
                     Column('reel', String),
                     Column('line', String),
                     Column('hook', String),
                     Column('leader', String)
                     )

fishing_conditions = Table('fishing_conditions',
                           metadata_obj,
                           Column('id', Integer, primary_key=True),
                           Column('weather', String, nullable=False),
                           Column('tide_pahse', String, nullable=False),
                           Column('current_flow', String),
                           Column('current_speed', Numeric),
                           Column('moon_phase', String),
                           Column('wind_direction', String(3)),
                           Column('wind_speed', Integer),
                           Column('pressure_yesterday', Numeric),
                           Column('pressure_today', Numeric)
                           )

fishing_spots = Table('fishing_spot',
                      metadata_obj,
                      Column('id', Integer, primary_key=True),
                      Column('name', String, nullable=False),
                      Column('gps_coordinates',
                             Numeric,
                             nullable=False,
                             unique=True),
                      Column('time_in', DateTime, nullable=True),
                      Column('time_out', DateTime, nullable=True),
                      Column('description', String),
                      Column('fishing_conditions_id',
                             ForeignKey('fishing_conditions.id'),
                             nullable=False)
                      )

fishes = Table('fish',
               metadata_obj,
               Column('id', Integer, primary_key=True),
               Column('species', String, nullable=False),
               Column('description', String),
               Column('weight', Numeric),
               Column('length', Numeric),
               Column('fishing_gear_id',
                      ForeignKey('fishing_gear.id'),
                      nullable=False),
               Column('bait_id', ForeignKey('bait.id'), nullable=False),
               Column('fishing_spot_id',
                      ForeignKey('fishing_spot.id'),
                      nullable=False)
               )

fishing_outings = Table('fishing_outing',
                        metadata_obj,
                        Column('id', Integer, primary_key=True),
                        Column('date', Date, nullable=False),
                        Column('type', String, nullable=False),
                        Column('water', String),
                        Column('description', String)
                        )
# Bridge table: fishing_outings and fishing_spots
outings_spots = Table('outings_spots',
                      metadata_obj,
                      Column('fishing_outing_id',
                             ForeignKey('fishing_outing.id'),
                             primary_key=True,
                             nullable=False),
                      Column('fishing_spot_id',
                             ForeignKey('fishing_spot.id'),
                             primary_key=True,
                             nullable=False)
                      )

# Bridge table: anglers and fishing_outings
outing_anglers = Table('outing_anglers',
                       metadata_obj,
                       Column('fishing_outing_id',
                              ForeignKey('fishing_outing.id'),
                              primary_key=True),
                       Column('angler_id',
                              ForeignKey('angler.id'),
                              primary_key=True)
                       )

# Bridge table: anglers and fish
fish_caught = Table('fish_caught',
                    metadata_obj,
                    Column('angler_id',
                           ForeignKey('angler.id'),
                           primary_key=True),
                    Column('fish_id',
                           ForeignKey('fish.id'),
                           primary_key=True)
                    )

metadata_obj.create_all(engine)