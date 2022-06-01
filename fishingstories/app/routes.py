# -*- coding: utf-8 -*-
"""
Created on Wed Jun  1 14:53:05 2022

@author: Robert J McGinness
"""
from flask import render_template
from app import app

@app.route('/')
@app.route('/index')
def index():
    return render_template('index.html')