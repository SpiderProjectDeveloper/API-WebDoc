function exportTable() {
  var server = 'http://000.000.000.000:8080';		// Specify the valid ip address and port
  var fileName = '1km_road_api.001.sprj'; 	// Put a valid path to your project

  var options={};
  options.mathod = 'post';
  options.payload = JSON.stringify({ command: 'openFile', fileName: fileName });
  var response = UrlFetchApp.fetch(server, options);
  var oResponse = JSON.parse(response);
  
  options.payload = JSON.stringify({ command:'getTableHandle', docHandle: oResponse.docHandle.toString(), table:'GanttAct' });
  response = UrlFetchApp.fetch(server, options);
  oResponse = JSON.parse(response);

  options.payload = JSON.stringify({ command:'getTable', tableHandle: oResponse.tableHandle.toString(), filter: 'Level<=3' });
  response = UrlFetchApp.fetch(server, options);
  oResponse = JSON.parse(response);
  
  var codes=[];
  var header = [];	// The header row 
  for( var i = 0 ; i < oResponse.fields.length ; i++ ) {
    codes.push(oResponse.fields[i].Code);
    header.push(oResponse.fields[i].Name + '(' + oResponse.fields[i].Code + ')');    
  }
  var colNum = codes.length;
  
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  sheet.getRange(1, 1, 1, colNum ).setValues([header]); 	// Writing the header row
  sheet.getRange(1, 1, 1, colNum ).setFontWeight('bold'); 	// Making it bold
  
  for( var row = 0 ; row < oResponse.array.length ; row++ ) {
    var values = [];
    for( var col = 0 ; col < colNum ; col++ ) {
      var key = codes[col];
      values.push( oResponse.array[row][key] );
    }      
    sheet.getRange(row+2, 1, 1, colNum ).setValues([values]); 	// Writing a row
  }
}
