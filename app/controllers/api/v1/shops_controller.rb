module Api
  module V1
    class ShopsController < ApplicationController
      respond_to :json, :except => [:button_framework]
      doorkeeper_for [:create]

      before_filter :fetch_store
      before_filter :log_impression_count, only: [:details]

      skip_before_filter :verify_authenticity_token
      skip_before_filter :fetch_store, only: [:create]

      BEGIN_STATE_HIDDEN = 0
      RENDER_CHOICE_BAR = 1

      def create
        if params[:name].present? #&& params[:email_frequency].present?
          virtual_shop_domain = params[:name]
          shop = Shop.search_or_add_by_domain(virtual_shop_domain)
          render(json: {data: {name: shop['name']}}, status: :created)
        else
          errors = []
          errors << ["Shop name cannot be blank"] if params[:name].blank?
          #errors << ["Email Frequency needs to be selected"] if params[:email_frequency].blank?
          render(status: :unprocessable_entity, json: {data: {errors: errors.as_json}})
        end
      end

      def button_script
        @application = @shop.oauth_application
        return button_script_content
      end

      def button_framework
        @application = @shop.oauth_application
        call_to_action = @application.call_to_action.to_i

        if [1, 2].include?(call_to_action)
          return button_framework_script
        elsif 3 == call_to_action
          return email_box_framework_script
        end
      end

      def details
        callback_name = params[:callback]
        response_body = %Q(
        var optynShop = #{@shop.api_welcome_details.to_json}
        #{callback_name}(optynShop);
        )

        render text: response_body
      end

      private
      def fetch_store
        @shop = Shop.by_app_id(params[:app_id].to_s)
        head :unauthorized and false unless @shop.present?
      end

      def log_impression_count
        unless @shop.virtual
          if @shop.button_display?
            @shop.increment_button_impression_count
          else
            @shop.increment_email_box_impression_count
          end
        end
      end

      def button_script_content
        respond_to do |format|
          script = %Q(
              var outerScript = document.createElement('script');
              outerScript.text =
              "try{" +
                "jQuery();" +
              "}catch(e){" +

                "var js = document.createElement('script');" +

                'js.type = "text/javascript";' +
                'js.src = "https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js";' +

                'document.body.appendChild(js);' +

              '}';
              document.body.appendChild(outerScript);

              setTimeout(function(){
                checkOptynJqueryAvailability();
              }, 1000);

              function checkOptynJqueryAvailability(){
                if (window.jQuery){
                  //possibly some other JQuery checks to make sure that everything is loaded here
                  renderOptynScript();
                } else {
                  setTimeout(checkOptynJqueryAvailability, 50);
                }
              }

              function renderOptynScript(){
                #{@application.render_choice.to_i == 1 ? bar : part}
              }

          )

          format.any { response.headers['Content-Type'] = "application/javascript"; render text: script }
        end
      end

      def button_framework_script
        respond_to do |format|

          script = %Q(jQuery(document).ready(function(){
                      jQuery.getJSON('#{SiteConfig.app_base_url}#{api_shop_details_path(app_id: params[:app_id], format: :json)}?callback=?', null, function(data){
          jQuery('#optyn_button_wrapper .optyn-text').html(data.welcome_message);
                        
          var outerContainer = jQuery('<div />');

          //Create the first container for button and user count.
              var firstContainer = jQuery('<div />');
            firstContainer.attr({id: 'optyn-first-container'});
            var optynLinkContainer = jQuery('<span />')
            optynLinkContainer.attr({id: 'optyn-link-container'});
            var optynLink = jQuery('<a />');
            optynLink.attr({
                href: 'javascript:void(0)',
                id: 'optyn-oauth-link',
                onClick: 'login()'
              });


            var optynImageCb = jQuery('<img />')
            optynImageCb.attr({
                src: '#{SiteConfig.app_base_url}/assets/optyn_button_checkbox.png',
                alt: 'Optyn Logo'
              });

            #{"optynLink.append(optynImageCb);" if @application.checkmark_icon}

            var optynImage = jQuery('<img />')
            optynImage.attr({
                src: '#{SiteConfig.app_base_url}/assets/#{@application.call_to_action.to_i == 1 ? 'optyn_button_small.png' : 'optyn_button_large.png'}',
                alt: 'Optyn Logo'
              });
            optynLink.append(optynImage);
            optynLinkContainer.append(optynLink);
            firstContainer.append(optynLinkContainer);

            //var userCountContainer = jQuery('<span />')
            //userCountContainer.attr({id: 'optyn-user-count-container'});
            //var userMessageContainer = jQuery('<strong />')
            //userMessageContainer.append(optynShop.user_count + " " + "user(s) connected");
            //userCountContainer.append(userMessageContainer);
            //firstContainer.append(userCountContainer);

            outerContainer.append(firstContainer);

            //Create the second container for welcome message
              var secondContainer = jQuery('<div />');
              var messageContainer = jQuery('<span />');
              messageContainer.attr({id: 'optyn-welcome-container'});
              messageContainer.append(optynShop.welcome_message);
              #{"secondContainer.append(messageContainer);" unless @shop.display_bar?}

              outerContainer.append(secondContainer);

              //replace the html of the optyn container
              jQuery('#optyn-container').html(outerContainer.html());


            });
        });

      var OAUTHURL    =   '#{SiteConfig.app_base_url}#{oauth_authorization_path}?';
      var VALIDURL    =   '#{SiteConfig.app_base_url}#{oauth_token_path}'; //Show page url
      var SCOPE       =   'public'; //Need to find out what this is used for?
      var CLIENTID    =   '#{@shop.app_id}';
      var CLIENTSECRET =  '#{@shop.secret}'
      var REDIRECT    =   '#{@shop.redirect_uri}';
      var TYPE        =   'code';

      var _url        =   OAUTHURL  + '&client_id=' + CLIENTID + '&redirect_uri=' + REDIRECT + '&response_type=' + TYPE + '&scope=' + SCOPE;
      //alert(_url);
      var win = null;

      function login() {
        win         =   window.open(_url, "Login - Optyn", 'scrollbars=1, width=600, height=520');

        var pollTimer   =   window.setInterval(function() {
            try {
              domainUrl = win.location.href.split('?')[0];
              if (domainUrl.match(REDIRECT)) {
                  window.clearInterval(pollTimer);
                  var url =   win.location.toString();
                  acToken = url.split("?")[1].split("=")[1];
                  jQuery(win.document).find('body').html("<h1>Loading....</h1>")
                  //win.close();
                  validateToken(acToken, win);
                }
              } catch(e) {
              }
            }, 500);
        }

        function validateToken(token, win) {
          param_obj = {'client_id': CLIENTID, 'client_secret': CLIENTSECRET, 'code': token, 'grant_type': 'authorization_code', 'redirect_uri': REDIRECT}
          jQuery.getJSON((VALIDURL + "?callback=?&" + jQuery.param(param_obj)), function(data){
              win.location = '#{SiteConfig.app_base_url}#{api_connection_path}?access_token=' + data.access_token;
              getUserInfo(data.access_token);
              //win.close();
            });
        }

        function getUserInfo(token) {
          jQuery.getJSON('#{SiteConfig.app_base_url}#{api_user_profile_path}?callback=?&access_token=' + token, function(user){
              jQuery('#optyn-first-container').text('Welcome ' + user.name + "!");
            });
        }
      )
      format.any { response.headers['Content-Type'] = "application/javascript"; render text: script }
    end
  end

  def email_box_framework_script
    respond_to do |format|
      script = %Q(jQuery(document).ready(function(){
                        jQuery.getJSON('#{SiteConfig.app_base_url}#{api_shop_details_path(app_id: params[:app_id], format: :json)}?callback=?', null, function(data){

      jQuery('#optyn_button_wrapper .optyn-text').html(data.welcome_message);
                         
      var $formContainer = jQuery("<div />");
      $formContainer.attr({
          id: 'optyn-first-container'
        })

      var $form = jQuery('<form />');
      $form.attr({
          id: 'optyn-email-form',
          action: '#{SiteConfig.app_base_url}#{authenticate_with_email_path}.json?callback=?',
          method: 'post'
        });

      var $emailBox = jQuery('<input />');
      $emailBox.attr({
          id: 'user_email',
          name: 'user[email]',
          type: 'email',
          size: '34',
          placeholder: 'enter your e-mail'
        });

      var $nameBox = jQuery('<input />');
      $nameBox.attr({
          id: 'user_name',
          name: 'user[name]',
          type: 'text',
          size: '34',
          placeholder: 'enter name'
        });

      var $hddenAppId = jQuery('<input />');
      $hddenAppId.attr({
          id: 'app_id',
          name: 'app_id',
          type: 'hidden',
          value: '#{params[:app_id]}'
        });

      var $submitButton = jQuery('<input />');
      $submitButton.attr({
          id: 'commit',
          name: 'commit',
          value: 'Subscribe',
          type: 'submit'
        });
      if(#{@application.show_name.to_s} == true){
        $form.append($nameBox);
      }
      $form.append($emailBox);
      $form.append($hddenAppId);
      $form.append($submitButton);
      $formContainer.append($form)
      var $temp = jQuery('<div />');
      $temp.append($formContainer);
      jQuery('#optyn-container').html($temp.html());
    });
});

var OAUTHURL    =   '#{SiteConfig.app_base_url}#{oauth_authorization_path(format: 'json')}?callback=?';
var VALIDURL    =   '#{SiteConfig.app_base_url}#{oauth_token_path}'; //Show page url
var SCOPE       =   'public'; //Need to find out what this is used for?
var CLIENTID    =   '#{@shop.app_id}';
var CLIENTSECRET =  '#{@shop.secret}'
var REDIRECT    =   '#{@shop.redirect_uri}';
var REDIRECT_URI    =   '#{@shop.redirect_uri_after_login}';
var TYPE        =   'code';

var _url = OAUTHURL  + '&client_id=' + CLIENTID + '&redirect_uri=' + REDIRECT + '&response_type=' + TYPE + '&scope=' + SCOPE;

//Call the get authentication method.
jQuery.getJSON(_url, null, function(data){
  //DO NOTHING
});

//Hook the form submission
jQuery('body').on('submit', '#optyn-email-form', function(event){
  event.preventDefault();
  jQuery.ajax({
      url: jQuery(this).attr('action'),
      type: 'GET',
      data: jQuery(this).serialize(),
      dataType: 'jsonp',
      beforeSend: function(){
        jQuery('#optyn-email-error').remove();
        jQuery('input[type=submit]', this).attr('disabled', 'disabled');
      },
      success: function(respJson){
        if(respJson.data.errors.length){
            var $tempErr = jQuery('<div />');
            $tempErr.append('<div id="optyn-email-error"><strong>Please check the email you entered.</strong></div>');
            jQuery('#optyn-first-container').append($tempErr.html());
            jQuery('input[type=submit]', this).attr('disabled', '');
          }else{
            replaceWithUserInfo();
          }
        }
      });
  });

//fetch the authentication code
function replaceWithUserInfo(){
  jQuery.getJSON(_url, null, function(respJson){
      if(respJson.data.code){
          validateToken(respJson.data.code);
        }
      });
  }

  //fetch the accessToken
  function validateToken(token) {
    param_obj = {'client_id': CLIENTID, 'client_secret': CLIENTSECRET, 'code': token, 'grant_type': 'authorization_code', 'redirect_uri': REDIRECT}
    jQuery.getJSON((VALIDURL + "?callback=?&" + jQuery.param(param_obj)), function(data){
        getUserInfo(data.access_token);
      });
  }

  //fetch the user info
  function getUserInfo(token) {
    jQuery.getJSON('#{SiteConfig.app_base_url}#{api_user_profile_path}?callback=?&access_token=' + token, function(respJson){
        var user = respJson.data;
        automaticConnection(token);
        if(REDIRECT_URI == ''){
            jQuery('#optyn-first-container').text('Welcome ' + user.name + "!");
          }
        else{
            window.location = REDIRECT_URI;
          }
        });
    }


    //Create an automatic connection.
      function automaticConnection(token){
      jQuery.ajax({
          url: '#{SiteConfig.app_base_url}#{api_automatic_connection_path}',
          type: 'POST',
          data: {'_method': 'put', 'access_token': token}
        });
    }
  )

  format.any { response.headers['Content-Type'] = "application/javascript"; render text: script }
end
end

def bar
%Q(
            jQuery('body').prepend(
              '#{style}' +
'#{email_box_style}' +
  #{optyn_wrapper_style} +
'<div id="optyn_button_wrapper">' +
  '<div class="optyn-text">' +
  '</div>' +
  '<div id="optyn-container">' +
  '<h4>Welcome to Optyn</h4>'  +
  '</div>' +
  '<script src="#{SiteConfig.app_base_url}/api/shop/button_framework.js?app_id=#{@application.uid}"></script>' +
  '<div id="close_optyn_button">' +
  '<a href="javascript:void(0)" onclick="hideOptynButtonWrapper(' + "'optyn_button_wrapper', 'show_optyn_button_wrapper')" + '">' +
  'X</a>' +
  '</div>' +
  '</div>' +
  '</div>' +
  '<iframe name="optyn-iframe" id="optyn-iframe" style="display:none"></iframe>' +
  '<div id="show_optyn_button_wrapper" style="display:none">' +
  '<a href="javascript:void(0)" onclick="showOptynButtonWrapper(' + "'optyn_button_wrapper', 'show_optyn_button_wrapper')" + '"><img src="http://s23.postimg.org/gm12p8p2f/optyn_button_logo.png" /></a>' +
  '</div>' +
  #{show_hide} +
#{collapse_bar} +
#{color_luminance_script} +
#{color_luminance_components} +
'<script>adjustColorLuminanceComponents();</script>'
)
)
end

def part
%Q(
            var scriptElem = jQuery("script[src='#{SiteConfig.app_base_url}/api/shop/button_script.js?app_id=#{@application.uid}']");
jQuery(scriptElem).before(
'<script src="#{SiteConfig.app_base_url}/api/shop/button_framework.js?app_id=#{@application.uid}"></script>' +
'#{style}' +
'<div  id="optyn-container">' +
'<h4>Welcome to Optyn</h4>'  +
'</div>' +
'<iframe name="optyn-iframe" id="optyn-iframe" style="display:none"></iframe>'
)
)
end

def style
  %Q(<style type="text/css"> #{@application.custom_css.gsub(/\r/," ").gsub(/\n/," ")}</style>)
end

def email_box_style
  if @shop.app_render_bar_choice?
    %Q(<style type="text/css">#optyn-container form input[type="email"] { border-bottom: 1px rgba(9, 67, 89, 0.75); border-top: none; border-left:none; border-right: none; font-size: 14px; height: 26px; padding: 5px; border-radius: 4px; margin-right: 10px; font-weight: bold;}</style>)
  else
    ""
  end
end

def optyn_wrapper_style
  if @shop.app_render_bar_choice?
    %Q('<style type="text/css">' +
              '#optyn_button_wrapper { background-color: #{@application.background_color}; margin: 0px; height: 60px; vertical-align: middle; border-bottom:thick solid #046d95; border-width: 2px;}' +
              '#show_optyn_button_wrapper { background-color: #{@application.background_color}; background-position: 0 -8px; display: block; height: 40px; /*overflow: hidden;*/ padding: 16px 0 0; position: absolute; right: 20px; top: -3px; width: 80px; z-index: 100; box-shadow: 0 0 5px rgba(0,0,0,0.35); -moz-box-shadow: 0 0 5px rgba(0,0,0,0.35); -webkit-box-shadow: 0 0 5px rgba(0,0,0,0.35); border-bottom-right-radius: 5px; border-bottom-left-radius: 5px; border: 2px solid #046d95; text-align: center; }' +
        '</style>')
  end
end

def show_hide
%Q(
        '<script type="text/javascript">' +
        'function hideOptynButtonWrapper(wrapperId, showLinkId){' +
          'document.getElementById(wrapperId).style.display = "none";' +
          'document.getElementById(showLinkId).style.display = "block";' +
    '}' +

        'function showOptynButtonWrapper(wrapperId, showLinkId){' +
        'document.getElementById(wrapperId).style.display = "block";' +
        'document.getElementById(showLinkId).style.display = "none";' +
    '}' +
    '</script>'
)
end

def collapse_bar
if @shop.app_begin_state_hidden?
%Q(
          '<script>hideOptynButtonWrapper("optyn_button_wrapper", "show_optyn_button_wrapper")</script>'
)
else
%Q(
          ''
)
end
end

def color_luminance_script
%Q(
        '<script type="text/javascript">' +
          'function ColorLuminance(hex, lum) {' +
            'hex = String(hex).replace(/[^0-9a-f]/gi, "");' +
            'if (hex.length < 6) {' +
              'hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];' +
            '}' +
            'lum = lum || 0;' +
            'var rgb = "#", c, i;' +
            'for (i = 0; i < 3; i++) {' +
              'c = parseInt(hex.substr(i*2,2), 16);' +
              'c = Math.round(Math.min(Math.max(0, c + (c * lum)), 255)).toString(16);' +
              'rgb += ("00"+c).substr(c.length);' +
            '}' +
            'return rgb;' +
          '}' +
        '</script>'
)
end

def color_luminance_components
%Q(
          '<script type="text/javascript">' +
            'function adjustColorLuminanceComponents(){' +
              'var darkShade = ColorLuminance("#{@application.background_color}", -0.5);' +
'jQuery("#close_optyn_button a").css({"color": darkShade});' +
'jQuery("#optyn_button_wrapper").css({"border-bottom": ("2px solid " + darkShade)});' +
'jQuery("#show_optyn_button_wrapper").css({"border": ("2px solid " + darkShade)});' +
'}' +
          '</script>'
)
end
end
end
end