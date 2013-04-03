$(document).ready(function () {
    var merchantMessage = new MerchantMessage();
    merchantMessage.initialize();
});

function MerchantMessage() {
    this.initialize = function () {
        if ($('#message_fields_wrapper').length) {
            this.hookChosen();
            this.hookActionEvent();
        }
    };

    this.hookChosen = function(){
        $('.chzn-select').chosen();
    };

    this.hookActionEvent = function(){
       $('#message_form .btn').click(function(event){
          $('#choice').val($(this).attr('name'));
       });
    };
}