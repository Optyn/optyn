class Admin::DashboardController < ApplicationController
	def index
		render :layout => 'admin'
	end
end