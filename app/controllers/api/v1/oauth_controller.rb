module Api
  module V1
    class OauthController < BaseController
      layout "cross_domain"

      respond_to :html, :json

      doorkeeper_for :connection, :update_permissions

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

        if current_user.update_attributes(params[:user])
          if user_changed

            render json: {message: render_to_string(partial: "api/v1/oauth/confirmation_message")}
          else
            head :ok
          end
        else
          head :unprocessable_entity
        end
      end
    end
  end
end
