class AddDeleteFalgToCoupon < ActiveRecord::Migration
  def change
  	add_column(:coupons, :deleted, :boolean, default: false)
  end
end
