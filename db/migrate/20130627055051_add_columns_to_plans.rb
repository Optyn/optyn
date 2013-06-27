class AddColumnsToPlans < ActiveRecord::Migration
  def change
  	add_column :plans, :min, :integer
  	add_column :plans, :max, :integer
  end
end
