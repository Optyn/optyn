class Coupon < ActiveRecord::Base
  has_one :shop

  validates :stripe_id, uniqueness: true, presence: true

  attr_accessible :stripe_id, :percent_off, :amount_off, :currency, :livemode, :duration, :redeem_by, :max_redemptions,
                  :times_redeemed, :duration_in_months

  def self.from_attrs(event)
    stripe_coupon = event['data']['object']['coupon'] 
    coupon = Coupon.find_by_stripe_id(stripe_coupon['id']) || Coupon.new
    coupon.stripe_id = stripe_coupon['id']
    coupon.percent_off = stripe_coupon['percent_off']
    coupon.amount_off = stripe_coupon['amount_off']
    coupon.currency = stripe_coupon['currency']
    coupon.livemode = stripe_coupon['livemode']
    coupon.duration = stripe_coupon['duration']
    coupon.redeem_by  = stripe_coupon['redeem_by']
    coupon.max_redemptions = stripe_coupon['max_redemptions']
    coupon.times_redeemed = stripe_coupon['times_redeemed']
    coupon.duration_in_months = stripe_coupon['duration_in_months']
    coupon
  end

  def free_forever?
    100 == self.percent_off.to_i
  end
end
