class AddStripePlanIdToCharge < ActiveRecord::Migration
  def change
    add_column :charges, :stripe_plan_id, :string
  end
end
