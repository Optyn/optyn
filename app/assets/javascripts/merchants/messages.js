var COLORPICKRVAL = null;
$(document).ready(function () {
    var merchantMessage = new MerchantMessage();
    merchantMessage.initialize();

    $(document).bind('ajaxComplete', function(){
        merchantMessage.setDiscountTypeSelected();
        merchantMessage.hookChosen();
    });
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
        
        if ( $( '.preview_template' ).length ) {
            this.hookEqualizePreviewColumnHeight();
        }

        /*
            Hooks for preview page for messages except templates
        */ 
        if ( $( '#preview_wrapper' ).length) {
            // Firefox fix for mobile preview of non-template campaigns.
            $( '#preview_wrapper > table table table:first img' ).addClass( 'logo-img' );
            $( '#preview_wrapper > table table table:nth-child(2) img' ).addClass( 'body-img' );
        }

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
            this.hookUpdateMessage();
            this.hookUploadLogo();
            this.hookRemoveLogo();
            this.hookRedemptionInstructions();
            this.hookFinePrint();
            this.hookExpirationDate();
            this.hookAddButton();
        }

        if ($('#template_wrapper').length) {
            this.hookChosen();
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

        // if($('.template_chooser').length){
        //     this.hookTemplateAssignment();            
        // }

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
          this.socialSharing();
          this.updateSocialSharing();
          this.hookTemplateHeaderAlignment();
          this.manageLogo();
          this.hookHeaderContentTitleKeyup();
          this.refreshTemplatePropertiesView();
          this.hookTemplateImageUpload();
          this.removeTemplateHeaderImage();
          this.hookLinkTemplateLinkBlur();
        }
        this.hookOpenLinkClickReport();
        this.hookEmailReport();
        if($('.open-reports').length){
          this.hookReport();
          
          // this.hookClearReportModal();
          this.backToMainReport();
        }

        if ( $( '#choose-new-logo' ).length ) {
            this.hookChangeLogo();
        }
        if ( $( '.preview-header' ).length ) {
            this.hookCampaignResponsiveViewer();
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
        $('.chzn-select').chosen({"width": "100%"});
    };

    this.hookActionEvent = function () {
        // $('#message_form .btn').click(function (event) {
        $(document).on('click', '#message_form .btn', function (event) {
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
            var $modalBody = $('#message_meta_modal form').parents('.modal-body');
            var $modalFooter = $modalBody.next('.modal-footer');
            $.ajax({
                url: $('#message_meta_modal form').prop('action'),
                type: 'POST',
                data: $('#message_meta_modal').find('form').serialize(),
                beforeSend: function(){
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
                },
                complete: function () {
                    $modalFooter.find('.loading').hide();
                    $modalFooter.find('.btn').show();
                }
            });
        });
    };

    this.hookCreateResponseMessage = function () {
        $('body').on('click', '#response_message_modal .btn-primary', function (e) {
            e.preventDefault();
            var serializedData = null;
            var actionVal = $('#response_message_modal #response_message_action').val();

            $('#message_form #content').val(CKEDITOR.instances.content.getData());

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
                    var $footer = $('#response_message_modal .modal-footer');
                    $footer.find('.actions').show();
                    $footer.find('.loading').hide();
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
            var confirmMessage = "This will save the current draft of your survey message and " +
                "open the response message for editing. Do you wish to continue?"
            if(confirm(confirmMessage)){
                $('#after_save_location').val($(this).prop('href'));
                $('#message_fields_wrapper form').submit();
            }
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
                //$('#preview-meta-data-view').hide();
                $('.loading').show();
            },
            success: function(data){
                $('#message_fields_wrapper').replaceWith(data);
                current.hookHeaderColorPicker();
                current.hookColorPickerChange();
                if ( $( '.preview-header' ).length ) {
                    $( '.preview-header a' ).removeClass( 'btn-primary' );
                    $( '#show-desktop-preview' ).addClass( 'btn-primary' );
                }
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
                    alert('Successfully sent an email to you. Please check the email in a minute or two.')
                },
                error: function(){ 
                    alert('An Error occurred while sending you email. Please send an email to support@optyn.com for any issues.')
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
        // This function might no longer be required.
      var templateMessage = this;
      var $merchantMenu = $('.merchant-menu');
      //var $menuParent = $merchantMenu.parent();
      //var $templateMenu = $('.template-property-menu');

      var $tempForMerchantMenu = $('<div />');
      $tempForMerchantMenu.append('<li><a class="show-template-menu" href="javascript:void(0)"><em>Show Template Menu</em></a></li>')
      $merchantMenu.append($tempForMerchantMenu.html());

      //var $tempForTemplateMenu = $('<div />');
      //$tempForTemplateMenu.append('<li><a class="show-message-menu" href="javascript:void(0)"><em>Show Main Menu</em></a></li>')
      //$templateMenu.append($tempForTemplateMenu.html());

      // $tempForTemplateMenu = $('<div />');
      // $tempForTemplateMenu.append($templateMenu);
      // $menuParent.append($tempForTemplateMenu.html());

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
        var elements =  $('#template_properties_form .tab-content-pane').find('input[type=text], select');
        for(var i = 0; i < elements.length; i++){
          var $element = $(elements[i]);
          var eval_str = $element.attr('id').replace(/_/g, '.');
          eval_arr = eval_str.split(".")
          var attr = eval_arr.pop();
          eval_str = eval_arr.join(".");
          eval_str = eval_str + '[' + "'" + attr + "'" + "]";
          var value = eval(eval_str);
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
      // $('.template-color-field').colorpicker({
      //       format: 'hex'
      // });

      $('span.template-color-field').each(function(){
        var $this = $(this);
        var cssId = "#" + $this.attr('id');
        var evalStr = "$('" + cssId + "').colorpicker({" +
                      "format: 'hex'" +
                      "});"
        eval(evalStr);    
      });
    };

    this.hookTemplateMenuColorPickerChange = function(){
        $( '.template-color-field' ).colorpicker().on( 'changeColor', function( ev ){
          $( this ).find( 'i' ).css( 'background-color', ev.color.toHex());
          // templateMessage.reloadTemplateSelectorIframe();
        });

        $( '.template-color-field' ).on('input paste blur', function(){
          COLORPICKRVAL = $(this).val().toString();
        });

      var templateMessage = this;

      $('span.template-color-field').each(function(){
          var $this = $(this);
          var cssId = "#" + $this.attr('id');

          var evalStr = "";
          evalStr = "$('" + cssId + "').colorpicker().on('hide', function(ev){" +
          "$( this ).find( 'i' ).css( 'background-color', ev.color.toHex());" +
            "$( this ).find( 'i' ).css( 'background-color', ev.color.toHex());" +
            "var $input = $(this).find('input');" +
            "if($input.length){" +
              "var inputVal = $input.val().toLowerCase();" +
              "if(COLORPICKRVAL != inputVal){" +
                "templateMessage.reloadTemplateSelectorIframe();" +
              "}" +
              "COLORPICKRVAL = inputVal;" +
            "}" +

          "});"  
           
           eval(evalStr);  
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
          // $('iframe#customHtmlTemplate').contents().find('html').replaceWith(data);
          iframe = document.getElementById('customHtmlTemplate');
          iframe.contentWindow.document.open();
          iframe.contentWindow.document.write(data);
          iframe.contentWindow.document.close();
        },
        error: function(){
          $('iframe#customHtmlTemplate').contents().html('<strong>An error occurred while setting your properties. Please select the template again</strong>');
        }
      });        
    };

    this.hookReport = function(){
      var _this = this;
      $('body').on('click', '.open-reports', function(){
        _this.populateMainReport(this);
      });
    };

    this.hookOpenLinkClickReport = function(){
      $('body').on('click', '.link-click-report-link', function(){
        var id = $(this).data('id');
        var content = $('#click_report_' + id).data('content');
        $('#report_dialog').html(content);

        var link = $('#click_report_path_' + id);
        var url = link.val();
       
        $.ajax({
            url: url,
            type: 'GET',
            success: function (data) {
                $('#report_dialog .modal-body').html(data);
                $('#report_dialog').modal('show');
            },
            error: function (jqXHR, textStatus, errorThrown)
            {
                alert(errorThrown)
            }
        });
      });
    };

    this.hookEmailReport = function(){
          $('body').on('click', '.email-report-report-link', function(){
            var id = $(this).data('id');
            var content = $('#email_report_' + id).data('content');
            $('#report_dialog').html(content);

            var url = $(this).data('location');
            $.ajax({
                url: url,
                type: 'GET',
                success: function (data) {
                    $('#report_dialog .modal-body').html(data.emails);
                    $('#report_dialog .modal-header h3').html(data.report_title);
                    $('#report_dialog').modal('show');
                },
                error: function (jqXHR, textStatus, errorThrown)
                {
                    alert(errorThrown)
                }
            });
          });
        };

    this.hookClearReportModal = function(){
      $('#report_details').on('hide', function(){
        $('#report_details').html('<div class="modal-body"><strong>Please Wait...</strong></div>');
      });
    };

    this.backToMainReport = function(){
      var _this = this;
      $('body').on('click', '.back-to-main-report', function(){
        _this.populateMainReport(this);
      });
    };

    this.populateMainReport = function(clickedElem){
      var _this = this;
      var id = $(clickedElem).data('id');
        var content = $('#report_' + id).data('content');
        $('#report_dialog').html(content);

        var url = $(clickedElem).data('location');
        $.ajax({
            url: url,
            type: 'GET',
            success: function (data) {
              $('#report_dialog').html(data);
              _this.populateSocialSiteReport(id);
            },
            error: function (jqXHR, textStatus, errorThrown)
            {
              alert(errorThrown)
            }
        });
    };

    this.populateSocialSiteReport = function(msg_uuid){
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
    };

    // manage social sharing icons visibility
    this.socialSharing = function(){    
      // var _this = this;
      $('#customHtmlTemplate').load(function(){   
        var twitter = $("#customHtmlTemplate").contents().find(".ss-twittershare")
        var facebook = $("#customHtmlTemplate").contents().find(".ss-fbshare")
        var twitterCustom = $("#customHtmlTemplate").contents().find("twittershare")
        var fbCustom = $("#customHtmlTemplate").contents().find("fbshare")

        if((twitter.length>0) || (facebook.length>0) || (fbCustom.length>0) || (twitterCustom.length>0))
        { 
          if(twitter.css("display") == "none")
            $("#twitter-setting").prop('checked', false);
          else
            $("#twitter-setting").prop('checked', true);

          if(facebook.css("display") == "none")
            $("#facebook-setting").prop('checked',false)
          else
            $("#facebook-setting").prop('checked',true)
          // _this.setSocialShareUrl();
        }
        else
          {$(".control-group.social-share").remove()}
      });

    };

    //When the checkboxes are checked and unchecked. An event already observes change. 
    //However making sure that that it observes the click event.
    this.updateSocialSharing = function(){
      var _this = this;
      $(document).on('click', '#facebook-setting, #twitter-setting', function(){
        _this.reloadTemplateSelectorIframe();
      });
    };

    this.manageLogo = function(){
      var templateMessage = this;
      
      // radio button for logo text or image
      $("#properties_header_logo_image, #properties_header_logo_text").click(function(){
        if($(this).data('value') == "image")
        {
          $('.logo_text').hide();
          $('#imgfile').show();
          $('.save_image').show();

          //hide the text related attributes
          //hinding the logotext
          $('#properties_header_logotext').parents('.control-group').first().hide();
          //hiding the font select container
          $('#properties_header_headline_css_font-family').parents('.control-group').first().hide();
          //hiding the text color picker
          $('#properties_header_headline_css_color').parents('.control-group').first().hide();
          //hiding the header text alignment
          $('#logo_align').parents('.control-group').first().hide();
          //hiding the fileupload section
          $('#fileupload').parents('.control-group').first().show();
        }
        else
        {
          $('#imgfile').hide();
          $('.logo_text').show();
          $('.save_image').hide();
          $('.change_image').hide();    

          //show the text related attributes
          //showing the logotext
          $('#properties_header_logotext').parents('.control-group').first().show();
          //showing the font select container
          $('#properties_header_headline_css_font-family').parents('.control-group').first().show();
          //showing the text color picker
          $('#properties_header_headline_css_color').parents('.control-group').first().show();
          //showing the header text alignment
          $('#logo_align').parents('.control-group').first().show();
          //showing the fileupload section
          $('#fileupload').parents('.control-group').first().hide();      
        }
        $('#properties_header_logo').val($(this).data('value'));
        templateMessage.reloadTemplateSelectorIframe();
      });
    };

    // alignment
    this.hookTemplateHeaderAlignment = function(){
      var _this = this;
      $('body').on('click', '.left-align, .center-align, .right-align', function(e){       
        $("#logo_align").val($(this).attr("data-align"));
        _this.reloadTemplateSelectorIframe();
      });
    };

    this.hookHeaderContentTitleKeyup = function(){
      var _this = this;
       $('body').on("keyup", '#properties_header_logotext', function(){
         $("#customHtmlTemplate").contents().find(".ss-introduction .ss-headline").html($(this).val());
       });
    };

    this.hookLinkTemplateLinkBlur = function(){
      var _this = this;
       $('body').on("blur", '#properties_header_logolink', function(){
         _this.reloadTemplateSelectorIframe();
       });
    };

    this.hookTemplateImageUpload = function(){
      var _this = this;
      var fileInstance = null;
      var filename = null;
      $('#fileupload').fileupload({
          url: $('#template_image_upload_path').val(),
          dataType: 'json',
          type: "POST",
          acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
          maxFileSize: 10000000, // 10 MB
          // Enable image resizing, except for Android and Opera,
          // which actually support image resizing, but fail to
          // send Blob objects via XHR requests:
          disableImageResize: /Android(?!.*Chrome)|Opera/
              .test(window.navigator.userAgent),
          previewMaxWidth: 100,
          previewMaxHeight: 100,
          previewCrop: true
      }).on('fileuploadadd', function (e, data) {
        $('#files').html('');
          data.context = $('<div/>').appendTo('#files');
          $.each(data.files, function (index, file) {
              var node = $('<p/>')
                      .append($('<span/>').text(file.name));
              
              if (!index) {
                if((file.name).match(/(\.|\/)(gif|jpe?g|png)$/i)){
                  node
                      .append('<br>');
                      data.submit();
                }else{
                  var $error = $("<span />");
                  $error
                    .text('-- File Type Not allowed')
                    .css('padding-left', '10px');

                  $(node).append($error);
                }
              }


              node.appendTo(data.context);
              filename = file.name;
          });
      }).on('fileuploadprocessalways', function (e, data) {
          var index = data.index,
              file = data.files[index],
              node = $(data.context.children()[index]);
          if (file.preview) {
              node
                  .prepend('<br>')
                  .prepend(file.preview);
          }
          if (file.error) {
              node
                  .append('<br>')
                  .append($('<span class="text-danger"/>').text(file.error));
          }
          if (index + 1 === data.files.length) {
              data.context.find('button')
                  .text('Upload')
                  .prop('disabled', !!data.files.error);
          }
      }).on('fileuploadprogressall', function (e, data) {
          var progress = parseInt(data.loaded / data.total * 100, 10);
          $('#progress .bar').css(
              'width',
              progress + '%'
          );
      }).on('fileuploaddone', function (e, data) {

          result = data.result.data;
          $('#properties_header_template_header_image_location').val(result.image_location);
          $('#properties_header_template_header_image_id').val(result.image_id);
          $('#properties_header_template_header_image_name').val(result.image_name);

          $('#progress .bar').css(
              'width',
              "0" + '%'
          );

          var $temp = $('<div />');
          var $imageLink = $('<a />');
          $imageLink
            .prop('href', $('#properties_header_template_header_image_location').val())
            .text(filename);
          
          var $icon = $('<i />');
          $icon
            .addClass('icon-remove icon-white');

          var $imageRemoveLink = $('<a />');
          $imageRemoveLink
            .prop('href', 'javascript:void(0)')
            .css('padding-left', '10px')
            .prop('id', 'remove_template_header_image');

          $imageRemoveLink.append($icon);      

          $temp.append($imageLink);
          $temp.append($imageRemoveLink);  

          $('#files').html($temp.html());

          $('#template_header_image_controls').hide();

          _this.reloadTemplateSelectorIframe();

      }).on('fileuploadfail', function (e, data) {
          $.each(data.files, function (index, file) {
              var error = $('<span class="text-danger"/>').text('File upload failed.');
              $(data.context.children()[index])
                  .append('<br>')
                  .append(error);
          });
      }).prop('disabled', !$.support.fileInput)
          .parent().addClass($.support.fileInput ? undefined : 'disabled');
    };

  this.removeTemplateHeaderImage = function(){
    var _this = this;
    $('body').on('click', '#remove_template_header_image', function(){
      $('#files').html('');
      $('#template_header_image_controls').show();

      $('#properties_header_template_header_image_location').val('');
      $('#properties_header_template_header_image_id').val('');
      $('#properties_header_template_header_image_name').val('');

      _this.reloadTemplateSelectorIframe();
    });
  };

  this.hookUpdateMessage = function(){
    $('body').on('click', '.submit-message #upload_new_logo .remove_logo', function (e) {
        $('.form-spinner').show();
    });
  };

  this.hookChangeLogo = function() {
    $( '#change-logo-image' ).change( function() {

        $( '#selected-logo-img-url' ).html( $( '#change-logo-image' ).val() + ' <a class="btn btn-small btn-success" id ="upload_new_logo" href="#"><i class="icon-upload"> Upload new logo</a>');
    });
    $( '#choose-new-logo' ).click( function() {
      $( '#change-logo-image' ).click();
    });
  };

  this.hookUploadLogo = function() {
    $('body').on('click', '#upload_new_logo', function (e) {
      $("#upload_image").submit();
      $('.form-spinner').show();
    });
  };

  this.hookRemoveLogo = function() {
    $('body').on('click', '.remove_logo', function() {
        if(confirm("Are you sure?"))
            $('.form-spinner').show();
        else
            return false;
    })
  }

  this.hookRedemptionInstructions = function() {
    $('body').on('click', '#add_redemption_instructions', function (e) {
        if($('#add_redemption_instructions').is(':checked'))
            $('#message_redemption_instructions').show();
        else
            $('#message_redemption_instructions').hide();
    });
  }

  this.hookFinePrint = function() {
    $('body').on('click', '#fine_print', function (e) {
    if($("#fine_print").is(':checked')){
     $("#message_fine_print").show();
    }
    else{
       $("#message_fine_print").hide(); 
      }
    });
  };

  this.hookExpirationDate = function() {
    $('body').on('click', '#add_expiration_date', function (e) {
      if($("#add_expiration_date").is(':checked')){
        $(".expiration_date").show();
      }
      else{
       $(".expiration_date").hide(); 
      }
    });
  };

  this.hookAddButton = function() {
    $('body').on('click', '#add_button', function (e) {
      if($("#add_button").is(':checked')){
        $(".optional").show();
      }
      else{
        $("#message_button_text").val('');
        $("#message_button_url").val('');
        $(".optional").hide();
      }
    });
  };


  this.hookCampaignResponsiveViewer = function() {
    var selector;
    $( 'body' ).hasClass( 'preview_template' ) ? selector = '#template_wrapper': selector = '#preview_wrapper';

    function highlightCurrentButton( $current ) {
        $( '.preview-header a' ).removeClass( 'btn-primary' );
        $( $current ).addClass( 'btn-primary' );
    }
    $( '#show-desktop-preview' ).click( function() {
        $('#message_fields_wrapper').removeClass( 'mobile-preview' );
        highlightCurrentButton( $( this ));
        $( selector ).animate({ width: '100%' }, 200, function() {
            if ( $( 'body' ).hasClass( 'preview_template' )) {
                equalizeDivHeightsWithIframe();
            }
        });
        opTheme.equalizeDivHeights([ '#merchants > .span6:first', '#preview_wrapper td:first' ]);
    });

    var equalizeDivHeightsWithIframe = function() {
        $( '#customHtmlTemplate' ).css( 'min-height', 'inherit' );
        $( '#campaign-details-pane' ).css( 'min-height', 'inherit' );
        $( '#customHtmlTemplate' ).css( 'min-height', $( '#customHtmlTemplate' ).contents().find( 'body' ).css( 'height' ));
        opTheme.equalizeDivHeights([ '#campaign-details-pane', '#customHtmlTemplate' ]);
    };

    $( '#show-mobile-preview' ).click( function() {
        $('#message_fields_wrapper').addClass( 'mobile-preview' );
        highlightCurrentButton( $( this ));
        $( '#preview_wrapper td:first' ).css ( 'height', 'auto' ); // To overcome sideeffects of equalizeDivHeights().
        $( selector ).animate({ width: '320px' }, 200, function() {
            if ( $( 'body' ).hasClass( 'preview_template' )) {
                equalizeDivHeightsWithIframe();
            }
        }).css( 'margin-left', 'auto' ).css( 'margin-right', 'auto' );
    });
  }

  this.hookEqualizePreviewColumnHeight = function() {
    if ( $( 'body' ).hasClass( 'merchants-messages' ) && $( 'body' ).hasClass( 'preview_template' )) {
        $( '#customHtmlTemplate' ).load( function() {
            $( '#preview-pane' ).css( 'background-color', $( '#customHtmlTemplate' ).contents().find( 'table.body' ).css( 'background-color' ));
        });
    }
    var $iframe = $( '#customHtmlTemplate' );
    var $editorPane = $( '#campaign-details-pane' );
    var workArea;
    var cb = function() {
        workArea = $( window ).height() - 50;
        $iframe.css( 'min-height', 'inherit' );
        var iframeHt = $iframe.contents().find( 'body' ).css( 'height' );
        $editorPane.css( 'min-height', 'inherit' );
        var editorHt = $editorPane.css( 'height' );
        var maxHt = Math.max( parseInt( iframeHt ), parseInt( editorHt ));
        maxHt < workArea ? maxHt = workArea : maxHt;
        $( 'iframe' ).css( 'min-height', maxHt );
        $( '#campaign-details-pane' ).css( 'min-height', maxHt + 60 );
    };
    $iframe.load( cb );
    $( window ).resize( cb );
  };

}
