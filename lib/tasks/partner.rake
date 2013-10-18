namespace :partner do
  desc "Add the Optyn Partner Id if not present and then assign the shops partner ids where missing"
  task :create_optyn => :environment do
    partner = Partner.for_organization('Optyn Inc.') || Partner.new(first_name: "Gaurav", last_name: "Gaglani",
                                                                       phone: "3127722109",
                                                                       password: "9p5yn123",
                                                                       password_confirmation: "9p5yn123",
                                                                       email: "gaurav@optyn.com",
                                                                       organization: "Optyn Inc.",
                                                                       redirect_uri: "https://www.optyn.com/robots.txt", 
                                                                       header_background_color: "#1791C0",
                                                                       footer_background_color: "#ffffff")
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
    partner = Partner.for_organization('Optyn Partners') || Partner.new(first_name: "Gaurav", last_name: "Gaglani",
                                                                       phone: "3127722109",
                                                                       password: "9p5yn123",
                                                                       password_confirmation: "9p5yn123",
                                                                       email: "gaurav+1@optyn.com",
                                                                       organization: "Optyn Partners",
                                                                       redirect_uri: "http://localhost:3001/partners/auth/optyn/callback",
                                                                       subscription_required: false, 
                                                                       header_background_color: "#1791C0",
                                                                       footer_background_color: "#ffffff")
    partner.save!
  end

  desc "Add the Partner: Eatstreet Inc. if not present and then assign the client_id and client_secret"
  task :create_eatstreet_partner => :environment do
    #TODO PUT IN THE REAL EATSTREET VALUES.
    puts "Adding the Eatstreet partner"
    partner = Partner.for_organization('Eatstreet Inc.') || Partner.new(first_name: "Gaurav", last_name: "Gaglani",
                                                                       phone: "3127722109",
                                                                       password: "9p5yn123",
                                                                       password_confirmation: "9p5yn123",
                                                                       email: "gaurav+2@optyn.com",
                                                                       organization: "Eatstreet Inc.",
                                                                       redirect_uri: "http://localhost:3002/partners/auth/optyn/callback",
                                                                       subscription_required: false,
                                                                       header_background_color: "#6dba3d",
                                                                       footer_background_color: "#393939")
    partner.save!
  end

  desc "Add the Partner: Eatstreet Inc. and a dummy shop with a manager"
  task :eatstreet_with_dummy_shop do
    puts "Adding the Eatstreet dummy shop"
    partner = Partner.find_by_organization("Eatstreet Inc.")
    partner.shops.create(name: 'Optyn Eatstreet Test', stype: 'online', phone_number: '+3125233844', managers_attributes: {'0' => {name: "Gaurav Gaglani", email: 'eatstreet+test@optyn.com', password: 'test1234', password_confirmation: 'test1234'}})
  end

  task :eatstreet_with_multiple_dummy_shops => :environment do
    if Rails.env.downcase == 'staging'
      puts "Adding the Eatstreet dummy shops only in #{Rails.env} env"
      partner = Partner.find_by_organization("Eatstreet Inc.")
      (1..5).each do |a|
        partner.shops.create(name: "Optyn Eatstreet Test #{a}", stype: 'online', phone_number: "+312523373#{a}", managers_attributes: {'0' => {name: "Gaurav Gaglani #{a}", email: "eatstreet+test#{a}@optyn.com", password: 'test1234', password_confirmation: 'test1234'}})
      end
    end
  end

  desc "Run all the tasks serially"
  task :seed => [:create_optyn, :create_optyn_partner, :create_eatstreet_partner, :eatstreet_with_dummy_shop]
end
