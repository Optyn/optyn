class RemoveFieldsfromShops < ActiveRecord::Migration
  def up
  	remove_column :shop, :uploaded_directly
  	remove_column :shop, :pre_added
  end

  def down
  	add_column :shop, :uploaded_directly, :string
  	add_column :shop, :pre_added, :string
  end
end
