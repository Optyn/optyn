module Users		
	module Importer
		def import(content, manager, label)
	    shop = manager.shop

	    csv_table = CSV.parse(content, { headers: true, converters: :numeric, header_converters: :symbol })
	  	headers = csv_table.headers

	    headers = csv_table.headers
	    validate_headers(headers)

	    output = []
	    unparsed_rows = []
	    output_headers = %{"Name","Email","Gender","Birth Date","Status"}
	    output << output_headers
	    unparsed_rows << output_headers

	    counters = ActiveSupport::OrderedHash.new()
	    counters[:user_creation] = 0
	    counters[:existing_user] = 0
	    counters[:connection_creation] = 0
	    counters[:existing_connection]  = 0
	    counters[:unparsed_rows] = 0

	    csv_table.each do |row|
	    	output_row = [%{"#{row[:name]}"}, %{"#{row[:email]}"}, %{"#{row[:gender]}"}, %{"#{row[:birth_date]}"}]

	    	begin
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


		      connection = Connection.find_by_shop_id_and_user_id(shop.id, user.id) || Connection.new(shop_id: shop.id, user_id: user.id)
		      if connection.new_record?
		        connection.active = true
		        connection.connected_via = Connection::CONNECTED_VIA_IMPORT
		        counters[:connection_creation] += 1
		      else
		        counters[:existing_connection] += 1
		      end
		      connection.save()

		      label_instance = Label.find_or_create_by_shop_id_and_name(shop.id, (label || FileImport::DEFAULT_LABEL_NAME))
		      UserLabel.find_or_create_by_user_id_and_label_id(user.id, label_instance.id)

		      output << output_row.join(",")
		    rescue Exception => e
		    	counters[:unparsed_rows] += 1 
		    	output_row << %{"Error: #{e.message}"} 
		    	output << output_row.join(",")
		    	unparsed_rows << output_row.join(",") 
	    	end
	    end
	    
	    unparsed = unparsed_rows.length > 0 ? unparsed_rows.join("\n") : ""

	    [counters, output.join("\n"), unparsed]
		end

    def validate_headers(headers)
    	raise "Incorrect Headers. The file should have headers of 'Name', 'Email', 'Gender' and 'Birth Date'" if !headers.include?(:name) || !headers.include?(:email)
  	end

	  def download_file_from_payload(payload)
      s3 = AWS::S3.new(
        :access_key_id => SiteConfig.aws_access_key_id,
        :secret_access_key => SiteConfig.aws_secret_access_key)
      bucket = s3.buckets["partner#{Rails.env}"]
      content = bucket.objects[payload.filepath].read
      csv_data = Iconv.iconv('utf-8', 'ISO_8859-1', content).to_s
	  end

	end #end of the importer module
end #end of the users module