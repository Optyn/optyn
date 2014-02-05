var OP = OP || {};
OP = (function($, window, doucument, Optyn){
  //Define the Overlay behavior
  Optyn.overlay = {
    addOverlay: function(elementToAppendTo) {
      $('#overlay').remove();
      var overlay = $('<div id="overlay" style="position: absolute; text-align: center; width: 100%; height: 100%; left: 0; top: 0; background-color: white; opacity: 0.8;"><img src="/assets/ajax-loader.gif"></div>');
      $(elementToAppendTo).css({ position: 'relative'});
      $(elementToAppendTo).append(overlay);
    },

    removeOverlay: function() {
      $('#overlay').remove();
    },
  };

  return Optyn;
})(jQuery, this, this.document, OP);