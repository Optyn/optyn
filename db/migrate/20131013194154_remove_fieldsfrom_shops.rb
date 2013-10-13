class RemoveFieldsfromShops < ActiveRecord::Migration
  def up
  	remove_column :shops, :uploaded_directly
  	remove_column :shops, :pre_added
  end

  def down
  	add_column :shops, :uploaded_directly, :string
  	add_column :shops, :pre_added, :string
  end
end
