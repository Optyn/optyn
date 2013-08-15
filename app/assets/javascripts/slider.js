$(function(){

    $('.howmany').slider({
        range: "min",
        min: 1,
        max: 25000,
        value: 0,
        slide: function(event, ui){

            $('.numberofcustomers').text(ui.value);
            function highlightRow(index){
                var row = '.pricingList > li';
                $(row).removeClass('selected');
                $(row).hide();
                $(row+':nth-child('+index+')').addClass('selected').show();
                $(row+'.selected').next().show();
                $(row+'.selected').next().next().show();
                $(row+'.selected').prev().show();
                $(row+'.selected').prev().prev().show();
            }

            switch (true) {
                case ((ui.value === 0)):
                    highlightRow(0);
                    break;
                case ((ui.value > 0) && (ui.value <= 100)):
                    highlightRow(1);
                    break;
                case ((ui.value >= 101) && (ui.value <= 1000)):
                    highlightRow(2);
                    break;
                case ((ui.value >= 1001) && (ui.value <= 2500)):
                    highlightRow(3);
                    break;
                case ((ui.value >= 2501) && (ui.value <= 5000)):
                    highlightRow(4);
                    break;
                case ((ui.value >= 5001) && (ui.value <= 10000)):
                    highlightRow(5);
                    break;
                case ((ui.value >= 10001) && (ui.value <= 15000)):
                    highlightRow(6);
                    break;
                case ((ui.value >= 15001) && (ui.value <= 20000)):
                    highlightRow(7);
                    break;
                case ((ui.value >= 20001) && (ui.value <= 25000)):
                    highlightRow(8);
                    break;
              default:
                //Default Case
            }
        }
    });
});