class AddMakePublicToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :make_public, :Boolean
  end
end
