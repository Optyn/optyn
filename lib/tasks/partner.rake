namespace :partner do
  desc "Add the Optyn Partner Id if not present and then assign the shops partner ids where missing"
  task :create_optyn => :environment do
    partner = Partner.find_by_organization('Optyn Inc.') || Partner.new(first_name: "Gaurav", last_name: "Gaglani",
                                                                       phone: "3125233844",
                                                                       password: "9p5yn123",
                                                                       password_confirmation: "9p5yn123",
                                                                       email: "gaurav@partner.com",
                                                                       organization: "Optyn Inc.",
                                                                       redirect_uri: "http://www.optyn.com/robots.txt")
    partner.save!
    partnerless_shops = Shop.where(partner_id: nil)
    partnerless_shops.each do |shop|
      shop.partner_id = partner.id
      shop.save(validate: false)
      puts "Assigned Partner Optyn Inc. to Shop: #{shop.name}"
    end
  end
end