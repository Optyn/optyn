class AddSubtotalToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :subtotal, :integer
    add_column :invoices, :total, :integer
    #add_column :invoices, :stripe_coupon_token, :string
  end
end
