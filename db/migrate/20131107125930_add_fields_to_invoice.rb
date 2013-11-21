class AddFieldsToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :stripe_coupon_token, :string
    add_column :invoices, :stripe_plan_token, :string
  end
end
