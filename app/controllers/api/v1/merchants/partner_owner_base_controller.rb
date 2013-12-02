module Api
  module V1
    module Merchants
      class PartnerOwnerBaseController < ApplicationController
        doorkeeper_for :all
        respond_to :json
        helper_method :current_shop, :current_manager
        before_filter :current_partner

        private
        
        def current_partner
          Rails.logger.info "=" * 100
          Rails.logger.info doorkeeper_token.resource_owner_id.inspect
          Rails.logger.info "&" * 100

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

      end
    end
  end
end