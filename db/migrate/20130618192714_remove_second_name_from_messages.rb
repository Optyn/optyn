class RemoveSecondNameFromMessages < ActiveRecord::Migration
  def up
    remove_column(:messages, :second_name)
  end

  def down
    add_column(:messages, :second_name, :string)
  end
end
