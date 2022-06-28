# -*- coding: utf-8 -*-
"""
Created on Thu Jun  2 23:13:25 2022

@author: Robert J McGinness
"""

from sqlalchemy import create_engine
from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import declarative_base
from sqlalchemy.exc import IntegrityError
from werkzeug.security import generate_password_hash


from config import Config

engine = create_engine(Config.DATABASE, echo=True, future=True)
db_session = scoped_session(sessionmaker(autocommit=False,
                                         autoflush=False,
                                         bind=engine))

# need to declare this before models is imported
Base = declarative_base()

def init_db():
    # need to import models so that tables will be created
    # get rid of this when alembic used
    from . import models
    # Base.metadata.create_all(engine)
    
    class FakeFlaskSQLAlchemy:
        def __init__(self, engine, metadata):
            self.engine = engine
            self.metadata = metadata
        
        def get_engine(self):
            return self.engine
    
    return FakeFlaskSQLAlchemy(engine, Base.metadata)

def init_admin():
    from .models import Privilege
    from .models import AccountType
    from .models import UserAccount
    
    privilege = Privilege(name='Administrator')
    
    account_type = AccountType(name='Admin',
                               price=0.0)
    
    account_type.privileges.append(privilege)
    
    
    user_account = UserAccount(username='admin',
                               password=generate_password_hash('admin'))
    
    user_account.account_type = account_type
    
    db_session.add(user_account)
    
    try:
        db_session.commit()
    except IntegrityError:
        db_session.rollback()
        pass
    
    
    
    
    
    

