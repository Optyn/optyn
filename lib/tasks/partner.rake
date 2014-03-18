namespace :partner do
  desc "Add the Optyn Partner Id if not present and then assign the shops partner ids where missing"
  task :create_optyn => :environment do
    load "#{Rails.root}/app/models/partner.rb"
    partner = Partner.for_organization('Optyn Inc.') || Partner.new(first_name: "Gaurav", last_name: "Gaglani",
                                                                       phone: "3127722109",
                                                                       password: "9p5yn123",
                                                                       password_confirmation: "9p5yn123",
                                                                       email: "gaurav@optyn.com",
                                                                       organization: "Optyn Inc.",
                                                                       redirect_uri: SiteConfig.robots_redirect_uri, 
                                                                       header_background_color: "#1791C0",
                                                                       footer_background_color: "#ffffff",
                                                                       subscription_required: true)
    partner.save!
    partnerless_shops = Shop.where(partner_id: nil)
    partnerless_shops.each do |shop|
      shop.partner_id = partner.id
      shop.save(validate: false)
      puts "Assigned Partner Optyn Inc. to Shop: #{shop.name}"
    end
  end

  desc "Add the Partner: Optyn Partners if not present and then assign the client_id and client_secret"
  task :create_optyn_partner => :environment do
    load "#{Rails.root}/app/models/partner.rb"
    partner = Partner.for_organization('Optyn Partners') || Partner.new(first_name: "Gaurav", last_name: "Gaglani",
                                                                       phone: "3127722109",
                                                                       password: "9p5yn123",
                                                                       password_confirmation: "9p5yn123",
                                                                       email: "gaurav+1@optyn.com",
                                                                       organization: "Optyn Partners",
                                                                       redirect_uri: SiteConfig.optyn_partner_redirect_uri,
                                                                       subscription_required: false, 
                                                                       header_background_color: "#1791C0",
                                                                       footer_background_color: "#ffffff")
    partner.save!
  end

  desc "Add the Partner: Eatstreet Inc. if not present and then assign the client_id and client_secret"
  task :create_eatstreet_partner => :environment do
    load "#{Rails.root}/app/models/partner.rb"
    #TODO PUT IN THE REAL EATSTREET VALUES.
    puts "Adding the Eatstreet partner"
    partner = Partner.for_organization('Eatstreet Inc.') || Partner.new(first_name: "Eric", last_name: "Martell",
                                                                       phone: "8666548777",
                                                                       password: "3atst4eet",
                                                                       password_confirmation: "3atst4eet",
                                                                       email: "office@eatstreet.com",
                                                                       organization: "Eatstreet Inc.",
                                                                       redirect_uri: SiteConfig.robots_redirect_uri,
                                                                       subscription_required: false,
                                                                       header_background_color: "#6dba3d",
                                                                       footer_background_color: "#393939")
    partner.save!
  end

  desc "Add the Partner: Eatstreet Inc. if not present and then assign the client_id and client_secret"
  task :create_your_best_deals => :environment do
    load "#{Rails.root}/app/models/partner.rb"
    #TODO PUT IN THE REAL Your Best Deals Values.
    puts "Adding the Your Best Deals partner"
     partner = Partner.for_organization('Your Best Deals Inc.') || Partner.new(first_name: "Gaurav", last_name: "Gaglani",
                                                                       phone: "3127722109",
                                                                       password: "9p5yn123",
                                                                       password_confirmation: "9p5yn123",
                                                                       email: "gaurav+2@optyn.com",
                                                                       organization: "Your Best Deals Inc.",
                                                                       redirect_uri: SiteConfig.optyn_partner_redirect_uri,
                                                                       subscription_required: true, 
                                                                       header_background_color: "#1791C0",
                                                                       footer_background_color: "#ffffff")
    partner.save!
  end

  desc "Add the Partner: Eatstreet Inc. and a dummy shop with a manager"
  task :eatstreet_with_dummy_shop do
    load "#{Rails.root}/app/models/partner.rb"
    puts "Adding the Eatstreet dummy shop"
    partner = Partner.find_by_organization("Eatstreet Inc.")
    partner.shops.create(name: 'Optyn Eatstreet Test', stype: 'online', phone_number: '+3125233844', managers_attributes: {'0' => {name: "Gaurav Gaglani", email: 'eatstreet+test@optyn.com', password: 'eatstreet', password_confirmation: 'eatstreet'}})
  end

  task :eatstreet_with_multiple_dummy_shops => :environment do
    load "#{Rails.root}/app/models/partner.rb"
    if Rails.env.downcase == 'staging'
      puts "Adding the Eatstreet dummy shops only in #{Rails.env} env"
      partner = Partner.find_by_organization("Eatstreet Inc.")
      (1..5).each do |a|
        partner.shops.create(name: "Optyn Eatstreet Test #{a}", stype: 'online', phone_number: "+312523373#{a}", managers_attributes: {'0' => {name: "Gaurav Gaglani #{a}", email: "eatstreet+test#{a}@optyn.com", password: 'test1234', password_confirmation: 'test1234'}})
      end
    end
  end

  desc "Add the 'seed' from email addresses for each partner"
  task :seed_verified_emails do
    load "#{Rails.root}/app/models/partner.rb"
    #Adding verified email for the Optyn partner
    partner = Partner.for_organization('Optyn Inc.')
    partner.from_email = 'email@optyn.com'
    partner.save

    #Adding verified email for the Optyn 1 partner
    partner = Partner.for_organization('Optyn Partners')
    partner.from_email = 'email@optyn.com'
    partner.save

    #Adding verified email for the Eatstreet partner
    partner = Partner.for_organization('Eatstreet Inc.')
    partner.from_email = 'specials@eatstreet.com'    
    partner.save
  end

  desc "Run all the tasks serially"
  task :seed => [:create_optyn, :create_optyn_partner, :create_your_best_deals, :create_eatstreet_partner, :eatstreet_with_dummy_shop, :seed_verified_emails]
end
