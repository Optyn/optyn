$(document).ready(function () {
    var label = new Label();
    label.initialize();
});


function Label() {
    this.initialize = function () {
        if ($('#add_user .chzn-select').length) {
            this.hookChosen();
            this.hookAddNewLabel();
        }
    };

    this.hookChosen = function () {
        $('.chzn-select').chosen();
    };

    this.hookAddNewLabel = function () {
        $('body').on('keydown', '.search-field input', function (e) {
            var $input = $(this);
            var code = e.keycode || e.which;
            if (code == 13) {
                var inputVal = $input.val();
                if (inputVal.length) {
                    var $currentLabel = $input.parents('.labels').first();
                    var $currentSelect = $currentLabel.find('select');

                    $.ajax({
                        url: $('#create_label_users_path').val(),
                        type: 'POST',
                        data: {label: inputVal},
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
}