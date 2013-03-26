class UserLabel < ActiveRecord::Base
  belongs_to :user
  belongs_to :label

  attr_accessible :user_id, :label_id
end
