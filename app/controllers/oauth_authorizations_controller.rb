class OauthAuthorizationsController < Doorkeeper::AuthorizationsController
	layout 'oauth_dialog'

	def new
		super
	end

	def create
	end

	def show
		if params[:callback].present?
			render text: "#{params[:callback]}()"
		end
	end
end
