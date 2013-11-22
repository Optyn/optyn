module Shops
  module Importer  
    def import(payload)
      #binding.pry
      content = download_csv_file(payload)

      csv_table = CSV.parse(content, { headers: true, converters: :numeric, header_converters: :symbol})
      headers = csv_table.headers
      validate_headers(headers)

      output = []
      unparsed_rows = []
      output_headers = %{"Shop Name","Shop Phone","Shop Type","Manager Name","Manager Email","Manager Password","Status"}
      output << output_headers
      unparsed_rows << output_headers
      
      counters = ActiveSupport::OrderedHash.new()
      counters[:shops_created] = 0
      counters[:existing_shops] = 0
      counters[:unparsed_rows] = 0
      counter = 0

      csv_table.each do |row|
        counter += 1
        status = nil
        output_row = [%{"#{row[:shop_name]}"}, %{"#{row[:shop_phone]}"}, %{"#{row[:shop_type]}"}, %{"#{row[:manager_name]}"}, %{"#{row[:manager_email]}"}, %{"#{row[:manager_password]}"}]
        
        begin
          shop_name = row[:shop_name]

          puts "#{counter} Parsing Shop: #{shop_name}"

          Shop.transaction do
            # shop = for_name(shop_name) || Shop.new()
            manager = Manager.find_by_email(row[:manager_email]) || Manager.new
            shop = manager.new_record? ? Shop.new : manager.shop
            if shop.new_record?
              shop.name = shop_name
              shop.phone_number = row[:shop_phone].to_s
              shop.phone_number = "+1" + shop.phone_number
              shop.partner_id = payload.partner_id
              shop.stype = row[:shop_type].present? ? row[:shop_type] : "local"
              
                

              manager = shop.managers.build

              manager.email                  = row[:manager_email].to_s.strip
              manager.name                   = row[:manager_name].to_s.strip
              manager.skip_name              = true
              manager.password               = row[:manager_password].to_s.strip
              manager.password_confirmation  = row[:manager_password].to_s.strip

              shop.save!
              shop.update_manager

              begin 
                shop.reload
                shop.remote_logo_img_url = row[:shop_image_uri].to_s.strip
                shop.save!
              rescue => e
                puts "Failed Image #{shop_name}"
                nil
              end

              status = %{"New Shop"}
              output_row << status
              counters[:shops_created] += 1
              output << output_row.join(",")
            else
              status = %{"Existing Shop"}
              output_row << status
              counters[:existing_shops] += 1 
              output << output_row.join(",")
            end
          end
        rescue Exception => e    
          Rails.logger.error e.message
          Rails.logger.error e.backtrace
          counters[:unparsed_rows] += 1
          status = %{"Error: #{e.message}"}
          output_row << status
          unparsed_rows << output_row.join(",")
        end
      end

      unparsed = unparsed_rows.size > 1 ? unparsed_rows.join("\n") : "" 

      [[counters], output.join("\n"), unparsed]
    end

    def validate_headers(headers)
      # binding.pry
      if !headers.include?(:shop_name) || !headers.include?(:shop_phone) || !headers.include?(:manager_email) || !headers.include?(:manager_password)
        raise "Incorrect Headers. The file should have headers of 'Shop Name','Shop Phone','Shop Type', 'Manager Name', 'Manager Email' and 'Manager Password'" 
      end  
    end

    def download_csv_file(payload)
      s3 = AWS::S3.new(
        :access_key_id => SiteConfig.aws_access_key_id,
        :secret_access_key => SiteConfig.aws_secret_access_key)
      bucket = s3.buckets["optyn#{Rails.env}"]
      content = bucket.objects[CGI::unescape(payload.filepath)].read
    end
  end # end of the shops importer module
end #end of the shops module