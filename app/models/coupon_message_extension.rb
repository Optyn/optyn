class CouponMessageExtension < ActiveRecord::Base
  belongs_to :message, :class_name => 'CouponMessage'
end