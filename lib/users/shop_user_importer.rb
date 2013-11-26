module Users
  module ShopUserImporter  
    def user_import(payload)
      puts "Starting the download"
      content = download_user_import_csv_file(payload)
      puts "Done downloading and cleaning the file"

      puts "Creating the table"
      csv_table = CSV.parse(content, { headers: true, converters: :numeric, header_converters: :symbol})
      puts "Done loading the csv table"
      headers = csv_table.headers
      validate_user_import_headers(headers)

      output = []
      unparsed_rows = []
      output_headers = %{"Shop","Manager Email","Email","Name",Gender","Birth Date"}
      output << output_headers
      unparsed_rows << output_headers
      
      counters = ActiveSupport::OrderedHash.new()
      counters[:users_created] = 0
      counters[:existing_users] = 0
      counters[:unparsed_rows] = 0

      counter = 0
      csv_table.each do |row|
        counter += 1

        status = nil
        output_row = [%{"#{row[:shop]}"},%{"#{row[:manager_email]}"}, %{"#{row[:email]}"}, %{"#{row[:name]}"}, %{"#{row[:gender]}"}, %{"#{row[:birth_date]}"}]

        begin
          shop_name = row[:shop].to_s.strip
          manager_email = row[:manager_email].to_s.strip
          Shop.transaction do
            
            shop = Shop.for_manager_email(manager_email)
            
		        user = User.find_by_email(row[:email].to_s.downcase.strip) || User.new(email: row[:email].to_s.downcase.strip)

            puts "Parsing row: #{counter}| Email: #{user.email}"
            
            user.skip_name = true
            user.skip_welcome_email = true
            user.name = row[:name].to_s.strip unless user.name.present?
            gender = if (gender_val = row[:gender].to_s.strip.downcase).length == 1
                       gender_val
                     else
                        gender_val == "male" ? "m" : (gender_val == "female" ? "f" : nil)
                     end
            user.gender = gender
            user.birth_date = (Date.parse(row[:birth_date].to_s.strip) rescue nil)
            
            user.shops = [shop]

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
              counters[:users_created] += 1
              output_row << %{"Created a New User"}
            else
              counters[:existing_users] += 1
              output_row << %{"User exists"}
            end #end of user.new_record?

            user.save()
          end #end of transaction

        rescue Exception => e
          Rails.logger.error e.message
          Rails.logger.error e.backtrace
          counters[:unparsed_rows] += 1
          status = %{"Error: #{e.message}"}
          output_row << status
          unparsed_rows << output_row.join(",")
        end #end of begin

        output << output_row.join(",")
      end #end of each
        unparsed = unparsed_rows.size > 1 ? unparsed_rows.join("\n") : "" 
        [[counters], output.join("\n"), unparsed]
      end #end of user_import



    def validate_user_import_headers(headers)
      if !headers.include?(:shop) || !headers.include?(:name) || !headers.include?(:gender) || !headers.include?(:birth_date)
        raise "Incorrect Headers. The file should have headers of 'Shop','Name','Gender', 'Birth Date'" 
      end  
    end

    def download_user_import_csv_file(payload)
      s3 = AWS::S3.new(
        :access_key_id => SiteConfig.aws_access_key_id,
        :secret_access_key => SiteConfig.aws_secret_access_key)
      bucket = s3.buckets["optyn#{Rails.env}"]
      content = bucket.objects[CGI::unescape(payload.filepath)].read
      csv_data = content.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?")
    end#end of function download_csv_file
  end # end of the shops importer module
end #end of the shops module
