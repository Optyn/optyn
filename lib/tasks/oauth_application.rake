#Tasks for generating applications etc.
namespace :oauth2 do
  desc "Generate a Merchant Application and corresponding application."
  task :generate_optyn_magic_application => :environment do
    optyn_magic = MerchantApp.find_by_name('Optyn Magic') || MerchantApp.new(name: 'Optyn Magic')
    optyn_magic.redirect_uri = "#{SiteConfig.app_base_url}/robots.txt"
    if optyn_magic.new_record?
      optyn_magic.save
    else
      optyn_magic.generate_application(true)
    end

    puts "Successfully generate client id and client secret for the Merchat App: #{optyn_magic.name}. Please check the database for further details."
  end
end