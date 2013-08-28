module Api
  module V1
    module Merchants
      class ShopsController < PartnerOwnerBaseController
	doorkeeper_for :all
	before_filter :import_list, :import, :import_status, :update
        def import_list
          partner_id = current_partner.id
          @import_list = ApiRequestPayload.shop_imports(partner_id)
        end

        def import
          @payload = ApiRequestPayload.create(controller: controller_name, action: action_name, partner_id: current_partner.id,
                                              filepath: params[:filepath], status: 'Queued')
          payload_id = @payload.id
          Resque.enqueue(ShopImporter, payload_id)
        end

        def import_status
          @payload = ApiRequestPayload.for_uuid(params[:id])
        end

        def create
          begin
            @shop = Shop.new(params[:shop])
            @shop.partner_id = current_partner.id
            @shop.save!
            @shop.update_manager
            render(status: :created)
          rescue ActiveRecord::RecordInvalid => e
            render(status: :unprocessable_entity)
          end
        end

        def update
          begin
            @shop = Shop.for_uuid(params[:id])
            @shop.update_attributes!(params[:shop])
          rescue ActiveRecord::RecordInvalid => e
            render(status: :unprocessable_entity)
          rescue ActiveRecord::RecordNotFound => e
            @shop = Shop.new
            @shop.errors.add(:base, "Could not find the shop you are looking for")
            render(status: :unprocessable_entity)
          end
        end
      end
    end
  end
end
