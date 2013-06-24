// $(document).ready(function(){
// 	$('.howmany').slider({
// 	    range: "min",
// 	    min:0,
// 	    max:3000,
// 	    value: 10,
// 	    slide: function (event, ui) {
// 	        var quantity = ui.value;
// 	        // clear all row styles
// 	        $("#pricing-table tbody tr").each(function(){
// 	        	$(this).css('background-color','none')
// 	        })

// 	        // highlight new row
// 	        if(quantity <= 100) {
// 	        	$("#pricing-table tbody tr:nth-child(0)").css('background-color','#e4e3e3')
// 	        }
// 	        else if(quantity <= 500) {
// 	        	$("#pricing-table tbody tr:nth-child(1)").css('background-color','#e4e3e3')
// 	        }
// 	        else if(quantity <= 1000) {
// 	        	$("#pricing-table tbody tr:nth-child(2)").css('background-color','#e4e3e3')	
// 	        }
// 	        else if(quantity <= 2500) {
// 	        	$("#pricing-table tbody tr:nth-child(3)").css('background-color','#e4e3e3')
// 	        }
// 	        else if(quantity <= 3000) {
// 	        	$("#pricing-table tbody tr:nth-child(4)").css('background-color','#e4e3e3')
// 	        }
// 	        $(".quantity").html(quantity)
// 	    }
// 	})
// })


$(function(){
	$('.numberofcustomers').text(10);
  	var row = '#pricing-table > tbody > tr';

  	function highlight(index){
  		$(row).removeClass('selected');
  		$(row+':nth-child('+index+')').addClass('selected');
  	}

  	$('.howmany').slider({
	    range: "min",
	    min: 10,
 	    max: 3000,
	    value: 10,
        slide: function( event, ui ) {
          $('.numberofcustomers').html(ui.value);

		if((ui.value > 100) && (ui.value < 500)){
			highlight(1);
          }
          else if((ui.value > 500) && (ui.value <= 1000)){
            highlight(2);
          }
          else if((ui.value > 1000) && (ui.value <= 2500)){
			highlight(3);
          }
          else if((ui.value > 2500) && (ui.value <= 3000)){
			highlight(4);
          }
          else {
            $(row).removeClass('selected');
          } 
       }
    });
});