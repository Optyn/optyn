module FrontEndStaticPage
  class ApplicationController < ActionController::Base
  	http_basic_authenticate_with name: SiteConfig.template_engine_username, password: SiteConfig.template_engine_password

  	before_filter :block_pessage_except_development_mode

		private
		def block_pessage_except_development_mode
			unless "development" == Rails.env
				respond_to do |format|
					template_location = Rails.public_path + "/403.html"
					format.html { render :file => template_location, :layout => false, :status => :forbidden }
					format.any{head :forbidden}
				end
				false
			end
		end
  end
end
