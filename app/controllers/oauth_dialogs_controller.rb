class OauthDialogsController < Doorkeeper::AuthorizationsController
	layout 'oauth_dialog'

	def show
		if params[:callback].present?
			render text: "#{params[:callback]}()"
		end
	end
end
