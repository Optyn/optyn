var OP = OP || {};
OP = (function($, window, doucument, Optyn){

  //Define the template Object and behavior
  Optyn.tours = {};
  Optyn.tours.initialize = function() {
    // console.log( 'tour init' );
    this.templateEditorTour();
  };

  Optyn.tours.templateEditorTour = function() {
    $( '#customHtmlTemplate' ).load( function() {
      if ( docCookies.getItem( 'dontShowTmplTourAgain' ) === null || docCookies.getItem( 'dontShowTmplTourAgain' ) !== 'true' ) {
        $( 'body' ).prepend( '<div id="tmpl-editor-tour-alert" class="alert" style="display:none;text-align:center;"><a class="btn btn-small btn-primary" href="#" id="start-tmpl-editor-tour">Watch instructions on how to edit a template</a> <a class="btn btn-small" href="#" id="dont-show-tmpl-editor-tour">Do not show this again.</a></div>' );
        $( '#tmpl-editor-tour-alert' ).slideDown();
      }
      $( '#start-tmpl-editor-tour' ).click( function() {
        $( '.alert' ).slideUp( function() {
          $( this ).remove();
          $( '#customHtmlTemplate' ).contents().find( 'body' ).chardinJs( 'start' );
        });
      });
      $( '#dont-show-tmpl-editor-tour' ).click( function() {
        docCookies.setItem( 'dontShowTmplTourAgain', 'true' );
        $( '.alert' ).slideUp( function() { $( this ).remove(); });
      });
    });
  };

  return Optyn;
})( jQuery, this, this.document, OP );



$( function() {
  if ( $( '#customHtmlTemplate' ).length && $( 'body' ).hasClass( 'template' )) {
    OP.tours.initialize();
  }
});
