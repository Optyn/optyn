class Plan < ActiveRecord::Base

  attr_accessible :amount, :currency, :interval, :name, :plan_id
  
  has_many :subscriptions,dependent: :destroy

  SUBSCRIPTION_PLANS = YAML.load(File.read(File.expand_path('../../../config/subscription_plans.yml', __FILE__)))

 def self.which(shop)
 		current_plan = shop.subscription.plan
  	connection_count = shop.active_connections.connection_count
 		evaluated_plan = Plan.find(get_plan_from_subscriptions(connection_count))
 		return evaluated_plan.amount < current_plan.amount ? current_plan : evaluated_plan
 end

 def self.free_connections_limit
 	 100
 end

 def self.subscription_plans
 	 SUBSCRIPTION_PLANS
 end

 def get_plan_from_subscriptions(count)
 	  plan = nil
 		SUBSCRIPTION_PLANS.each do |key, value|
 			plan = key if (value['min'] <= count and count <= value['max'])
 		end
 end

end
