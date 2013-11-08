class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.string :stripe_charge_id, index: true
      t.integer :created, index: true
      t.boolean :livemode
      t.integer :fee_amount
      t.string :stripe_invoice_id
      t.text :description
      t.string :dispute
      t.boolean :refunded
      t.boolean :paid
      t.integer :amount
      t.integer :card_last4
      t.integer :amount_refunded
      t.string :stripe_customer_token
      t.text :fee_description
      t.references :invoice

      t.timestamps
    end
  end
end
