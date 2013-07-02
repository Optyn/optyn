class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
    	t. integer :subscription_id
    	t.string :stripe_customer_token
    	t.string :stripe_invoice_id
    	t.boolean :paid_status
    	t.integer :amount
      t.timestamps
    end
  end
end
