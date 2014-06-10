module Api
  module V1
    class OptynButtonController < ShopOwnerBaseController
      layout "cross_domain"

      respond_to :html, :json

      doorkeeper_for :connection, :update_permissions, :automatic_connection

      before_filter :map_current_user_to_store, only: [:update_permissions]

      def login
        session[:omniauth_manager] = nil
        session[:omniauth_user] = true
        @user_login = User.new
        @user = User.new
      end

      def connection
        @shop = doorkeeper_token.application.owner
        @permissions_user = current_user.permissions_users.present? ? current_user.permissions_users : current_user.build_permission_users
      end

      def update_permissions
        current_user.attributes = params[:user]
        @shop = doorkeeper_token.application.owner
        user_changed = current_user.changed? || @connection

        if current_user.save(validate: false) #current_user.update_attributes(params[:user])
          @message = permissions_message
        else
          session[:user_return_to] = nil
          head :unprocessable_entity
        end
      end

      def automatic_connection
        map_current_user_to_store
        if @shop.present? && @connection.present? && current_user.present?
          @message = permissions_message
        else
          @errors =  ["A connection could not be created"]
        end
      end

      private
      def permissions_message
        "A connection between you and #{@shop.name} has been successfully created. Thank you and keep on keepin' on."
      end
    end
  end
end
