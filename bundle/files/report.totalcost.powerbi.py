import sys, requests
import pandas as pd

url = 'http://localhost:8080'         # Spider Project API Server 
filename = "1km_road_api.001.sprj"    # The full path to the project file

r = requests.post( url, json={'command':'openFile', 'fileName':filename} )
sys.stderr.write('Project opened.') if r.status_code == 200 else sys.exit(0)
docHandle = r.json()['docHandle'] 

r = requests.post( url, json={'command':'getObjectHandle', "docHandle":str(docHandle), "table":"GanttAct", "index":"0" } )
sys.stderr.write('Phase "0" handle obtained!') if r.status_code == 200 else sys.exit(0)
phaseHandle = r.json()['objectHandle']

r = requests.post( url, json={'command':'getObjectHandle', "docHandle":str(docHandle), "table":"ReportSpend", "code":"TotalCost" } )
sys.stderr.write('The "TotalCost" template found in the "ReportSpend" template table and the handle obtained!') if r.status_code == 200 else sys.exit(0)
templateHandle = r.json()['objectHandle']

r = requests.post( url, json={'command':'getReport', "objectHandle":str(phaseHandle), "templateHandle":str(templateHandle)} )
sys.stderr.write('The "ReportSpend" report obtained!') if r.status_code == 200 else sys.exit(0)
r = r.json()

df = pd.DataFrame( { 'Time': [ v[0] for v in r['graphs'][0]['array'] ], 'Value':[ v[1] for v in r['graphs'][0]['array'] ] } )
print(df)
