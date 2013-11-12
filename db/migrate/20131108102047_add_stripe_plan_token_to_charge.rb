class AddStripePlanTokenToCharge < ActiveRecord::Migration
  def change
    add_column :charges, :stripe_plan_token, :string
  end
end
