//= require jquery
//= require jquery_ujs
//= require jquery-ui-1.9.2.custom.min
//= require jquery.remotipart
//= jquery-migrate-1.2.1
//= require bootstrap
//= require ckeditor_fix
//= require ckeditor_button
//= require ckeditor/init
//= require_self


var OP = OP || {};
OP = (function($, window, doucument, Optyn){

  //Define the template Object and behavior
  Optyn.template = {

    initialize: function(){
      this.hookUpdatingSection();
      this.hookEditTrigger();
      this.hookAddSection();
      this.hookDeleteSection();
      this.hookContentCreationOnLoad();
      this.fixCkEditorModalIssue();
      this.hookImageClick();
      this.hookSortTemplateElements();
      setTimeout( function() {
        OP.setParentIframeHeight();
        OP.setImageLinkTarget();
      }, 3000);  // Find a better alternative for this setTimeout.
    },

    hookSortTemplateElements: function(){
        // Unwrap all the sortable items

        // Wrapping in a container with CSS class .sortable-item
        // $('.ss-content').find($('div.template-section-toolset')).each(function(){
        //   if(!$(this).parents('.sortable-item').length){
        //     $(this).next().andSelf().wrapAll('<div class="sortable-item">');  
        //   }
        // });
        
        $('.ss-content').find('.ss-grid').each(function(){
          $(this).find($('div.template-section-toolset')).each(function(){
            if(!$(this).parents('.sortable-item').length){
              $(this).next().andSelf().wrapAll('<div class="sortable-item">');  
            }
          });  
        });

        $(".handle").css("cursor", "pointer");   // Hand cursor
        $(".handle").css("cursor", "move");      // Directional cursor.

        // Wrapping all .sortable items in #sortable container
        // if(!$('.sortable-item').parents('#sortable').length){
        //   $('.sortable-item').wrapAll('<div id="sortable">');
        // }

        $('.sortable-item').parents('.ss-grid').each(function(){
          if(!$(this).find('.sortable-container').length){
            $(this).find('.sortable-item').wrapAll("<div class='sortable-container'>");
          }
        });

        // Sortable init
        $('.sortable-container').sortable({
          revert       : true,
          stop: function( event, ui ) {OP.template.saveSectionChanges();},
          handle : '.handle',
          cancel : ''

      });

      $('.sortable-container').disableSelection();
    },

    fixCkEditorModalIssue: function(){
      // bootstrap-ckeditor-modal-fix.js
      // hack to fix ckeditor/bootstrap compatiability bug when ckeditor appears in a bootstrap modal dialog
      //
      // Include this AFTER both jQuery and bootstrap are loaded.

      $.fn.modal.Constructor.prototype.enforceFocus = function() {
        modal_this = this
        $(document).on('focusin.modal', function (e) {
          if (modal_this.$element[0] !== e.target && !modal_this.$element.has(e.target).length
            // add whatever conditions you need here:
            && !$(e.target.parentNode).hasClass('cke_dialog_ui_input_select') && !$(e.target.parentNode).hasClass('cke_dialog_ui_input_text')) {
            modal_this.$element.focus()
          }
        })
      };
    },

    //fire up a editing of the section when user edits a section
    hookEditTrigger: function() {
      $('body').on('click', '.ink-action-edit', function() {
        var $division = $(this).parents('.template-section-toolset').first().next( '.ss-division' ),
        $editableElem = $division.find('.ss-division'),
        divisionContents = [];

        $division.find('.ss-headline, .ss-paragraph, .ss-replaceable-image').each(function(index, updateableElement){
          var $updateableElement = $(updateableElement);
          var artifact = null;

          if($updateableElement.hasClass('ss-headline')){
            artifact = {
              type: 'headline',
              content: $updateableElement.text()
            };
          }else if($updateableElement.hasClass('ss-paragraph')){

            //Add the style tag to the button to show properly in ckEditor
            $updateableElement.find('a.ss-button-link').each(function(){
              $(this).attr('style', OP.ckeditorButton.getStyle());
            })

            artifact = {
              type: 'paragraph',
              content: $updateableElement.html()
            };
          }else if($updateableElement.hasClass('ss-replaceable-image')){
            var placeholderSrc = null;
            var href = null;
            var $image = $updateableElement.find('img');

            if($image.length){
              placeholderSrc = $image.attr('src');
              if ($image.closest('a').length){
                href = $image.closest('a').attr("href");
              }
              else{
                href = "";
              }
            }else{
              placeholderSrc =  $updateableElement.data( 'src-placeholder' );
            }

            artifact = {
              type: 'image',
              content: [placeholderSrc, href]
            };
          }

          divisionContents.push(artifact);
        });
        OP.template.openCkeditor($division, divisionContents);
        OP.setParentIframeHeight();
      });
    },

    //Code to open up the CKEditor
    openCkeditor: function(division, divisionContents){

      // Add fields for editing headlines, images and paragraphs. Only paragraphs open in CKEditor.
      try{
        if( CKEDITOR.instances.template_editable_content.length ) {
          CKEDITOR.instances.template_editable_content.destroy();
        }
      }catch(err){}

      var htmlVal = '';
      var image_form_action = "/merchants/messages/" + $('#editor_area_modal').data('msg-id') + "/template_upload_image";
      var paragraphIndex = 0;
      var imageIndex = 0;

      for( var index = 0; index < divisionContents.length; index++) {
        var currentArtifact = divisionContents[index];
        var $this = $(currentArtifact);

        if('headline' == currentArtifact.type){
          htmlVal += 'Title: <input class="edit-headline" type="text" value="' + currentArtifact.content + '">' +
          '<div class="separator-micro-dark"></div>';
        }else if('paragraph' == currentArtifact.type){
          htmlVal += 'Description: <textarea rows="10" name="template_editable_content" id="template_editable_content-' +
          paragraphIndex.toString() + '" cols="20">' + currentArtifact.content + '</textarea>' +
          '<div class="separator-micro-dark"></div>';
          paragraphIndex += 1;
        }else if('image' == currentArtifact.type){
          row_id = 'imagerow-' + imageIndex;
          var form_display = null;
          var link_display = null;

          if(currentArtifact.content[0].toString().match("placehold.it")){
            form_display = "block";
            link_display = "none";
          }else{
            form_display = "none";
            link_display = "block";
          }

          var remove_link = null;
          var link_text = null;

          if (currentArtifact.content[1].length != 0){
            remove_link = '<div style="display: '+ link_display +'; cursor: pointer" class="add-img-link-option"> | <a class="remove_link_from_image" href="#'+ row_id+'" role="button" data-link = "'+ currentArtifact.content[1]+'">Remove Link</a></div>' ;
            link_text = "Edit Link";
          }else{
            remove_link = "";
            link_text = "Add Link";
          }

          var links = '<div style="display: ' + link_display + '; cursor: pointer; float:left;" class="add-img-link-option"> <a id="add_link_to_image" href="#AddLink'+ row_id+'" role="button"  data-toggle="modal">'+ link_text + '</a> | <a class="remove_image" href="javascript:void(0)" data-placeholder="">Remove Image</a></div>' ;
          var image_link = currentArtifact.content[1].replace(/^https?\:\/\//i, "");

          htmlVal += '</div><div class="nl-image-form control-group" id="' + row_id + '">' +
          '<div>Preview:<br /> <img src="' + currentArtifact.content[0] + '" class="uploaded-image" data-href="' + currentArtifact.content[1] + '" /></div>' +
          '<div class="image-form-container" style="display: '  + form_display + ';"' + '>' + 
            '<label class="control-label" for="image_upload">Upload</label>' +
            '<div class="controls">' +
              '<span class="btn btn-success fileinput-button">' +
              '<i class="glyphicon glyphicon-plus"></i>' +
              '<span>Select File</span>' +
              '<input single="single" name="files[]" type="file" class="templatefileuploader">' +
              '</span>' +
               '<input type="hidden" name="image_form_action", id="image_form_action" value="' + image_form_action + '" />' +
               '<input type="hidden" name="authenticity_token" value="' + $('#authenticity_token').val() + '" />' +
               '<input type="hidden" name="imagerow" value="' + row_id +'" />' +
               '<input type="hidden" data-link-href-id="AddLink'+ row_id+'" name="href" data-populate-image-link="AddLink'+ row_id+'"/>' +
              '<br>' +
              '<br>' +
              '<div class="progress" id="progress">' +
                '<div class="bar bar-success"></div>' +
              '</div>' +
            '</div>' +
            '<div class="files" id="files">' +
            '</div>' +
          '</div>' +
          links +
          remove_link +
          '</div></div>'+
          '<div class="separator-micro-dark"></div>'+
          '<div  id="AddLink'+ row_id+'" class="modal hide fade">'+
          '<div class="modal-header">' +
          '<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>' +
          '<h3 style="color: black;">Add Link</h3></div>' +
          '<div class="modal-body">' +
          '<p><input type="url" name="link" value="'+ image_link +'" id="imageLinkModel'+ row_id+'"></p></div>' +
          '<div class="modal-footer">' +
          '<input type="submit" value="Save changes" class="btn btn-primary saveLinkUrl" data-dismiss="modal" data-image-link-url="AddLink'+ row_id+'" id="populateLink'+ row_id+'"/></div></div>';

          imageIndex += 1;
        }
      }



      OP.selectedSection.setElem(division);

      
      window.parent.$('#template_editable_content').val(htmlVal);
      window.parent.$('#template_editable_content').trigger('change');
    },


  

    //Update the section html for the updates made by user in CKEditor
    hookUpdatingSection: function(){
      $('body').on('change', '#editor_changed_content', function(){
        var properties = JSON.parse($(this).val());

        var selectedElem = OP.selectedSection.getElem();
        
        var headlines = properties.headlines;
        $(selectedElem).find( '.ss-headline').each( function( index, headlineElem ) {
          $( headlineElem ).html( headlines[index] );
        });

        var paragraphs = properties.paragraphs;
        $(selectedElem).find( '.ss-paragraph').each( function( index, paragraphElem ) {
          $( paragraphElem ).html( paragraphs[index] );
        });

        //Add appropriate Image
        var images = properties.images;
        $(selectedElem).find('.ss-replaceable-image').each( function( index, imageElem ) {

          var $imageContainer = $(imageElem);
          var placeholderSrc = $imageContainer.data('src-placeholder');
          var uploadedImageSrc = images[index][0];

          if(placeholderSrc != uploadedImageSrc){
            var $temp = $("<div />");
            var $img = $('<img />');
             var $a = $('<a />');
             var result = images[index][1].search(new RegExp(/^http/i));
              if( !result ) {
             $a.attr("href", images[index][1]);
              } else {
             $a.attr("href", "http://" + images[index][1]);
              }

             
             $a.attr("class", "imageLink");
             if(images[index][1].length > 0){
             $a.append($img); 
             }
            $img.attr({
              src: uploadedImageSrc,
              height: $imageContainer.attr('height'),
              width: $imageContainer.attr('width'),
              style: $imageContainer.attr('style'),
              'class': $imageContainer.attr('class').replace(/ss-replaceable-image/, "")
            });
            if(images[index][1].length > 0){
            $temp.append($a);
            }
            else{
             $temp.append($img);
            }
            $imageContainer.html($temp.html());
          }
        });

        OP.template.saveSectionChanges();
      });
    },

    hookImageClick: function(){
      $('body').on('click', '.imageLink', function() {
        var location = $(this).attr('href');
        window.open(location,'_blank','width=800, height=900');
        return false;
      });
    },
    //Add a new section observer
    hookAddSection: function(){
      $('body').on('click', '.add-section-link', function( event ) {
        event.preventDefault();
        var desiredGridType = $( this ).data( 'section-type' );
        var $currentGrid = $( this ).parents('.ss-grid').first();
        var requiredMarkup = $currentGrid.find( '[data-component-type="content"]' ).data( 'components' )[desiredGridType];
        if($currentGrid.find( '.no-divisions-toolset' ).length){
          $( this ).parents('.no-divisions-toolset').first().replaceWith(requiredMarkup);
        }else{
          var $currentDivision = $( this ).parents('.template-section-toolset').first().parents('.sortable-item').first();
          $currentDivision.after(requiredMarkup);
          var $addedDivision = $currentDivision.nextAll('.ss-division').first();
          $addedDivision.addClass( 'recently-added-division' );

          setTimeout( function () {
            $addedDivision.removeClass( 'recently-added-division' );
          }, 1200 );
        }

        setTimeout(function(){
          OP.template.saveSectionChanges();
        }, 100);
        
        OP.setParentIframeHeight();
        OP.setImageLinkTarget();
        OP.template.hookSortTemplateElements();
      });
    },

    //get the main window of the Optyn app.
    getParentWindow: function(){
      return window.parent.document;
    },

    //Observe the delete section and clear the fields
    hookDeleteSection: function(){
      $('body').on('click', '.ink-action-delete', function(){
        var divisionCount = $( this ).parents( '.ss-grid' ).find( '.ss-division' ).size();
        var $temp = null;
        if ( divisionCount == 1 ) {
          $toolsetCloned = $( this ).parents( '.template-section-toolset' ).first().clone();
          $toolsetCloned.find('.ink-action-edit').remove();
          $toolsetCloned.find('.ink-action-delete').remove();
          $toolsetCloned.find('.ink-action-move').remove();
          $toolsetCloned.addClass( 'no-divisions-toolset' );
          $temp = $('<div />').append( $toolsetCloned );
        }
        
        var $toolsetSortable = $(this).parents('.template-section-toolset').first().parents('.sortable-item').first()
        var $toolsetSortableParent = $toolsetSortable.parent()

        $toolsetSortable.slideUp(function(){
          $(this).remove();
          if($temp != null){
            $toolsetSortableParent.append( $temp.html());
          }

          OP.setParentIframeHeight();
          OP.template.saveSectionChanges();
          OP.setImageLinkTarget();
          window.parent.opTheme.equalizeHeights();
        }); //end of $toolsetSortable slideup
      });
    },

    saveSectionChanges: function(){
      var uri = $('#save_merchants_message_location').val();
      var messageWrapper = OP.MessageWrapper.fetch();
      messageWrapper.authenticity_token = $('#authenticity_token').val();
      messageWrapper._method = 'PUT'

      $.ajax({
        url: uri,
        type: 'PUT',
        data: JSON.stringify(messageWrapper),
        contentType: "application/json",
        success: function(){
          window.parent.$('.template-edit-actions').show();
        },
        error: function(){
          alert('We are sorry, a problem occourred while while saving your changes. Please reload your page. We are sorry.');
        }
      });

    },

    hookContentCreationOnLoad: function(){
      if($('#content_entered').length && $('#content_entered').val().length <= 0){
        OP.template.saveSectionChanges();
      }
    }

  };

  //Define the Selected Element
  Optyn.selectedSection = {
    SelectedElement: {},

    setElem: function(selectedElem){
      this.SelectedElement = selectedElem;
    },

    getElem: function(){
      return this.SelectedElement;
    },
  };

  //Define the Message json structure
  Optyn.MessageWrapper = {
    fetch: function(){
      var messageWrapper = {
        'message': {
          'containers':[]
        }
      };
      var containers = messageWrapper.message.containers

      //iterate through the containers to get the rows
      $('body').find('.ss-container').each(function(container_index, jContainer){
        var $container = $(jContainer);
        var container = {
          'type': $container.attr('data-type'),
          'rows': []
        };

        var rows = container.rows;
        //interate through the rows to get the grids
        $container.find('.ss-row').each(function(row_index, jRow){
          var $row = $(jRow);
          var row = {
            'grids': []
          };

          var grids = row.grids;
          //iterate through grids to get the various divisions
          $row.find('.ss-grid').each(function(grid_index, jGrid){
            var $grid = $(jGrid);
            var grid = {
              'divisions': []
            };

            var divisions = grid.divisions;
            //iterate through the divisions to get the divisions and the contnet of headline paragraph
            //** TODO IMPLEMENT THE CHANGES FOR THE HEADER CONTENT AND IF THE HEADER CONTENT HAS JUST AN IMAGE
            $grid.find('.ss-division').each(function(division_index, jDivision){
              var $division = $(jDivision);
              var divisionWrapper = {
                'division': {}
              };
              var division = divisionWrapper.division;

              divisionWrapper.division.type = $division.attr('data-type')

              //populate the headlines
              divisionWrapper.division.headlines = []
              headlines = divisionWrapper.division.headlines
              $division.find('.ss-headline').each(function(headline_index, headline){
                headlines.push($(headline).html());
              });

              //populate the paragraphs
              divisionWrapper.division.paragraphs =  []
              paragraphs = divisionWrapper.division.paragraphs
              $division.find('.ss-paragraph').each(function(paragraph_index, paragraph){
                paragraphs.push($(paragraph).html());
              });

              //populate the images
              divisionWrapper.division.images =  []
              images = divisionWrapper.division.images
              $division.find('.ss-replaceable-image').each(function(image_index, imageContainer){
                var $imageElem = $(imageContainer).find('img');
                if($imageElem.length){
                  images.push({
                    'url': $imageElem.attr('src'),
                    'height': $imageElem.attr('height'),
                    'width': $imageElem.attr('width'),
                    'style': $imageElem.attr('style'),
                    'class': $imageElem.attr('class'),
                    'href': $imageElem.closest('a').attr("href")
                  });
                }
              });

              divisions.push(divisionWrapper);
            }); //end of each .optyn-division

            grids.push(grid);
          }); //end of each .optyn-grid

          rows.push(row);
        }); //end of each .optyn-row

        containers.push(container);
      }); //end of each .optyn-container
      return messageWrapper;
    }

  };

  Optyn.setParentIframeHeight = function() {
    return; // Verify this function is not required and used, and remove it.
    var resize = function() {
      $( window.parent.document.body ).find( 'iframe' ).css( 'height', parseInt($( '.body > tbody > tr > .center > center' ).css( 'height' )) + 100 + 'px' );
    };
    resize();
    $( window ).resize( resize );
  };

  Optyn.setImageLinkTarget = function() {
    $('.imageLink').click(function() {
        var location = $(this).attr('href');
        window.open(location,'_blank','width=800, height=900');
        return false;
      });
  };

  return Optyn;
})(jQuery, this, this.document, OP);

// initialize on document ready
$(document).ready(function(){
  OP.template.initialize();

});