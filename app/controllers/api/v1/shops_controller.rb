module Api
  module V1
    class ShopsController < ApplicationController
      respond_to :json, :except => [:button_framework]
      doorkeeper_for [:create, :clear_session]

      before_filter :fetch_store
      before_filter :log_impression_count, only: [:details]

      skip_before_filter :verify_authenticity_token
      skip_before_filter :fetch_store, :log_impression_count, only: [:create, :clear_session]

      def create
        if params[:name].present? && params[:email_frequency].present?
          virtual_shop_domain = params[:name]
          shop = Shop.search_or_add_by_domain(virtual_shop_domain)
          render(json: {data: {name: shop['name']}}, status: :created)
        else
          errors = []
          errors << ["Shop name cannot be blank"] if params[:name].blank?
          errors << ["Email Frequency needs to be selected"] if params[:email_frequency].blank?
          render(status: :unprocessable_entity, json: {data: {errors: errors.as_json}})
        end
      end

      def button_framework
        @application = @shop.oauth_application

        respond_to do |format|

          script = %Q(jQuery(document).ready(function(){
                      jQuery.getJSON('#{SiteConfig.app_base_url}#{api_shop_details_path(app_id: params[:app_id], format: :json)}?callback=?', null, function(data){

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
                          src: '#{SiteConfig.app_base_url}/assets/#{@application.button_size == 1 ? 'optyn_button_small.png' : 'optyn_button_large.png'}',
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
                        secondContainer.append(messageContainer);

                        outerContainer.append(secondContainer);

                        //replace the html of the optyn container
                        jQuery('#optyn-container').html(outerContainer.html());


                      });
                    });

                    var OAUTHURL    =   '#{SiteConfig.app_base_url}#{oauth_authorization_path}?';
                    var VALIDURL    =   '#{SiteConfig.app_base_url}#{oauth_token_path}'; //Show page url
                    var SCOPE       =   '#{SiteConfig.app_base_url}#{api_user_profile_path}'; //Need to find out what this is used for?
                    var CLIENTID    =   '#{@shop.app_id}';
                    var CLIENTSECRET =  '#{@shop.secret}'
                    var REDIRECT    =   '#{@shop.redirect_uri}';
                    var SCOPE       =   'public'
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
                              win.close();
                              validateToken(acToken);
                            }
                          } catch(e) {
                          }
                      }, 500);
                    }

                    function validateToken(token) {
                      param_obj = {'client_id': CLIENTID, 'client_secret': CLIENTSECRET, 'code': token, 'grant_type': 'authorization_code', 'redirect_uri': REDIRECT}
                      jQuery.getJSON((VALIDURL + "?callback=?&" + $.param(param_obj)), function(data){
                        parsed_data = JSON.parse(data);
                        accessToken = parsed_data;
                        getUserInfo(parsed_data.access_token);
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
        @shop.increment_impression_count
      end
    end
  end
end