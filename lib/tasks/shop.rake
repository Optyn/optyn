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
end
