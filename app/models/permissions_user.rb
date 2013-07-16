class PermissionsUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :permission

  attr_accessible :action, :permission_id, :user_id

  scope :for_permission, ->(permission_identifier) { where(permission_id: permission_identifier) }

  scope :visible, where(action: true)

  def self.permission_visible?(permission_identifier)
  	for_permission(permission_identifier).visible.present?
  end
end
