var OPT = OPT || {};

OPT = (function($, window, document, Optyn){

  Optyn.register = {   
    businessType: function(){     
      $('#shop_name_stype_local').click(function(e){
        $(".address").show();
      });
      $('#shop_name_stype_online').click(function(e){
        $(".address").hide();
      });
    }
  }

  $(function(){
    Optyn.register.businessType();
  });

return Optyn;
})(jQuery, this, this.document, OPT);