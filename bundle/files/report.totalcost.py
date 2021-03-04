# -*- coding: utf-8 -*-
import sys, requests, numpy as np, matplotlib.pyplot as plt, matplotlib.dates as mdates
from datetime import datetime as dt

url = 'http://localhost:8080'	# Spider Project's API Server 
filename = "1km_road_api.001.sprj"    # Please prepend with the full path

r = requests.post( url, json={'command':'openFile', 'fileName':filename} )
print('Project opened.') if r.status_code == 200 else sys.exit(0)
docHandle = r.json()['docHandle'] 

r = requests.post( url, json={'command':'getObjectHandle', "docHandle":str(docHandle), "table":"GanttAct", "index":"0" } )
print('Phase "0" handle obtained!') if r.status_code == 200 else sys.exit(0)
phaseHandle = r.json()['objectHandle']

r = requests.post( url, json={'command':'getObjectHandle', "docHandle":str(docHandle), "table":"ReportSpend", "code":"TotalCost" } )
print('The "TotalCost" template found in the "ReportSpend" template table and the handle obtained!') if r.status_code == 200 else sys.exit(0)
templateHandle = r.json()['objectHandle']

r = requests.post( url, json={'command':'getReport', "objectHandle":str(phaseHandle), "templateHandle":str(templateHandle)} )
print('The "ReportSpend" report obtained!') if r.status_code == 200 else sys.exit(0)
r = r.json()

fig, ax = plt.subplots(1, 1)
fig.suptitle(r['project']['name'])

text = r['object']['name'] + '\n' + dt.fromtimestamp(r['project']['curTime']).strftime('%Y-%m-%d %H:%M') + '\n'  
text += "Ver.: " + str(r['project']['version']) + '\n' 
plt.text(10, 10, text,	ha='left', va='bottom', transform=None )

xy = np.array(r['graphs'][0]['array'])
ax.plot([ dt.fromtimestamp(x) for x in xy[:,0] ], xy[:,1], 'o-')
ax.set_ylabel(r['graphs'][0]['name'])
ax.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d'))
ax.set_xlabel('Время')

plt.show()