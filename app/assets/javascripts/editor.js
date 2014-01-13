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
      this.sprinkleToolsetOnLoad();
      this.hookUpdatingSection();
      this.hookModalHidden();
      this.hookEditTrigger();
      this.hookAddSection();
      this.hookDeleteSection();
    },

    //Add the toolsets new, edit and delete
    sprinkleToolsetOnLoad: function(){
      var toolset = OP.template.getToolSetMarkup();
      $('.template-section').each(function(){
        $(this).before(toolset);
      });
    },

    //Create the toolsets new, edit and delete html markup
    getToolSetMarkup: function(){
      var dropdownLinks = "";
      $('.addable-section').each(function(){
        dropdownLinks += '<li>' + '<a class="add-section-link" href="#"' + ' data-section-type= ' + '"' + $(this).attr('data-section-type') + '"' + '>' + '&nbsp;&nbsp;' + $(this).val() + '&nbsp;</a>' + '</li>'
      });

      var toolset = '<div class="row template-section-toolset">' +
      '<div class="btn-group pull-right">' +
      '<button class="btn ink-action-edit"><i class="icon-edit icon-white"></i></button>' +
      '<button class="btn ink-action-delete"><i class="icon-trash icon-white action-delete"></i></button>' + 
      '<a class="btn dropdown-toggle" data-toggle="dropdown" href="#">' +
      '<i class="icon-plus icon-white">' +
      '&nbsp;' +
      '<span class="caret">' +
      '</span>' +
      '</a>' +
      '<ul class="dropdown-menu">' +
        dropdownLinks +
      '</ul>' +
      '</div>' +
      '</div>';

      return toolset;
    },

    //clear the modal html on load
    hookClearModalOnLoad: function(){
      $('#editor_area_modal').toggleClass('hide');
      $('#editor_area_modal').html('');
    },

    //fire up a modal when user edits a section
    hookEditTrigger: function(){
      $('body').on('click', '.ink-action-edit', function(){
        var $section = $(this).parents('.template-section-toolset').first().next('.template-section');
        var $editableElem = $section.find('.ink-editable');
        var content = $(this).parents('td').find('.headline').html();
        OP.template.openCkeditor($editableElem, content);
      });
    },

    //Code to open up the CKEditor
    openCkeditor: function(editableElem, content){
        console.log( "Trying to open the CKEditor", content );
        try{
          if( CKEDITOR.instances.template_editable_content.length ) {
            console.log( 'Destroying the God damn instance.' );
            CKEDITOR.instances.template_editable_content.destroy();
          }
        }catch(err){}

        
        var contentlVal = $(editableElem).html();
        var htmlVal = '<textarea rows="10" name="template_editable_content" id="template_editable_content" cols="20">' + contentlVal + '</textarea>'
        OP.template.populateModalCase(htmlVal);
        $('#editor_area_modal').modal('show');    

        CKEDITOR.replace('template_editable_content');
        CKEDITOR.instances.template_editable_content.setData(content);
        OP.selectedSection.setElem(editableElem);
    },

    //Update the section html for the updates made by user in CKEditor
    hookUpdatingSection: function(){
      $('body').on('click', '#section_save_changes', function(){
        var selectedElem = OP.selectedSection.getElem();
        $(selectedElem).html(CKEDITOR.instances.template_editable_content.getData());
        $('#editor_area_modal').modal('hide');
        OP.template.updateRemoteSection(selectedElem);
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
          '<h3>' +
            'Contnet' +
          '</h3>' +
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

    //Ajax call to update the section on the server
    updateRemoteSection: function(selectedElem){
      var $form = $(selectedElem).parents('.template-section').next('.template-section-form').first();
      var $temp = $('<div />');
      $temp.append($(selectedElem).parents('.template-section').first().clone());

      $form.find('.hidden-content').val($temp.html());
      $.ajax({
        url: $form.attr('action'),
        type: "POST",
        data: $form.serialize(),
        error: function(){
          alert("A problem occourred while updating the content. Please reload your page. We are sorry.");
        }
      });
    },

    //Add a new section observer
    hookAddSection: function(){
      $('body').on('click', '.add-section-link', function(){
        OP.template.addRemoteSection($(this));
      });
    },

    //Ajax to create a new section on the server
    addRemoteSection: function(toAddElem){
      var $linkElem = $(toAddElem);
      var $toolset = $linkElem.parents('.template-section-toolset').first();
      var $currentSectionForm = $toolset.nextAll('.template-section-form').first();
      var $currentSectionPosition = $currentSectionForm.find('.section-id');

      $.ajax({
        url: $('#add_new_section_location').val(),
        type: 'POST',
        data: {'previous_id': $currentSectionPosition.val(), 'section_type': $linkElem.attr('data-section-type'), 'authenticity_token': $currentSectionForm.find('input[name=authenticity_token]').val()},
        beforeSend: function(){
          var $parentWindow = $(OP.template.getParentWindow());
          $parentWindow.find('#loading').show();
        },
        success: function(data){
          $currentSectionForm.after(data);
          var toolset = OP.template.getToolSetMarkup();
          $currentSectionForm.after(toolset);
        },
        error: function(){
          alert("A problem occourred while while adding a section. Please reload your page. We are sorry.");
        },
        complete: function(){
          var $parentWindow = $(OP.template.getParentWindow());
          $parentWindow.find('#loading').hide();
        }
      });
    },

    //get the main window of the Optyn app.
    getParentWindow: function(){
      return window.parent.document;
    },

    //Observe the delete section and clear the fields
    hookDeleteSection: function(){
      $('body').on('click', '.ink-action-delete', function(){
        var $toolsetContainer = $(this).parents('.template-section-toolset').first();
        var $templateSection = $toolsetContainer.nextAll('.template-section').first();
        var $templateSectionForm = $templateSection.nextAll('.template-section-form');
        OP.template.deleteRemoteSection($templateSectionForm);
        $toolsetContainer.remove();
        $templateSection.remove();
        $templateSectionForm.remove();
      });
    },

    //Ajax for remote delete of a section
    deleteRemoteSection: function(templateSectionForm){
      var url = $(templateSectionForm).find('.delete-section-location').val();
      var authenticity_token = $(templateSectionForm).find('input[name=authenticity_token]').val()
      console.log('Url', url);
      $.ajax({
        url: url,
        type: "POST",
        data: {'_method': 'delete', 'authenticity_token': authenticity_token},
        success: function(){

        },
        error: function(){
          alert("A problem occourred while deleting. Please reload your page. We are sorry.");
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
      return SelectedElement;
    },
  };

  return Optyn;
})(jQuery, this, this.document, OP)

// initialize on document ready
$(document).ready(function(){
  OP.template.initialize();
});
