class RemoveUniqueNameIndexFromShops < ActiveRecord::Migration
  def up
    remove_index(:shops, :name) #remove the unique index
    add_index(:shops, :name) # add the normal index
  end

  def down
    remove_index(:shops, :name) # remove the normal index
    add_index(:shops, :name, unique: true) # add the unique index
  end
end
