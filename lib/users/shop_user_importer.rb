module Shops
  module Importer  
    def user_import(payload)
      binding.pry
      content = download_csv_file(payload)

      csv_table = CSV.parse(content, { headers: true, converters: :numeric, header_converters: :symbol})
      headers = csv_table.headers
      validate_headers(headers)
      binding.pry

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
            if shop.present?
              # user = User.find_or_initialize_by_email(row[:email])	
              # user.name = row[:name]
              ##find shop and set the shop id heere
              shop_id = 
              user.shop_id = shop_id
		      user = User.find_by_email(row[:email]) || User.new(email: row[:email])
		      user.skip_name = true
		      user.skip_welcome_email = true
		      user.name = row[:name] unless user.name.present?
		      gender = if (gender_val = row[:gender].to_s.downcase).length == 1
		                 gender_val
		               else
		                  gender_val == "male" ? "m" : (gender_val == "female" ? "f" : nil)
		               end
		      user.gender = gender
		      user.birth_date = (Date.parse(row[:birth_date]) rescue nil)
		      user.valid?
		      binding.pry
		      if user.errors.include?(:email) || user.errors.include?(:name)
		      	counters[:unparsed_rows] += 1 
		      	error_str = %{"Error: #{user.errors.full_messages.first}"}   
						output_row << error_str
						output << output_row.join(",")
						unparsed_rows << output_row.join(",") 
						next 
					end

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


            #   status = %{"New User"}
            #   output_row << status
            #   counters[:users_created] += 1
            #   output << output_row.join(",")
            # else
            #   status = %{"Existing User"}
            #   output_row << status
            #   counters[:existing_user] += 1 
            #   output << output_row.join(",")
            # end
          #end
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
    end

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
    end
  end # end of the shops importer module
end #end of the shops module