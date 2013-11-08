$(document).ready(function(){
  $('div#merchants span.expandable').expander({
    slicePoint:       50,  // default is 100
    expandPrefix:     ' ', // default is '... '
    expandText:       '[...]', // default is 'read more'
    userCollapseText: '[^]'  // default is 'read less'
  });

  $(".open-infoDialog").click(function(){ // Click to only happen on more info links
     //$("#dialogId").val($(this).data('id'));
     //var userId = $(".open-infoDialog").val($(this).data('id'))
    var id = $(this).attr('id');
    $.ajax({
      url: $('#show_path_' + id).val(),
      type: 'GET',
      success: function (data) {
        $("#infoDialog_" + id).html( data );
      }
    });
    $('#infoDialog_' + id).modal('show');
  });

  $(".edit_user").click(function(){
    var id = $(this).attr('id');
    $.ajax({
      url: $('#edit_path_' + id).val(),
      type: 'POST',
      success: function (data) {
        $("#infoDialog_" + id + " .modal-body").html( data );
      }
    });
  });

  $(".update_user").click(function(){
    var id = $(this).attr('id');
    var form_url = $("#edit_user_form").attr('action');
    $.ajax({
      url: form_url,
      type: 'POST',
      data: {name: $("#user_name").val(), email: $("#user_email").val()},
      success: function (data) {
        if(data.search("User updated successfully.") != '-1')
        {
          alert(data)
          window.location.replace(window.location.pathname);
        }
        else
          $("#infoDialog_" + id + " .modal-body").html( data );
      },
      error: function (jqXHR, textStatus, errorThrown)
      {
        alert(errorThrown)
      }
    });
  });
});