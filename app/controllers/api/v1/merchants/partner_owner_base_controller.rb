module Api
  module V1
    module Merchants
      class PartnerOwnerBaseController < ApplicationController

        private
        #TODO TO BE IMPLEMTED. THIS IS ONLY A PLACEHOLDER
        def current_partner
          Partner.optyn
        end

        #TODO TO BE IMPLEMTED. THIS IS ONLY A PLACEHOLDER
        def current_manager
          Manager.find_by_email('gaurav+10@optyn.com')
        end

        #TODO TO BE IMPLEMTED. THIS IS ONLY A PLACEHOLDER
        def current_shop
          current_manager.shop
        end
      end
    end
  end
end