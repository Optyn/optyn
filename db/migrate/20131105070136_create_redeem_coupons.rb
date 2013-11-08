class CreateRedeemCoupons < ActiveRecord::Migration
  def change
  	create_table :redeem_coupons do |t|
      t.references :message, index: true
      t.references :user, index: true
      t.timestamps
  	end
  end
end
