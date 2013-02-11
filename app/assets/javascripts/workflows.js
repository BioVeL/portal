  function showonlyone(selected_div, selected_tab) {
      var wf_part_divs = document.getElementsByTagName("div");
            for(var x=0; x<wf_part_divs.length; x++) {
                  name = wf_part_divs[x].getAttribute("class");
                  if (name == 'workflow_part') {
                        if (wf_part_divs[x].id == selected_div) {
                        wf_part_divs[x].style.display = 'block';
                  }
                  else {
                        wf_part_divs[x].style.display = 'none';
                  }
            }
      }
      var wf_part_tabs = document.getElementsByTagName("li");
      for(var y=0; y<wf_part_tabs.length; y++) {
        name = wf_part_tabs[y].getAttribute("class");
        if (name == 'wf_tab') {
          if (wf_part_tabs[y].id == selected_tab) {
            wf_part_tabs[y].style.background = 'hsla(80, 90%, 40%, 0.7)';
          }
          else {
            wf_part_tabs[y].style.background = 'hsla(120, 100%, 50%, 0.7)';
          }
        }
      }
  }
  function showhide(showHideDiv, switchTextDiv) {
	var ele = document.getElementById(showHideDiv);
	var text = document.getElementById(switchTextDiv);
	if(ele.style.display == "block") {
    		ele.style.display = "none";
		text.innerHTML = "more";
  	}
	else {
		ele.style.display = "block";
		text.innerHTML = "less";
	}
  }
