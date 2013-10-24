$(document).ready(function(){
   $(".open-infoDialog").click(function(){ // Click to only happen on more info links
     //$("#dialogId").val($(this).data('id'));
     //var userId = $(".open-infoDialog").val($(this).data('id'));
     $('#infoDialog').modal('show');
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