class Merchants::ShopsController < Merchants::BaseController

	skip_before_filter :active_subscription?, :only => [:show]
  before_filter :check_for_blank_q, only: [:check_identifier]

	def index
	end

	def edit
		@shop = current_shop
    @shop.website = @shop.website.to_s.gsub(/https?:\/\//, "") if @shop.website.present?
	end

	def update
		@shop = current_shop
		if @shop.update_attributes(params[:shop])
			flash[:notice] = "Shop details updated successfully"
      redirect_to merchants_shop_path
    else
      @shop_errors = @shop.errors
      render :action => :edit
    end
	end
	
	def show
		@shop = current_shop
  end

  def check_identifier
    shop = Shop.fetch_same_identifier(current_shop.id, params[:q])

    head((shop.present?  ? :unprocessable_entity : :ok))
  end

  def update_affiliate_tracking
    current_shop.update_attribute(:affiliate_tracker_pinged, true)
    head :ok
  rescue ActiveRecord::RecordNotFound
    head :unprocessible_entity
  end

  def remove_logo
    @shop = Shop.find(params[:id])
    @message = Message.find_by_uuid(params[:uuid])
    @shop.remove_logo_img!
    @shop.save
    @shop_logo = true
  end

  def upload_logo
    @shop = current_shop
    @shop.update_attributes(params[:shop])
    @message = Message.find_by_uuid(params[:uuid])
  end

  private
  def check_for_blank_q
    if params[:q].blank?
      head :unprocessable_entity
      false
    end
  end
end