# -*- coding: utf-8 -*-
"""
Created on Thu May 26 14:37:03 2022

@author: Robert J McGinness
"""


from sqlalchemy import create_engine
from sqlalchemy import declarative_base
from sqlalchemy import Table
from sqlalchemy import Column
from sqlalchemy import ForeignKey
from sqlalchemy import Integer
from sqlalchemy import String
from sqlalchemy import Numeric

from sqlalchemy.orm import relationship

engine = create_engine('sqlite+pysqlite:///:memory:', echo=True, future=True)

Base = declarative_base()

account_priviledges = Table('account_priviledge',
                            Base.metadata,
                            Column('account_type_id',
                                   ForeignKey('account_type.id'),
                                   primary_key=True),
                            Column('priviledge_id',
                                   ForeignKey('priviledge.id'),
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
    account_type_id = Column(Integer, ForeignKey('account_type.id'))
    angler_id = Column(Integer, ForeignKey('angler,id'))
    