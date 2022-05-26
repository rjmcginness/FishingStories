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

from sqlalchemy.orm import relationship

engine = create_engine('sqlite+pysqlite:///:memory:', echo=True, future=True)

Base = declarative_base()

account_priviledges = Table('account_priviledge',
                            Base.metadata,
                            Column('account_type_id',
                                   ForeignKey('account_type.id')),
                            Column('priviledge_id',
                                   ForeignKey('priviledge.id'))
                            )

class Priviledge(Base):
    __tablename__ = 'priviledges'
    
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False, unique=True)
    account_types = relationship('AccountType', secondary=account_priviledges)