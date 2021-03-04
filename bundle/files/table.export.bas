Sub TableExport
  fileName = "1km_road_api.001.sprj"

  oScriptControl = CreateObject("MSScriptControl.ScriptControl")
  oScriptControl.Language = "JScript"  
  oScriptControl.AddCode "function getVal(jsonObj, propertyName) { return (propertyName in jsonObj) ? jsonObj[propertyName] : """"; }"
  oScriptControl.AddCode "function getValByIndex(jsonObj, index) { return (jsonObj.length > index) ? jsonObj[index] : """"; }"
  oScriptControl.AddCode "function getLength( jsonObj ) { return jsonObj.length; }"
  oScriptControl.AddCode "function hasKey( jsonObj, key ) { return key in jsonObj; }"
  oScriptControl.AddCode "function getKeys( obj ) { var keys = new Array(); for(var i=0 ; i < obj.length ; i++) { keys.push(obj[i].Code); } return keys; } "
  oScriptControl.AddCode "function getNames( obj ) { var names = new Array(); for(var i=0 ; i < obj.length ; i++) { names.push(obj[i].Name); } return names; } "
  oScriptControl.AddCode "function getTypes( obj ) { var types = new Array(); for(var i=0 ; i < obj.length ; i++) { types.push(obj[i].Type); } return types; } "

  oRequest = CreateObject("WinHttp.WinHttpRequest.5.1")  ' Object to make requests
  oRequest.Open "POST", "http://localhost:8080", false  ' Specifying Spider Project API server name and port
  oRequest.SetTimeouts 0, 0, 0, 0             ' Waiting for reponse infinitely                                                                      

  oRequest.Send "{ ""command"":""openFile"", ""fileName"": """ + fileName + """ }"
  oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")    

  oRequest.Send "{ ""command"":""getTableHandle"", ""docHandle"":""" + oResponse.docHandle + """, ""table"":""GanttAct"" }"
  oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")    

  oRequest.Send "{ ""command"":""getTable"", ""tableHandle"":""" + oResponse.tableHandle + """ }"
  oResponse = oScriptControl.Eval("(" + oRequest.ResponseText + ")")

  ' Obtaining column keys, names and types 
  oFields = oScriptControl.RUN("getVal", oResponse, "fields")  
  oKeys = oScriptControl.RUN("getKeys", oFields)
  keysNumber = oScriptControl.RUN("getLength", oKeys)
  oTypes = oScriptControl.RUN("getTypes", oFields)
  oNames = oScriptControl.RUN("getNames", oFields)

  ' Creating header: filling the first row of the sheet with key names
  oSheet = ThisComponent.GetCurrentController.ActiveSheet
  FOR i = 0 TO keysNumber-1
    oCell = oSheet.getCellByPosition(i,0)
    oCell.String = oScriptControl.RUN("getValByIndex", oNames, i) & " (" & oScriptControl.RUN("getValByIndex", oKeys, i) & ")"
  NEXT i

  oArray = oScriptControl.RUN("getVal", oResponse, "array")
  arrayLength = oScriptControl.RUN("getLength", oArray)
  FOR j = 0 TO arrayLength-1                                    ' Looping through the data array row by row
    oRow = oScriptControl.RUN("getValByIndex", oArray, j)     ' Obtaining a row
    FOR i = 0 TO keysNumber-1                                 ' Looping through a row column by column
      key = oScriptControl.RUN("getValByIndex", oKeys, i)   ' Obtaining a key
      IF oScriptControl.RUN("hasKey", oRow, key) THEN       ' If the row has the key...
        value = oScriptControl.RUN("getVal", oRow, key)   ' ...obtaining it
        oCell = oSheet.getCellByPosition(i,j+1)           
        valueType = oScriptControl.RUN("getValByIndex", oTypes, i)  ' Obtaining the type of the value
        IF valueType = "number" THEN 
          oCell.value = value
        ELSE 
          oCell.String = value
        END IF
      END IF
    NEXT i
  NEXT j  
End Sub