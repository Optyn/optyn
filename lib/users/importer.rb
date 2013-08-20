module Users		
	module Importer
		def import(content, manager, label)
	    shop = manager.shop

	    csv_table = CSV.parse(content, { headers: true, converters: :numeric, header_converters: :symbol })
	  	headers = csv_table.headers

	    headers = csv_table.headers
	    validate_headers(headers)

	    counters = ActiveSupport::OrderedHash.new()
	    counters[:user_creation] = 0
	    counters[:existing_user] = 0
	    counters[:connection_creation] = 0
	    counters[:existing_connection]  = 0
	    counters[:unparsed_rows] = 0

	    csv_table.each do |row|

	      user = User.find_by_email(row[:email]) || User.new(email: row[:email])
	      user.skip_name = true
	      user.name = row[:name] unless user.name.present?
	      gender = if (gender_val = row[:gender].to_s.downcase).length == 1
	                 gender_val
	               else
	                  gender_val == "male" ? "m" : (gender_val == "female" ? "f" : nil)
	               end
	      user.gender = gender
	      user.birth_date = (Date.parse(row[:birth_date]) rescue nil)
	      user.valid?

	      (counters[:unparsed_rows] += 1) and (add_unparsed_row(row)) and next if user.errors.include?(:email) || user.errors.include?(:name)

	      if user.new_record?
	        passwd = Devise.friendly_token.first(8)
	        user.password = passwd
	        user.password_confirmation = passwd
	        user.show_password = true
	        user.show_shop = true
	        user.shop_identifier = shop.id
	        counters[:user_creation] += 1
	      else
	        counters[:existing_user] += 1
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
	    end
	    
	    counters
		end

    def validate_headers(headers)
    	raise "Incorrect Headers. The file should have headers of 'Name' and 'Email'" if !headers.include?(:name) || !headers.include?(:email)
  	end

	  def add_unparsed_row(row)
	    puts "Adding an unparsed row"
	    unparsed_file_path = create_unparsed_rows_file_if
	    File.open(unparsed_file_path, "a") do |file|
	      file << (row.to_s + "\n")
	    end
	  end

	  def download_file_from_payload(payload)
      s3 = AWS::S3.new(
        :access_key_id => SiteConfig.aws_access_key_id,
        :secret_access_key => SiteConfig.aws_secret_access_key)
      bucket = s3.buckets["partner#{Rails.env}"]
      content = bucket.objects[payload.filepath].read
	  end

	end #end of the importer module
end #end of the users module