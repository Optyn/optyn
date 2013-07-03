require "#{File.dirname(__FILE__)}/seed_data/admins.rb"
require "#{File.dirname(__FILE__)}/seed_data/business.rb"
#require "#{File.dirname(__FILE__)}/seed_data/plans.rb"
require "#{File.dirname(__FILE__)}/seed_data/states.rb"
require "#{File.dirname(__FILE__)}/seed_data/permissions.rb"
require "#{File.dirname(__FILE__)}/seed_data/message_folders.rb"


#Add some dummy data in the development mode.
if Rails.env.development?
  dev_data = "#{File.dirname(__FILE__)}/seed_data/dummy_data/dev_seed.rb"
  eval(IO.read(dev_data), binding, dev_data)
end