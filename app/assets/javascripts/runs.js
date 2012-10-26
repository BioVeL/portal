  function uploadFile(fileList, targetName) {
    if (fileList == null) { return; }
    var file = fileList[0];
    var reader = new FileReader();
    reader.onload = function(evt) {
      document.getElementById(targetName).value = evt.target.result;
    };
    reader.readAsText(file);
  }
