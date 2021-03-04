Sub Table()
  Dim oScriptControl, oRequest, oResponse, oArray, oRow As Object
  Dim arrayLength, arrayIndex As Integer
  Dim durSum As Double
  Dim fileName As String
  
  fileName = "1km_road_api.001.sprj"    ' Please prepend with the full path
    
  Set oScriptControl = CreateObject("MSScriptControl.ScriptControl")  ' An object to parse JSON responses of the Spider Project's API server
  oScriptControl.Language = "JScript"
  oScriptControl.AddCode "function getVal(jsonObj, propertyName) { return (propertyName in jsonObj) ? jsonObj[propertyName] : """"; }"
  oScriptControl.AddCode "function getValByIndex(jsonObj, index) { return (jsonObj.length > index) ? jsonObj[index] : """"; }"
  oScriptControl.AddCode "function getLength( jsonObj ) { return jsonObj.length; }"

  Set oRequest = CreateObject("WinHttp.WinHttpRequest.5.1") ' An object to make requests to the Spider Project's API server
  oRequest.Open "POST", "http://localhost:8080", False  ' Initiating a connection to the server
  oRequest.SetTimeouts 0, 0, 0, 0 'wait infinitely

  oRequest.Send "{ ""command"":""openFile"", ""fileName"": """ + fileName + """ }"
  Set oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")

  oRequest.Send "{ ""command"":""getTableHandle"", ""docHandle"":""" + CStr(oResponse.docHandle) + """, ""table"":""GanttAct"" }"
  Set oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")

  oRequest.Send "{ ""command"":""getTable"", ""tableHandle"":""" + CStr(oResponse.tableHandle) + """ }"
  Set oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")

  Set oArray = oScriptControl.Run("getVal", oResponse, "array")
  arrayLength = oScriptControl.Run("getLength", oArray)
  For arrayIndex = 0 To arrayLength - 1
    Set oRow = oScriptControl.Run("getValByIndex", oArray, arrayIndex)
    durSum = oScriptControl.Run("getVal", oRow, "DurSum")
    ActiveSheet.Cells(arrayIndex + 1, 2).Value = durSum
  Next arrayIndex
End Sub