module Api
  module V1
    module Merchants
      class ShopsController < PartnerOwnerBaseController
	      # doorkeeper_for :all
	
        def index
          @shops = current_partner.shops.real.includes_managers
        end  

        def import_list
          partner_id = current_partner.id
          @import_list = ApiRequestPayload.shop_imports(partner_id)
        end

        def import
          ##import shops :get
          @payload = ApiRequestPayload.create(controller: controller_name, action: action_name, partner_id: current_partner.id,
                                              filepath: params[:filepath], status: 'Queued')
          payload_id = @payload.id
          Resque.enqueue(ShopImporter, payload_id)
        end

        def import_user
          ##will import users for a Partner > shop :post
          binding.pry
          @payload = ApiRequestPayload.create(controller: controller_name, action: action_name, partner_id: current_partner.id,
                                              filepath: params[:filepath], status: 'Queued')
          payload_id = @payload.id
          Resque.enqueue(ShopUsersImporter, payload_id)
        end

        def import_user_list
          ##gets list of all the user import
          binding.pry
          partner_id = current_partner.id
          @import_list = ApiRequestPayload.user_imports_for_partner(partner_id)
        end

        def import_status
          ##get stats for a paritcular import
          @payload = ApiRequestPayload.for_uuid(params[:id])
        end

        def create
          begin
            @shop = Shop.new(params[:shop])
            @shop.partner_id = current_partner.id
            set_shop_image
            @shop.save!
            @shop.update_manager
            render(status: :created)
          rescue ActiveRecord::RecordInvalid => e
            render(status: :unprocessable_entity)
          end
        end

        def show
          begin
            @shop = Shop.for_uuid(params[:id])
          rescue ActiveRecord::RecordInvalid => e
            render(status: :unprocessable_entity)
          rescue ActiveRecord::RecordNotFound => e
            @shop = Shop.new
            @shop.errors.add(:base, "Could not find the shop you are looking for")
            render(status: :unprocessable_entity)
          end
        end

        def update
          begin
            @shop = Shop.for_uuid(params[:id])
            @shop.update_with_existing_manager(params[:shop])
          rescue ActiveRecord::RecordInvalid => e
            render(status: :unprocessable_entity)
          rescue ActiveRecord::RecordNotFound => e
            @shop = Shop.new
            @shop.errors.add(:base, "Could not find the shop you are looking for")
            render(status: :unprocessable_entity)
          end
        end
            
        def active_connections
          render :json=>{:data=>{:active_connections=>current_shop.active_connection_count}} 
        end

        private
        def set_shop_image
          if params[:shop][:logo_img]
            image_params = params[:shop][:logo_img][:image]
            tempfile = Tempfile.new("fileupload")
            tempfile.binmode
            tempfile.write(Base64.decode64(image_params["file"]))
            @uploaded_file = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :filename => image_params["filename"], :original_filename => image_params["original_filename"]) 
            @uploaded_file.headers=image_params[:headers]
            @uploaded_file.content_type=image_params[:content_type]
            params[:shop][:logo_img] = @uploaded_file 
            #message_image = @message.build_message_image(params[:message][:message_image_attributes])
            @shop.logo_img = params[:shop][:logo_img]
          end
        end


      end
    end
  end
end
