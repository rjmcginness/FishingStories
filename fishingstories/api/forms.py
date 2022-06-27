# -*- coding: utf-8 -*-
"""
Created on Thu Jun  2 13:36:52 2022

@author: Robert J McGinness
"""

from flask_wtf import FlaskForm
# from werkzeug.utils import secure_filename
# from flask_uploads import UploadSet
# from flask_uploads import IMAGES
# from flask_uploads import configure_uploads
# from flask_wtf.file import FileField
# from flask_wtf.file import FileAllowed
from wtforms import StringField
from wtforms import PasswordField
from wtforms import BooleanField
from wtforms import SelectField
from wtforms import SubmitField
from wtforms import IntegerField
from wtforms import HiddenField
from wtforms import DecimalField
from wtforms import FloatField
from wtforms import FormField
from wtforms import SelectMultipleField
from wtforms import TextAreaField
from wtforms.validators import DataRequired
from wtforms.validators import ValidationError
from wtforms.validators import Optional
from wtforms.widgets import HiddenInput
from wtforms.fields import DateField
from wtforms.fields import TimeField
from wtforms.fields import DateTimeField
import datetime

# class LoginForm(FlaskForm):
#     username = StringField('Username', validators=[DataRequired()])
#     password = PasswordField('Password', validators=[DataRequired()])
#     remember_me = BooleanField('Remember Me')
#     submit = SubmitField('Sign In')

# pip install git+https://github.com/maxcountryman/flask-uploads.git@f66d7dc

# form_images = UploadSet('images', IMAGES)

class SearchBasicForm(FlaskForm):
    search = StringField('', validators=[DataRequired()])
    submit = SubmitField('Search')
    
    def __init__(self, search_name: str=None, **kwargs) -> None:
        super(SearchBasicForm, self).__init__(**kwargs)
        if search_name is not None:
            self.search.label = search_name

def validate_measure(form, field):
    if field.data is not None and field.data <= 0:
        raise ValidationError('Must have positive or blank ' + field.name)
def validate_select(form, field):
    if field.data == -1:
        raise ValidationError("Please select " + field.name)

class AddFishForm(FlaskForm):
    species = StringField('Species', validators=[DataRequired()])
    weight = DecimalField('Weight (lb)', validators=[Optional(), validate_measure])
    length = DecimalField('Length (inches)', validators=[Optional(), validate_measure])
    fishing_spot = SelectField('Place Caught', coerce=int, validators=[validate_select])
    bait = SelectField('Bait Used', coerce=int, validators=[validate_select])
    gear = SelectField('Gear Combo Used')
    date = DateField('Date and Time Caught')
    time = TimeField('Time Caught')
    description = TextAreaField('Description')
    # image = FileField('Image', validators=[FileAllowed(form_images, 'Images Only!')])
    submit = SubmitField('Record Fish')

class FishViewOnlyForm(FlaskForm):
    species = StringField('Species', render_kw={'readonly': True})
    weight = DecimalField('Weight (lb)', validators=[Optional(), validate_measure])
    length = DecimalField('Length (inches)', validators=[Optional(), validate_measure])
    fishing_spot = SelectField('Place Caught', render_kw={'readonly': True})
    bait = SelectField('Bait Used', render_kw={'readonly': True})
    gear = SelectField('Gear Combo Used', render_kw={'readonly': True})
    date_time = DateTimeField('Date and Time Caught', render_kw={'readonly': True})
    description = TextAreaField('Description', render_kw={'readonly': True})
    
class EditFishForm(FlaskForm):
    species = StringField('Species', validators=[DataRequired()])
    weight = DecimalField('Weight (lb)', validators=[Optional(), validate_measure])
    length = DecimalField('Length (inches)', validators=[Optional(), validate_measure])
    fishing_spot = SelectField('Place Caught', coerce=int, validators=[validate_select])
    bait = SelectField('Bait Used', coerce=int, validators=[validate_select])
    gear = SelectField('Gear Combo Used')
    date = DateField('Date and Time Caught', render_kw={'readonly': True})
    time = TimeField('Time Caught', render_kw={'readonly': True})
    description = TextAreaField('Description')
    # image = FileField('Image', validators=[FileAllowed(form_images, 'Images Only!')])
    submit = SubmitField('Save Edits')
    
def check_agree_to_delete(form, field):
    if field.data == False:
        raise ValidationError('You must agree to delete this item')
    
class DeleteFishForm(FlaskForm):
    species = StringField('Species', render_kw={'readonly': True})
    weight = DecimalField('Weight (lb)', validators=[Optional(), validate_measure])
    length = DecimalField('Length (inches)', validators=[Optional(), validate_measure])
    fishing_spot = SelectField('Place Caught', render_kw={'readonly': True})
    date_time = DateTimeField('Date and Time Caught', render_kw={'readonly': True})
    description = TextAreaField('Description', render_kw={'readonly': True})
    agree = BooleanField("Permanently Delete Fish?", validators=[DataRequired(), check_agree_to_delete])
    submit = SubmitField('DELETE FISH')


def date_check(form, field):
    if form.end_date.data is None:
        return 
    
    if form.start_date.data > form.end_date.data:
        raise ValidationError("From Date cannot be after To Date")
    
class FishSearchForm(FlaskForm):
    start_date = DateField('From Date', validators=[Optional()])
    end_date = DateField('To Date', validators=[Optional(), date_check])
    fishing_spot = SelectField('Where Caught', validators=[Optional()])
    bait = SelectField('Bait Used', validators=[Optional()])
    species = SelectField('Species', validators=[Optional()])
    submit = SubmitField('Search')
    

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
        
class DeleteBaitForm(FlaskForm):
    name = StringField('Name', render_kw={'readonly': True})
    size = DecimalField('Size', render_kw={'readonly': True})
    color = StringField('Color', render_kw={'readonly': True})
    agree = BooleanField('Permanently Delete Bait?',
                         validators=[DataRequired(),
                                     check_agree_to_delete])
    submit = SubmitField('Delete Bait')
    
    def __init__(self, name: str, size: float, color: str, **kwargs) -> None:
        super(DeleteBaitForm, self).__init__(**kwargs)
        self.name.data = name
        self.size.data = size
        self.color.data = color

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
    
class GearViewOnlyForm(FlaskForm):
    rod = StringField('Rod', render_kw={'readonly': True})
    reel = StringField('Reel', render_kw={'readonly': True})
    line = StringField('Line', render_kw={'readonly': True})
    hook = StringField('Hook', render_kw={'readonly': True})
    leader = StringField('Leader', render_kw={'readonly': True})
    agree = BooleanField('Permanently Delete Gear?',
                         validators=[DataRequired(),
                                     check_agree_to_delete])
    submit = SubmitField('Delete Gear')

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
    latitude = StringField('Latitude', validators=[DataRequired()])
    longitude = StringField('Longitude', validators=[DataRequired()])
    is_public = BooleanField('Public')
    nickname = StringField('Nickname')
    description = StringField('Description')
    submit = SubmitField('Add Spot')
    
    # def __init__(self, spot_choices: list, **kwargs) -> None:
    #     super(AddFishingSpotForm, self).__init__(**kwargs)
    #     self.name.choices = spot_choices
    
class CreateAccountTypeForm(FlaskForm):
    name = StringField('Account Type Name', validators=[DataRequired()])
    price = DecimalField('Price', validators=[DataRequired()])
    priviledges = SelectMultipleField('Select Priviledges')
    submit = SubmitField('Add Account Type')

class CreatePriviledgeForm(FlaskForm):
    name = StringField('Priviledge Name', validators=[DataRequired()])
    submit = SubmitField('Add Priviledge')
    