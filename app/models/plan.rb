class Plan < ActiveRecord::Base

  attr_accessible :amount, :currency, :interval, :name, :plan_id, :min, :max

  has_many :subscriptions, dependent: :destroy
  after_save :inform_admins

  def self.which(shop)
    current_plan = shop.subscription.plan
    current_plan.amount
    connection_count = shop.active_connection_count
    evaluated_plan = Plan.where(" (min <= ?) and (? <= max) ", connection_count, connection_count).first
    return ((evaluated_plan.amount < current_plan.amount) and evaluated_plan == starter) ? current_plan : evaluated_plan
  rescue Exception => e
    Rails.logger.error e
    current_plan
  end

  def self.starter
    Plan.where("plans.name ILIKE 'starter'")
  end


  def inform_admins
    StripeMailer.plan_change_notification(self).deliver
  end


end
