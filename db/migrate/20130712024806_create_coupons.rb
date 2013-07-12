class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :stripe_id
      t.decimal :percent_off
      t.decimal :amount_off
      t.string :currency
      t.boolean :livemode
      t.string :duration
      t.string :redeem_by
      t.string :max_redemptions
      t.string :times_redeemed
      t.string :duration_in_months

      t.timestamps
    end

    add_index(:coupons, :stripe_id, :unique => true)
  end
end
