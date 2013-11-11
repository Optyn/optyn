class ShopsController < ApplicationController

	include EmailRegister

  def show
    @shop  = Shop.find_by_identifier(params[:identifier])
    redirect_to(new_user_session_path, notice: "Could not find the shop you are looking for.")  if @shop.blank?
  end

	def subscribe_with_email
		#step 1 : if shop is valid
		if params[:uuid].present? 
		  @shop_identifier = Shop.for_uuid(params["uuid"]).identifier

		else 
		  flash[:alert] = "No Valid Shop Specified"
		  redirect_to :back and return
		end

		#step 2 : check if user is present
		if !params[:user].present? 
		  flash[:alert] = "Parameters Invalid"
		  redirect_to "#{SiteConfig.app_base_url_http}#{public_shop_path(@shop_identifier)}" and return
		end#end of if

		#step 3 : check user email
		if params[:user][:email].match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/)
		  #email id is fine
		  @user = User.find_by_email(params[:user][:email])
		  @user = sudo_registration(params) unless @user.present?
		  @shop = Shop.for_uuid(params[:uuid])
		  @user.make_connection_if!(@shop)
		  flash[:success] = "Successfully Subscribed"
		else
		  #your email id is not valid
		  flash[:alert] = "Please check your email address"
		end#end of params[:user][:email].match

		redirect_to "#{SiteConfig.app_base_url_http}#{public_shop_path(@shop_identifier)}" and return
	end#end if subsribe_with_email

end
