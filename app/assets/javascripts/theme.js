$(document).ready(function () {
    $( '.scrolltop' ).html( "<i class='icon-arrow-up icon-white'></i>" );
    $(window).scroll(function(){
        // add navbar opacity on scroll
        if ($(this).scrollTop() > 100) {
            $(".navbar.navbar-fixed-top").addClass("scroll");
        } else {
            $(".navbar.navbar-fixed-top").removeClass("scroll");
        }

        // global scroll to top button
        if ($(this).scrollTop() > 300) {
            $('.scrolltop').fadeIn();
        } else {
            $('.scrolltop').fadeOut();
        }        
    });

    $('#myCarousel').carousel('cycle');

    // scroll back to top btn
    $('.scrolltop').click(function(){
        $("html, body").animate({ scrollTop: 0 }, 700);
        return false;
    });
    
    // scroll navigation functionality
    $('.scroller').click(function(){
    	var section = $($(this).data("section"));
    	var top = section.offset().top;
        $("html, body").animate({ scrollTop: top }, 700);
        return false;
    });

    // FAQs
    var $faqs = $("#faq .faq");
    $faqs.click(function () {
        var $answer = $(this).find(".answer");
        $answer.slideToggle('fast');
    });

    if (!$.support.leadingWhitespace) {
        //IE7 and 8 stuff
        $("body").addClass("old-ie");
    }


    // Placeholder support for old browsers ....................................
    if ( 'placeholder' in document.createElement( 'input' )) {}
    else {
      $( 'input[type=text]' ).each( function( i, v ) {
        if ( $( this ).attr( 'placeholder' ).length > 0 && $( this ).attr( 'value' ).length == 0 ) {
          $( v ).attr( 'value', $( v ).attr( 'placeholder' ));
        }
      });
    }


    // Initialise tooltips .....................................................
    var initTooltips = function() {
        $( '[data-toggle=tooltip]' ).each( function( index, value ) {
            var position = $( this ).attr( 'data-tooltip-pos' );
            if ( position == '' ) {
                position = 'top';
            }
            $( this ).tooltip({
                placement: position
            });
        });
    };
    initTooltips();


    // Ensure footer is stuck to bottom of window ..............................
    var setMidContentHt = function ( headerSelector, contentSelector, footerSelector ) {
        var headerHt = parseInt( $( headerSelector ).css( 'height' ));
        var footerHt = parseInt( $( footerSelector ).css( 'height' ));
        var windowHt = $( window ).height();
        $( contentSelector ).css( 'min-height', windowHt - headerHt - footerHt );
    };

    // For Merchant and Consumer app pages.
    setMidContentHt( '.navbar.inner', '#dashboard .yield', 'footer' );
    $( window ).resize( function() {
        setMidContentHt( '.navbar.inner', '#dashboard .yield', 'footer' );
    });

    // For shops#show page.
    setMidContentHt( '.navbar', '.shops.show #merchant_page', 'footer' );
    $( window ).resize( function() {
        setMidContentHt( '.navbar', '.shops.show #merchant_page', 'footer' );
    });

    // Ensuring footer is stuck to the bottom in email_feedback layout .........
    setMidContentHt( '.ef-l .navbar', '.ef-l .yield', 'footer' );
    $( window ).resize( function() {
        setMidContentHt( '.ef-l .navbar', '.ef-l .yield', 'footer' );
    });

    // Ensuring footer is stuck to the bottom in removal_confirmation layout ...
    setMidContentHt( 'header.navbar', '#consumer.unsubscribe', 'footer' );
    $( window ).resize( function() {
        setMidContentHt( 'header.navbar', '#consumer.unsubscribe', 'footer' );
    });

    // Setting height of modal .................................................
    var setModalHt = function() {
        $( '.modal-body' ).each( function( index, value ) {
            var modalHeaderHt = parseInt( $( this ).parent().find( '.modal-header' ).css( 'height' ));
            var modalFooterHt = parseInt( $( this ).parent().find( '.modal-footer' ).css( 'height' ));
            $( this ).css( 'max-height', $( window ).height() - modalHeaderHt - modalFooterHt - 80 );
        });
    };
    setModalHt();
    $( window ).resize( setModalHt );
});
