//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= jquery-migrate-1.2.1
//= require bootstrap
//= require_self
//= require ckeditor/init

var OP = OP || {};
OP = (function($, window, doucument, Optyn){

  //Define the template Object and behavior
  Optyn.template = {

    initialize: function(){
      this.hookClearModalOnLoad();
      this.hookUpdatingSection();
      this.hookModalHidden();
      this.hookEditTrigger();
      this.hookAddSection();
      this.hookDeleteSection();
      this.hookContentCreationOnLoad();
    },

    //clear the modal html on load
    hookClearModalOnLoad: function(){
      $('#editor_area_modal').toggleClass('hide');
      $('#editor_area_modal').html('');
    },

    //fire up a modal when user edits a section
    hookEditTrigger: function() {
      $('body').on('click', '.ink-action-edit', function() {
        //var $section = $(this).parents('.template-section-toolset').first().next('.template-section');
        var $division = $(this).parents('.template-section-toolset').first().next( '.optyn-division' ),
          $editableElem = $division.find('.optyn-division'),
          divisionContents = [];

        $division.find('.optyn-headline, .optyn-paragraph, .optyn-replaceable-image').each(function(index, updateableElement){
          var $updateableElement = $(updateableElement);
          var artifact = null;

          if($updateableElement.hasClass('optyn-headline')){
            artifact = {type: 'headline', content: $updateableElement.text()};
          }else if($updateableElement.hasClass('optyn-paragraph')){
            artifact = {type: 'paragraph', content: $updateableElement.html()};
          }else if($updateableElement.hasClass('optyn-replaceable-image')){
            var placeholderSrc = null;
            var $image = $updateableElement.find('img');

            if($image.length){
              placeholderSrc = $image.attr('src');
            }else{
              placeholderSrc =  $updateableElement.data( 'src-placeholder' );
            }

            artifact = {type: 'image', content: placeholderSrc};
          }

          divisionContents.push(artifact);
        });

        // console.log("Division Contents", divisionContents)

        OP.template.openCkeditor($division, divisionContents);
      });
    },

    //Code to open up the CKEditor
    openCkeditor: function(division, divisionContents){

        // Add fields for editing headlines, images and paragraphs. Only paragraphs open in CKEditor.
        // console.log( 'Trying to open the CKEditor' );
        try{
          if( CKEDITOR.instances.template_editable_content.length ) {
            console.log( 'Destroying the God damn instance.' );
            CKEDITOR.instances.template_editable_content.destroy();
          }
        }catch(err){}

        var htmlVal = '';
        var image_form_action = "/merchants/messages/" + $('#editor_area_modal').data('msg-id') + "/template_upload_image"
        var paragraphIndex = 0
        var imageIndex = 0

        for( var index = 0; index < divisionContents.length; index++) {
          var currentArtifact = divisionContents[index];
          var $this = $(currentArtifact);

          if('headline' == currentArtifact.type){
            htmlVal += 'Title: <input class="edit-headline" type="text" value="' + currentArtifact.content + '">';
          }else if('paragraph' == currentArtifact.type){
            htmlVal += 'Description: <textarea rows="10" name="template_editable_content" id="template_editable_content-' +
              paragraphIndex.toString() + '" cols="20">' + currentArtifact.content + '</textarea>' +
              '<div class="blank-space"></div>';

              paragraphIndex += 1;
          }else if('image' == currentArtifact.type){
            row_id = 'imagerow-' + imageIndex;
            htmlVal += '<div class="blank-space"></div><div class="row-fluid" id="' + row_id + '">' +
            '<div class="span4">Preview:<br /><img src="' + currentArtifact.content + '" class="uploaded-image" /></div>' +
            '<div class="span8"><form class="msg_img_upload" action="' + image_form_action + '" method="post" enctype="multipart/form-data" data-remote="true" >' +
            '<input type="hidden" name="authenticity_token" value="' + $('#authenticity_token').val() + '" />' +
            '<input type="hidden" name="imagerow" value="' + row_id +'" />' +
            '<div class="span8">Upload:<br /><input type="file" name="imgfile" accept=".jpg,.png,.gif,.jpeg"><br />' +
            '<input type="submit" value="Upload image" class="upload-img-btn btn btn-success btn-small" /></div>' +
            '<img class="loading" src="/assets/ajax-loader.gif"/></form></div></div>';

            imageIndex += 1;
          }
        }

        OP.template.populateModalCase(htmlVal);
        $('#editor_area_modal').modal('show');

        for ( var count = 0; count < paragraphIndex; count++ ) {
          CKEDITOR.replace( 'template_editable_content-' + count );
          (CKEDITOR.instances['template_editable_content-' + count]).setData( divisionContents );
        }

        OP.selectedSection.setElem(division);

        $('.upload-img-btn').click(function(e){
          $(this).parents('.msg_img_upload').first().find('.loading').first().show();
        });
    },



    //Update the section html for the updates made by user in CKEditor
    hookUpdatingSection: function(){
      $('body').on('click', '#section_save_changes', function(){
        var selectedElem = OP.selectedSection.getElem();
        $(selectedElem).find( '.optyn-headline').each( function( index, headlineElem ) {
          var newHeadline = $($('#editor_area_modal').find( '.edit-headline')[index]).val();
          $( headlineElem ).html( newHeadline );
        });

        $(selectedElem).find( '.optyn-paragraph').each( function( index, paragraphElem ) {
          var newPara = CKEDITOR.instances['template_editable_content-' + index].getData();
          $( paragraphElem ).html( newPara );
        });

        //Add appropriate Image
        $(selectedElem).find( '.optyn-replaceable-image').each( function( index, imageElem ) {

          var $imageContainer = $(imageElem);
          var placeholderSrc = $imageContainer.data('src-placeholder');
          var $uploadedImage = $($('#editor_area_modal' + " " + ".uploaded-image")[index])

          if($uploadedImage != null && $uploadedImage != undefined && placeholderSrc != $uploadedImage.attr('src')){
            var $temp = $("<div />");
            var $img = $('<img />');

            $img.attr({
              src: $uploadedImage.attr('src'),
              height: $imageContainer.attr('height'),
              width: $imageContainer.attr('width')
            });
            $temp.append($img);

            $imageContainer.html($temp.html());
          }
        });

        $('#editor_area_modal').modal('hide');

        OP.template.saveSectionChanges();
      });
    },

    //Clear the modal html on its hidden event
    hookModalHidden: function(){
      $('#editor_area_modal').on('hidden', function(){
        $('#editor_area_modal').html('');
      });
    },

    //poplate modal on open
    populateModalCase: function(htmlVal){
      var caseHtml = '<div class="modal-header">' +
          '<h3>Edit Content</h3>' +
        '</div>' +
        '<div class="modal-body">' +
          '<div>' +
          htmlVal +
          '</div>' +
        '</div>' +
        '<div class="modal-footer">' +
          '<button class="btn btn-small" data-dismiss="modal">Close</button>' +
          '<button class="btn btn-small btn-primary" id="section_save_changes">Save changes</button>' +
        '</div>';

      $('#editor_area_modal').html(caseHtml);
    },

    //Add a new section observer
    hookAddSection: function(){
      $('body').on('click', '.add-section-link', function( event ) {
        event.preventDefault();
        var desiredGridType = $( this ).data( 'section-type' );
        var requiredMarkup = $( this ).parents('.optyn-grid').first().find( '[data-component-type="content"]' ).data( 'components' )[desiredGridType];
        if($( '.no-divisions-toolset' ).length){
          $( '.no-divisions-toolset' ).replaceWith(requiredMarkup);
        }else{
          var $currentDivision = $( this ).parents('.template-section-toolset').first().next('.optyn-division');
          $currentDivision.after(requiredMarkup);
        }

        OP.template.saveSectionChanges();
      });
    },

    //get the main window of the Optyn app.
    getParentWindow: function(){
      return window.parent.document;
    },

    //Observe the delete section and clear the fields
    hookDeleteSection: function(){
      $('body').on('click', '.ink-action-delete', function(){
        var divisionCount = $( this ).parents( '.optyn-grid' ).find( '.optyn-division' ).size();
        var $temp = null;
        if ( divisionCount == 1 ) {
          console.log( divisionCount );
          $toolsetCloned = $( this ).parents( '.template-section-toolset' ).first().clone();
          $toolsetCloned.find('.ink-action-edit').remove();
          $toolsetCloned.find('.ink-action-delete').remove();
          $toolsetCloned.addClass( 'no-divisions-toolset' );
          $temp = $('<div />').append( $toolsetCloned );
        }
        var $toolset = $(this).parents('.template-section-toolset').first();
        var $toolsetParent = $toolset.parent();
        var $division = $(this).parents('.template-section-toolset').first().next( '.optyn-division' );
        $toolset.slideUp( function() { $( this ).remove(); });
        $division.slideUp( function() {
          $( this ).remove();
          if($temp != null){
            $toolsetParent.append( $temp.html());
          }
          OP.template.saveSectionChanges();
        }); //end of slide up division
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
        error: function(){
          alert('We are sorry, a problem occourred while while saving your changes. Please reload your page. We are sorry.');
        }
      });

    },

    hookContentCreationOnLoad: function(){
      if($('#content_entered').length && $('#content_entered').val().length <= 0){
        OP.template.saveSectionChanges();
      }
    },

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
        var messageWrapper = {'message': {'containers':[]}};
        var containers = messageWrapper.message.containers

        //iterate through the containers to get the rows
        $('body').find('.optyn-container').each(function(container_index, jContainer){
          var $container = $(jContainer);
          var container = {'type': $container.attr('data-type'), 'rows': []};

          var rows = container.rows;
          //interate through the rows to get the grids
          $container.find('.optyn-row').each(function(row_index, jRow){
            var $row = $(jRow);
            var row = {'grids': []};

            var grids = row.grids;
            //iterate through grids to get the various divisions
            $row.find('.optyn-grid').each(function(grid_index, jGrid){
              var $grid = $(jGrid);
              var grid = {'divisions': []};

              var divisions = grid.divisions;
              //iterate through the divisions to get the divisions and the contnet of headline paragraph
              //** TODO IMPLEMENT THE CHANGES FOR THE HEADER CONTENT AND IF THE HEADER CONTENT HAS JUST AN IMAGE
              $grid.find('.optyn-division').each(function(division_index, jDivision){
                var $division = $(jDivision);
                var divisionWrapper = {'division': {}};
                var division = divisionWrapper.division;

                divisionWrapper.division.type = $division.attr('data-type')

                //populate the headlines
                divisionWrapper.division.headlines = []
                headlines = divisionWrapper.division.headlines
                $division.find('.optyn-headline').each(function(headline_index, headline){
                  headlines.push($(headline).html());
                });

                //populate the paragraphs
                divisionWrapper.division.paragraphs =  []
                paragraphs = divisionWrapper.division.paragraphs
                $division.find('.optyn-paragraph').each(function(paragraph_index, paragraph){
                  paragraphs.push($(paragraph).html());
                });

                //populate the images
                divisionWrapper.division.images =  []
                images = divisionWrapper.division.images
                $division.find('.optyn-replaceable-image').each(function(image_index, imageContainer){
                  var $imageElem = $(imageContainer).find('img');
                  if($imageElem.length){
                    images.push({'url': $imageElem.attr('src')});
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
      },
  };

  return Optyn;
})(jQuery, this, this.document, OP);

// initialize on document ready
$(document).ready(function(){
  OP.template.initialize();
});
