class CreateCouponMessageExtensions < ActiveRecord::Migration
  def change
  	create_table :coupon_message_extensions do |t|
  	  t.integer :message_id
  	  t.text    :redemption_instructions
  	end

  	add_index :coupon_message_extensions, :message_id
  end
end
