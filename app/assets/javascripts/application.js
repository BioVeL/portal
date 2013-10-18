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
//     Robert Haines
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
// -----------------------------------------------------------------------------
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery_ujs
//= require jquery.ui.button
//= require jquery.ui.tabs
//= require jquery.ui.accordion
//= require dataTables/jquery.dataTables
//= require_tree .

// This class ("pre-filled") handles the text selection policy of pre-filled
// form elements.
//
// When the pre-filled value is still unedited select all text upon first
// click, then never select all again unless moving away from the element,
// then back again. Also, once the original value has been changed, don't
// select all.
$(document).ready(function() {
  $('.pre-filled').each(function() {
    var original_value = this.value
    var selected = false

    $(this).select(function() {
      selected = true
    });

    $(this).blur(function() {
      selected = false;
    });

    $(this).click(function() {
      if (selected == false && this.value == original_value) {
        $(this).select();
      }
    });
  });
});
