# -*- coding: utf-8 -*-
"""
Created on Thu Jun 23 10:43:42 2022

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
from sqlalchemy import LargeBinary
from sqlalchemy import UniqueConstraint
from sqlalchemy.orm import relationship



from werkzeug.security import generate_password_hash
from werkzeug.security import check_password_hash

from flask_login import UserMixin


from .db import Base


angler_fishing_spots = Table('angler_fishing_spots',
                             Base.metadata,
                             Column('angler_id',
                                    ForeignKey('anglers.id',
                                               name='angler_fishing_Spots_angler_id_fkey',
                                              ondelete='CASCADE'),
                                    primary_key=True),
                             Column('fishing_spot_id',
                                    ForeignKey('fishing_spots.id',
                                               name='angler_fishing_spots_fishing_spot_id_fkey',
                                              ondelete='CASCADE'),
                                    primary_key=True)
                            )

angler_baits = Table('angler_baits',
                     Base.metadata,
                     Column('angler_id',
                            ForeignKey('anglers.id',
                                       name='angler_baits_angler_id_fkey',
                                      ondelete='CASCADE'),
                            primary_key=True),
                     Column('bait_id',
                            ForeignKey('baits.id',
                                       name='angler_baits_bait_id_fkey',
                                      ondelete='CASCADE'),
                            primary_key=True)
                     )

angler_gear = Table('angler_gear',
                    Base.metadata,
                    Column('angler_id',
                           ForeignKey('anglers.id',
                                      name='angler_gear_angler_id_fkey',
                                     ondelete='CASCADE'),
                           primary_key=True),
                    Column('fishing_gear_id',
                           ForeignKey('fishing_gear.id',
                                      name='angler_gear_fishing_gear_id_fkey',
                                     ondelete='CASCADE'),
                           primary_key=True)
                    )

angler_outings = Table('angler_outings',
                       Base.metadata,
                       Column('angler_id',
                              ForeignKey('anglers.id',
                                         name='angler_outings_angler_id_fkey',
                                        ondelete='CASCADE'),
                              primary_key=True),
                       Column('fishing_outing_id',
                              ForeignKey('fishing_outings.id',
                                         name='angler_outings_fishing_outing_id_fkey',
                                        ondelete='CASCADE'),
                              primary_key=True)
                      )

account_privileges = Table('account_privileges',
                            Base.metadata,
                            Column('account_type_id',
                                    ForeignKey('account_types.id',
                                               name='account_privileges_account_type_id_fkey',
                                              ondelete='CASCADE'),
                                    primary_key=True),
                            Column('privilege_id',
                                    ForeignKey('privileges.id',
                                               name='account_privileges_privilege_id_fkey',
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
    
    def serialize(self) -> dict:
        return (
                {
                    'id': self.id,
                    'name': self.name,
                    'price': self.price
                }
               )

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
    email = Column(String(280))
    
    def set_password(self, password) -> None:
        self.password = generate_password_hash(password)
        
    def check_password(self, password) -> bool:
        return check_password_hash(self.password, password)
    
    # many-to-one relationship with account_types (unidirectional)
    account_type_id = Column(Integer,
                              ForeignKey('account_types.id',
                                         name='user_accounts_account_type_id_fkey',
                                        ondelete='CASCADE'),
                              nullable=False)
    # one-to-one relationship with anglers (this is the child)
    angler_id = Column(Integer,
                        ForeignKey('anglers.id',
                                   name='user_accounts_angler_id_fkey',
                                  ondelete='CASCADE'))
    
    account_type = relationship('AccountType', back_populates='user_accounts') 
    anglers = relationship('Angler', back_populates='user_accounts')
    
    def serialize(self) -> dict:
        return (
                {
                    'id': self.id,
                    'username': self.username,
                    'email': self.email
                }
               )

class Rank(Base):
    __tablename__ = 'ranks'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False, unique=True)
    rank_number = Column(Integer, nullable=False, unique=True)
    description = Column(String, nullable=False)
    
    anglers = relationship('Angler', back_populates='rank')
    
    def serialize(self) -> dict:
        return (
                {
                    'id': self.id,
                    'name': self.name,
                    'rank_number': self.rank_number,
                    'description': self.description
                }
               )

class Angler(Base):
    __tablename__ = 'anglers'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(280), nullable=False, unique=True)
    rank_id = Column(Integer,
                      ForeignKey('ranks.id',
                                 name='anglers_rank_id_fkey',
                                ondelete='CASCADE'),
                      nullable=False)
    
    # one-to-one relationship with user_accounts
    #(unidirectional- this is parent)
    user_accounts = relationship('UserAccount',
                                back_populates='anglers',
                                uselist=False)
    
    # one-to-many relationship with ranks
    rank = relationship('Rank', back_populates='anglers')
    
    # many-to_many relationship with fishing_spots
    fishing_spots = relationship('FishingSpot', secondary=angler_fishing_spots, back_populates='anglers')
    # many-to_many relationship with baits
    baits = relationship('Bait', secondary=angler_baits, back_populates='anglers')
    # many-to_many relationship with fishing_gear
    gear = relationship('FishingGear', secondary=angler_gear, back_populates='anglers')
    
    # one-to-many relationship with fish
    fish = relationship('Fish', back_populates='angler')
    
    outings = relationship('FishingOuting', secondary=angler_outings, back_populates='anglers')
    
    def serialize(self) -> dict:
        return (
                {
                    'id': self.id,
                    'name': self.name
                    ###### should i serialize the relationships here???
                }
               )


class Bait(Base):
    __tablename__ = 'baits'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False)
    artificial = Column(Boolean, nullable=False)
    size = Column(Numeric)
    color = Column(String)
    description = Column(String)
    
    __table_args__ = (UniqueConstraint('name', 'size', 'color'),)
    
    fish = relationship('Fish', back_populates='bait')
    anglers = relationship('Angler', secondary=angler_baits, back_populates='baits')
    
    def serialize(self) -> dict:
        return (
                {
                    'id': self.id,
                    'name': self.name,
                    'artificial': self.artificial,
                    'size': self.size,
                    'color': self.color,
                    'description': self.description
                }
               )

class FishingGear(Base):
    __tablename__ = 'fishing_gear'

    id = Column(Integer, primary_key=True, autoincrement=True)
    rod = Column(String, nullable=False)
    reel = Column(String)
    line = Column(String)
    hook = Column(String)
    leader = Column(String)
    
    fish = relationship('Fish', back_populates='fishing_gear')
    anglers = relationship('Angler', secondary=angler_gear, back_populates='gear')
    
    def serialize(self) -> dict:
        return (
                {
                    'id': self.id,
                    'rod': self.rod,
                    'reel': self.reel,
                    'line': self.line,
                    'hook': self.hook,
                    'leader': self.leader
                }
               )

class GlobalPosition(Base):
    __tablename__ = 'global_positions'
    id = Column(Integer, primary_key=True, autoincrement=True)
    latitude = Column(Numeric, nullable=False)
    longitude = Column(Numeric, nullable=False)
    
    # __table_args__ = (UniqueConstraint('latitude', 'longitude'),)
    
    data_urls = relationship('DataUrl', back_populates='global_position')
    fishing_spots = relationship('FishingSpot')
    current_station = relationship('CurrentStation', back_populates='global_position', uselist=False)
    
    def serialize(self) -> dict:
        return (
                {
                    'id': self.id,
                    'latitude': self.latitude,
                    'longitude': self.longitude
                }
               )
    
class DataUrl(Base):
    __tablename__ = 'data_urls'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    url = Column(String, nullable=False)
    data_type = Column(String(8), nullable=False)
    global_position_id = Column(Integer,
                        ForeignKey('global_positions.id',
                                   name='data_urls_global_position_id_fkey'),
                        nullable=False)
    
    global_position = relationship('GlobalPosition', back_populates='data_urls')
    fishing_spots = relationship('FishingSpot', back_populates='current_url')
    
    def serialize(self) -> dict:
        return (
                {
                    'id': self.id,
                    'url': self.url
                }
               )

class CurrentStation(Base):
    __tablename__ = 'current_stations'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(280), nullable=False, unique=True)
    global_position_id = Column(Integer,
                                ForeignKey('global_positions.id',
                                           name='current_stations_global_position_id_fkey'),
                                nullable=False)
    
    global_position = relationship('GlobalPosition', back_populates='current_station')
    
    def serialize(self) -> dict:
        return (
                {
                    'id': self.id,
                    'name': self.name
                }
               )

class FishingSpot(Base):
    __tablename__ = 'fishing_spots'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False)
    nickname = Column(String)
    description = Column(String)
    # for this to work in the db, it must be server_default=
    is_public = Column(Boolean, nullable=False, server_default='false')######default not working,but it is not null boolean??server_default=text('ALTER TABLE fishing_spots ALTER is_public SET DEFAULT FALSE'))
    global_position_id = Column(Integer,
                                ForeignKey('global_positions.id',
                                           name='fishing_spots_global_position_id_fkey'),
                                nullable=False)
    current_url_id = Column(Integer,
                            ForeignKey('data_urls.id',
                                       name='fishing_spots_current_url_id_fkey'))
    
    fish = relationship('Fish', back_populates='fishing_spot')
    global_position = relationship('GlobalPosition', back_populates='fishing_spots')
    current_url = relationship('DataUrl', back_populates='fishing_spots')
    anglers = relationship('Angler', secondary=angler_fishing_spots, back_populates='fishing_spots')
    outings = relationship('FishingOuting', back_populates='fishing_spot')
    
    def serialize(self) -> dict:
        return (
                {
                    'id': self.id,
                    'name': self.name,
                    'nickname': self.nickname,
                    'description': self.description
                }
               )
    
class Fish(Base):
    __tablename__ = 'fishes'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    species = Column(String, nullable=False)
    weight = Column(Numeric)
    length = Column(Numeric)
    description = Column(String)
    image = Column(LargeBinary)
    date_time_caught = Column(DateTime, nullable=False)

    angler_id = Column(Integer,
                       ForeignKey('anglers.id',
                                  name='fishes_angler_id_fkey'),
                       nullable=False)
    fishing_spot_id = Column(Integer,
                       ForeignKey('fishing_spots.id',
                                  name='fishes_fishing_spot_id_fkey'),
                       nullable=False)
    bait_id = Column(Integer,
                       ForeignKey('baits.id',
                                  name='fishes_bait_id_fkey'),
                       nullable=False)
    gear_id = Column(Integer,
                       ForeignKey('fishing_gear.id',
                                  name='fishes_gear_id_fkey'))
    
    angler = relationship('Angler', back_populates='fish')
    fishing_spot = relationship('FishingSpot', back_populates='fish')
    bait = relationship('Bait', back_populates='fish')
    fishing_gear = relationship('FishingGear', back_populates='fish')
    
    # catch = relationship('Catch', back_populates='fish', uselist=False)
    
    def serialize(self) -> dict:
        return (
                {
                    'id': self.id,
                    'species': self.species,
                    'weight': self.weight,
                    'length': self.length,
                    'description': self.description
                }
               )
    
# class Catch(Base):
#     __tablename__ = 'catches'
    
#     id = Column(Integer, primary_key=True, autoincrement=True)
#     date_time_caught = Column(DateTime, nullable=False)
#     fish_id = Column(Integer,
#                        ForeignKey('fishes.id',
#                                   name='catches_fish_id_fkey'),
#                        nullable=False)
#     angler_id = Column(Integer,
#                        ForeignKey('anglers.id',
#                                   name='catches_angler_id_fkey'),
#                        nullable=False)
#     fishing_spot_id = Column(Integer,
#                        ForeignKey('fishing_spots.id',
#                                   name='catches_fishing_spot_id_fkey'),
#                        nullable=False)
#     bait_id = Column(Integer,
#                        ForeignKey('baits.id',
#                                   name='catches_bait_id_fkey'),
#                        nullable=False)
#     gear_id = Column(Integer,
#                        ForeignKey('fishing_gear.id',
#                                   name='catches_gear_id_fkey'))
    
#     fish = relationship('Fish', back_populates='catch')
#     angler = relationship('Angler', back_populates='catches')
#     fishing_spot = relationship('FishingSpot', back_populates='catches')
#     bait = relationship('Bait', back_populates='catches')
#     fishing_gear = relationship('FishingGear', back_populates='catches')
    
#     def serialize(self) -> dict:
#         return (
#                 {
#                     'id': self.id,
#                     'date_time': self.date_time_caught
#                 }
#                )
    
class FishingOuting(Base):
    __tablename__ = 'fishing_outings'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(280), nullable=False)
    outing_date = Column(Date, nullable=False)
    fishing_spot_id = Column(Integer,
                             ForeignKey('fishing_spots.id',
                                        name='fishing_outings_fishing_spot_id_fkey'),
                             nullable=False)
    fishing_conditions_id = Column(Integer,
                                   ForeignKey('fishing_conditions.id',
                                              name='fishing_outings_fishing_conditions_id_fkey'),
                                   nullable=False)
    
    fishing_spot = relationship('FishingSpot', back_populates='outings')
    anglers = relationship('Angler', secondary=angler_outings, back_populates='outings')
    conditions = relationship('FishingConditions', back_populates='fishing_outing')
    
    def serialize(self) -> dict:
        return (
                {
                    'id': self.id,
                    'name': self.name,
                    'date': self.outing_date
                }
               )

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

    fishing_outing = relationship('FishingOuting', back_populates='conditions')
    
    def serialize(self) -> dict:
        return (
                {
                    'id': self.id,
                    'weather': self.weather,
                    'tide_phase': self.tide_phase,
                    'time_stamp': self.time_stamp,
                    'current_flow': self.current_flow,
                    'current_speed': self.current_speed,
                    'moon_phase': self.moon_phase,
                    'wind_direction': self.wind_direction,
                    'wind_speed': self.wind_speed,
                    'pressure_yesterday': self.pressure_yesterday,
                    'pressure_today': self.pressure_today
                }
               )

#######################################################################
######FUNCTIONS AND TRIGGER TO SET NEAREST CURRENT URL ON FISHING_SPOTS
######BASED ON DISTANCE FROM CURRENT SITES


'''
CREATE OR REPLACE FUNCTION curr_min_distance(lat NUMERIC, lon NUMERIC) RETURNS INTEGER AS
$$
DECLARE url_id INTEGER;
BEGIN
	WITH distances AS (
	SELECT u.id as u_id, 3963 * ACOS(SIN(gp.latitude) * SIN($1) + COS(gp.latitude) * COS($1) * COS($2 - gp.longitude)) AS dist FROM data_urls u
	INNER JOIN global_positions gp
	ON u.global_position_id = gp.id WHERE u.data_type = 'current'
	) SELECT u_id FROM distances WHERE dist = (SELECT MIN(dist) FROM distances) INTO url_id;
	RETURN url_id;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION find_nearest_curr() RETURNS TRIGGER AS
$$
DECLARE url_id INTEGER;
DECLARE lat NUMERIC;
DECLARE lon NUMERIC;
BEGIN
	 
	SELECT gp.latitude, gp.longitude FROM global_positions gp
	WHERE NEW.global_position_id = gp.id INTO lat, lon;
	SELECT * FROM curr_min_distance(lat, lon) INTO url_id;
	NEW.current_url_id = url_id;
	RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE TRIGGER set_nearest_curr
BEFORE INSERT ON fishing_spots
FOR ROW EXECUTE FUNCTION find_nearest_curr();
'''