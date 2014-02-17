var props = null;
$(document).ready(function () {
    var merchantMessage = new MerchantMessage();
    merchantMessage.initialize();

});

function MerchantMessage() {
    var current = this;

    this.initialize = function () {

        // Checking if iframe exists
        /*
         *  Check if it exists
         *  if it does add overlay and then
         *  remove the overlay when iframe is done loading
         */
        if ( $('#template_pane').length) {
            OP.overlay.addOverlay('#template_wrapper');
            this.loadSpinnerForIframe();
        }

        /*
            Hooks for preview page for messages except templates
        */ 
        if ($('#message_fields_wrapper').length) {
            this.hookChosen();
            this.hookActionEvent();
            this.hookDateTimePicker();
            this.hookPermanentCouponSelection();
            this.hookUncheckPermanentCouponCheck();
            this.clearDuplicateErrors();
            this.hookDiscountType();
            this.setDiscountTypeSelected();
            this.removeDuplicateLabelIdsError();
        }
        if ( $('#message_send_on_container').length ) {
            // For Date/Time picker on preview Newsletter page.
            this.hookDateTimePicker();
        }

        if ($('#message_fields_wrapper').length || $('#customHtmlTemplate').length) {
            this.hookSendSelfEmail();
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

        if($('#message_header_settings_form').length){
            this.hookHeaderColorPicker();
            this.hookColorPickerChange();
            this.hookHeaderColorChange();
            this.hookHeaderSettingSubmission();
        }

        if($('.template_chooser').length){
            this.hookTemplateAssignment();            
        }

        if($('#system_templates_modal').length){
            this.hookTemplateChooserClick();
        }

        if($('.template-delete-btn').length){
          this.hookTemplateDelete();        
        }

        if($('#template_properties_tab').length){
          this.hookTemplatePropertyTab();
          this.hookTemplatePropertyNavigation();
          this.hookTemplatePropertiesSubmit();
          this.hookAssginTemplateAssignName();
          setTimeout(function(){
            $('#template_properties_tab a:last').trigger('click');
          }, 100);

          this.hookReplaceMerchantMenuOnLoad();
          this.hookShowMessageMenuClick();
          this.hookShowTemplateMenuClick();
          this.hookPopulateTemplateSettableProperties();
          this.hookTemplateMenuColorPicker();
          this.hookTemplateMenuColorPickerChange();
          this.refreshTemplatePropertiesView();
        }
    };

    this.loadSpinnerForIframe = function() {
      $('#customHtmlTemplate').load(function(){
         setTimeout(function(){
            OP.overlay.removeOverlay();
          }, 100);  
      });
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

        $('.date-picker').datetimepicker({
            language: 'en',
            startDate: new Date(),
            endDate: sixMonthsSince,
            pickTime: false
        });

        $('.time-picker').datetimepicker({
            language: 'en',
            pick12HourFormat: true,
            pickSeconds: false,
            pickDate: false
        });
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

    this.hookPermanentCouponSelection = function(){
        $('body').on('change', '#message_permanent_coupon', function(){
            if($(this).is(":checked")){
                $('#message_ending').val('');
                $('#message_ending_time').val('');
            }
        });
    };

    this.hookUncheckPermanentCouponCheck = function(){
        if($('#message_permanent_coupon').length){
            window.setInterval(function(){
                if($('#message_ending').val().length){
                    $('#message_permanent_coupon').attr('checked', false);
                }
            }, 500);
            window.setInterval(function(){
                if($('#message_ending_time').val().length){
                    $('#message_permanent_coupon').attr('checked', false);
                }
            }, 500);
        }
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
                beforeSend: function(){
                    var $modalBody = $('#message_meta_modal form').parents('.modal-body');
                    var $modalFooter = $modalBody.next('.modal-footer');
                    $modalFooter.find('.btn').hide();
                    $modalFooter.find('.loading').show();
                },
                success: function (data) {
                    $('#message_meta_modal').modal('hide');
                    setTimeout(function () {
                        $('#preview-meta-data-view').replaceWith(data.message);
                        current.hookDateTimePicker();
                    }, 1000);

                },
                error: function (data) {
                    var $modal = $('#message_meta_modal');
                    $modal.html($.parseJSON(data.responseText).message);
                    setTimeout(function () {
                        current.hookDateTimePicker();
                        var sendOnErrorMessage = $('#message_meta_modal #send_on_error').val();
                        if(sendOnErrorMessage.length){
                            var $tempErr = $('<div />');
                            $tempErr.append("<span class='field-with-errors'><span class='help-inline error'>" + sendOnErrorMessage + "</span></span>");
                            $('#message_meta_modal #message_send_on_container').append($tempErr.html());
                        }

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
            {
                name: '_method',
                value: 'put'
            }
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
                        $('#message_menu').replaceWith(data.message_menu)
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
                    {
                        name: '_method',
                        value: 'delete'
                    }
                    ],
                    beforeSend: function () {  
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

    this.hookHeaderColorPicker = function(){
        $('#header_background').colorpicker({
            format: 'hex'
        });
    };

    this.hookHeaderColorChange = function(){
        $('body').on('change', '#header_background_color', function(){
            $('#header_background').colorpicker('setValue', $('#header_background_color').val());      
        });
    };

    this.hookColorPickerChange = function(){
        $('#header_background').colorpicker().on('changeColor', function(event){
            var hexVal = event.color.toHex();
            $('.message-visual-property-value').val('background-color: ' + hexVal);
            $('#header_background_color').val(hexVal);

        });
    };

    this.hookHeaderSettingSubmission = function(){
        $('body').on('submit', '#message_header_settings_form', function(event){
            event.preventDefault();
            current.ajaxHeaderFormSubmit();
        });
    };

    this.ajaxHeaderFormSubmit = function(){
        var $headerForm = $('#message_header_settings_form');
        
        $.ajax({
            type: 'POST',
            url: $headerForm.attr('action'),
            data: $headerForm.serialize(),
            beforeSend: function(){
                $('#preview-meta-data-view').hide();
                $('.loading').show();
            },
            success: function(data){
                $('#message_fields_wrapper').replaceWith(data);
                current.hookHeaderColorPicker();
                current.hookColorPickerChange();
            },
            error: function(){
                alert("An Error Occured white setting the color. Please refresh you page and try again.");
                $('#message_preview_container').show();
                $('.loading').hide(); 
            }
        });
    };

    this.clearDuplicateErrors = function(){
        if($('#message_type_of_discount_percentage_off').next('.error').length){
    // var error = true;
    // var $container = $('#message_type_of_discount_percentage_off').parents('.radio').first().parent();
    // $('#message_type_of_discount_percentage_off').next('.error').remove();
    // $('#message_type_of_discount_dollar_off').next('.error').remove();
    // $container.append("<div class='field-with-errors'><span class='help-inline error'>can't be blank</span></div>");
    }
    };

    this.hookDiscountType = function(){
        $( '.disc .btn' ).click( function() {
            var value = $( this ).data( 'value' );
            $( '#message_type_of_discount' ).attr( 'value', value );
        });
    };

    this.setDiscountTypeSelected = function(){
        if($('#message_type_of_discount').length){
            var discountTypeVal = $('#message_type_of_discount').val();
            var $discountContainer = $('#discount_type_container');
            if(discountTypeVal.length){
                $discountContainer.find('button').each(function(index, element){
                    if($(element).attr('data-value') === discountTypeVal){
                        $(element).addClass('active');
                    }else{
                        $(element).removeClass('active');
                    }
                });
            }
        }
    };

    this.removeDuplicateLabelIdsError = function(){
        $('input[name*=label_ids][type=hidden]').next('span.error').remove();
    };

    this.hookSendSelfEmail = function(){
        $('body').on('click', '#self_email', function(event){
            event.preventDefault();
            $.ajax({
                url: $(this).attr('href'),
                type: 'GET',
                success: function(){
                    alert('Successfully sent and email to you. Please check the email in a minute or two.')
                },
                error: function(){ 
                    alert('An Error occurred while sending you email. Please send an email to support@optyn.com for any issues.')
                }    
            });
        });
    };

    this.hookTemplateAssignment = function(){
        var _this = this;
        $('body').on('click', '.template_type', function(event){
            event.preventDefault();
            var uuid = $(this).attr('href').split('/')[3];
            $.ajax({
                url: $(this).attr('href'),
                type: 'POST',
                data: {
                    '_method': 'PUT',
                    'template_id': $(this).attr('data-template-id')
                    },
                beforeSend: function(){
                    OP.overlay.addOverlay('#template_wrapper');
                    _this.loadSpinnerForIframe();
                    $('.loading').show();
                    $('.btn-close').hide();
                },
                success: function(data){
                    $('.loading').hide();
                    $('#system_templates_modal').modal('hide');
                    $('#template_wrapper').replaceWith(data);
                    $('#choose_message .pull-right').append('<a class="btn btn-success" href="/merchants/messages/'+ uuid +'/preview_template">Preview</a>');
                  
                },
                error: function(){
                    $('.loading').hide();
                    alert("Could not choose a template. Please refresh your page and try again.");
                    $('.btn-close').show();
                }
            });
        });
    };

    this.hookTemplateChooserClick = function(){
        $('body').on('click', '#system_template_chooser_link', function(){
            $('#system_templates_modal').modal('show');        
        });
    };

    this.hookTemplatePropertiesSubmit = function(){
      $('body').on('click', '#assign_template_name', function(){
        var $templateField = $('#template_name_field');
        if(undefined != $templateField && $templateField.val() != undefined && $templateField.val().trim() != ""){
          var $form = $('#template_properties_form');
          
          $form.submit();
        }else{
          $templateField.jrumble({
            x:50,
            y:0,
            rotate: 4
          });
          $templateField.trigger('startRumble');

          setTimeout(function(){
            $templateField.trigger('stopRumble');            
          }, 2000)
        }
      })
    };

    this.hookTemplateDelete = function(){
      $('body').on('click', '.template-delete-btn', function(event){
        event.preventDefault();
        if(confirm('Are you sure you want to delete: ' + $(this).data('template-name') + "? Once deleted you will not be able to get it back.")){
          $.ajax({
            url: $(this).data('delete-template-path'),
            type: 'POST',
            data: {
              '_method': 'DELETE'
            },
            beforeSend: function(){
              OP.overlay.addOverlay('body');
            },
            success: function(data){
              window.location = window.location.toString();
            },
            error: function(){
              OP.overlay.removeOverlay();
              alert("Could not delete your template. Please refresh your page and try again.");
            }
          });
        }
      });  
    };

    this.hookTemplatePropertyTab = function(){
      $('body').on('click', '.template-property-tab', function(event){
        event.preventDefault();
        $(this).tab('show');
      });  
    };

    this.hookTemplatePropertyNavigation = function(){
      $('body').on('click', '.template-property-action', function(event){
        var tabId = $(this).data('tab');
        var jTabId = "#" + tabId;
        $('a[href=' + jTabId + ']').trigger('click');
      });
    };

    this.hookAssginTemplateAssignName = function(){
      $('body').on('click', '.template-property-submit', function(){
        $('#template_name').modal('show');      
      });
    };

    this.hookReplaceMerchantMenuOnLoad = function(){
      var templateMessage = this;
      var $merchantMenu = $('.merchant-menu');
      var $menuParent = $merchantMenu.parent();
      var $templateMenu = $('.template-property-menu');

      var $tempForMerchantMenu = $('<div />');
      $tempForMerchantMenu.append('<li><a class="show-template-menu" href="javascript:void(0)"><em>Show Template Menu</em></a></li>')
      $merchantMenu.append($tempForMerchantMenu.html());

      var $tempForTemplateMenu = $('<div />');
      $tempForTemplateMenu.append('<li><a class="show-message-menu" href="javascript:void(0)"><em>Show Main Menu</em></a></li>')
      $templateMenu.append($tempForTemplateMenu.html());

      $tempForTemplateMenu = $('<div />');
      $tempForTemplateMenu.append($templateMenu);
      $menuParent.append($tempForTemplateMenu.html());

      templateMessage.renderTemplateMenu();
    };

    this.hookShowMessageMenuClick = function(){
      var templateMessage = this;
      $('body').on('click', '.show-message-menu', function(){
        templateMessage.renderMerchantMenu();
      }); 
    };

    this.hookShowTemplateMenuClick = function(){
      var templateMessage = this;
      $('body').on('click', '.show-template-menu', function(){
        templateMessage.renderTemplateMenu();
      }); 
    };    

    this.renderMerchantMenu = function(){
      var $merchantMenu = $('.merchant-menu');
      var $templateMenu = $('.template-property-menu');

      $templateMenu.slideUp(function(){
        $(this).hide();
        
        $merchantMenu.slideDown(function(){
          $(this).show();
        });
      });
    } ;

    this.renderTemplateMenu = function(){
      var $merchantMenu = $('.merchant-menu');
      var $templateMenu = $('.template-property-menu');

      $merchantMenu.slideUp(function(){
        $(this).hide();
        
        $templateMenu.slideDown(function(){
          $(this).show();
        });
      });
    };

    this.hookPopulateTemplateSettableProperties = function(){
        var properties = $('.template-selectable-properties').data('selectable-properties').properties;
        props = properties;
        var elements =  $('#template_properties_form .tab-content-pane').find('input[type=text], select');
        for(var i = 0; i < elements.length; i++){
          var $element = $(elements[i]);
          var eval_str = $element.attr('id').replace(/_/g, '.');
          eval_arr = eval_str.split(".")
          var attr = eval_arr.pop();
          eval_str = eval_arr.join(".")
          eval_str = eval_str + '[' + "'" + attr + "'" + "]"
          var value = eval(eval_str)
          $element.val(value);

          if(attr.match('color')){
            var $colorSpan = $element.parents('.color').first();
            $colorSpan.attr('data-color', value);

            var $addon = $element.next('.add-on')
            $colorSpan.attr('background-color', value);            
          }
        }
    };

    this.hookTemplateMenuColorPicker = function(){
      $('.template-color-field').colorpicker({
            format: 'hex'
      });
    };

    this.hookTemplateMenuColorPickerChange = function(){
      var templateMessage = this;
      $('.template-color-field').colorpicker().on('hide', function(){
        templateMessage.reloadTemplateSelectorIframe();
      });
    };

    this.refreshTemplatePropertiesView = function(){
      var templateMessage = this;
      $('body').on('change', '.template-property-menu input[type=text], .template-property-menu select', function(){
        templateMessage.reloadTemplateSelectorIframe();          
      });
    };

    this.reloadTemplateSelectorIframe = function(){
      $.ajax({
        url: $('#merchants_selectable_properties_preview_path').val(),
        type: "POST",
        data: $('#template_properties_form').serialize(),
        success: function(data){
          $('iframe#customHtmlTemplate').contents().find('html').html(data);
        },
        error: function(){
          $('iframe#customHtmlTemplate').contents().html('<strong>An error occurred while setting your properties. Please select the template again</strong>');
        }
      });        
    };


}

$(document).ready(function(){
    $(".open-reports").click(function(){
        msg_uuid = $(this).attr('data-id');
        $('#reportDialog').modal('show');
        getSocialSiteReport(msg_uuid);
    });

    $(".click-reports").click(function(){
        msg_uuid = $(this).attr('data-uuid').substr(3);
        $('#clickReportDialog').modal('show');
        getClicksReport(msg_uuid);
    });
});

function getSocialSiteReport(msg_uuid) {
    var link = $('#social_site_report_path_' + msg_uuid);
    var url = link.val();
   
    $.ajax({
        url: url,
        type: 'GET',
        success: function (data) {
            $('#social_site_report_' + msg_uuid).html(data);
        },
        error: function (jqXHR, textStatus, errorThrown)
        {
            alert(errorThrown)
        }
    });
}

function getClicksReport(msg_uuid){
    var link = $('#click_report_path_' + msg_uuid);
    var url = link.val();
   
    $.ajax({
        url: url,
        type: 'GET',
        success: function (data) {
            $('#click_report_' + msg_uuid).html(data);
        },
        error: function (jqXHR, textStatus, errorThrown)
        {
            alert(errorThrown)
        }
    });
}