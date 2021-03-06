module Api
  module V1
    module Merchants
      class PartnerOwnerBaseController < ApplicationController
        doorkeeper_for :all, except: [:get_message]
        respond_to :json
        helper_method :current_shop, :current_manager
        before_filter :set_time_zone, :current_partner

        private
        
        def current_partner
          if doorkeeper_token
            @_current_partner = Partner.find(doorkeeper_token.resource_owner_id)
          end        
        rescue 
          Partner.last
        end

        def current_manager
          Manager.for_uuid(params[:manager_uuid])
        end
        
        def current_shop
          current_manager.shop
        end

        def set_time_zone
          ShopTimezone.set_timezone(current_shop)
        end

      end
    end
  end
end