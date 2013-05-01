module Api
  module V1
    class BaseController < ApplicationController
      respond_to :json

      private
      def map_current_user_to_store
        @shop = doorkeeper_token.application.owner

        @connection = current_user.make_connection_if!(@shop)
      end

      def current_user
        if doorkeeper_token
          @current_user ||= User.find(doorkeeper_token.resource_owner_id)
        end
      end
    end
  end
end