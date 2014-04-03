var OP = OP || {};
OP = (function($, window, doucument, Optyn){
  //Define the editor behavior in the sidebar
  Optyn.templateEditor = {
    initialize: function(){
      this.setUpSidebarEditing();
      this.cancelTemplateEditorAction();
      this.saveTemplateEditorAction();
      this.addImageLinkURL();
      this.RemoveImageLinkURL();
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
            var link = $(this).parent().siblings(".modal-body").find('input[type="url"]').val();
            console.log(link);
            if(/^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/i.test(link)) {
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
         $(".show_link").click(function(){
          $(this).parents().siblings(".add-img-link-option").show();
          $(this).parents().siblings("form").hide();
          $(this).parents(".show-img-link-option").hide();
        });
        $(".edit_image").click(function(){
          $(this).parents().siblings("form").show();
          $(this).parents().siblings("form").find(".upload-img-btn").show();
          $(this).parents().siblings(".show-img-link-option").show();
          $(this).parents(".add-img-link-option").hide();
        });

        OP.templateEditor.openCKEditor($templateContainer);

      });
    },

    openCKEditor: function($templateContainer){
      var textareas = $templateContainer.find('textarea');
      for ( var count = 0; count < textareas.length; count++ ) {
        CKEDITOR.replace( 'template_editable_content-' + count, {
          extraPlugins : 'simpleLink,mediaembed',
          
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
          '/',
          {
            name: 'links'
          },
          {
            name: 'SimpleLink'
          }],
      toolbar :
      [
        ['Font', 'FontSize', '-', 'Bold','Italic','Underline', '-', 'TextColor','-'],
        ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock',
    'NumberedList','BulletedList','Outdent','Indent','Blockquote','-', 'RemoveFormat', '-', 'MediaEmbed'],
        ['Link', 'SimpleLink']
      ]
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
          //manipulate the links before adding the paragraphs
          var data = CKEDITOR.instances['template_editable_content-' + index].getData();
          var $temp = $('<div />');
          $temp.append(data);
          var $links = $temp.find('a');
          $links.each(function(){
            var $this = $(this);
            if(!$this.is("[class]")){
              $this.addClass('optyn-link');
            }else if($this.hasClass('optyn-button-link')){
              $this.attr('style', '');
            }
          });

          paragraphs.push($temp.html());
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
    },

    RemoveImageLinkURL: function() {
      $(document).on('click', '.remove_link_from_image', function () {
        var containerId = $(".remove_link_from_image").attr("href");
        var imageLink = $(".remove_link_from_image").attr("data-link");
        $(containerId).find("[data-href='" + imageLink + "']").attr("data-href", "");
        $(this).hide();

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
