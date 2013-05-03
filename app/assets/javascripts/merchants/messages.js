$(document).ready(function () {
    var merchantMessage = new MerchantMessage();
    merchantMessage.initialize();
});

function MerchantMessage() {
    var current = this;

    this.initialize = function () {

        if ($('#message_fields_wrapper').length) {
            this.hookChosen();
            this.hookActionEvent();
            this.hookDateTimePicker();
        }

        if ($('#messages_collection_container').length) {
            this.hookCollectionSubmission();
            this.hookCheckUncheckAll();
            this.hookAllAutoCheckUncheckSelectAll();
        }

        if ($('.message-list').length) {
            this.hookCellClick();
        }

        if ($('#message_meta_modal')) {
            this.hookMetadataSubmit();
        }
    };

    this.hookChosen = function () {
        $('.chzn-select').chosen();
    };

    this.hookActionEvent = function () {
        $('#message_form .btn').click(function (event) {
            $('#choice').val($(this).attr('name'));
        });
    };

    this.hookDateTimePicker = function () {
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

    this.hookCollectionSubmission = function () {
        $('.collection-action').click(function () {
            var checkboxValues = new Array();

            $('.message-list').find('input.real:checked').each(function () {
                checkboxValues.push($(this).val());
            });


            if (checkboxValues.length > 0) {
                $('#messages_collection_form').prop('action', $('#' + $(this).prop('name') + '_link').val());
                $('#messages_collection_container').find('#message_ids').val(checkboxValues.join(","));
                $('#messages_collection_form').submit();

            }
        });
    };

    this.hookCheckUncheckAll = function () {
        $('.message-list .select-all').click(function () {
            var isSelectAllChecked = $(this).is(':checked');
            var $cbs = $('.message-list .real');
            $cbs.each(function (index, element) {
                if (!$(element).prop('disabled')) {
                    if (isSelectAllChecked) {
                        $(element).prop('checked', true);
                    } else {
                        $(element).prop('checked', false);
                    }
                }
            });
        });
    };

    this.hookAllAutoCheckUncheckSelectAll = function () {
        $('.message-list .real').click(function () {
            var $selectAll = $('.message-list .select-all');
            $selectAll.prop('checked', false);
        })
    };

    this.hookCellClick = function () {
        $('.message-list tr td.show-link').click(function () {
            var link = $(this).parents('tr').find('td.show-link-address').text();
            window.location = link;
        });
    };

    this.hookMetadataSubmit = function () {
        $('body').on('click', '#message_meta_modal .btn-primary', function (e) {
            e.preventDefault();
            $.ajax({
                url: $('#message_meta_modal form').prop('action'),
                type: 'POST',
                data: $('#message_meta_modal').find('form').serialize(),
                success: function (data) {
                    $('#message_meta_modal').modal('hide');
                    setTimeout(function () {
                        $('#message_meta_data').replaceWith(data.message);
                        current.hookDateTimePicker();
                    }, 1000);

                },
                error: function (data) {
                    var $modal = $('#message_meta_modal');
                    $modal.modal('hide');
                    $modal.html($.parseJSON(data.responseText).message);
                    setTimeout(function () {
                        current.hookDateTimePicker();
                        $('#message_meta_modal').modal('show');
                        moveDatetimepickerErrorMessage();
                    }, 500);
                }
            });
        });
    };
}