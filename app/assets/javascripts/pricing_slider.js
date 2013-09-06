$( function() {

  $( '#tiers #myCarousel' ).carousel({ interval: false });
  //$( '#tiers #myCarousel' ).carousel( 'pause' );

  $( '#tiers #pricing-slider' ).slider({
    min: 1,
    max: 25000,
    range: 'min',
    change: function( event, ui ) {
      $( '#tiers .cus-count' ).text( ui.value + ' customers' );
      suggestPlan( ui.value );
    }
  });

  function highlightPlan( carouselIndex, planId ) {
    $( '#tiers #myCarousel' ).carousel( carouselIndex );
    $( '#tiers #myCarousel' ).carousel( 'pause' );

    // Highlight current plan.
    $( '#myCarousel .plan.current' ).removeClass( 'current' );
    $( '[data-plan-id=' + planId + ']' ).addClass( 'current' );

    // Highlight button for current plan.
    $( '.plans .btn.btn-primary' ).removeClass( 'btn-primary' );
    $( '[data-plan-id=' + planId + '] .btn' ).addClass( 'btn-primary' );

    $( '#tiers .plan-price' ).text( $( '[data-plan-id=' + planId + '] h5' ).text());
  }

  function suggestPlan( customerCount ) {
    switch (true) {
      case ((customerCount === 0)):
        highlightPlan( 0 );
        break;
      case ((customerCount > 0) && (customerCount <= 100)):
        highlightPlan( 0, 0 );
        break;
      case ((customerCount >= 101) && (customerCount <= 1000)):
        highlightPlan( 0, 1 );
        break;
      case ((customerCount >= 1001) && (customerCount <= 2500)):
        highlightPlan( 0, 2 );
        break;
      case ((customerCount >= 2501) && (customerCount <= 5000)):
        highlightPlan( 1, 3 );
        break;
      case ((customerCount >= 5001) && (customerCount <= 10000)):
        highlightPlan( 1, 4 );
        break;
      case ((customerCount >= 10001) && (customerCount <= 15000)):
        highlightPlan( 1, 5 );
        break;
      case ((customerCount >= 15001) && (customerCount <= 20000)):
        highlightPlan( 2, 6 );
        break;
      case ((customerCount >= 20001) && (customerCount <= 25000)):
        highlightPlan( 2, 7 );
        break;
      default:
        console.log( 'value out of range' );
    }  // end of switch
  }  // /suggestPlan()

});
