
(function() {
  jQuery(function() {
    return $('#credentials-table').dataTable({
      sPaginationType: "full_numbers",
      "iDisplayLength": 10,
      "bJQueryUI": true,
      "aoColumnDefs": [
        { "bSortable": false, "aTargets": [ -1 ] }
    ]
    });
  });
}).call(this);
