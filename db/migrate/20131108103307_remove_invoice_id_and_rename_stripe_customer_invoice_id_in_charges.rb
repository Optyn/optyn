class RemoveInvoiceIdAndRenameStripeCustomerInvoiceIdInCharges < ActiveRecord::Migration
  def up
    remove_column :charges, :stripe_invoice_id
    remove_column :charges, :invoice_id
    add_column :charges, :stripe_invoice_token, :string
  end

  def down
    add_column :charges, :stripe_invoice_id, :string
    add_column :charges, :invoice_id, :integer
    remove_column :charges, :stripe_invoice_token
  end
end
