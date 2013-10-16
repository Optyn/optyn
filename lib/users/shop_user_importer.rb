module Users
  module ShopUserImporter  
    def user_import(payload)
      binding.pry
      content = download_csv_file(payload)

      csv_table = CSV.parse(content, { headers: true, converters: :numeric, header_converters: :symbol})
      headers = csv_table.headers
      validate_headers(headers)

      output = []
      unparsed_rows = []
      output_headers = %{"Shop","Email","Name",Gender","Birth Date"}
      output << output_headers
      unparsed_rows << output_headers
      
      counters = ActiveSupport::OrderedHash.new()
      counters[:users_created] = 0
      counters[:existing_users] = 0
      counters[:unparsed_rows] = 0

      csv_table.each do |row|
        status = nil
        output_row = [%{"#{row[:shop]}"}, %{"#{row[:email]}"}, %{"#{row[:name]}"}, %{"#{row[:gender]}"}, %{"#{row[:birth_date]}"}]
        
        begin
          shop_name = row[:shop]
          Shop.transaction do
            shop = for_name(shop_name)
		        user = User.find_by_email(row[:email]) || User.new(email: row[:email])
            if user.new_record?
              passwd = Devise.friendly_token.first(8)
              user.password = passwd
              user.password_confirmation = passwd
              user.show_password = true
              user.show_shop = true
              user.shop_identifier = shop.id
              counters[:user_creation] += 1
              output_row << %{"Created a New User"}
            else
              counters[:existing_user] += 1
              output_row << %{"User exists"}
            end
            user.save()
          end
          rescue Exception => e
            Rails.logger.error e.message
            Rails.logger.error e.backtrace
            counters[:unparsed_rows] += 1
            status = %{"Error: #{e.message}"}
            output_row << status
            unparsed_rows << output_row.join(",")
          end
          output << output_row.join(",")
        end
        unparsed = unparsed_rows.size > 1 ? unparsed_rows.join("\n") : "" 
        [[counters], output.join("\n"), unparsed]
      end#end of user_import



    def validate_headers(headers)
      # binding.pry
      if !headers.include?(:shop) || !headers.include?(:name) || !headers.include?(:gender) || !headers.include?(:birth_date)
        raise "Incorrect Headers. The file should have headers of 'Shop','Name','Gender', 'Birth Date'" 
      end  
    end

    def download_csv_file(payload)
      s3 = AWS::S3.new(
        :access_key_id => SiteConfig.aws_access_key_id,
        :secret_access_key => SiteConfig.aws_secret_access_key)
      bucket = s3.buckets["optyn#{Rails.env}"]
      content = bucket.objects[CGI::unescape(payload.filepath)].read
    end#end of function download_csv_file
  end # end of the shops importer module
end #end of the shops module
