class Permission < ActiveRecord::Base
	has_many :permissions_users
  has_many :users, :through => :permissions_users
  attr_accessible :name

  NAME = "name"
  EMAIL = "email" 

  #scope :for_name, ->(name){where(["permissions.name LIKE ?", name])}

  #def self.name_id()
  	#for_name(NAME).first.name
  #end

  #def self.email_id()
  	#for_name(EMAIL).first.id	
  #end
end