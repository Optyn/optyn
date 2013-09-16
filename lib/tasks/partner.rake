namespace :partner do
  desc "Add the Optyn Partner Id if not present and then assign the shops partner ids where missing"
  task :create_optyn => :environment do
    partner = Partner.for_organization('Optyn Inc.') || Partner.new(first_name: "Gaurav", last_name: "Gaglani",
                                                                       phone: "3127722109",
                                                                       password: "9p5yn123",
                                                                       password_confirmation: "9p5yn123",
                                                                       email: "gaurav@optyn.com",
                                                                       organization: "Optyn Inc.",
                                                                       redirect_uri: "https://www.optyn.com/robots.txt")
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
                                                                       redirect_uri: "http://localhost:3001/partners/auth/optyn/callback")
    partner.save!
  end
end