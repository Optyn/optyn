$(document).ready(function () {
  if ($('#filter_Form .chzn-select').length) {
    $('.chzn-select').chosen();
  }
  if ( $('#toggle-search-form-visibility').length) {
    $( '#toggle-search-form-visibility' ).click( function() {
      $( '#filter_Form' ).toggleClass( 'filter_Form-visible' );
    });
  }
});
