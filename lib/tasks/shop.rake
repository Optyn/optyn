namespace :shop do
  desc "Forcefully reset the embedcode for the shops"
  task :reset_embed_code => :environment do
    shops = Shop.all.select { |shop| shop.oauth_application.present? }
    shops.each do |shop|
      options = shop.oauth_application.attributes.except('created_at', 'updated_at', 'embed_code', 'id', 'uid', 'secret', 'name', 'owner_id', 'owner_type')
      puts "Resetting Embed Code for shop: #{shop.name}"
      shop.generate_oauth_token(options.symbolize_keys, true)
    end
  end

  desc "Add Virtual Shops for Browser Extensions"
  task :add_browser_extensions => :environment do
    puts "Adding/Updating Chrome Extension"
    shop = Shop.find_by_name('Chrome Extension') || Shop.new(name: 'Chrome Extension')
    shop.virtual = true
    shop.description = "This shop will be used for Chrome Extension"
    unless shop.oauth_application.present?
      shop.generate_oauth_token({redirect_uri: "#{SiteConfig.app_base_url}/robots.txt"})
    end
    shop.save(validate: false)
  end

  desc "Add Virtual Shop for Optyn Magic shop"
  task :add_optyn_magic_shop => :environment do
    puts "Adding/Updating Optyn Magic shop"
    shop = Shop.find_by_name('Optyn Magic') || Shop.new(name: 'Optyn Magic')
    shop.virtual = true
    shop.description = "This shop will be used for Optyn Magic emails"
    shop.save(validate: false)

    puts "Adding/Updating Optyn Magic Manager"
    manager = Manager.find_by_email("optynmagic@optyn.com") || Manager.new(name: "Optyn Postfix", email: "optynmagic@optyn.com", password: '9p5yn123', password_confirmation: '9p5yn123')
    manager.shop_id = shop.id
    manager.save(validate: false)
    puts manager.inspect    
    manager.owner = true
    manager.save(validate: false)
  end 

  desc "Task to make all the virtual shops online"
  task :make_virtual_ones_online => :environment do 
    Shop.where(virtual: true).each do |shop|
      puts "Updating Shop: #{shop.name}"
      shop.stype = "online"
      shop.save(validate: false)
    end
  end

  desc "Create shops for sales reps going door to door"
  task :pre_add_for_sales => :environment do
    filepath = ENV['filepath']
    if filepath.present?
      csv_table = CSV.table(filepath, {headers: true})
      headers = csv_table.headers
      output = []  
      output_headers = %Q("Shop Name","Shop Phone","Manager Name","Manager Email","Password",Status")
      output << output_headers
      puts "Starting the parser..."
      counter = 1
      csv_table.each do |row|
        puts "Parsing row #{counter}: Shop: #{row[:shop_name]}"
        output_row = []
        output_row << %Q("#{row[:shop_name]}")
        output_row << %Q("#{row[:shop_phone]}")
        output_row << %Q("#{row[:manager_name]}")
        output_row << %Q("#{row[:manager_email]}")
        existing_shop = Shop.where(["LOWER(shops.name) LIKE LOWER(?)", row[:shop_name].to_s])

        unless existing_shop.present?
          begin
            shop = Shop.new()
            shop.name = row[:shop_name] 
            shop.phone_number = row[:shop_phone]
            shop.stype = "local"
            manager = shop.managers.build
            manager.name = row[:manager_name]
            manager.email = row[:manager_email]
            token =  Devise.friendly_token.first(8).downcase
            manager.password = token
            manager.password_confirmation = token
            shop.save!

            output_row << %Q("#{manager.password}")
            output_row << %Q{"New Shop Created"}
          rescue => e
            output_row << %Q("-")
            output_row << %Q("#{e.message}")  
          end
        else
          output_row << %Q("-")
          output_row << %Q("Existing Shop")
        end

        puts "Status for row: #{output_row.last}"
        output << output_row.join(",")
        counter += 1
      end

      output_filepath = "#{Rails.root.to_s}/tmp/#{File.basename(filepath)}.#{Time.now.to_i}"
      File.open(output_filepath, "w+") do |file|
        file.puts(output.join("\n"))
      end
    end
  end
end
