class PermissionsUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :permission

  attr_accessible :action, :permission_id
end
