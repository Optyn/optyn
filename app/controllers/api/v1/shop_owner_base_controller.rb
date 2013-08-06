module Api
  module V1
    class ShopOwnerBaseController < ApplicationController
      respond_to :json

      helper_method :current_shop

      private
      def map_current_user_to_store
        Rails.logger.info "Using the shop as: #{current_shop.name}"
        Rails.logger.info "Using the current user as: #{current_user.name}"
        @shop = current_shop
        return true if @shop.blank?
        @connection = current_user.make_connection_if!(@shop)
      end

      def current_user
        if doorkeeper_token
          @current_user ||= User.find(doorkeeper_token.resource_owner_id)
        end
      end

      def current_shop
        if doorkeeper_token
          return @shop = doorkeeper_token.application.owner
        end

        @shop = Shop.by_app_id(params[:client_id].to_s)
      end
    end
  end
end