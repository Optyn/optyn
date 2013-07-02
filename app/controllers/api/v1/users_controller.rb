module Api
  module V1
    class UsersController < ApiBaseController
      doorkeeper_for :all

      before_filter :map_current_user_to_store
      before_filter :sanitize_tab_html, :validate_subscribe_params, only: [:subscribe]
      before_filter :validate_connection_state_params, only: [:connection_state]
      before_filter :validate_shop

      def show
        #respond_with current_user.as_json(only: [:name])
        if params[:callback].present?
          resp = "var userInfo = #{current_user.as_json(only: [:name]).to_json};"
          resp << "#{params[:callback]}(userInfo);"
          render text: resp
        else
          render(json: {data: {name: current_user.as_json(only: [:name])}}, status: :ok)
        end
      end

      def connection_state
        connection = Connection.find_by_shop_id_and_user_id(@shop.id, current_user.id)
        if connection.present?
          return render(status: :ok, json: {data: {state: "Connected"}})
        end

        virtual_connection = VirtualConnection.find_by_shop_id_and_user_id(@shop.id, current_user.id)
        render(status: :ok, json: {data: {state: virtual_connection.state}})
      end

      def subscribe
        sanitized_html = @sanitized_tab_html.scan(/(<form(.*?)<\/form>)/imx).collect(&:first).collect { |form| "<div>#{form}</div>" }.join("")
        @virtual_connection = VirtualConnection.find_or_create_by_shop_id_and_user_id(@shop.id, current_user.id, html_content: sanitized_html, state: VirtualConnection::IN_PROCESS_STATE)
        render(json: {data: {user: {name: current_user.name}, connection: {state: @virtual_connection.state}, shop: {name: @shop.name}}}, status: :ok)
      end

      private
      def validate_subscribe_params
        if params[:shop_name].blank? || @sanitized_tab_html.blank?
          errors = []
          errors << ["Shop name cannot be blank"] if params[:shop_name].blank?
          errors << ["The form content of the current tab is missing"] if @sanitized_tab_html.blank?
          render(status: :unprocessable_entity, json: {data: {errors: errors.as_json}})
          false
        end
      end

      def sanitize_tab_html
        @sanitized_tab_html = params[:tab_html].encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '').encode('UTF-8', 'UTF-16')
      end

      def validate_shop
        if params[:shop_name].present?
          if @shop.blank?
            render(status: :unprocessable_entity, json: {data: {errors: "Could find the shop"}})
            false
          end
        end
      end

      def validate_connection_state_params
        if params[:shop_name].blank?
          render(status: :unprocessable_entity, json: {data: {errors: "Shop name cannot be blank"}})
          false
        end
      end
    end
  end
end