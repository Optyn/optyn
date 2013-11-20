$(document).ready(function(){
  var socialProfile = new SocialProfile();
  socialProfile.initialize();  
});

function SocialProfile(){
  this.initialize = function(){
    if($('#social_profile_table').length){
      this.hookModal();
      this.hookAddNewProfileLink();
      this.hookEditProfileLink();      
      this.hookModalClose();
      this.hookFormSubmission()
    }
  };

  this.hookModal = function(){
    $('#social_profile_wrapper').modal({
      keyboard: false,
      show: false
    });
  };

  this.hookAddNewProfileLink = function(){
    var current = this;
    $('body').on('click', '.soical-profile-action-new', function(event){
      event.preventDefault();

      current.populateAddEditLink(this);     
    });
  };

  this.hookEditProfileLink = function(){
    var current = this;
    $('body').on('click', '.soical-profile-action-edit', function(event){
      event.preventDefault();

      current.populateAddEditLink(this);
    });
  }

  this.hookModalClose = function(){
    $('#social_profile_wrapper').on('hidden', function(){
      $('#social_profile_wrapper').html('<div id="loading" class="social-profile-loader">&nbsp;</div>');
    });    
  };

  this.hookFormSubmission  = function(){
    $('body').on('submit', '#social_profile_form', function(event){
      event.preventDefault();

      var $form = $(this);
      $.ajax({
        url: $form.attr('action'),
        type: 'POST',
        data: $form.serialize(),
        beforeSend: function(){
          $form.find('input[type=submit]').hide();
          $form.find('.btn').hide();
          $form.find('.form-spinner').show();
        },
        success: function(data){
          $('#social_profile_table').replaceWith(data);

          $('#social_profile_wrapper').modal('hide');
        },
        error: function(data){
          $('#social_profile_wrapper').html(data.responseText);
        }
      });
    });  
  };

  this.populateAddEditLink = function(link){
    $.ajax({
      url: $(link).attr('href'),
      type: 'GET',
      beforeSend: function(){
        $('#social_profile_wrapper').modal('show');
      },
      success: function(data){
        $('#social_profile_wrapper').html(data);
      },
      error: function(data){
        $('#social_profile_wrapper').html(data);
      }  
    });
  };
}

