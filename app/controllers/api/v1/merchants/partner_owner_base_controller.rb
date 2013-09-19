module Api
  module V1
    module Merchants
      class PartnerOwnerBaseController < ApplicationController
        doorkeeper_for :all
        private
        
        def current_partner
          current_shop.partner        
        end

        def current_manager
          Manager.where(:uuid=>params[:manager_uuid]).first
        end
        
        def current_shop
          current_manager.shop
        end
      end
    end
  end
end