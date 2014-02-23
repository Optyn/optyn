function stripeResponseHandler(status, response) {
  if (response.error) {
      $(".payment-errors").text(response.error.message);
  } 
  else {
      var form$ = $("#stripe-form");
      var token = response['id'];
      form$.append("<input type='hidden' name='stripeToken' value='" + token + "'/>");
      form$.get(0).submit();
  }
}

$(document).ready(function() {

  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));

  $("#stripe-form").submit(function(event) {
    $('.pay-button').attr("disabled", "disabled");

    Stripe.createToken({
        number: $('.credit-number').val(),
        cvc: $('.credit-security').val(),
        exp_month: $('.card-expiry-month').val(),
        exp_year: $('.card-expiry-year').val()
    }, stripeResponseHandler);

    return false;
  });

});