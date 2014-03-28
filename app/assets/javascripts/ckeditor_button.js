// 'border-radius: 0;background: #D4D4D4; padding: 2px 10px;text-decoration: none;display: inline-block;'
// CKEditorButtonStyle

var OP = OP || {};
OP = (function($, window, doucument, Optyn){
  //Define the Overlay behavior
  Optyn.ckeditorButton = {
    getStyle: function(){
      return 'border-radius: 0;background: #D4D4D4; padding: 2px 10px;text-decoration: none;display: inline-block;';
    }
  };

  return Optyn;
})(jQuery, this, this.document, OP);
