class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.integer :created
      t.string :live_mode
      t.integer :fee_amount
      t.string :invoice
      t.string :description
      t.string :dispute
      t.string :refunded
      t.string :paid
      t.integer :amount
      t.integer :card_last4
      t.integer :amount_refunded
      t.string :customer
      t.string :fee_description
      t.references :invoice

      t.timestamps
    end
  end
end
