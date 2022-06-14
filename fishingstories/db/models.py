# -*- coding: utf-8 -*-
"""
Created on Thu Jun  2 15:12:30 2022

@author: Robert J McGinness
"""



from sqlalchemy import Table
from sqlalchemy import Column
from sqlalchemy import ForeignKey
from sqlalchemy import Integer
from sqlalchemy import String
from sqlalchemy import Numeric
from sqlalchemy import Boolean
from sqlalchemy import DateTime
from sqlalchemy import Date
from sqlalchemy import UniqueConstraint

from sqlalchemy.orm import relationship

from werkzeug.security import generate_password_hash
from werkzeug.security import check_password_hash

from flask_login import UserMixin


from .db import Base

from .. import login_manager

account_priviledges = Table('account_priviledges',
                            Base.metadata,
                            Column('account_type_id',
                                    ForeignKey('account_types.id',
                                              ondelete='CASCADE'),
                                    primary_key=True),
                            Column('priviledge_id',
                                    ForeignKey('priviledges.id',
                                              ondelete='CASCADE'),
                                    primary_key=True)
                            )

class AccountType(Base):
    __tablename__ = 'account_types'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False, unique=True)
    price = Column(Numeric, nullable=False)
    
    # many-to-many relationship with priviledges
    priviledges = relationship('Priviledge', secondary=account_priviledges, back_populates='account_types')
    
    # one-to-many relationship with user accounts
    user_accounts = relationship('UserAccount', back_populates='account_type')

class Priviledge(Base):
    __tablename__ = 'priviledges'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False, unique=True)
    
    account_types = relationship('AccountType', secondary=account_priviledges, back_populates='priviledges')
    



class UserAccount(UserMixin, Base):
    __tablename__ = 'user_accounts'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(30), nullable=False, unique=True)
    password = Column(String(256), nullable=False)
    
    def set_password(self, password) -> None:
        self.password = generate_password_hash(password)
        
    def check_password(self, password) -> bool:
        return check_password_hash(self.password, password)
    
    
    
    # many-to-one relationship with account_types (unidirectional)
    account_type_id = Column(Integer,
                              ForeignKey('account_types.id',
                                        ondelete='CASCADE'),
                              nullable=False)
    
    account_type = relationship('AccountType', back_populates='user_accounts')
    
    
    # one-to-one relationship with anglers (this is the child)
    angler_id = Column(Integer,
                        ForeignKey('anglers.id',
                                  ondelete='CASCADE'))
    
    anglers = relationship('Angler', back_populates='user_accounts')

fish_caught = Table('fish_caught',
                    Base.metadata,
                    Column('anglers_id',
                            ForeignKey('anglers.id',
                                      ondelete='CASCADE'),
                            primary_key=True),
                    Column('fishes_id',
                            ForeignKey('fishes.id',
                                      ondelete='CASCADE'),
                            primary_key=True)
                    )

outings_fished = Table('outings_fished',
                        Base.metadata,
                        Column('fishing_outing_id',
                              ForeignKey('fishing_outings.id',
                                          ondelete='CASCADE'),
                              primary_key=True),
                        Column('angler_id',
                              ForeignKey('anglers.id',
                                          ondelete='CASCADE'),
                              primary_key=True)
                        )

class Rank(Base):
    __tablename__ = 'ranks'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False, unique=True)
    rank_number = Column(Integer, nullable=False, unique=True)
    description = Column(String, nullable=False)
    

class Angler(Base):
    __tablename__ = 'anglers'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(30), nullable=False, unique=True)
    # rank = Column(String(40))
    rank_id = Column(Integer,
                      ForeignKey('ranks.id',
                                ondelete='CASCADE'),
                      nullable=False)
    
    # many-to-one relationship with ranks(unidirectional)
    
    # one-to-one relationship with user_accounts
    #(unidirectional- this is parent)
    user_accounts = relationship('UserAccount',
                                back_populates='anglers',
                                uselist=False)
    
    # fishes = relationship('Fish', secondary=fish_caught)


class FishingGear(Base):
    __tablename__ = 'fishing_gear'

    id = Column(Integer, primary_key=True, autoincrement=True)
    rod = Column(String, nullable=False)
    reel = Column(String)
    line = Column(String)
    hook = Column(String)
    leader = Column(String)
    
    fishes = relationship('Fish')

class Bait(Base):
    __tablename__ = 'baits'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False)
    artificial = Column(Boolean, nullable=False)
    size = Column(Numeric)
    color = Column(String)
    description = Column(String)
    
    __table_args__ = (UniqueConstraint('name', 'size', 'color'),)
    
    fishes = relationship('Fish')


fished_spots = Table('fished_spots',
                      Base.metadata,
                      Column('fishing_outing_id',
                            ForeignKey('fishing_outings.id'),
                            primary_key=True),
                      Column('fishing_spot_id',
                            ForeignKey('fishing_spots.id'),
                            primary_key=True)
                      )

class FishingOuting(Base):
    __tablename__ = 'fishing_outings'

    id = Column(Integer, primary_key=True, autoincrement=True)
    date = Column(Date, nullable=False)
    trip_type = Column(String, nullable=False)
    water = Column(String)
    description = Column(String)
    
    # many-to-one relationship with fishing_spots (unidirectional)
    fishing_spots = relationship('FishingSpot', secondary=fished_spots)
    
    # many-to-one relationship with anglers (unidirectional)
    anglers = relationship('Angler', secondary=outings_fished)
    

class FishingSpot(Base):
    __tablename__ = 'fishing_spots'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    latitude = Column(Numeric, nullable=False)
    longitude = Column(Numeric, nullable=False)
    name = Column(String, nullable=False)
    description = Column(String)
    
    __table_args__ = (UniqueConstraint('latitude', 'longitude'),)
    
    fishing_conditions = relationship('FishingConditions')
    fishes = relationship('Fish')
    
    

class FishingConditions(Base):
    __tablename__ = 'fishing_conditions'

    id = Column(Integer, primary_key=True, autoincrement=True)
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
    fishing_spot_id = Column(Integer,
                              ForeignKey('fishing_spots.id',
                                        ondelete='CASCADE'),
                              nullable=False)

class Fish(Base):
    __tablename__ = 'fishes'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    species = Column(String, nullable=False)
    datetime_caught = Column(DateTime, nullable=False)
    weight = Column(Numeric)
    length = Column(Numeric)
    description = Column(String)
    
    bait_id = Column(Integer, ForeignKey('baits.id'))
    fishing_gear_id = Column(Integer,
                              ForeignKey('fishing_gear.id', ondelete='SET NULL'))
    fishing_spot_id = Column(Integer,ForeignKey('fishing_spots.id'))
    
    anglers = relationship('Angler', secondary=fish_caught)
    
    

