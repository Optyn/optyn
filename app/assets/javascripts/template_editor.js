var OP = OP || {};
OP = (function($, window, doucument, Optyn){
  //Define the editor behavior in the sidebar
  Optyn.templateEditor = {
    initialize: function(){
      this.setUpSidebarEditing();
      this.cancelTemplateEditorAction();
      this.saveTemplateEditorAction();
      this.addImageLinkURL();
      this.removeImageLinkURL();
      this.imageFileUpload();
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
            if(/^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/i.test(link)) {
            } else if ( /^(http:\/\/|https:\/\/)?((([\w-]+\.)+[\w-]+)|localhost)(\/[\w- .\/?%&=]*)?/i.test(link)){}
            else{
              alert("invalid url");
              return false;
            }
          });

        });

        $(".remove_image").click(function(){
          var $ctrlGrp = $(this).parents('.control-group').first();
          $ctrlGrp.find('.image-alt-container input').val('');
          // $ctrlGrp.find('.image-alt-container').hide();
          $ctrlGrp.find('.image-form-container').show();
          $ctrlGrp.find('img').prop('src', 'http://placehold.it/150&text=Upload%20Image');
          $ctrlGrp.find(".add-img-link-option").hide();
        });

        OP.templateEditor.imageFileUpload();

        OP.templateEditor.openCKEditor($templateContainer);

      });
    },

    openCKEditor: function($templateContainer){
      var textareas = $templateContainer.find('textarea');
      for ( var count = 0; count < textareas.length; count++ ) {
        CKEDITOR.replace( 'template_editable_content-' + count, {
          extraPlugins : 'simpleLink',
          
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
    'NumberedList','BulletedList','Outdent','Indent','Blockquote','-', 'RemoveFormat', '-'],
        ['Link', 'SimpleLink', 'Source']
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
              $this.addClass('ss-link');
            }else if($this.hasClass('ss-button-link')){
              $this.attr('style', '');
            }
          });

          paragraphs.push($temp.html());
        });

        var images = properties.images;
        $templateContainer.find('.uploaded-image').each(function(){
          var $uploadedImage = $(this);
          var imgAlt = "";
          try{
            imgAlt = $uploadedImage.parents('.control-group').first().find('[name^=image_alt]').val();
          }catch(e){
            imageAlt = "";
          }

          images.push([$uploadedImage.attr('src'), $uploadedImage.attr("data-href"), imgAlt]);
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
        var link_href = $(this).attr('data-image-link-url');
        var container = link_href.replace("AddLink", "");
        var link = $("#"+container).find("a[href='#" + link_href + "']");
        link.text("Edit Link");
        var link_value = $( this ).parents('.modal').find('input[type="url"]').val()
        $('[data-link-href-id=' + $(this).data('image-link-url') + ']').closest('.nl-image-form').find(".uploaded-image").attr('data-href', link_value);
        var $ctrlGrp = link.parents('.control-group').first();
        var $removeLink = $ctrlGrp.find('.remove_link_from_image');
        
        
        if($removeLink.length) {
          $removeLink.parent().remove();
        }
        
        link.parent().append('<div style="cursor: pointer; float:right" class="add-img-link-option removeLink"> | <a class="remove_link_from_image" href="#'+ container+'" role="button" data-link = "'+ link_value +'">Remove Link</a></div>');          
        
        
      });
    },

    removeImageLinkURL: function() {
      $(document).on('click', '.remove_link_from_image', function () {
        var containerId = $(".remove_link_from_image").attr("href");
        var link = $(containerId).find("a[href='#AddLink" + containerId.replace("#", "") + "']");
        link.text("Add Link");
        var imageLink = $(".remove_link_from_image").attr("data-link");
        $(containerId).find("[data-href='" + imageLink + "']").attr("data-href", "");
        var modelInput = "#imageLinkModel"+ containerId.replace("#", "");
        $(modelInput).val("");
        $(this).parent().hide();

      });
    },

    imageFileUpload: function(){
      var _this = this;
      var fileInstance = null;
      var filename = null;
      $('body').on('click', '.templatefileuploader', function(){
        $('.templatefileuploader').fileupload({
            url: $(this).parents('.control-group').first().find('#image_form_action').val(),
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
          var $file = $(this).parents('.control-group').first().find('.files').first();
          $file.html('');
          data.context = $('<div/>').appendTo($file);

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
        }).on('fileuploadprogressall', function (e, data) {
            var progress = parseInt(data.loaded / data.total * 100, 10);
            $('#progress .bar').css(
                'width',
                progress + '%'
            );
        }).on('fileuploaddone', function (e, data) {
          
          result = data.result.data;
          $('#progress .bar').css(
              'width',
              "0" + '%'
          );

          var $controlGroup = $(this).parents('.control-group').first();
          $controlGroup.find('img').prop('src', result.image_location);

          var $file = $(this).parents('.control-group').first().find('.files').first();
          $file.html('');

          $file.parents('.image-form-container').first().hide();
          $file.parents('.control-group').first().find(".add-img-link-option").show();


        }).on('fileuploadfail', function (e, data) {
            $.each(data.files, function (index, file) {
                var error = $('<span class="text-danger"/>').text('File upload failed.');
                $(data.context.children()[index])
                    .append('<br>')
                    .append(error);
            });
        }).prop('disabled', !$.support.fileInput)
            .parent().addClass($.support.fileInput ? undefined : 'disabled');

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
