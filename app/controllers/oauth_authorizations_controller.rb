class OauthAuthorizationsController < Doorkeeper::AuthorizationsController
	layout 'oauth_dialog'

	def new
    if pre_auth.authorizable?
      if Doorkeeper::AccessToken.matching_token_for(pre_auth.client, current_resource_owner.id, pre_auth.scopes) || skip_authorization?
        auth = authorization.authorize
        redirect_to api_connection_path(redirect_uri: auth.redirect_uri, access_token: auth.auth.token.token) #redirect_to auth.redirect_uri
      else
        auth = authorization.authorize
        redirect_to api_connection_path(redirect_uri: auth.redirect_uri, access_token: auth.auth.token.token) #render :new
      end
    else
      render :error
    end
	end

	def create
    auth = authorization.authorize
    if auth.redirectable?
      redirect_to api_connection_path(redirect_uri: auth.redirect_uri, access_token: auth.auth.token.token) #redirect_to auth.redirect_uri
    else
      render :json => auth.body, :status => auth.status
    end
	end

	def show
		super
		if params[:callback].present?
			render text: "#{params[:callback]}()"
		end
  end
end
