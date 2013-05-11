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
	        	$(this).css('border','none')
	        })

	        // highlight new row
	        if(quantity <= 100) {
	        	$("#pricing-table tbody tr:nth-child(0)").css('border','3px solid red')
	        }
	        else if(quantity <= 500) {
	        	$("#pricing-table tbody tr:nth-child(1)").css('border','3px solid red')
	        }
	        else if(quantity <= 1000) {
	        	$("#pricing-table tbody tr:nth-child(2)").css('border','3px solid red')	
	        }
	        else if(quantity <= 2500) {
	        	$("#pricing-table tbody tr:nth-child(3)").css('border','3px solid red')
	        }
	        else if(quantity <= 3000) {
	        	$("#pricing-table tbody tr:nth-child(4)").css('border','3px solid red')
	        }
	        $(".quantity").html(quantity)
	    }
	})
})
