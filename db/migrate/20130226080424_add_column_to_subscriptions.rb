class AddColumnToSubscriptions < ActiveRecord::Migration
  def up
    add_column :subscriptions, :stripe_customer_token, :string
  end

  def down
    remove_column :subscriptions, :stripe_customer_token
  end
end
