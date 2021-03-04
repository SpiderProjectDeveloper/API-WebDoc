Sub ReportTotalCost
  fileName = "1km_road_api.001.sprj"    ' Please prepend with the full path

  oScriptControl = CreateObject("MSScriptControl.ScriptControl")  ' An object to parse JSON responses of the Spider Project's API server
  oScriptControl.Language = "JScript"  
  oScriptControl.AddCode "function getValByKey(jsonObj, key) { return (key in jsonObj) ? jsonObj[key] : """"; }"
  oScriptControl.AddCode "function getValByIndex(jsonObj, index) { return (jsonObj.length > index) ? jsonObj[index] : """"; }"
  oScriptControl.AddCode "function getLength( jsonObj ) { return jsonObj.length; }"

  oRequest = CreateObject("WinHttp.WinHttpRequest.5.1")   ' Object to make requests
  oRequest.Open "POST", "http://localhost:8080", false    ' Specifying Spider Project's API server name and port
  oRequest.SetTimeouts 0, 0, 0, 0                         ' Waiting for response infinitely

  oRequest.Send "{ ""command"":""openFile"", ""fileName"": """ + fileName + """ }"  
  oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")    
  docHandle = oResponse.docHandle

  oRequest.Send "{ ""command"":""getObjectHandle"", ""docHandle"":""" + docHandle + """, ""table"":""GanttAct"", ""index""=""0"" }"
  oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")    
  phaseHandle = oResponse.objectHandle

  oRequest.Send "{ ""command"":""getObjectHandle"", ""docHandle"":""" + docHandle + """, ""table"":""ReportSpend"", ""code""=""TotalCost"" }"
  oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")    
  templateHandle = oResponse.objectHandle
  
  oRequest.Send "{ ""command"":""getReport"", ""objectHandle"":""" + phaseHandle + """, ""templateHandle"":""" + templateHandle + """ }"
  oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")    

  oGraphs = oScriptControl.RUN("getValByKey", oResponse, "graphs")   ' Getting a list of graphs 
  oGraph = oScriptControl.RUN("getValByIndex", oGraphs, 0)           ' Getting the first graph in the list
  oArray = oScriptControl.RUN("getValByKey", oGraph, "array")        ' Getting the array of values of the first graph 
  arrayLength = oScriptControl.RUN("getLength", oArray)              ' Obtaining the length of the array
  oSheet = ThisComponent.GetCurrentController.ActiveSheet            ' Obtaining current sheet
  FOR i = 0 TO arrayLength-1                                         ' Populating the sheet with the values of the array
    oRow = oScriptControl.RUN("getValByKey", oArray, i)
    timeInSec = oScriptControl.RUN("getValByIndex", oRow, 0)
    cost = oScriptControl.RUN("getValByIndex", oRow, 1)
    oCell = oSheet.getCellByPosition(1,i)
    oCell.value = timeInSec
    oCell = oSheet.getCellByPosition(2,i)
    oCell.value = cost
  NEXT i    
End Sub

