class RemoveStateTable < ActiveRecord::Migration
  def up
    drop_table :states
  end

end
