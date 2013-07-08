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
end
