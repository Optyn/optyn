$(document).ready(function () {
    var merchantMessage = new MerchantMessage();
    merchantMessage.initialize();
});

function MerchantMessage() {
    this.initialize = function () {
        if ($('#message_fields_wrapper').length) {
            this.hookWysihtml5();
            this.hookDatetimepicker();
        }
    };

    this.hookWysihtml5 = function () {
        $('#message_fields_wrapper .details').wysihtml5();
    };

    this.hookDatetimepicker = function(){
      $('#message_send_on_wrapper').datetimepicker({
          language: 'en',
          pick12HourFormat: true,
          pickSeconds: false,
          startDate: new Date()
      });
    };
}