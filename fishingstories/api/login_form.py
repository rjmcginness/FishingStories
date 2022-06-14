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
from wtforms.validators import DataRequired

class LoginForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    remember_me = BooleanField('Remember Me')
    submit = SubmitField('Sign In')


class RegistrationForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    password_repeat = PasswordField('Password (repeat)', validators=[DataRequired()])
    account_types = SelectField('Account Type')
    submit = SubmitField('Register')
    
    def check_passwords_match(self) -> bool:
        return self.password == self.password_repeat
    
    