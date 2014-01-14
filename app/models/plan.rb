class Plan < ActiveRecord::Base

  attr_accessible :amount, :currency, :interval, :name, :plan_id, :min, :max

  has_many :subscriptions, dependent: :destroy
  after_save :inform_admins

  class << self
    class_eval do
      if Plan.table_exists?
        starter_plan = Plan.where("plans.name ILIKE 'starter'").first
        define_method(:starter) do
          eval("@@STARTER ||= starter_plan")
        end
      end
    end
  end

  def self.which(shop)
    current_plan = shop.subscription.plan
    current_plan.amount
    connection_count = shop.active_connection_count
    ##optmize this
    evaluated_plan = Plan.where(" (min <= ?) and (? <= max) ", connection_count, connection_count).first
    return evaluated_plan
  rescue Exception => e
    Rails.logger.error e
    current_plan
  end


  def inform_admins
    StripeMailer.plan_change_notification(self).deliver
  end


end
