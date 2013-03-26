class CreateLabels < ActiveRecord::Migration
  def change
    create_table :labels do |t|
      t.references :shop
      t.string :name

      t.timestamps
    end

    add_index(:labels, :shop_id)
    add_index(:labels, [:shop_id, :name], unique: true)
  end
end
