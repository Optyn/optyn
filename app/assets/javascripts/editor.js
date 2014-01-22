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
    },

    //clear the modal html on load
    hookClearModalOnLoad: function(){
      $('#editor_area_modal').toggleClass('hide');
      $('#editor_area_modal').html('');
    },

    //fire up a modal when user edits a section
    hookEditTrigger: function(){
      $('body').on('click', '.ink-action-edit', function(){
        //var $section = $(this).parents('.template-section-toolset').first().next('.template-section');
        var $grid = $(this).parents('.optyn-grid').first();
        var $editableElem = $grid.find('.columns');
        var divisionContents = {};
        if ( $grid.find('.optyn-headline').size()) {
          divisionContents.headline = $grid.find('.optyn-headline').html();
        }
        if ( $grid.find('.optyn-paragraph').size()) {
          divisionContents.paragraph = $grid.find('.optyn-paragraph').html();
        }
        if ( $grid.find('img').size()) {
          divisionContents.image = $grid.find( 'image' ).html();
        }
        console.log( Object.keys( divisionContents ), 'divisionContents:', divisionContents );
        OP.template.openCkeditor($editableElem, divisionContents);
      });
    },

    //Code to open up the CKEditor
    openCkeditor: function(editableElem, divisionContents){
        console.log( 'Trying to open the CKEditor' );
        try{
          if( CKEDITOR.instances.template_editable_content.length ) {
            console.log( 'Destroying the God damn instance.' );
            CKEDITOR.instances.template_editable_content.destroy();
          }
        }catch(err){}


        var contentlVal = $(editableElem).html();
        var htmlVal = '';
        if ( 'headline' in divisionContents ) {
          htmlVal += '<input type="text" value="' + divisionContents.headline + '">';
        }
        if ( 'paragraph' in divisionContents ) {
          htmlVal += '<textarea rows="10" name="template_editable_content" id="template_editable_content" cols="20">' + divisionContents.paragraph + '</textarea>';
        }
        if ( 'image' in divisionContents ) {
          htmlVal += '<br /><br />Show image upload form. If image already present, show thumbnail and replace image button.';
        }
        OP.template.populateModalCase(htmlVal);
        $('#editor_area_modal').modal('show');

        if ( 'paragraph' in divisionContents ) {
          CKEDITOR.replace('template_editable_content');
          CKEDITOR.instances.template_editable_content.setData(divisionContents.paragraph);
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
          '<div class="row-fluid">' +
          htmlVal +
          '</div>' +
        '</div>' +
        '<div class="modal-footer">' +
          '<button class="btn" data-dismiss="modal">Close</button>' +
          '<button class="btn btn-primary" id="section_save_changes">Save changes</button>' +
        '</div>';

      $('#editor_area_modal').html(caseHtml);
    },

    //Add a new section observer
    hookAddSection: function(){
      $('body').on('click', '.add-section-link', function( event ) {
        event.preventDefault();
        var desiredGridType = $( this ).data( 'section-type' );
        var requiredMarkup = $( '[data-component-type="content"]' ).data( 'components' )[desiredGridType];
        //console.log( requiredMarkup );
        var $containerParent = $( this ).parents( '.optyn-content' ).first().find( 'td' ).first();
        requiredMarkup = '<table class="optyn-row"><tbody><tr><td>' +
          '<table class="columns optyn-grid"><tbody><tr><td>' +
          requiredMarkup +
          '</td></tr></tbody></table>' +
          '</td></tr></tbody></table>';
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

                divisionWrapper.division.headline = $division.find('.optyn-headline').html(); 
                divisionWrapper.division.paragraph =  $division.find('.optyn-paragraph').html();

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
