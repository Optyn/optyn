var OP = OP || {};
OP = (function($, window, doucument, Optyn){
  //Define the Overlay behavior
  Optyn.overlay = {
    addOverlay: function(elementToAppendTo) {
      $('#overlay').remove();
      var overlay = $('<div id="overlay"><img src="/assets/ajax-loader.gif"></div>');
      $(elementToAppendTo).css({ position: 'relative'});
      $(elementToAppendTo).append(overlay);
    },

    removeOverlay: function() {
      $('#overlay').remove();
    },
  };

  return Optyn;
})(jQuery, this, this.document, OP);