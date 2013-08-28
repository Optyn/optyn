puts "Generating client_id and client_secret for Optyn Magic Owner"
Rake::Task['oauth2:generate_optyn_magic_application'].invoke
puts "Adding Virtual Chrome Extension Shop"
Rake::Task['shop:add_browser_extensions'].invoke
puts "Adding the shop for Optyn Magic"
Rake::Task['shop:add_optyn_magic_shop'].invoke