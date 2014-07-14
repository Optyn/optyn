class AddColumnGreetingToMessages < ActiveRecord::Migration
  def change
  	add_column :messages, :greeting, :string
  end
end
