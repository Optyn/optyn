
var OP = OP || {};

OP = (function($, window, doucument, Optyn){

  Optyn.StaticPages = {};

  Optyn.StaticPages.initialize = function() {
    if ( $( '#cc-price' ).length ) { this.constantContactPricingComparison(); }
    if ( $( 'body' ).hasClass( 'email_marketing' )) { this.moveBreadcrumbsToBottom(); }

    // Show acquisition message modal on static pages.
    if ( $( '.sa-modal' ).length ) { $( '.sa-modal' ).modal( 'show' ); }
  };

  Optyn.StaticPages.constantContactPricingComparison = function() {
    // Code for Constant Contact pricing section.
    $( '#custom-price' ).keyup( function() {
      if ( $( this ).val() < 0 ) {
        $( '#op-price' ).text( '' );
        return;
      }
      $( '#op-price' ).text( Math.floor( $( this ).val() / 2 ));
    });
    $( '#cc-price' ).change( function() {
      if ( $( this ).val() === 'other' ) {
        $( '.ccc-price' ).val( '' ).slideDown();
        $( '#op-price' ).text( '' );
        return;
      }
      $( '.ccc-price' ).slideUp();
      $( '#op-price' ).text( Math.floor( $( this ).val() / 2 ));
    });
  };

  Optyn.StaticPages.moveBreadcrumbsToBottom = function() {
    console.log( 'moveBreadcrumbsToBottom' );
    $breadCrumbs = $( '.breadcrumbs' ).detach();
    $( 'footer' ).before( $breadCrumbs );
  };

  return Optyn;
})(jQuery, this, this.document, OP);



$(document).ready(function(){
  OP.StaticPages.initialize();
});
