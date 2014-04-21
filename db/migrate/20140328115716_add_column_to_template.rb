class AddColumnToTemplate < ActiveRecord::Migration
  def change
  	add_column :templates, :title, :string
  	add_column :templates, :logo, :string
  	remove_column :messages, :title
  	remove_column :messages, :logo
  end
end
