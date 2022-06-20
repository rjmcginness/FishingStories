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
from wtforms import HiddenField
from wtforms import DecimalField
from wtforms import FormField
from wtforms import SelectMultipleField
from wtforms.validators import DataRequired
from wtforms.widgets import HiddenInput

# class LoginForm(FlaskForm):
#     username = StringField('Username', validators=[DataRequired()])
#     password = PasswordField('Password', validators=[DataRequired()])
#     remember_me = BooleanField('Remember Me')
#     submit = SubmitField('Sign In')


class SearchBasicForm(FlaskForm):
    search = StringField('', validators=[DataRequired()])
    submit = SubmitField('Search')
    
    def __init__(self, search_name: str=None, **kwargs) -> None:
        super(SearchBasicForm, self).__init__(**kwargs)
        if search_name is not None:
            self.search.label = search_name

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

class BaitForm(FlaskForm):
    name = StringField('Name', validators=[DataRequired()])
    artificial = BooleanField('Artificial', validators=[DataRequired()])
    size = StringField('Size')
    color = StringField('Color')
    description = StringField('Description')
    submit = SubmitField('Update')
    
    def __init__(self, bait=None, **kwargs) -> None:
        super(BaitForm, self).__init__(**kwargs)
        self.name.data = bait.name
        self.artificial.data = bait.artificial
        self.size.data = bait.size
        self.color.data = bait.color
        self.description.data = bait.description
        self.bait_id = bait.id
        self.is_readonly = True
    
    def readonly(self, set_readonly=True):
        self.is_readonlt = set_readonly
        self.name.render_kw={'readonly': set_readonly}
        self.artificial.render_kw={'disabled': set_readonly}
        self.size.render_kw={'readonly': set_readonly}
        self.color.render_kw={'readonly': set_readonly}
        self.description.render_kw={'readonly': set_readonly}
        
    
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

class ViewFishingSpotForm(FlaskForm):
    spot_name = HiddenField('spot_name')
    submit = SubmitField('Go')
    
class AddFishingSpotForm(FlaskForm):
    name = StringField('Name', validators=[DataRequired()])
    latitude = DecimalField('Latitude', validators=[DataRequired()])
    longitude = DecimalField('Longitude', validators=[DataRequired()])
    description = StringField('Description')
    submit = SubmitField('Add Spot')
    
class CreateAccountTypeForm(FlaskForm):
    name = StringField('Account Type Name', validators=[DataRequired()])
    price = DecimalField('Price', validators=[DataRequired()])
    priviledges = SelectMultipleField('Select Priviledges')
    submit = SubmitField('Add Account Type')

class CreatePriviledgeForm(FlaskForm):
    name = StringField('Priviledge Name', validators=[DataRequired()])
    submit = SubmitField('Add Priviledge')
    