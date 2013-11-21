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
        if ( $( this ).attr( 'value' ).length == 0 ) {
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
    var setMidContentHt = function( headerSelector, contentSelector, footerSelector ) {
        var headerHt = parseInt( $( headerSelector ).css( 'height' ));
        var footerHt = parseInt( $( footerSelector ).css( 'height' ));
        var windowHt = $( window ).height();
        $( contentSelector ).css( 'min-height', windowHt - headerHt - footerHt );
    };

    // Ensuring footer is stuck to the bottom in application layout ............
    setMidContentHt( 'header.navbar', '.a-layout .yield', 'footer' );
    $( window ).resize( function() {
        setMidContentHt( 'header.navbar', '.a-layout .yield', 'footer' );
    });

    // Ensuring footer is stuck to the bottom in base layout ...................
    setMidContentHt( '.navbar', '.b-layout .yield', 'footer' );
    $( window ).resize( function() {
        setMidContentHt( '.navbar', '.b-layout .yield', 'footer' );
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

    // Call handleTabLayout() only when there's a h1 and tab pane beside it,
    // like the one on campaign pages.
    if ( $( 'h1' ).css( 'float' ) === 'left' && $( '.tab-pane' ).size())
        handleTabLayout();
});
// Equalize div heights
function equalizeDivHeights( targetElementSelector ) {
    var setHt = function() {
        // This function sets width of the team member divs.
        var maxHt = 0;
        $( targetElementSelector ).each( function() {
            $( this ).css( 'height', 'auto' );
        });
        $( targetElementSelector ).each( function() {
            if ( parseInt($( this ).css( 'height' )) > maxHt ) {
                maxHt = parseInt( $( this ).css( 'height' ));
            }
        });
        $( targetElementSelector ).each( function() {
            $( this ).css( 'height', maxHt + 10 );
        });
    };
    setTimeout( setHt, 100 );
    $( window ).resize( setHt );
}


// Handle tabs in various resolutions
function handleTabLayout() {
    var h1Width = parseInt( $( '.wid75pc h1:first' ).css( 'width' ));
    var handleLayout = function() {
        var tabsWidth = 0;
        $( '.wid75pc .tab-pane a' ).each( function( index, value) {
            tabsWidth += parseInt( $( this ).css( 'width' ));
        });
        //console.log( h1Width, tabsWidth, tabsWidth + h1Width > parseInt( $( '.wid75pc' ).css( 'width' )), parseInt( $( '.wid75pc' ).css( 'width' )));
        if ( h1Width + tabsWidth > parseInt( $( '.wid75pc' ).css( 'width' ))) {
            //console.log( 'hide some tabs' );
            $( 'h1:first' ).css({
                'float': 'none',
                'margin-bottom': '0'
            });
        } else {
            $( 'h1:first' ).css({
                'float': 'left',
            });
        }
    };
    handleLayout();
    $( window ).resize( handleLayout );
}
