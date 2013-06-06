class CreateUserLabels < ActiveRecord::Migration
  def change
    create_table :user_labels do |t|
      t.references :user
      t.references :label

      t.timestamps
    end
  end
end
