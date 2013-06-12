class ChangeDescriptionDataTypeForShops < ActiveRecord::Migration
  def up
    change_column :shops, :description, :text
  end

  def down
    change_column :shops, :description, :string
  end
end
