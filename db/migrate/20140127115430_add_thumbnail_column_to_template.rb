class AddThumbnailColumnToTemplate < ActiveRecord::Migration
  def change
    add_column :templates, :thumbnail, :string
  end
end
