puts "Adding the Optyn Partner"
Rake::Task['partner:create_optyn'].invoke

puts "Adding Optyn Partners App as the partner" 
Rake::Task['partner:create_optyn_partner'].invoke