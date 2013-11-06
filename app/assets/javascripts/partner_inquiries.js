$(document).ready(function(){
  var partnerInquiry = new PartnerInquiry();
  partnerInquiry.initialize();
});


function PartnerInquiry(){
  this.initialize = function(){
    if($('#partner_inquiry_wrapper').length){
      this.hookFormSubmission();
    }
  };

  this.hookFormSubmission = function(){
    var formId = '#partner_inquiry_form';
    $('body').on('submit', formId, function(event){
      event.preventDefault();

      var $form = $(formId);

      $.ajax({
        url: $form.attr('action'),
        type: 'POST',
        data: $form.serialize(),
        beforeSend: function(){
          $form.find('input[type=submit]').attr('disabled', 'disabled');
          $form.find('#loading').show();
        },
        success: function(){
          $('#partner_inquiry_wrapper').html('<strong>Thank you ver much for your inquiry. We will be in touch whithin 24 hours or less</strong>');
        },
        error: function(data){
          $('#partner_inquiry_wrapper').html(data.responseText);
        },
        complete: function(){
          $("html, body").animate({ scrollTop: 0 }, "slow");
        } 
      });
    });
  }
}