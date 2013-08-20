module Api
  module V1
    module Merchants
			class UsersController < PartnerOwnerBaseController
				def import
					@payload = ApiRequestPayload.create(controller: controller_name, action: action_name, manager_id: current_manager.id,
                                              filepath: params[:filepath], status: 'Queued', label: params[:label])
					payload_id = @payload.id
					Resque.enqueue(PartnersUserImporter, payload_id)
				end

				#TODO TO BE IMPLEMENTED
				def import_status
				end

				#TODO TO BE IMPLEMENTED
				def import_list
				end
			end #end of the ConsumersController class
    end #end of Merchants module
  end #end of the V1 module
end #end of the Api module
