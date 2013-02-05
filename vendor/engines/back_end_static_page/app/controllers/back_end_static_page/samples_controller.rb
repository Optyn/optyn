require_dependency "back_end_static_page/application_controller"

module BackEndStaticPage
  class SamplesController < ApplicationController
  	def login
  		@hide_menu = true
  	end
  end
end
