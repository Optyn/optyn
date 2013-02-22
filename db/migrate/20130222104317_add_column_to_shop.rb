class AddColumnToShop < ActiveRecord::Migration
  def up
    add_column :shops,:stype,:string
  end
end
