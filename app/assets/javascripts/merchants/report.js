$(document).ready(function(){
  $(".report_connection_link").click(function(){
    alert("caeeeeed");
    var $link = $(this);
    var url = $link.next('input[type="hidden"]').val();
    $.ajax({
      url: url,
      type: 'GET',
      success: function (data) {
        $('#reportDialog').modal('show')
        $('#reportDialog').html(data);
      },
      error: function (jqXHR, textStatus, errorThrown)
      {
        alert(errorThrown)
      }
    });
  });
});