module Api
  module V1
    module Merchants
      class ManagersController < PartnerOwnerBaseController
        doorkeeper_for :all
        before_filter :fetch_manager, :update_or_destroy_allowed?, only: [:update, :destroy]
        #before filter to check update the manager self or not admin
        #before filter to check only a owner should be able to delete a manager

        def index
          @managers = current_shop.managers
        end

        def create
          @manager = Manager.new(params[:manager])
          @manager.shop_id = current_manager.shop_id
          @manager.save!
          render(status: :created, template: 'api/v1/merchants/managers/manager')
        rescue ActiveRecord::RecordInvalid => e
          render(status: :unprocessable_entity)
        end

        def update
          begin
            manager_params = params[:manager]
            if manager_params[:password].blank? && manager_params[:password_confirmation].blank? && manager_params[:current_password].blank?
              updated = @manager.update_without_password(params[:manager])
            else
              updated = @manager.update_with_password(params[:manager])
            end
            
            render(status: :unprocessable_entity, template: 'api/v1/merchants/managers/manager') and return unless updated
            render(status: :ok, template: 'api/v1/merchants/managers/manager')
          rescue ActiveRecord::RecordInvalid => e
            render(status: :unprocessable_entity, template: 'api/v1/merchants/managers/manager')
          rescue ActiveRecord::RecordNotFound => e
            @manager = Manager.new
            @manager.errors.add(:base, "Could not find the manager you are looking for")
            render(status: :unprocessable_entity, template: 'api/v1/merchants/managers/manager')
          end
        end

        def show
          @manager = Manager.for_uuid(params[:id])
          render(status: :created, template: 'api/v1/merchants/managers/manager')
        rescue ActiveRecord::RecordNotFound => e
          @manager = Manager.new
          @manager.errors.add(:base, "Could not find the manager you are looking for")
          render(status: :unprocessable_entity, template: 'api/v1/merchants/managers/manager')
        end

        def destroy
          @manager.destroy
          render(template: 'api/v1/merchants/managers/manager', status: :ok)
        end

        def get_manager_from_email
          @manager = current_partner.managers.where(:email=>params[:email]).limit(1).first
          Rails.logger.info "$" * 100
          Rails.logger.info @manager.inspect
          Rails.logger.info "#" * 100


          unless @manager
             render(status: :unprocessable_entity)
          end
        end

        # Expire Access Token 
        def logout_manager
          access_token = current_partner.access_tokens.where(:token=>params[:access_token]).limit(1).first
          if access_token
            access_token.revoked_at = Time.now
            access_token.save
            render(head: :ok)
          else
            render(head: :unprocessable_entity)
          end
        end

        private
        def fetch_manager
          @manager = Manager.for_uuid(params[:id])
        end

        def update_or_destroy_allowed?
          return true if current_manager.owner && 'destroy' != action_name

          if current_manager.owner && 'destroy' == action_name && @manager == current_manager
            flash[:error] = "You cannot delete yourself"
            render(status: :unprocessable_entity, template: "api/v1/shared/filter_errors")
            return false
          elsif current_manager.owner && 'destroy' == action_name && @manager != current_manager
            return true
          end

          if current_manager == @manager
            if action_name != 'destroy'
              return true
            elsif !current_manager.owner && action_name == 'destroy'
              flash[:error] = "You cannot delete users"
              render(status: :unprocessable_entity, template: "api/v1/shared/filter_errors")
              return false
            end
          end

          flash[:error] = "You don't have appropriate rights to perform this operation"
          render(status: :unprocessable_entity, template: "api/v1/shared/filter_errors")
          false
        end
      end
    end
  end
end
