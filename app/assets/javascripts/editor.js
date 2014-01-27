//= require jquery
//= require jquery_ujs
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
        var $grid = $(this).parents('.template-section-toolset').first().next( '.optyn-division' ),
          $editableElem = $grid.find('.columns'),
          headlineTexts = [],
          paragraphMarkups = [],
          divisionContents = {};
        divisionContents.imageURLs = [];
        divisionContents.texts = [];

        $grid.find( '.optyn-headline' ).each( function() {
          headlineTexts.push( $( this ).text());
        });
        $grid.find( '.optyn-paragraph' ).each( function() {
          paragraphMarkups.push( $( this ).html());
        });
        $grid.find( 'img' ).each( function() {
          divisionContents.imageURLs.push( $( this ).attr( 'src' ));
        });
        //console.log( headlineTexts, paragraphMarkups, divisionContents.imageURLs );

        // Forming pairs of headlines and paragraphs. Assuming each headline has
        // an associated paragraph.
        for ( var count = 0; count < headlineTexts.length; count++ ) {
          divisionContents.texts.push({
            heading: headlineTexts[ count ],
            paragraph: paragraphMarkups[ count ]
          });
        }

        if ( $grid.find('.optyn-headline').size()) {
          divisionContents.headline = $grid.find('.optyn-headline').html();
        }
        if ( $grid.find('.optyn-paragraph').size()) {
          divisionContents.paragraph = $grid.find('.optyn-paragraph').html();
        }
        if ( $grid.find('img').size()) {
          divisionContents.image = $grid.find( 'img' ).attr('src');
        }
        console.log( 'divisionContents keys:', Object.keys( divisionContents ), divisionContents );
        OP.template.openCkeditor($editableElem, divisionContents);
      });
    },

    //Code to open up the CKEditor
    openCkeditor: function(editableElem, divisionContents){
        // Add fields for editing headlines, images and paragraphs. Only paragraphs open in CKEditor.
        console.log( 'Trying to open the CKEditor' );
        try{
          if( CKEDITOR.instances.template_editable_content.length ) {
            console.log( 'Destroying the God damn instance.' );
            CKEDITOR.instances.template_editable_content.destroy();
          }
        }catch(err){}

        var contentlVal = $(editableElem).html();
        var htmlVal = '';

        for ( var count = 0; count < divisionContents.texts.length; count++ ) {
          htmlVal += '<input class="edit-headline" type="text" value="' + divisionContents.texts[0].heading + '">';
          htmlVal += '<textarea rows="10" name="template_editable_content" id="template_editable_content-' + count + '" cols="20">' + divisionContents.paragraph + '</textarea>';
        }
        for ( var count = 0; count < divisionContents.imageURLs.length; count++ ) {
          htmlVal += '<div class="blank-space"></div><div class="row-fluid">' +
            '<div class="span4">Preview:<br /><img src="' + divisionContents.imageURLs[count] + '" /></div>' +
            '<div class="span8">Upload:<br /><input type="file" accept=".jpg,.png,.gif,.jpeg"><br />' +
            '<input type="button" value="Upload image" class="btn btn-success btn-small" /></div></div>';
        }

        OP.template.populateModalCase(htmlVal);
        $('#editor_area_modal').modal('show');

        for ( var count = 0; count < divisionContents.texts.length; count++ ) {
          CKEDITOR.replace( 'template_editable_content-' + count );
          CKEDITOR.instances.template_editable_content.setData( divisionContents.texts[count].paragraph );
        }

        OP.selectedSection.setElem(editableElem);
    },

    //Update the section html for the updates made by user in CKEditor
    hookUpdatingSection: function(){
      $('body').on('click', '#section_save_changes', function(){
        var selectedElem = OP.selectedSection.getElem();
        $(selectedElem).html(CKEDITOR.instances.template_editable_content.getData());
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
        var requiredMarkup = $( '[data-component-type="content"]' ).data( 'components' )[desiredGridType];
        var $containerParent = $( this ).parents( '.optyn-grid' ).first();
        console.log()
        $containerParent.append( requiredMarkup );
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
        var $elementToRemove = $( this ).parents( 'td' ).first();  // Should we remove .optyn-grid over here?
        console.log( $elementToRemove );
        $elementToRemove.slideUp( function() { $( this ).remove(); });
        return;
        var $toolsetContainer = $(this).parents('.template-section-toolset').first();
        var $templateSection = $toolsetContainer.nextAll('.template-section').first();
        var $templateSectionForm = $templateSection.nextAll('.template-section-form');
        OP.template.saveSectionChanges();
        $toolsetContainer.remove();
        $templateSection.remove();
        $templateSectionForm.remove();
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
      SelectedElement = selectedElem;
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
