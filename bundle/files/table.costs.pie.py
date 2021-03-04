# -*- coding: utf-8 -*-
import sys, requests

url = 'http://localhost:8080'	# Spider Project's API Server 
filename = "1km_road_api.001.sprj"    # Please prepend with the full path

r = requests.post( url, json={'command':'openFile', 'fileName':filename, 'sessId':''} )
print('Project opened.') if r.status_code == 200 else sys.exit(0)
docHandle = r.json()['docHandle'] 

r = requests.post( url, json={ 'command':'getTableHandle', 'docHandle':str(docHandle), 'table':'GanttAct', 'sessId':'' } )
print('Table handle obtained.') if r.status_code == 200 else sys.exit(0)
tableHandle = r.json()['tableHandle'] 

r = requests.post( url, json={ 'command':'getTable', 'tableHandle':str(tableHandle), 'sessId':'' } )
print('Table content obtained.') if r.status_code == 200 else sys.exit(0)
r = r.json()

import matplotlib.pyplot as plt

labels = [ '%s, %.0f р.' % (x['Name'], float(x['c_sum_кс'])) for x in r['array'] if 'c_sum_кс' in x and not ('Level' in x) ]
sizes = [ round(float(x['c_sum_кс']), 1) for x in r['array'] if 'c_sum_кс' in x and not ('Level' in x) ]
explode = [ 0 for x in r['array'] if 'c_sum_кс' in x and (not 'Level' in x) ]
explode[ sizes.index( max(sizes) ) ] = 0.1 
fig, ax = plt.subplots()
ax.pie(sizes, explode=explode, labels=labels, autopct='%1.1f%%', shadow=True, startangle=0)
ax.axis('equal')
plt.show()
