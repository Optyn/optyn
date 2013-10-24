module EmailRegister
	private
		def sudo_registration
		    @user = User.new(params[:user])
		    passwd = Devise.friendly_token.first(8)
		    @user.password = passwd
		    @user.password_confirmation = passwd

		    saved = @user.save
		    @user.errors.delete(:name)

		    if !saved && @user.errors.blank?
		      @user.show_password = true
		      @shop = Shop.by_app_id(params[:app_id]) rescue Shop.for_uuid(params[:uuid])
		      @user.show_shop = true
		      @user.shop_identifier = @shop.id
		      @user.save(validate: false)
		    end
		    #return the user
		    @user
	  end
end