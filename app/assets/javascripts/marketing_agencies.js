$(document).ready(function(){
  var partnerInquiry = new PartnerInquiry();
  partnerInquiry.initialize();


  function PartnerInquiry(){
    this.initialize = function(){
      if($('#marketing_inquiry_wrapper').length){
        this.hookFormSubmission();
        this.initSlider();
      }
    };

    this.hookFormSubmission = function(){
      var formId = '#marketing_agency_form';
      $('body').on('submit', formId, function(event){
        event.preventDefault();

        var $form = $(formId);

        if ( $('#pin-not-bot').slider( 'value' ) === 100 ) {
          $.ajax({
            url: $form.attr('action'),
            type: 'POST',
            data: $form.serialize(),
            beforeSend: function(){
              $form.find('input[type=submit]').attr('disabled', 'disabled');
              $form.find('#loading').show();
            },
            success: function(){
               window.location = "/marketing-agency/thank-you";
            },
            error: function(data){
              $('#marketing_inquiry_wrapper').html(data.responseText);
              partnerInquiry.initSlider();
            },
            complete: function(){
              $("html, body").animate({ scrollTop: 0 }, "slow");
            }
          });
        }
        else {
          alert( 'Please use the slider to unlock the submit button.');
        }
      });
    };

    this.initSlider = function() {
      $( '#pin-not-bot' ).slider({
        min: 0,
        max: 100,
        stop: function( event, ui ) {
          if ( $(this).slider( 'value' ) === 100 )
            $( '.pin-submit' ).removeAttr( 'disabled');
          else
            $( '.pin-submit' ).attr( 'disabled', 'disabled' );
        }
      });
    };
  }
});
