module Api
  module V1
    module Merchants
      class ShopsController < PartnerOwnerBaseController
        def import_list
          #TODO get the patner from the access token
          partner_id = Partner.optyn_id
          @import_list = ApiRequestPayload.for_partner(partner_id)
        end

        def import
          #TODO get the patner from the access token
          @payload = ApiRequestPayload.create(controller: controller_name, action: action_name, partner_id: Partner.optyn_id,
                                              body: params, status: 'Queued')
          payload_id = @payload.id
          Resque.enqueue(ShopImporter, payload_id)
        end

        def import_status
          @payload = ApiRequestPayload.for_uuid(params[:uuid])
        end

        def create
          begin
            @shop = Shop.new(params[:shop])
            @shop.partner_id = Partner.optyn_id #Need to set this explicitly
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