# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
  function uploadFile(fileList, targetName) {
    if (fileList == null) { return; }
    var file = fileList[0];
    var reader = new FileReader();
    reader.onload = function(evt) {
      document.getElementById(targetName).value = evt.target.result;
    };
    reader.readAsText(file);
  }
