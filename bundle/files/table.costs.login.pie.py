# -*- coding: utf-8 -*-
import sys, requests

url = 'http://localhost:8080'	# Spider Project's API Server 
filename = "1km_road_with_users_api.001.sprj"    # Please prepend with the full path

r = requests.post( url, json={'command':'login', 'user':'user', 'password':'user'} )
print('Login request done.') if r.status_code == 200 else sys.exit(0)
r = r.json()
if r['errcode'] != 0:
	print('Invalid login or password!')
	sys.exit(0)

r = requests.post( url, json={ 'command':'getTable', 'fileName':filename, 'table':'GanttAct', 'sessId':r['sessId'] } )
print('Table request done.') if r.status_code == 200 else sys.exit(0)
r = r.json()
if r['errcode'] != 0:
	print('Failed to obtain the table!')
	sys.exit(0)

import matplotlib.pyplot as plt

labels = [ '%s, %.0f р.' % (x['Name'], float(x['c_sum_кс'])) for x in r['array'] if 'c_sum_кс' in x and not ('Level' in x) ]
sizes = [ round(float(x['c_sum_кс']), 1) for x in r['array'] if 'c_sum_кс' in x and not ('Level' in x) ]
explode = [ 0 for x in r['array'] if 'c_sum_кс' in x and (not 'Level' in x) ]
explode[ sizes.index( max(sizes) ) ] = 0.1 
fig, ax = plt.subplots()
ax.pie(sizes, explode=explode, labels=labels, autopct='%1.1f%%', shadow=True, startangle=0)
ax.axis('equal')
plt.show()