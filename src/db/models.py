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
from sqlalchemy import event
from sqlalchemy.orm import relationship
from sqlalchemy.orm import backref
from sqlalchemy.schema import DDL


from werkzeug.security import generate_password_hash
from werkzeug.security import check_password_hash

from flask_login import UserMixin


from .db import Base


account_privileges = Table('account_privileges',
                            Base.metadata,
                            Column('account_type_id',
                                    ForeignKey('account_types.id',
                                              ondelete='CASCADE'),
                                    primary_key=True),
                            Column('privilege_id',
                                    ForeignKey('privileges.id',
                                              ondelete='CASCADE'),
                                    primary_key=True)
                            )

class AccountType(Base):
    __tablename__ = 'account_types'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False, unique=True)
    price = Column(Numeric, nullable=False)
    
    # many-to-many relationship with priviledges
    privileges = relationship('Privilege', secondary=account_privileges, back_populates='account_types')
    
    # one-to-many relationship with user accounts
    user_accounts = relationship('UserAccount', back_populates='account_type')

class Privilege(Base):
    __tablename__ = 'privileges'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False, unique=True)
    
    account_types = relationship('AccountType', secondary=account_privileges, back_populates='privileges')
    
    def serialize(self) -> dict:
        return {
                'id': self.id,
                'name': self.name
                #'account_types': self.account_types
               }
    



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
    
    anglers = relationship('Angler', back_populates='rank')
    
angler_spots = Table ('angler_spots',
                      Base.metadata,
                      Column('angler_id',
                             ForeignKey('anglers.id',
                                        ondelete='CASCADE'),######will ondelete='CASCADE' delete the angler???????
                             primary_key=True),
                      Column('fishing_spot_id',
                             ForeignKey('fishing_spots.id',
                                        ondelete='CASCADE'),
                             primary_key=True),
                      Column('nickname', String(128))
    )
    

class Angler(Base):
    __tablename__ = 'anglers'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(30), nullable=False, unique=True)
    # rank = Column(String(40))
    rank_id = Column(Integer,
                      ForeignKey('ranks.id',
                                ondelete='CASCADE'),
                      nullable=False)
    
    # many-to-one relationship with ranks
    rank = relationship('Rank', back_populates='anglers')
    
    # one-to-one relationship with user_accounts
    #(unidirectional- this is parent)
    user_accounts = relationship('UserAccount',
                                back_populates='anglers',
                                uselist=False)
    
    fishing_spots = relationship('FishingSpot', secondary=angler_spots, back_populates='anglers')
    
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

class CurrentStation(Base):
    __tablename__ = 'current_stations'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(280), nullable=False, unique=True)
    global_position_id = Column(Integer,
                                ForeignKey('global_positions.id'),
                                nullable=False)
    
    global_position = relationship('GlobalPosition', back_populates='current_station')


class FishingSpot(Base):
    __tablename__ = 'fishing_spots'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False)
    nickname = Column(String)
    description = Column(String)
    global_position_id = Column(Integer,
                                ForeignKey('global_positions.id'),
                                nullable=False)
    # for this to work in the db, it must be server_default=SQL text to default to FALSE
    is_public = Column(Boolean, nullable=False, server_default='f')######default not working,but it is not null boolean??server_default=text('ALTER TABLE fishing_spots ALTER is_public SET DEFAULT FALSE'))
    
    global_position = relationship('GlobalPosition', back_populates='fishing_spots')
    fishing_conditions = relationship('FishingConditions')
    fishes = relationship('Fish')
    anglers = relationship('Angler', secondary=angler_spots, back_populates='fishing_spots')
    

# find_nearest_current = DDL('''
#                            CREATE FUNCTION find_nearest()
#                            RETURNS TRIGGER AS $$
#                            BEGIN
#                                WITH distances AS (
#                                    SELECT id,
#                                    MIN(3963 * ACOS(SIN(cs.latitude) * SIN(NEW.latitude) + 
#                                                 COS(cs.latitude) * COS(NEW.latitude) *
#                                                 COS(NEW.latitude - cs.latitude)
#                                                )
#                                     ) AS dist FROM current_stations cs
#                                 ) INSERT INTO fishing_spots (nearest_known_id)
#                                   SELECT id FROM distances WHERE dist=(SELECT MIN(dist) from distances);
#                            RETURN NEW;
#                            END;
#                            $$ LANGUAGE PLPGSQL
#                            '''
# )

# trigger = DDL('''
#               CREATE TRIGGER insert_nearest
#               AFTER INSERT ON fishing_spots
#               FOR EACH ROW EXECUTE find_nearest();
#               '''
# )

# event.listen(FishingSpot.__table__,
#              'after_create',
#              find_nearest_current.execute_if(dialect='postgresql')
# )

# event.listen(FishingSpot.__table__,
#              'after_create',
#              trigger.execute_if(dialect='postgresql')
# )

class GlobalPosition(Base):
    __tablename__ = 'global_positions'
    id = Column(Integer, primary_key=True)
    latitude = Column(Numeric, nullable=False)
    longitude = Column(Numeric, nullable=False)
    
    # __table_args__ = (UniqueConstraint('latitude', 'longitude'),)
    
    data_urls = relationship('DataUrl', back_populates='global_position')
    fishing_spots = relationship('FishingSpot')
    current_station = relationship('CurrentStation', back_populates='global_position', uselist=False)

class DataUrl(Base):
    __tablename__ = 'data_urls'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    url = Column(String, nullable=False)
    global_position_id = Column(Integer,
                        ForeignKey('global_positions.id'),
                        nullable=False)
    
    global_position = relationship('GlobalPosition', back_populates='data_urls')
    

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
    
    

