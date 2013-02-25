class Plan < ActiveRecord::Base
  attr_accessible :amount, :currency, :interval, :name, :plan_id
end
