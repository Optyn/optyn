class CreateShopCredits < ActiveRecord::Migration
  def change
    create_table :shop_credits do |t|
      t.references :shop
      t.integer :remaining_count
      t.datetime :begins
      t.datetime :ends

      t.timestamps
    end

    add_index(:shop_credits, [:shop_id, :begins, :ends], unique: true)
  end
end
