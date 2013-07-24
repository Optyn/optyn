module Doorkeeper
  module ResourceTypeManager

  	def self.included(controller)
  	  controller.helper_method :optyn_oauth_resoruce_type, :'optyn_oauth_resource_type=', :optyn_oauth_resource_type_shop?, :optyn_oauth_resource_type_manager?	
  	end

    private
  	def optyn_oauth_resource_type
  	  session[:optyn_oauth_resource_type]	
  	end

  	def set_optyn_oauth_resource_type(client_id)
      app = Doorkeeper::Application.find_by_uid(client_id)
  	  session[:optyn_oauth_resource_type] = app.owner_type rescue nil		
  	end

  	def optyn_oauth_resource_type_shop?
  	  Shop.name.to_s == optyn_oauth_resource_type
  	end

  	def optyn_oauth_resource_type_merchant_app?
  	  MerchantApp.name.to_s == optyn_oauth_resource_type
    end

    def optyn_oauth_resource_type_partner_app?
      Partner.name.to_s == optyn_oauth_resource_type
    end
  end
end