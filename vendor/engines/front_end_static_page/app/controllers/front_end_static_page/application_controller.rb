module FrontEndStaticPage
  class ApplicationController < ActionController::Base
  	http_basic_authenticate_with name: SiteConfig.template_engine_username, password: SiteConfig.template_engine_password
  end
end
