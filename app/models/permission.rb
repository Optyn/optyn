class Permission < ActiveRecord::Base
	has_many :permissions_users, dependent: :destroy
  has_many :users, :through => :permissions_users
  attr_accessible :permission_name

  NAME = "name"
  EMAIL = "email" 

  scope :lookup_name, ->(perm_name){ where(["permissions.permission_name ILIKE :perm_name", {perm_name: perm_name}]) }

  def self.fullname
    lookup_name(NAME).first
  end

  def self.email
    lookup_name(NAME).first
  end
    
  def self.fullname_id()
  	Permission.lookup_name(NAME).first.id
  end

  def self.email_id()
  	Permission.lookup_name(EMAIL).first.id	
  end

  def self.cached_count
    @@PERMISSIONS ||= Permission.count
  end

end