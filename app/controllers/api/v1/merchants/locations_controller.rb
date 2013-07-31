module Api
  module V1
    module Merchants
      class LocationsController < PartnerOwnerBaseController
        before_filter :populate_state_id, only: [:create, :update]

        def index
          @locations = current_shop.locations
        end

        def show
          @location = Location.for_uuid(params[:id])
          render(template: "api/v1/merchants/locations/location")
        rescue ActiveRecord::RecordNotFound => e
          @location = Location.new
          @location.errors.add(:base, "Could not find the location you are looking for")
          render(status: :unprocessable_entity, template: 'api/v1/merchants/locations/location')
        end

        def create
          @location = Location.new(params[:location])
          @location.shop_id = current_shop.id
          @location.save!
          render(status: :created, template: "api/v1/merchants/locations/location")
        rescue ActiveRecord::RecordInvalid => e
          render(status: :unprocessable_entity, template: "api/v1/merchants/locations/location")
        end

        def update
          @location = Location.for_uuid(params[:id])
          @location.update_attributes!(params[:location])
          render(template: "api/v1/merchants/locations/location")
        rescue ActiveRecord::RecordInvalid => e
          render(status: :unprocessable_entity, template: 'api/v1/merchants/locations/location')
        rescue ActiveRecord::RecordNotFound => e
          @location = Location.new
          @location.errors.add(:base, "Could not find the location you are looking for")
          render(status: :unprocessable_entity, template: 'api/v1/merchants/locations/location')
        end

        def destroy
          @location = Location.for_uuid(params[:id])
          @location.destroy
          render(template: "api/v1/merchants/locations/location")
        rescue ActiveRecord::RecordNotFound => e
          @location = Location.new
          @location.errors.add(:base, "Could not find the location you are looking for")
          render(status: :unprocessable_entity, template: 'api/v1/merchants/locations/location')
        end

        private
        def populate_state_id
          params[:location][:state_id] = State.for_abbreviation(params[:location][:state_abbr]).id rescue nil
        end
      end
    end
  end
end
