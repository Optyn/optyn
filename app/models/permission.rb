class Permission < ActiveRecord::Base
	has_many :permissions_users, dependent: :destroy
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

  def self.cached_count
    @@PERMISSIONS ||= Permission.count
  end

  class << self
    class_eval do
      if Permission.table_exists?
        permissions = Permission.all()
        permissions.each do |permission|
          define_method(permission.name.underscore.to_sym) do
            eval("@@#{permission.name.upcase} ||= permission")
          end

          define_method("#{permission.name.underscore}_id".to_sym) do
            permission.id
          end

        end
      end
    end
  end #end of self block
end