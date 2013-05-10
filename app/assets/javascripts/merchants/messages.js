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

        if ($('#response_message_section').length) {
            this.hookCreateResponseMessage();
            this.hookDiscardChildMessage();
            this.hookEditChildMessage();
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

    this.hookCreateResponseMessage = function () {
        $('body').on('click', '#response_message_modal .btn-primary', function (e) {
            e.preventDefault();
            var serializedData = null;
            var actionVal = $('#response_message_modal #response_message_action').val();

            if (actionVal.match(/\/na\//)) {
                serializedData = $('#message_fields_wrapper form').serializeArray();
            } else {
                serializedData = $('#response_message_modal :input , #response_message_modal select').serializeArray()
            }

            serializedData = serializedData.concat([
                {name: '_method', value: 'put'}
            ]);

            $.ajax({
                url: actionVal,
                type: 'POST',
                data: serializedData,
                beforeSend: function () {
                    var $footer = $('#response_message_modal .modal-footer');
                    $footer.find('.actions').hide();
                    $footer.find('.loading').show();
                },
                success: function (data) {
                    $('#response_message_modal').modal('hide');
                    setTimeout(function () {
                        $('#message_fields_wrapper').html(data.response_message);
                        current.hookChosen();
                    }, 500);
                },
                error: function (data) {
                    alert('An error occoured while creating the response message. Please refresh your page and try again.');
                }
            });
        });
    };

    this.hookDiscardChildMessage = function () {
        $('body').on('click', '#discard_child_message_link', function (e) {
            e.preventDefault();
            if (confirm('Are you sure you want to discard this message and create a new one? This message will be permanently lost!')) {
                $.ajax({
                    url: $(this).prop('href'),
                    type: 'POST',
                    data: [
                        {name: '_method', value: 'delete'}
                    ],
                    beforeSend: function () {  s
                        $('#response_message_section .adjust-child-message-link').hide();
                        $('#response_message_section .adjust-child-message-loading').show();
                    },
                    success: function (data) {
                        $('#response_message_section').html(data.response_email_fields);
                    },
                    error: function () {
                        alert('Could not discard the child message. Please refresh your page and try again.');
                    }
                });
            }
        });

    };

    this.hookEditChildMessage = function () {
        $('body').on('click', '#edit_child_message_link', function (e) {
            e.preventDefault();
            $('#edit_child_location').val($(this).prop('href'));
            $('#message_fields_wrapper form').submit();
        });
    };
}