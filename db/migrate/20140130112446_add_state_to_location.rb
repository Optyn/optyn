class AddStateToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :state_name, :string
  end
end
