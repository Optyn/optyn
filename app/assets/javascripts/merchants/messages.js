$(document).ready(function () {
    var merchantMessage = new MerchantMessage();
    merchantMessage.initialize();
});

function MerchantMessage() {
    this.initialize = function () {
        if ($('#message_fields_wrapper').length) {
            this.hookChosen();
            this.hookActionEvent();
            this.hookDateTimePicker();
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

    this.hookDateTimePicker = function(){
        var todaysDate = new Date();
        var sixMonthsSince = new Date(new Date(todaysDate).setMonth(todaysDate.getMonth() + 3));

        $('.date-time-picker').datetimepicker({
            language: 'en',
            pick12HourFormat: true,
            pickSeconds: false,
            startDate: new Date(),
            endDate: sixMonthsSince
        })
    };
}