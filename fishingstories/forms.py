# -*- coding: utf-8 -*-
"""
Created on Thu Jun  2 13:36:52 2022

@author: Robert J McGinness
"""

from flask_wtf import FlaskForm
from wtforms import StringField
from wtforms import PasswordField
from wtforms import BooleanField
from wtforms import SelectField
from wtforms import SubmitField
from wtforms import IntegerField
from wtforms.validators import DataRequired

class LoginForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    remember_me = BooleanField('Remember Me')
    submit = SubmitField('Sign In')
    

class AddBaitForm(FlaskForm):
    name = StringField('Name', validators=[DataRequired()])
    artificial = BooleanField('Artificial', validators=[DataRequired()])
    size = StringField('Size')
    color = StringField('Color')
    description = StringField('Description')
    submit = SubmitField('Add Bait')
    
    def clear(self) -> None:
        self.name.data = ''
        self.artificial.data = ''
        self.size.data = ''
        self.color.data = ''
        self.description.data = ''
    
class AddGearForm(FlaskForm):
    rod = StringField('Rod', validators=[DataRequired()])
    reel = StringField('Reel')
    line = StringField('Line')
    hook = StringField('Hook')
    leader = StringField('Leader')
    submit = SubmitField('Add Gear')

class CreateAnglerForm(FlaskForm):
    name = StringField('Name', validators=[DataRequired()])
    submit = SubmitField('Add Gear')
    
class RankForm(FlaskForm):
    name = StringField('Rank', validators=[DataRequired()])
    rank_number = IntegerField('Rank Number (must be unique)',
                              validators=[DataRequired()])
    description = StringField('Description', validators=[DataRequired()])
    submit = SubmitField('Create Rank')
    
    def clear(self) -> None:
        self.name.data = ''
        self.rank_number.data = ''
        self.description.data = ''