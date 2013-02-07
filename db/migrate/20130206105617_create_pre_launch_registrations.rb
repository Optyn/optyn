class CreatePreLaunchRegistrations < ActiveRecord::Migration
  def change
    create_table :pre_launch_registrations do |t|
      t.string :email

      t.timestamps
    end
  end
end
