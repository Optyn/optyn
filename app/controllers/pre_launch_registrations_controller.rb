class PreLaunchRegistrationsController < ApplicationController
	respond_to :json

	def new
		@pre_launch_registration = PreLaunchRegistration.new
		respond_with @pre_launch_registration
	end

	def create
		@pre_launch_registration = PreLaunchRegistration.new(params[:pre_launch_registration])
		@pre_launch_registration.persist

		if @pre_launch_registration.errors.any? && @pre_launch_registration.errors[:email].size > 1
			@pre_launch_registration.errors.delete(:email)
			@pre_launch_registration.errors[:email] = "is invalid"
		end
		
		respond_with @pre_launch_registration, location: nil
	end
end
