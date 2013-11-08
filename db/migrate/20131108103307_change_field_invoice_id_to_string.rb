class ChangeFieldInvoiceIdTostring < ActiveRecord::Migration
  def up
  	remove_column :charges, :invoice_id
    add_column :charges, :stripe_invoice_token, :string
  end

  def down
  end
end
