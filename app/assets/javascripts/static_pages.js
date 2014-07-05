
$( function() {
  // Code for Constant Contact pricing section.
  $( '#custom-price' ).keyup( function() {
    if ( $( this ).val() < 0 ) {
      $( '#op-price' ).text( '' );
      return;
    }
    $( '#op-price' ).text( Math.floor( $( this ).val() / 2 ));
  });
  if ( $( '#cc-price' ).length ) {
    // 
    $( '#cc-price' ).change( function() {
      if ( $( this ).val() === 'other' ) {
        $( '.ccc-price' ).val( '' ).slideDown();
        return;
      }
      $( '.ccc-price' ).slideUp();
      $( '#op-price' ).text( Math.floor( $( this ).val() / 2 ));
    });
  }
});
