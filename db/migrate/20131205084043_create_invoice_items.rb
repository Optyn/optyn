class CreateInvoiceItems < ActiveRecord::Migration
  def change
    create_table :invoice_items do |t|
      t.string :stripe_invoice_item_token
      t.integer :amount
      t.string :livemode
      t.string :proration
      t.string :stripe_customer_token
      t.string :description
      t.string :stripe_invoice_token

      t.timestamps
    end
  end
end
