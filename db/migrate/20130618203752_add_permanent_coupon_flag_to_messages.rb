class AddPermanentCouponFlagToMessages < ActiveRecord::Migration
  def change
    add_column(:messages, :permanent_coupon, :boolean)
  end
end
