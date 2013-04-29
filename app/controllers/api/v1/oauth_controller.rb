module Api
  module V1
    class OauthController < BaseController
      layout "cross_domain"

      doorkeeper_for :all, except: [:login]

      def login
        session[:omniauth_manager] = nil
        session[:omniauth_user] = true
        @user_login = User.new
        @user = User.new
      end

      def connection
        @shop = doorkeeper_token.application.owner
        @current_user = User.find(doorkeeper_token.resource_owner_id)
        @permissions_user = @current_user.permissions_users.present? ? @current_user.permissions_users : @current_user.build_permission_users
      end

      def update_permissions
        current_user.update_attributes(params[:user])

        head :ok
      end
    end
  end
end
