$( function() {
  opTheme = {};


  // Equalize div heights
  opTheme.equalizeDivHeights = function( selectorArray ) {
    // This function is made to be used with Message Center.
    $('#preview_wrapper td:first td:first').css( 'vertical-align', 'top' );
    var setHt = function() {
      // This function sets width of the team member divs.
      var maxHt = 0;
      var minHt = $( window ).height() - parseInt( $( 'h1.dark-heading' ).css( 'height' ));
      $( selectorArray ).each( function( index, value ) {
        $( value ).css( 'min-height', 'auto' );
      });
      $( selectorArray ).each( function( index, value ) {
        if (( parseInt($( value ).css( 'height' ))) > maxHt ) {
          maxHt = parseInt( $( value ).css( 'height' ));
        }
      });
      $( selectorArray ).each( function( index, value ) {
        var previewHeaderHeight = 0;
        if ( $( '.preview-header' ).length && value === '#preview_wrapper td:first' ) {
          // Hack for preview campaign email pane.
        }
        if ( value === '#preview_wrapper' && $( 'body').hasClass( 'preview' )) {
          // Take care of .preview-header.
          previewHeaderHeight = parseInt( $( '.preview-header' ).css( 'height' ));
          maxHt > minHt ? maxHt : maxHt = minHt; // Ensuring the divs fill the entire screen.
          $( value ).css( 'min-height', maxHt - previewHeaderHeight );
        } else {
          maxHt > minHt ? maxHt : maxHt = minHt; // Ensuring the divs fill the entire screen.
          $( value ).css( 'min-height', maxHt );
        }
      });
    };
    setTimeout( setHt, 100 );
    $( window ).resize( setHt );
  };


  opTheme.equalizeHeights = function() {
    setTimeout( function() {
      var maxHeight = 0;
      $( '#merchants > .editor_wrpr > .span6' ).css( 'min-height', 'inherit' );
      $( '#merchants > .editor_wrpr > .span6' ).each( function( index, value ) {
        if ( parseInt( $( this ).css( 'height' )) > maxHeight ) maxHeight = parseInt( $( this ).css( 'height' ));
      });
      ( $( window ).height() - 50 ) < maxHeight ? maxHeight : maxHeight = $( window ).height();
      $( '#merchants > .editor_wrpr > .span6' ).css( 'min-height', maxHeight );
      //$( '#template_wrapper' ).css( 'height', maxHeight );
    }, 500);
  };


  opTheme.makeMenuResponsive = function() {
    if ( $( 'body' ).hasClass( 'merchants-messages' )) {
      if ( !$( 'body' ).hasClass( 'show' )) {
        // Menu is removed from merchants/messages controller, except the show page.
        return;
      }
    }
    $( '.m-menu-toggle' ).click(function() {
      $( '.menuleft' ).fadeToggle( 150 );
    });

    $( window ).resize( function() {
      if ( $( window ).width() > 1024 )
        $( '.menuleft' ).fadeIn( 150 );
      else
        $( '.menuleft' ).hide();
    });
  };


  (function() {  // Init function.
    if ( $( '.m-menu-toggle' ).length ) {
      opTheme.makeMenuResponsive();
    }
  })();
});
