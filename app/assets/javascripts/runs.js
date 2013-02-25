  function uploadFile(fileList, targetName) {
    if (fileList == null) { return; }
    var file = fileList[0];
    var reader = new FileReader();
    reader.onload = function(evt) {
      document.getElementById(targetName).value = evt.target.result;
    };
    reader.readAsText(file);
  }

(function() {

  jQuery(function() {
    return $('#runs_table').dataTable({
      //sPaginationType: "full_numbers",
      "iDisplayLength": 10,
      "bFilter": false,
      "bLengthChange": false,
      "bRetrieve": true,
      "bJQueryUI": true
    });
  });

}).call(this);


     
