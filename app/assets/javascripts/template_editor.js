var OP = OP || {};
OP = (function($, window, doucument, Optyn){
  //Define the editor behavior in the sidebar
  Optyn.templateEditor = {
    initialize: function(){
      this.setUpSidebarEditing();
      this.cancelTemplateEditorAction();
      this.saveTemplateEditorAction();
      this.addImageLinkURL();
    },

    setUpSidebarEditing: function(){
      $('body').on('change', '#template_editable_content', function(){
        $("html, body").animate({ scrollTop: 0 }, "slow");
        var $merchantMenu = $('.merchant-menu');

        if($('.template-editor-container').length){
          $('.template-editor-container').remove();
          $merchantMenu.slideDown();
        }

        var $merchantMenu = $('.merchant-menu');
        var $sidebar = $merchantMenu.parent();

        var sideBarContent = '<ul class="template-editor-container"><li class="template-editor-section"></li></ul>';

        $sidebar.append(sideBarContent);

        var $templateContainer = $sidebar.find('.template-editor-container');
        var $templateSection = $templateContainer.find('.template-editor-section');
        $templateSection.append($('#template_editable_content').val());
         $templateSection.append('<button class="btn btn-small template-editor-cancel">Close</button>' +
          '<button class="btn btn-small btn-primary template-editor-save-changes" id="section_save_changes">Save changes</button>');

        $merchantMenu.slideUp(function(){
          $(this).hide();

          $templateContainer.slideDown(function(){
            $(this).show();
          });
          var submitButton = $('[id^=populateLink]')

          $(submitButton).on('click', function() {
            var link = $('[id^=imageLinkModel]').val()
            if(/^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/i.test(link)) {
            } else {
              alert("invalid url");
              return false;
            }
          });

        });

        $('.upload-img-btn').click(function(e){
          $(this).parents('.msg_img_upload').first().find('.loading').first().show();
          $(this).hide();
        });
        $("#edit_image").click(function(){
          $('.template-editor-container .upload-img-btn').show();
          $('.template-editor-container .browsBtn').show();
          $('.template-editor-container .add-img-link-option').hide();
        });

        OP.templateEditor.openCKEditor($templateContainer);

      });
    },

    openCKEditor: function($templateContainer){
      var textareas = $templateContainer.find('textarea');
      for ( var count = 0; count < textareas.length; count++ ) {
        CKEDITOR.replace( 'template_editable_content-' + count, {
          toolbarGroups: [
          {
            name: 'document',
            groups: [ 'mode', 'document' ]
          },            // Displays document group with its two subgroups.
          {
            name: 'clipboard',
            groups: [ 'clipboard', 'undo' ]
          },            // Group's name will be used to create voice label.
          '/',                                                              // Line break - next group will be placed in new line.
          {
            name: 'basicstyles',
            groups: [ 'basicstyles', 'cleanup' ]
          },
          {
            name: 'links'
          }]
        });
      }
    },

    cancelTemplateEditorAction: function(){
      $('body').on('click', '.template-editor-cancel', function(){
        OP.templateEditor.showMerchantMenu();
      });
    },

    saveTemplateEditorAction: function(){
      $('body').on('click', '.template-editor-save-changes', function(){
        var $inputField = $('iframe#customHtmlTemplate').contents().find('#editor_changed_content').first();

        var $templateContainer = $('.template-editor-container');
        var properties = {
          headlines: [],
          paragraphs: [],
          images: []
        }

        var headlines = properties.headlines;
        $templateContainer.find('.edit-headline').each(function(){
          headlines.push($(this).val());
        });

        var paragraphs = properties.paragraphs;
        $templateContainer.find('textarea').each(function(index, elem){
          paragraphs.push(CKEDITOR.instances['template_editable_content-' + index].getData());
        });

        var images = properties.images;
        console.log(images);
        $templateContainer.find('.uploaded-image').each(function(){
          var $uploadedImage = $(this);
          images.push([$uploadedImage.attr('src'), $uploadedImage.attr("data-href")]);
        });
        
        $inputField.val(JSON.stringify(properties));

        document.getElementById('customHtmlTemplate').contentWindow.$('#editor_changed_content').trigger('change');
                
        OP.templateEditor.showMerchantMenu();
      });
    },

    showMerchantMenu: function(){
      var $merchantMenu = $('.merchant-menu');
      var $sidebar = $merchantMenu.parent();
      var $templateContainer = $sidebar.find('.template-editor-container');

      $templateContainer.slideUp(function(){
        $(this).hide();

        $merchantMenu.slideDown(function(){
          $(this).show();
        });
      });

      $templateContainer.remove();
    },

    addImageLinkURL: function() {
      $(document).on('click', '.saveLinkUrl', function () {
        $('[data-link-href-id=' + $(this).data('image-link-url') + ']').closest('.nl-image-form').find(".uploaded-image").attr('data-href', $( this ).parents('.modal').find('input[type="url"]').val());
      });
    }
  };

    return Optyn;
  })(jQuery, this, this.document, OP);

$(document).ready(function(){
  if($('#template_editable_content').length){
    OP.templateEditor.initialize();
  }
  if($('#customHtmlTemplate').length){
    $( '#customHtmlTemplate' ).load( function() {
      $( this ).css( 'height', $('#customHtmlTemplate').contents().find('body').css('height') );
    });
  }
});
