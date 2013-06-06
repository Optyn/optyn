class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.string :plan_id
      t.string :currency
      t.integer :amount
      t.string :interval

      t.timestamps
    end
  end
end
