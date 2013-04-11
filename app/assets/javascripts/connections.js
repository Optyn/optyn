// $(document).ready(function(){
//     $('a#optyn_btn').click(function(){
//         $(this).toggleClass("down");
//     });
// });
$(document).ready(function(){
	$("a.optyn_btn").click(function(event){
		var shopId = $(this).data("shop");
		var self = this;
		$.ajax({
		  type: 'POST',
		  dataType: "json",
		  url: "/connections/add_connection",  
		  data:{shop_id:shopId} ,
		  
		  success: function(data) { 
		    if(data.success == false)
		    	alert(data.error_message);	
		    $(self).text(data.success_text);
		 	}
		});	
		event.preventDefault();
	});
	$(".open-shopDialog").click(function(){ // Click to only happen on more info links
	 $('#shopDialog').modal('show');
	});

});
