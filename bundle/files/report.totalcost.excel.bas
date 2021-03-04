Sub ReportTotalCost()
  Dim oScriptControl, oRequest, oResponse, oArray, oGraphs, oGraph, oRow As Object
  Dim arrayLength, arrayIndex As Integer
  Dim timeInSec, cost As Double
  Dim fileName, phaseHandle, docHandle, templateHandle As String
  
  fileName = "1km_road_api.001.sprj"    ' Please prepend with the full path
  
  Set oScriptControl = CreateObject("MSScriptControl.ScriptControl")  ' An object to parse JSON reponse of the Spider Project's API server
  oScriptControl.Language = "JScript"
  oScriptControl.AddCode "function getValByKey(jsonObj, key) { return (key in jsonObj) ? jsonObj[key] : """"; }"
  oScriptControl.AddCode "function getValByIndex(jsonObj, index) { return (jsonObj.length > index) ? jsonObj[index] : """"; }"
  oScriptControl.AddCode "function getLength( jsonObj ) { return jsonObj.length; }"

  Set oRequest = CreateObject("WinHttp.WinHttpRequest.5.1")   ' An object to make requests to SPI server
  oRequest.Open "POST", "http://localhost:8080", False        ' Initiating a request
  oRequest.SetTimeouts 0, 0, 0, 0                             ' Waiting for reponse infinitely

  oRequest.Send "{ ""command"":""openFile"", ""fileName"": """ + fileName + """ }"
  Set oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")
  docHandle = oResponse.docHandle

  oRequest.Send "{ ""command"":""getObjectHandle"", ""docHandle"":""" + CStr(docHandle) + """, ""table"":""GanttAct"", ""index""=""0"" }"
  Set oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")
  phaseHandle = oResponse.objectHandle

  oRequest.Send "{ ""command"":""getObjectHandle"", ""docHandle"":""" + CStr(docHandle) + """, ""table"":""ReportSpend"", ""code""=""TotalCost"" }"
  Set oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")
  templateHandle = oResponse.objectHandle
  
  oRequest.Send "{ ""command"":""getReport"", ""objectHandle"":""" + CStr(phaseHandle) + """, ""templateHandle"":""" + templateHandle + """ }"
  Set oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")

  Set oGraphs = oScriptControl.Run("getValByKey", oResponse, "graphs")  ' Getting a list of graphs
  Set oGraph = oScriptControl.Run("getValByIndex", oGraphs, 0)          ' Getting the first graph in the list
  Set oArray = oScriptControl.Run("getValByKey", oGraph, "array")       ' Getting the array of values of the first graph
  arrayLength = oScriptControl.Run("getLength", oArray)                 ' Getting the length of the array
  For arrayIndex = 0 To arrayLength - 1                                 ' Populating the sheet with the values of the array: "time", "cost"
    Set oRow = oScriptControl.Run("getValByKey", oArray, arrayIndex)
    timeInSec = oScriptControl.Run("getValByIndex", oRow, 0)
    cost = oScriptControl.Run("getValByIndex", oRow, 1)
    ActiveSheet.Cells(arrayIndex + 1, 1).Value = timeInSec
    ActiveSheet.Cells(arrayIndex + 1, 2).Value = cost
  Next arrayIndex
End Sub
