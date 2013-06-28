#Admin Users

#super_admin
puts 'Setting up default super_admin'
admin = Admin.create!(
  :email => 'super_admin@optyn.com', 
  :password => "admin_super",
  :password_confirmation => "admin_super",
  :role => "super_admin" 
  )
puts 'New super_admin created: ' << admin.email

#admin
puts 'Setting up default admin'
admin = Admin.create!(
  :email => 'admin@optyn.com', 
  :password => "admin_super",
  :password_confirmation => "admin_super",
  :role => "admin" 
  )
puts 'New admin created: ' << admin.email

require "#{File.dirname(__FILE__)}/seed_data/business.rb"
require "#{File.dirname(__FILE__)}/seed_data/plans.rb"
require "#{File.dirname(__FILE__)}/seed_data/states.rb"




#Add permissions
Permission.create!(:name => "name")
Permission.create!(:name => "email")

#Add Message Folder inbox, deleted etc.
MessageFolder.create(:name => "Inbox")
MessageFolder.create(:name => "Deleted")
MessageFolder.create!(:name => "Saved")
MessageFolder.create!(:name => "Discarded")

#Add some dummy data in the development mode.
if Rails.env.development?
  dev_data = "#{File.dirname(__FILE__)}/dummy_data/dev_seed.rb"
  eval(IO.read(dev_data), binding, dev_data)
end