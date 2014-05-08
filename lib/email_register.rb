module EmailRegister
	private
		def sudo_registration(params)
		    @user = User.new(params[:user])
		    split_name = params["user"]["name"].split(" ")
        @user.first_name = split_name.first
        @user.last_name = split_name.last if split_name.size > 1
		    @user.skip_name = true
		    passwd = Devise.friendly_token.first(8)
		    @user.password = passwd
		    @user.password_confirmation = passwd
	      @shop = Shop.by_app_id(params[:app_id]) || Shop.for_uuid(params[:uuid])
	      if @shop.present?
		      @user.show_shop = true
		      @user.shop_identifier = @shop.id
	    	end
		    saved = @user.save
		    if @shop.present?
		    	Connection.find_or_create_by_user_id_and_shop_id(:user_id => @user.id, :shop_id => @shop.id, :connected_via => "Website")
		    	if !@shop.oauth_application.label_ids.blank?
		    		labels_ids = @shop.oauth_application.label_ids.split(",")
          	labels_ids.each do |l|
            	user_label = UserLabel.find_or_create_by_user_id_and_label_id(user_id: @user.id, label_id: l.to_i)
          	end
        	end
		    end
		    @user.errors.delete(:name)

		    if !saved && @user.errors.blank?
		      @user.show_password = true
		      @user.save(validate: false)
		    end
		    #return the user
		    @user
	  end
end