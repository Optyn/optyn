class AddColumnToLocations < ActiveRecord::Migration
  def up
    add_column :locations, :zip ,:string
  end

  def down
  end
end
