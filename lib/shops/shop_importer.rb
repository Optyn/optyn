module Shops
  module ShopImporter  
    def import(payload)
    content = download_csv_file(payload)

    csv_table = CSV.parse(content, { headers: true, converters: :numeric, header_converters: :symbol })
    headers = csv_table.headers
    payload.stats = []

    csv_table.each do |row|
      status = nil
      begin
        shop_name = row[:shop_name]
        Shop.transaction do
          shop = for_name(shop_name) || Shop.new()
          if shop.new_record?
            shop.name = shop_name
            shop.phone_number = row[:shop_phone]
            shop.partner_id = payload.partner_id
            shop.stype = row[:shop_type].present? ? row[:shop_type] : "local"


            manager = shop.managers.build

            manager.email                  = row[:manager_email]
            manager.name                   = row[:manager_name]
            manager.skip_name              = true
            manager.password               = row[:manager_password]
            manager.password_confirmation  = row[:manager_password]

            shop.save!
            shop.update_manager
            status = "New Shop"
          else
            status = "Existing Shop"
          end

          payload.stats << {shop: {name: shop_name, uuid: shop.uuid, status: status, created_at: shop.created_at}}
        end
      rescue Exception => e    
        Rails.logger.error e.message
        Rails.logger.error e.backtrace
        payload.stats << {shop: {name: shop_name, uuid: "-", status: "Error: #{e.message}"}}
      end
    end
  end

  def download_csv_file(payload)
    s3 = AWS::S3.new(
      :access_key_id => SiteConfig.aws_access_key_id,
      :secret_access_key => SiteConfig.aws_secret_access_key)
    bucket = s3.buckets["partner#{Rails.env}"]
    content = bucket.objects[payload.filepath].read
  end
  end # end of the shops importer module
end #end of the shops module