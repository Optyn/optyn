class AddPercentOffToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :stripe_coupon_percent_off, :integer
    add_column :invoices, :stripe_coupon_amount_off, :integer
  end
end
