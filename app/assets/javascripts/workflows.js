// Copyright (c) 2012-2013 Cardiff University, UK.
// Copyright (c) 2012-2013 The University of Manchester, UK.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// 
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// 
// * Neither the names of The University of Manchester nor Cardiff University nor
//   the names of its contributors may be used to endorse or promote products
//   derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// 
// Authors
//     Abraham Nieva de la Hidalga
// 
// Synopsis 
// 
// BioVeL Taverna Lite  is a prototype interface to Taverna Server which is 
// provided to support easy inspection and execution of workflows.
// 
// For more details see http://www.biovel.eu
// 
// BioVeL is funded by the European Commission 7th Framework Programme (FP7),
// through the grant agreement number 283359. 
(function() {
  jQuery(function() {
    return $('#public_workflows').dataTable({
      //sPaginationType: "full_numbers",
      "iDisplayLength": 10,
      "bFilter": false,
      "bLengthChange": false,
      "bJQueryUI": true,
     "aoColumnDefs": [
        { "bSortable": false, "aTargets": [ -1 ] }
    ]
    });
  });
}).call(this);
(function() {
  jQuery(function() {
    return $('#private_workflows').dataTable({
      //sPaginationType: "full_numbers",
      "iDisplayLength": 10,
      "bFilter": false,
      "bLengthChange": false,
      "bJQueryUI": true
    });
  });
}).call(this);
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
