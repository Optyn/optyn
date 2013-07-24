module Api
  module V1
    class UsersController < ApiBaseController
      doorkeeper_for :all

      before_filter :map_current_user_to_store, only: [:show]
      before_filter :validate_subscribe_params, only: [:create_connection]
      before_filter :validate_shop, :validate_connection_state_params, except: [:show, :alias]

      def show
        #DO NOTHING
      end

      def check_connection
        @connection = Connection.find_by_user_id_and_shop_id(current_user.id, @shop.id)
        render 'connection'
      end

      def create_connection
        @connection = Connection.find_by_user_id_and_shop_id(current_user.id, @shop.id) ||
            Connection.new(user_id: current_user.id, shop_id: @shop.id)
        @connection.active = true
        @connection.connected_via = Connection::CONNECTED_VIA_EXTENSION if @connection.new_record?
        @connection.save

        render 'connection'
      end

      def create_error
        @connection_error = ConnectionError.create(user_id: current_user.id, shop_id: @shop.id, error: params[:error])
        render 'connection'
      end

      def alias
        #DO NOTHING
      end

      private
      def validate_subscribe_params
        if params[:name].blank?
          @errors = []
          @errors << ["Shop name cannot be blank"] if params[:name].blank?
          render(action: 'errors.json', status: :unprocessable_entity)
          false
        end
      end

      def validate_shop
        if params[:name].present?
          @shop = Shop.find_by_name(params[:name])
          if @shop.blank?
            @errors = ["Could not find the shop"]
            render(action: 'errors.json', status: :unprocessable_entity)
            false
          end
        end
      end

      def validate_connection_state_params
        if params[:name].blank?
          @errors = ["Shop name cannot be blank"]
          render(action: 'errors.json', status: :unprocessable_entity)
          false
        end
      end
    end
  end
end