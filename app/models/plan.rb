class Plan < ActiveRecord::Base

  attr_accessible :amount, :currency, :interval, :name, :plan_id
  
  has_many :subscriptions

end
