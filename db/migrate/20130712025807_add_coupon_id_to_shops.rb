class AddCouponIdToShops < ActiveRecord::Migration
  def change
    add_column(:shops, :coupon_id, :integer)
    add_column(:shops, :discount_end_at, :datetime)
  end
end
