class Merchants::BaseController < ApplicationController
	before_filter :authenticate_merchants_manager!, :set_time_zone, except: [:public_view, :generate_qr_code, :redeem, :share_email, :send_shared_email, :template_upload_image]
	before_filter :check_connection_count, except: [:public_view, :generate_qr_code, :redeem, :share_email, :send_shared_email, :template_upload_image]
	helper_method :current_shop, :manager_signed_in?, :current_manager, :current_partner

	private

  def is_current_manager_owner?
    unless current_manager.owner?
      redirect_to merchants_locations_path
      flash[:alert] ="Sorry,only Admin Manager can update location"
    end
  end

  def set_time_zone
    ShopTimezone.set_timezone(current_shop)
  end

  def check_connection_count
    ##INFO: if someone creates a starter plan with no max signup of merhcant will crash.
    ## we need to handle this
    return if current_shop.active_connection_count <= Plan.starter.max 
    flash[:alert] = "Please provide your payment details <a href='#{merchants_upgrade_subscription_path}'>here</a> in order to continue sending messages/emails." if current_shop.disabled?
  end

	
	def current_shop
		@_shop ||= current_merchants_manager.shop if merchants_manager_signed_in?
	end

  def current_partner
    @_partner ||= current_shop.partner if merchants_manager_signed_in?
  end
end
