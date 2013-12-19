class AddDescriptionToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :description, :string
  end
end
