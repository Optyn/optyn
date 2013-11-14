$(document).ready(function () {
    var shop = new Shop();
    shop.initialize();
    shop.checkIdentifier($('#shop_identifier'))
});

function Shop() {
    this.initialize = function () {
        if ($('#update_shop_wrapper').length) {
            this.setTimeZone();
            this.hookChosen();
            this.hookIdentifierKeyup();
        }

        if($('#affiliate_tracking_frame').length){
            $('#affiliate_tracking_frame').on('load', function(){
                $.ajax({
                    url: $('#update_affiliate_tracking_merchants_shop_path').val(),
                    type: 'POST',
                    data: {'_method' : 'put'}
                })
            });
        }
    };

    this.setTimeZone = function(){
        if($('#shop_time_zone').val()){
            if(!($('#shop_time_zone').val().length)){
               var tz = jstz.determine();
               var tzinfo = tz.name();
               var mapping = JSON.parse($('#timezone_mapping').val());
               var detection = null;

               $(mapping).each(function(){  
                 
                 if($(this).last()[0].match(tzinfo)){
                    detection = $(this).first()[0];
                    return false;
                 }
               });

               $("#shop_time_zone").val('');
               $("#shop_time_zone option").each(function(index, element){
                 if($(element).val() === detection){
                    $(element).prop('selected', 'selected');
                    return false;
                 }
               });
            }
        }
    };

    this.hookChosen = function () {
        // Hook the 'Chosen' plugin selection
        $('.chzn-select').chosen({
            allow_single_deselect: true,
            no_results_text: 'No results matched'
        });
    };

    this.hookIdentifierKeyup = function () {
        var current = this;
        $(document).on('keyup', '#shop_identifier', function (event) {
            current.checkIdentifier($(this))
        });
    };

    this.checkIdentifier = function ($input) {
        if ($('#update_shop_wrapper').length) {
            $.ajax({
                url: $('#check_identifier_merchants_shop_path').val(),
                type: 'GET',
                data: {q: $input.val()},
                beforeSend: function () {
                    $('#loading').show();
                    $('#loading').removeClass('success');
                    $('#loading').removeClass('error');
                    $('#loading .text').text('Loading...');
                },
                success: function (data) {
                    $('#loading').addClass('success');
                    $('#loading .text').text('Your ID is Available');
                },
                error: function () {
                    $('#loading').addClass('error');
                    $('#loading .text').text('Your ID is Unavailable. Please choose another.');
                }
            });
        }
    }
}
