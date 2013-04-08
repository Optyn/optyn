class Permission < ActiveRecord::Base
  belongs_to :user
  attr_accessible :vis_name, :vis_email, :user_id
end
