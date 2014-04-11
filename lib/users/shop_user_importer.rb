module Users
  module ShopUserImporter
    HEADERS = {
                "last" => "last_name",
                "first" => "first_name",
                "email_address" => "email"                      
              }

    def convert_header(h)
      changed_header = h.to_s.downcase.gsub('-', '').gsub(' ','_')
      (HEADERS[changed_header].present? ? HEADERS[changed_header] : changed_header).intern
    end

    def user_import(payload)
      Rails.logger.info "Starting the download"
      content = download_user_import_csv_file(payload)
      Rails.logger.info "Done downloading and cleaning the file"

      Rails.logger.info "Creating the table"
      csv_table = CSV.parse(content, { headers: true, converters: :numeric, header_converters: lambda { |h| convert_header(h)}})
      Rails.logger.info "Done loading the csv table"
      headers = csv_table.headers
      validate_user_import_headers(headers)

      output = []
      unparsed_rows = []
      output_headers = %{"Shop","Manager Email","Email","First Name","Last Name","Gender","Birth Date"}
      output << output_headers
      unparsed_rows << output_headers
      
      counters = ActiveSupport::OrderedHash.new()
      counters[:users_created] = 0
      counters[:existing_users] = 0
      counters[:connection_creation] = 0
      counters[:existing_connection]  = 0
      counters[:unparsed_rows] = 0

      counter = 0
      csv_table.each do |row|
        counter += 1

        status = nil
        output_row = [%{"#{row[:shop]}"},%{"#{row[:manager_email]}"}, %{"#{row[:email]}"}, %{"#{row[:first_name]}"}, %{"#{row[:last_name]}"}, %{"#{row[:gender]}"}, %{"#{row[:birth_date]}"}]

        begin
          shop_name = row[:shop].to_s.strip
          manager_email = row[:manager_email].to_s.strip
          Shop.transaction do
            
            shop = Shop.for_manager_email(manager_email)
            shop.skip_payment_email = true if shop.present?
            
		        user = User.find_by_email(row[:email].to_s.downcase.strip) || User.new(email: row[:email].to_s.downcase.strip)

            Rails.logger.info "Parsing row: #{counter}| Email: #{user.email}|"
            
            user.skip_name = true
            user.skip_welcome_email = true
            user.first_name = row[:first_name].to_s.strip unless user.first_name.present?
            user.last_name = row[:last_name].to_s.strip unless user.last_name.present?
            gender = if (gender_val = row[:gender].to_s.strip.downcase).length == 1
                       gender_val
                     else
                        gender_val == "male" ? "m" : (gender_val == "female" ? "f" : nil)
                     end
            user.gender = gender
            user.birth_date = (Date.parse(row[:birth_date].to_s.strip) rescue nil)

            if user.errors.include?(:email) || user.errors.include?(:first_name) || user.errors.include?(:last_name)
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

          connection = Connection.find_by_shop_id_and_user_id(shop.id, user.id) || Connection.new(shop_id: shop.id, user_id: user.id)
          if connection.new_record?
            connection.active = true
            connection.connected_via = Connection::CONNECTED_VIA_IMPORT
            counters[:connection_creation] += 1
          else
            counters[:existing_connection] += 1
          end
          connection.skip_payment_email = true
          connection.save

          end #end of transaction

        rescue Exception => e
          Rails.logger.error e.message
          Rails.logger.error e.backtrace
          counters[:unparsed_rows] += 1
          status = %{"Error: System Error while parsing"}
          output_row << status
          unparsed_rows << output_row.join(",")
        end #end of begin

        output << output_row.join(",")
      end #end of each
        unparsed = unparsed_rows.size > 1 ? unparsed_rows.join("\n") : "" 
        [[counters], output.join("\n"), unparsed]
      end #end of user_import



    def validate_user_import_headers(headers)
      if !headers.include?(:shop) || !headers.include?(:first_name) || !headers.include?(:last_name) || !headers.include?(:gender) || !headers.include?(:birth_date)
        raise "Incorrect Headers. The file should have headers of 'Shop', 'Manager Email', 'Email', 'First Name','Last Name','Gender', 'Birth Date'" 
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
