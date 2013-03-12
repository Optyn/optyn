class OauthAuthorizationsController < Doorkeeper::AuthorizationsController
	layout 'oauth_dialog'

	def new
		super
	end

	def create
		super
	end

	def show
		super
		if params[:callback].present?
			render text: "#{params[:callback]}()"
		end
	end
end
