# -*- coding: utf-8 -*-
"""
Created on Fri Jun 10 09:43:57 2022

@author: Robert J McGinness
"""

import requests
from datetime import datetime
from scrapy.selector import Selector


url = 'http://tbone.biol.sc.edu/tide/tideshow.cgi?'

date_time = datetime(year=2022, month=6, day=11)


formdata={
            'sitesave': 'Newburyport (Merrimack River), Massachusetts Current',
            'glen': '1',
            'year': str(date_time.year),
            'month': str(date_time.month),
            'day': str(date_time.day)}

r = requests.post(url, data=formdata)


selector = Selector(text=r.content)

data = selector.xpath('//pre/text()').get()

print(data)