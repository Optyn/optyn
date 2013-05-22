$(document).ready(function(){
	$('.howmany').slider({
	    range: "min",
	    min:0,
	    max:3000,
	    value: 10,
	    slide: function (event, ui) {
	        var quantity = ui.value;
	        // clear all row styles
	        $("#pricing-table tbody tr").each(function(){
	        	$(this).css('background-color','none')
	        })

	        // highlight new row
	        if(quantity <= 100) {
	        	$("#pricing-table tbody tr:nth-child(0)").css('background-color','#e4e3e3')
	        }
	        else if(quantity <= 500) {
	        	$("#pricing-table tbody tr:nth-child(1)").css('background-color','#e4e3e3')
	        }
	        else if(quantity <= 1000) {
	        	$("#pricing-table tbody tr:nth-child(2)").css('background-color','#e4e3e3')	
	        }
	        else if(quantity <= 2500) {
	        	$("#pricing-table tbody tr:nth-child(3)").css('background-color','#e4e3e3')
	        }
	        else if(quantity <= 3000) {
	        	$("#pricing-table tbody tr:nth-child(4)").css('background-color','#e4e3e3')
	        }
	        $(".quantity").html(quantity)
	    }
	})
})
