var OP = OP || {};
OP = (function($, window, doucument, Optyn){
  //Define the editor behavior in the sidebar
  Optyn.templateEditor = {
    initialize: function(){
      this.setUpSidebarEditing();
      this.cancelTemplateEditorAction();
      this.saveTemplateEditorAction();
    },

    setUpSidebarEditing: function(){
      $('body').on('change', '#template_editable_content', function(){
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

        });

        $('.upload-img-btn').click(function(e){
          $(this).parents('.msg_img_upload').first().find('.loading').first().show();
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
        $templateContainer.find('.uploaded-image').each(function(){
          var $uploadedImage = $(this);
            images.push($(this).attr('src'));
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
  };

    return Optyn;
  })(jQuery, this, this.document, OP);

$(document).ready(function(){
  if($('#template_editable_content').length){
    OP.templateEditor.initialize();
  }
});