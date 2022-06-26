# -*- coding: utf-8 -*-
"""
Created on Sun Jun 12 22:56:12 2022

@author: Robert
"""

from flask_wtf import FlaskForm
from wtforms import StringField
from wtforms import PasswordField
from wtforms import BooleanField
from wtforms import SubmitField
from wtforms import SelectField
from wtforms.foelds import EmailField
from wtforms.validators import DataRequired
from wtforms.validators import ValidationError

class LoginForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    remember_me = BooleanField('Remember Me')
    submit = SubmitField('Sign In')


def passwords_match_check(form, field):
    ''' Used as a validator in the password repeat field
        of a Flask form subclass
    '''
    if not form.passwords_match_check():
        raise ValidationError('Passwords do not match')

def password_length_check(form, field):
    ''' Used as a validator in password field to ensure
        length >= 8 and <=20
    '''
    if not (8 <= len(field.data) <=20):
        raise ValidationError('Password must have length 8-20')

def valid_password_check(form, field):
    ''' Used as a validator in password field to ensure
        1 number (not in first position), a capital letter,
        a lower case letter, and a special character (not in
        first position), after ensuring length 8-20 characters
    '''
    password_length_check(form, field)
    
    has_number = False
    has_lower = False
    has_upper = False
    has_special = False
    
    password = field.data
    
    # check first character in password is a letter
    if not password[0].isalpha():
        raise ValidationError('Password must start with a letter')
    
    for c in password:
        if c.islower():
            has_lower = True
        
        if c.isupper():
            has_upper = True
        
        if c.isnumeric():
            has_number = True
        
        if not c.isalnum():
            has_special = True
        
        if has_number and has_lower and has_upper and has_special:
            break
    else: # the "ubiquitous" for-else :) called if loop ends (not valid)
        ValidationError('Password must have letter, number, special')
        

class RegistrationForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired(),
                                                     valid_password_check])
    password_repeat = PasswordField('Password (retype)',
                                    validators=[DataRequired(),
                                                passwords_match_check])
    account_types = SelectField('Account Type')
    email = EmailField('Email')
    submit = SubmitField('Register')
    
    def passwords_match_check(self) -> bool:
        # make sure comparing data, not objects
        return self.password.data == self.password_repeat.data
    
    