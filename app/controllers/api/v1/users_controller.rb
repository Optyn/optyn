module Api
  module V1
    class UsersController < ApiBaseController
      doorkeeper_for :all

      before_filter :map_current_user_to_store, only: [:show]
      before_filter :validate_subscribe_params, only: [:create_connection]
      before_filter :validate_shop, :validate_connection_state_params, except: [:show]

      def show
        #respond_with current_user.as_json(only: [:name])
        if params[:callback].present?
          resp = "var userInfo = #{{name: current_user.display_name}.to_json};"
          resp << "#{params[:callback]}(userInfo);"
          render text: resp
        else
          render(json: {data: {name: current_user.display_name}}, status: :ok)
        end
      end

      def check_connection
        connection = Connection.find_by_user_id_and_shop_id(current_user.id, @shop.id)
        if connection.present?
          render json: {data: {user: connection.user.display_name, shop: connection.shop.name, active: connection.active}}
        else
          render json: {data: {user: nil, shop: nil}}
        end
      end

      def create_connection
        connection = Connection.find_by_user_id_and_shop_id(current_user.id, @shop.id) ||
            Connection.new(user_id: current_user.id, shop_id: @shop.id)
        connection.active = true
        connection.connected_via = Connection::CONNECTED_VIA_EXTENSION if connection.new_record?
        connection.save

        render json: {data: {user: current_user.display_name, shop: @shop.name, active: connection.active}}
      end

      def create_error
        connection_error = ConnectionError.create(user_id: current_user.id, shop_id: @shop.id, error: params[:error])
        render json: {data: {user: current_user.display_name, shop: @shop.name}}
      end

      def alias
        render json: {data: {user: current_user.display_name, alias: current_user.alias}}
      end

      private
      def validate_subscribe_params
        if params[:name].blank?
          errors = []
          errors << ["Shop name cannot be blank"] if params[:name].blank?
          errors << ["The form content of the current tab is missing"] if @sanitized_tab_html.blank?
          render(status: :unprocessable_entity, json: {data: {errors: errors.as_json}})
          false
        end
      end

      def validate_shop
        if params[:name].present?
          @shop = Shop.find_by_name(params[:name])
          if @shop.blank?
            render(status: :unprocessable_entity, json: {data: {errors: "Could not find the shop"}})
            false
          end
        end
      end

      def validate_connection_state_params
        if params[:name].blank?
          render(status: :unprocessable_entity, json: {data: {errors: "Shop name cannot be blank"}})
          false
        end
      end
    end
  end
end