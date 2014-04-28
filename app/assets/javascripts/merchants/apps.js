$(document).ready(function () {
    var apps = new Apps();
    apps.initialize();
});

function Apps() {
    if ($('#app_form').length) {
        var current = this;
    }

    this.initialize = function () {

        if ($('#app_form').length) {
            this.hookGenerateButton();
            this.hookSaveButton();
            this.hookSaveAndResetButton();
            this.hookOptynButtonTextToggle();
            this.hookTooltip();
            this.hookChangeChosen();
            this.hookBarOption();
        }

        if ($('.app-container').length) {
            this.hookCopyButtonEmbedCode();
        }
    };

    this.hookCopyButtonEmbedCode = function () {
        $('a#copy_description').zclip('remove');
        $('a#copy_description').zclip({
            path: '/ZeroClipboard.swf',
            copy: function () {
                return $('.app-container').first().find('#embed_code').val()
            },
            afterCopy: function(){
                if("copied" === $('a#copy_description').html().toLowerCase()){
                    $('a#copy_description').html('Copy to Clipboard');
                }else{
                    $('a#copy_description').html('Copied');
                }
                return null;
            }
        });
    };

    this.showCopiedNotice = function() {
        $( '.copy-notice' ).text( 'Copied to clipboard.' ).slideDown( 300, function() {
            setTimeout( function() {
                $( '.copy-notice' ).text( '' )
                    .slideUp();
            }, 3000 );
        });
        return null;
    };

    this.hookGenerateButton = function () {
        $('body').on('click', '#app_form #generate_button', function (event) {
            event.preventDefault();
            current.refreshAppContainer();
        });
    };

    this.hookSaveButton = function () {
        $('body').on('click', '#app_form #save_button', function (event) {
            event.preventDefault();
            current.refreshAppContainer();
        });
    };

    this.hookSaveAndResetButton = function () {
        $('body').on('click', '#app_form #save_and_reset_button', function (event) {
            event.preventDefault();
            $('#app_form #reset').val('true');
            current.refreshAppContainer();
        });
    };

    this.refreshAppContainer = function () {
        $.ajax({
            url: $('#app_form').prop('action'),
            type: 'POST',
            data: $('#app_form').serialize(),
            beforeSend: function(){
                $('.app-container #loading').show();
                $('.app-container .refresh').hide();
            },
            success: function (data) {
                $('.app-container .btn-preview').replaceWith(data.preview_content);
                $('.app-container .form-wrapper').replaceWith(data.form_content);
                $('.app-container .advanced').replaceWith(data.advanced_content);

                $('a#copy_description').zclip('remove');
                    current.hookChangeChosen();
                $('a#copy_description').zclip({
                    path: '/ZeroClipboard.swf',
                    copy: function () {
                        return $('.app-container').first().find('#embed_code').val()
                    },
                    afterCopy: function(){
                        if("copied" === $('a#copy_description').html().toLowerCase()){
                            $('a#copy_description').html('Copy to Clipboard');
                        }else{
                            $('a#copy_description').html('Copied');
                        }
                        return null;
                    }
                });

                $('.app-container #loading').hide();
                $('.app-container .refresh').show();
            },
            error: function (data) {
                alert($.parseJSON(data.responseText).error_message);
                $('.app-container #loading').hide();
                $('.app-container .refresh').show();
            }
        });
    };

    this.hookOptynButtonTextToggle = function () {
        $('body').on('click', '.optyn-text-preference', function () {

            var isChecked = $(this).is(':checked');

            $('.optyn-text-preference').each(function (index, element) {
                $(element).prop('checked', false);
            });

            $(this).prop('checked', isChecked);

            if ($('.optyn-text-preference:checked').length <= 0) {
                $('#oauth_application_show_default_optyn_text').prop('checked', true);
            }
        });
    };

    this.hookTooltip = function(){
        $('.tip').tooltip()
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

 this.hookBarOption = function () {
      $('.render_choice').change(function (event) {
         var value = $(this).val();
         if(value == 2){
            $(".bar_options").hide();
         }
         else{
            $(".bar_options").show();
         }
        });
    };
}