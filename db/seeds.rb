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

# Add the stripe plans
Plan.create(plan_id: 'pro', interval: 'month', name: 'Pro', amount: 10000, currency: 'usd')
Plan.create(plan_id: 'advanced', interval: 'month', name: 'Advanced', amount: 5000, currency: 'usd')
Plan.create(plan_id: 'standard', interval: 'month', name: 'Standard', amount: 2500, currency: 'usd')
Plan.create(plan_id: 'starter', interval: 'month', name: 'Starter', amount: 1000, currency: 'usd')
Plan.create(plan_id: 'lite', interval: 'month', name: 'Lite', amount: 500, currency: 'usd')

#Add the states
State.create(:name => "Alabama", :abbreviation => "AL")
State.create(:name => "Alaska", :abbreviation => "AK")
State.create(:name => "Arizona", :abbreviation => "AZ")
State.create(:name => "Arkansas", :abbreviation => "AR")
State.create(:name => "California", :abbreviation => "CA")
State.create(:name => "Colorado", :abbreviation => "CO")
State.create(:name => "Connecticut", :abbreviation => "CT")
State.create(:name => "Delaware", :abbreviation => "DE")
State.create(:name => "District of Columbia", :abbreviation => "DC")
State.create(:name => "Florida", :abbreviation => "FL")
State.create(:name => "Georgia", :abbreviation => "GA")
State.create(:name => "Hawaii", :abbreviation => "HI")
State.create(:name => "Idaho", :abbreviation => "ID")
State.create(:name => "Illinois", :abbreviation => "IL")
State.create(:name => "Indiana", :abbreviation => "IN")
State.create(:name => "Iowa", :abbreviation => "IA")
State.create(:name => "Kansas", :abbreviation => "KS")
State.create(:name => "Kentucky", :abbreviation => "KY")
State.create(:name => "Louisiana", :abbreviation => "LA")
State.create(:name => "Maine", :abbreviation => "ME")
State.create(:name => "Maryland", :abbreviation => "MD")
State.create(:name => "Massachusetts", :abbreviation => "MA")
State.create(:name => "Michigan", :abbreviation => "MI")
State.create(:name => "Minnesota", :abbreviation => "MN")
State.create(:name => "Mississippi", :abbreviation => "MS")
State.create(:name => "Missouri", :abbreviation => "MO")
State.create(:name => "Montana", :abbreviation => "MT")
State.create(:name => "Nebraska", :abbreviation => "NE")
State.create(:name => "Nevada", :abbreviation => "NV")
State.create(:name => "New Hampshire", :abbreviation => "NH")
State.create(:name => "New Jersey", :abbreviation => "NJ")
State.create(:name => "New Mexico", :abbreviation => "NM")
State.create(:name => "New York", :abbreviation => "NY")
State.create(:name => "North Carolina", :abbreviation => "NC")
State.create(:name => "North Dakota", :abbreviation => "ND")
State.create(:name => "Ohio", :abbreviation => "OH")
State.create(:name => "Oklahoma", :abbreviation => "OK")
State.create(:name => "Oregon", :abbreviation => "OR")
State.create(:name => "Pennsylvania", :abbreviation => "PA")
State.create(:name => "Hode Island", :abbreviation => "RI")
State.create(:name => "South Carolina", :abbreviation => "SC")
State.create(:name => "South Dakota", :abbreviation => "SD")
State.create(:name => "Tennessee", :abbreviation => "TN")
State.create(:name => "Texas", :abbreviation => "TX")
State.create(:name => "Utah", :abbreviation => "UT")
State.create(:name => "Vermont", :abbreviation => "VT")
State.create(:name => "Virginia", :abbreviation => "VA")
State.create(:name => "Washington", :abbreviation => "WA")
State.create(:name => "West Virginia", :abbreviation => "WV")
State.create(:name => "Wisconsin", :abbreviation => "WI")
State.create(:name => "Wyoming", :abbreviation => "WY")

#Add business
Business.create(:name => "Animation")
Business.create(:name => "Apparel & Fashion")
Business.create(:name => "Arts & Crafts")
Business.create(:name => "Books")
Business.create(:name => "Bank & Financial services")
Business.create(:name => "Consumer Electronics")
Business.create(:name => "Cars & Motorcycles")
Business.create(:name => "Education")
Business.create(:name => "Entertainment")
Business.create(:name => "Event Planning/Event Services")
Business.create(:name => "Food & Drink")
Business.create(:name => "Internet/Software")
Business.create(:name => "Hair & Beauty")
Business.create(:name => "Health & Fitness")
Business.create(:name => "Home Decor")
Business.create(:name => "Motion Pictures and Film")
Business.create(:name => "Music")
Business.create(:name => "Nonprofit Organization Management")
Business.create(:name => "Outdoor gear/Sporting Goods")
Business.create(:name => "Photography")
Business.create(:name => "Real Estate")
Business.create(:name => "Social Media")
Business.create(:name => "Technology")
Business.create(:name => "Travel & Tourism")
Business.create(:name => "Transportation")

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