Sub Table
  fileName = "1km_road_api.001.sprj"    ' Please prepend with the full path

  oScriptControl = CreateObject("MSScriptControl.ScriptControl")    ' An object to parse JSON responses of the Spider Project's API server
  oScriptControl.Language = "JScript"
  oScriptControl.AddCode "function getVal(jsonObj, propertyName) { return (propertyName in jsonObj) ? jsonObj[propertyName] : """"; }"
  oScriptControl.AddCode "function getValByIndex(jsonObj, index) { return (jsonObj.length > index) ? jsonObj[index] : """"; }"
  oScriptControl.AddCode "function getLength( jsonObj ) { return jsonObj.length; }"

  oRequest = CreateObject("WinHttp.WinHttpRequest.5.1")    ' Object to make requests
  oRequest.Open "POST", "http://localhost:8080", false     ' Specifying Spider Project API server name and port
  oRequest.SetTimeouts 0, 0, 0, 0                          ' Waiting for reponse infinitely                                                                      

  oRequest.Send "{ ""command"":""openFile"", ""fileName"": """ + fileName + """ }"
  oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")    

  oRequest.Send "{ ""command"":""getTableHandle"", ""docHandle"":""" + oResponse.docHandle + """, ""table"":""GanttAct"" }"
  oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")    

  oRequest.Send "{ ""command"":""getTable"", ""tableHandle"":""" + oResponse.tableHandle + """ }"
  oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")    

  oArray = oScriptControl.RUN("getVal", oResponse, "array")
  arrayLength = oScriptControl.RUN("getLength", oArray)
  oSheet = ThisComponent.GetCurrentController.ActiveSheet
  FOR i = 0 TO arrayLength-1
    oRow = oScriptControl.RUN("getValByIndex", oArray, i)
    durSum = oScriptControl.RUN("getVal", oRow, "DurSum")
    oCell = oSheet.getCellByPosition(0,i)
    oCell.value = durSum
  NEXT i    
End Sub