# -*- coding: utf-8 -*-
"""
Created on Thu Jun  2 13:36:52 2022

@author: Robert J McGinness
"""

from flask_wtf import FlaskForm
from wtforms import StringField
from wtforms import PasswordField
from wtforms import BooleanField
from wtforms import SubmitField
from wtforms.validators import DataRequired

class LoginForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    remember_me = BooleanField('Remember Me')
    submit = SubmitField('Sign In')
