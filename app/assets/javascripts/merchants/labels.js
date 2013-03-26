$(document).ready(function () {
    var label = new Label();
    label.initialize();
});


function Label() {
    this.initialize = function () {
        if ($('.chzn-select').length) {
            this.hookChosen();
            this.hookAddNewLabel();
            this.hookChangeChosen();
        }
    };

    this.hookChosen = function () {
        $('.chzn-select').chosen();
    };

    this.hookAddNewLabel = function () {
        $('input.default').bind('keypress', function (e) {
            var $input = $(this);
            var code = e.keyCode || e.which;
            if (code == 13) {
                console.log("Enter captured");
                var inputVal = $input.val();
                if (inputVal.length) {
                    var $currentLabel = $input.parents('.labels').first();
                    var $currentSelect = $currentLabel.find('select');

                    $.ajax({
                        url: $('#create_label_merchants_survey_survey_answers_path').val(),
                        type: 'POST',
                        data: {label: inputVal, user_id: $currentLabel.find('.user_id').val()},
                        success: function (data) {
                            $('.chzn-select').append(
                                $('<option></option>')
                                    .val(data.id)
                                    .html(data.name)
                            );
                            $currentSelect.find('option[value="' + data.id + '"]').attr('selected', 'selected');
                            $('.chzn-select').trigger("liszt:updated");
                        }
                    });
                }
//                else{
//                    console.log("Input Val: ", inputVal);
//                    console.log("Captured entered but request made");
//                }
            }
        });
    };

    this.hookChangeChosen = function () {
        $('.chzn-select').chosen().change(function(){
            var $select = $(this);

            $.ajax({
               url: $('#update_labels_merchants_survey_survey_answers_path').val(),
               type: 'POST',
               data: {user_id: $select.parent().find('.user_id').val(), label_ids: $select.val()}
            });
        });
    };
}