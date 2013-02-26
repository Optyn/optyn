class Subscription < ActiveRecord::Base

  attr_accessible :email, :plan_id

  belongs_to :plan

end
