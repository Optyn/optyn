$(document).ready(function () {
    var label = new Label();
    label.initialize();
});


function Label() {
    this.initialize = function () {
        if ($('#user_label_list .chzn-select').length) {
            this.hookChosen();
            this.hookAddNewLabel();
            this.hookChangeChosen();
            if($('#user_label_list .chzn-select').length > 0)
              $('div.labels div.chzn-container').width(500);
        }
    };

    this.hookChosen = function () {
        $('.chzn-select').chosen();
    };

    this.hookAddNewLabel = function () {
        $('body').on('keydown', '#user_label_list .search-field input', function (e) {
            var $input = $(this);
            var code = e.keycode || e.which;
            if (code == 13) {
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
            }
        });
    };

    this.hookChangeChosen = function () {
        $('#user_label_list .chzn-select').chosen().change(function(){
            var $select = $(this);

            $.ajax({
               url: $('#update_labels_merchants_survey_survey_answers_path').val(),
               type: 'POST',
               data: {user_id: $select.parent().find('.user_id').val(), label_ids: $select.val()}
            });
        });
    };
}