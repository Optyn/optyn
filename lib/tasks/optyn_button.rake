namespace :button do
  desc "Make the call_to_action attribute of all Shops' OAuth Application as email"
  task :make_call_to_action_email => :environment do
    Shop.real.collect(&:oauth_application).uniq.compact.each do |app|
      puts "Updating OAuth Application Call to Action for the Shop: #{app.owner.name}"
      app.call_to_action = 3
      app.save
    end
  end
end