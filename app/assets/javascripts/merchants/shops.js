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
    };

    this.setTimeZone = function(){
        var tz = jstz.determine();
        var tz1 = tz.name();
        var timezone = tz1.split('/').pop();
        $("#shop_time_zone").val(timezone);
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
                    $('#loading .text').text('Available');
                },
                error: function () {
                    $('#loading').addClass('error');
                    $('#loading .text').text('Unavailable');
                }
            });
        }
    }
}
