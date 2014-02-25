class ShopCredit < ActiveRecord::Base
  attr_accessible :shop_id, :remaining_count, :begins, :ends

  belongs_to :shop

  scope :currently_active, ->(begin_stamp, end_stamp) {
    where(['shop_credits.begins <= :begin_stamp AND shop_credits.ends >= :end_stamp', {begin_stamp: begin_stamp, end_stamp: end_stamp}])
  }

  EATSTREET_MAX_CREDITS_COUNT = 4

  def self.fetch_credit(begin_stamp, end_stamp)
    currently_active(begin_stamp, end_stamp).first
  end

  def decrement
    self.remaining_count -= 1
    self.save
  end
end