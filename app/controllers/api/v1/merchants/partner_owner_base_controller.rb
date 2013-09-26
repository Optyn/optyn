module Api
  module V1
    module Merchants
      class PartnerOwnerBaseController < ApplicationController
        doorkeeper_for :all
        private
        
        def current_partner
          if doorkeeper_token
            @_current_partner ||= Partner.find(doorkeeper_token.resource_owner_id)
          end        
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