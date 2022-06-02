# -*- coding: utf-8 -*-
"""
Created on Thu Jun  2 15:12:30 2022

@author: Robert J McGinness
"""



from sqlalchemy import create_engine
from sqlalchemy import Table
from sqlalchemy import Column
from sqlalchemy import ForeignKey
from sqlalchemy import Integer
from sqlalchemy import String
from sqlalchemy import Numeric
from sqlalchemy import Boolean
from sqlalchemy import DateTime
from sqlalchemy import Date

from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import relationship

# engine = create_engine('sqlite+pysqlite:///:memory:', echo=True, future=True)

Base = declarative_base()

account_priviledges = Table('account_priviledge',
                            Base.metadata,
                            Column('account_type_id',
                                   ForeignKey('account_types.id'),
                                   primary_key=True),
                            Column('priviledge_id',
                                   ForeignKey('priviledges.id'),
                                   primary_key=True)
                            )

class Priviledge(Base):
    __tablename__ = 'priviledges'
    
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False, unique=True)
    
    account_types = relationship('AccountType', secondary=account_priviledges)

class AccountType(Base):
    __tablename__ = 'account_types'
    
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False, unique=True)
    price = Column(Numeric, nullable=False)
    
    account_types = relationship('Priviledge', secondary=account_priviledges)

class UserAccount(Base):
    __tablename__ = 'user_accounts'
    
    id = Column(Integer, primary_key=True)
    username = Column(String(30), nullable=False, unique=True)
    password = Column(String(20), nullable=False)
    account_type_id = Column(Integer, ForeignKey('account_types.id'))
    angler_id = Column(Integer, ForeignKey('anglers.id'))
    
    angler = relationship('Angler',
                          back_populates='anglers',
                          uselist=False)

fish_caught_table = Table('fish_caught',
                    Base.metadata,
                    Column('anglers_id', ForeignKey('anglers.id')),
                    Column('fishes_id', ForeignKey('fishes.id'))
                    )

outings_fished = Table('outings_fished',
                       Base.metadata,
                       Column('fishing_outing_id',
                              ForeignKey('fishing_outings.id')),
                       Column('angler_id',
                              ForeignKey('anglers.id'))
                       )

class Angler(Base):
    __tablename__ = 'anglers'
    
    id = Column(Integer, primary_key=True)
    name = Column(String(30), nullable=False, unique=True)
    rank = Column(String(40))
    user_account_id = Column(Integer, ForeignKey('user_accounts.id'))
    
    fishes = relationship('Fish',
                          secondary=fish_caught_table,
                          back_populates='fishes')
    outings = relationship('FishingOuting',
                           secondary=outings_fished,
                           back_populates='fishing_outings')

class FishingGear(Base):
    __tablename__ = 'fishing_gear'

    id = Column(Integer, primary_key=True)
    rod = Column(String, nullable=False)
    reel = Column(String)
    line = Column(String)
    hook = Column(String)
    leader = Column(String)
    
    fishes = relationship('Fish')

class Bait(Base):
    __tablename__ = 'baits'
    
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    artificial = Column(Boolean, nullable=False)
    size = Column(Numeric)
    color = Column(String)
    description = Column(String)
    
    fishes = relationship('Fish')


fished_spots = Table('fished_spots',
                     Base.metadata,
                     Column('fishing_outing_id',
                            ForeignKey('fishing_outings.id')),
                     Column('fishing_spot_id',
                            ForeignKey('fishing_spots.id'))
                     )

class FishingOuting(Base):
    __tablename__ = 'fishing_outings'

    id = Column(Integer, primary_key=True)
    date = Column(Date, nullable=False)
    trip_type = Column(String, nullable=False)
    water = Column(String)
    description = Column(String)
    
    fishing_spots = relationship('FishingSpot', secondary=fished_spots)
    anglers = relationship('Angler',
                           secondary=outings_fished,
                           back_populates='anglers')
    

class FishingSpot(Base):
    __tablename__ = 'fishing_spots'
    
    id = Column(Integer, primary_key=True)
    gps_coordinates = Column(Numeric, nullable=False, unique=True)
    name = Column(String, nullable=False)
    description = Column(String)
    
    fishing_conditions = relationship('FishingConditions')
    fishes = relationship('Fish')
    
    # fishing_conditions = relationship('FishingConditions',
    #                                   back_populates='fishing_spots')
    

class FishingConditions(Base):
    __tablename__ = 'fishing_conditions'

    id = Column(Integer, primary_key=True)
    weather = Column(String, nullable=False)
    tide_phase = Column(String, nullable=False)
    time_stamp = Column(DateTime, nullable=False)
    current_flow = Column(String)
    current_speed = Column(Numeric)
    moon_phase = Column(String(20))
    wind_direction = Column(String(3))
    wind_speed = Column(Integer)
    pressure_yesterday = Column(Numeric)
    pressure_today = Column(Numeric)
    fishing_spot_id = Column(Integer, ForeignKey('fishing_spots.id'))

class Fish(Base):
    __tablename__ = 'fishes'
    
    id = Column(Integer, primary_key=True)
    species = Column(String, nullable=False)
    datetime_caught = Column(DateTime, nullable=False)
    weight = Column(Numeric)
    length = Column(Numeric)
    description = Column(String)
    
    bait_id = Column(Integer, ForeignKey('baits.id'))
    fishing_gear_id = Column(Integer, ForeignKey('fishing_gear.id'))
    fishing_spot_id = Column(Integer, ForeignKey('fishing_spots.id'))
    
    anglers = relationship('Angler', secondary=fish_caught_table)

# Base.metadata.create_all(engine)


# from sqlalchemy import insert

# tsunami = Bait(name='Tsunami Swimshad',
#                artificial=True,
#                size=6.0,
#                color='black back',
#                description='soft plastic')