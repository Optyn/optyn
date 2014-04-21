class AddColumnToMessage < ActiveRecord::Migration
  def change
  	add_column :messages, :title, :string
  	add_column :messages, :logo, :string
  end
end
