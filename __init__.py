# -*- coding: utf-8 -*-
"""
Created on Wed Jun 15 21:07:30 2022

@author: Robert J McGinness
"""

from sys import path
from pathlib import Path
import os


# set PYTHONPATH
def set_paths():
    base_path = os.fspath(Path(os.path.abspath('.')))
    
    if base_path not in path:
        path.append(base_path)
    
    if base_path + '/src' not in path:
        path.append(base_path + '/src')
        
set_paths()

print('PATH:', path)