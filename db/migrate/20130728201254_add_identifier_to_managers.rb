class AddIdentifierToManagers < ActiveRecord::Migration
  def change
    add_column(:managers, :uuid, :string)
    add_index(:managers, :uuid, unique: true)
  end
end
