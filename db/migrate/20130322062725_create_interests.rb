class CreateInterests < ActiveRecord::Migration
  def change
    create_table :interests do |t|
      t.integer :holder_id
      t.string :holder_type
      t.integer :business_id

      t.timestamps
    end
  end
end
