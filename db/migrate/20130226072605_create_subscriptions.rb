class CreateSubscriptions < ActiveRecord::Migration
  def up
    create_table :subscriptions do |t|
      t.string :email
      t.integer :plan_id

      t.timestamps
    end
  end

  def down
    drop_table :subscriptions
  end
  
end
