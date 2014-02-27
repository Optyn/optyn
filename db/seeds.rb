require "#{File.dirname(__FILE__)}/seed_data/admins.rb"
require "#{File.dirname(__FILE__)}/seed_data/business.rb"
require "#{File.dirname(__FILE__)}/seed_data/plans.rb"
require "#{File.dirname(__FILE__)}/seed_data/permissions.rb"
require "#{File.dirname(__FILE__)}/seed_data/message_folders.rb"
require "#{File.dirname(__FILE__)}/seed_data/message_visual_sections.rb"
require "#{File.dirname(__FILE__)}/seed_data/partners.rb"
require "#{File.dirname(__FILE__)}/seed_data/oauths.rb"
require "#{File.dirname(__FILE__)}/seed_data/templates.rb"

#Add some dummy data in the development mode.
#if Rails.env.development?
 # dev_data = "#{File.dirname(__FILE__)}/seed_data/dummy_data/dev_seed.rb"
  #eval(IO.read(dev_data), binding, dev_data)
#end
