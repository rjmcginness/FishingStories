# -*- coding: utf-8 -*-
"""
Created on Mon Jun  6 23:39:27 2022

@author: Robert J McGinness
"""

from flask import current_app
from flask import Blueprint
from flask import render_template
from flask import flash
from flask_login import login_required
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

from ..db import models
from .forms import RankForm
from .forms import CreateAnglerForm


bp = Blueprint('admin', __name__)


@bp.route('/admin')
@login_required
def admin():
    return render_template('admin/index.html', authenticated=True)


@bp.route('/manage-anglers')
@login_required
def manage_anglers():
    return render_template('admin/anglermenu.html', authenticated=True)

@bp.route('/anglers')
@login_required
def anglers():
    anglers_list = current_app.session.execute(select(models.Angler))
    
    return render_template('admin/anglers.html', anglers=anglers_list, authenticated=True)

@bp.route('/ranks', methods = ['GET', 'POST'])
@login_required
def ranks():
    form = RankForm()
    ranks = current_app.session.execute(select(models.Rank))
    ranks = [rank[0] for rank in ranks]
    
    if form.validate_on_submit():
        
        rank = models.Rank(name=form.name.data,
                           rank_number=form.rank_number.data,
                           description=form.description.data)
        
        try:
            current_app.session.add(rank)
            current_app.session.commit()
            ranks.append(rank)
        except IntegrityError:
            
            flash('Invalid rank entry')
            
    form.clear()
            
    return render_template('admin/ranks.html', form=form, ranks=ranks, authenticated=True)

            

@bp.route('/create-anglers')
@login_required
def add_angler():
    form = CreateAnglerForm()
    if form.validate_on_submit():
        
        angler = models.Angler()

