$(document).ready(function(){
   $(".open-infoDialog").click(function(){ // Click to only happen on more info links
     //$("#dialogId").val($(this).data('id'));
     //var userId = $(".open-infoDialog").val($(this).data('id'));
     $('#infoDialog').modal('show');
   });
});