module Api
	module V1
		class ShopsController < ApplicationController
			respond_to :json, :except => [:button_framework]

			before_filter :fetch_store
			
			def button_framework
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
													var optynImage = jQuery('<img />')
													optynImage.attr({
														src: '#{SiteConfig.app_base_url}/assets/logo.png',
														alt: 'Optyn Logo'
													});
													optynLink.append(optynImage);
													optynLinkContainer.append(optynLink);
													firstContainer.append(optynLinkContainer);

													var userCountContainer = jQuery('<span />')
													userCountContainer.attr({id: 'optyn-user-count-container'});
													var userMessageContainer = jQuery('<strong />')
													userMessageContainer.append(optynShop.user_count + " " + "user(s) connected");
													userCountContainer.append(userMessageContainer);
													firstContainer.append(userCountContainer);

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
							        var VALIDURL    =   '#{SiteConfig.app_base_url}/oauth/authorize/'; //Show page url
							        var SCOPE       =   '#{SiteConfig.app_base_url}#{api_user_profile_path}'; //Need to find out what this is used for?
							        var CLIENTID    =   '#{@shop.app_id}';
							        var REDIRECT    =   '#{@shop.redirect_uri}';
							        var TYPE        =   'token';
							        //+ 'scope=' + SCOPE
							        var _url        =   OAUTHURL  + '&client_id=' + CLIENTID + '&redirect_uri=' + REDIRECT + '&response_type=' + TYPE;
							        var win = null;

											function login() {
          							win         =   window.open(_url, "Login - Optyn", 'width=800, height=600'); 

          							var pollTimer   =   window.setInterval(function() { 
              							try {
              								domainUrl = win.location.href.split('?')[0];
                    					if (domainUrl.match(REDIRECT)) {
                      					window.clearInterval(pollTimer);
                      					var url =   win.location;
                      					acToken =   gup(url, 'access_token');
                      					tokenType = gup(url, 'token_type');
                      					expiresIn = gup(url, 'expires_in');
                      					win.close();
                      					validateToken(acToken);
                  						}
              							} catch(e) {
              								console.log(e);
              							}
          							}, 500);
      								}

        							function validateToken(token) {
            						jQuery.ajax({
                					url: VALIDURL + token + ".json",
                					data: null,
                					success: function(data){  
                    				getUserInfo();
                    				loggedIn = true;
                					},  
                					dataType: "jsonp"  
            						});
        							}

        							function getUserInfo() {
            						jQuery.ajax({
                					url: '#{SiteConfig.app_base_url}#{api_user_profile_path}?access_token=' + acToken,
                					data: null,
                					success: function(resp) {
                						console.log(resp);
                    				user    =   resp;
                    				jQuery('#optyn-first-container').text('Welcome ' + user.name + "!");
                					},
                					dataType: "jsonp"
            						});
        							}

        							//credits: http://www.netlobo.com/url_query_string_javascript.html
        							function gup(url, name) {
            						name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
            						var regexS = "[\\#&]"+name+"=([^&#]*)";
            						var regex = new RegExp( regexS );
            						var results = regex.exec( url );
            						if( results == null ){
                					return "";
            						}
            						else{
                					return results[1];
            						}
        							}

        							function startLogoutPolling() {
            						jQuery('#loginText').show();
            						jQuery('#logoutText').hide();
            						loggedIn = false;
            						jQuery('#uName').text('Welcome ');
            						jQuery('#imgHolder').attr('src', 'none.jpg');
        							}
										)
					format.any {response.headers['Content-Type'] = "application/javascript";render text: script}
				end
			end

			def details
				callback_name = params[:callback]
				response_body =  %Q(
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
		end
	end
end