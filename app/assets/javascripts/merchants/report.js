$(document).ready(function(){
  $(".report_connection_link").click(function(){
    $('#reportDialog').modal('show')
    var $link = $(this);
    var url = $link.next('input[type="hidden"]').val();
    $.ajax({
      url: url,
      type: 'GET',
      success: function (data) {
        $('#reportDialog').html(data);
      },
      error: function (jqXHR, textStatus, errorThrown)
      {
        alert(errorThrown)
      }
    });
  });
});