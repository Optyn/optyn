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

        respond_to do |format|
          format.html { render(file: 'api/v1/optyn_button/login') }
          json_str = {data: {authenticity_token: form_authenticity_token, errors: nil}}.to_json
          format.json {
            if params[:callback].present?
              render(text: "#{params[:callback]}('#{json_str}')")
            else
              render(status: :ok, json: json_str)
            end
          }

          format.any { render text: "Only HTML and JSON supported" }
        end
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
          render json: {message: render_to_string(partial: "api/v1/optyn_button/confirmation_message")}
        else
          session[:user_return_to] = nil
          head :unprocessable_entity
        end
      end

      def automatic_connection
        map_current_user_to_store
        if @shop.present? && @connection.present? && current_user.present?
          json_str = {data: {message: render_to_string(partial: "api/v1/optyn_button/confirmation_message")}}.to_json
          if params[:callback].present?
            render text: "#{params[:callback]}(#{json_str})", status: :ok
          else
            render json: json_str, status: :ok
          end
        else
          json_str = {data: {errors: "A connection could not be created"}}.to_json
          if params[:callback].present?
            render text: "#{params[:callback]}(#{json_str})", status: :unprocessable_entity
          else
            render json: json_str, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
