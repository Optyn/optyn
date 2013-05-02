class AddPictureToManager < ActiveRecord::Migration
  def change
    add_column :managers, :picture, :string
  end
end
