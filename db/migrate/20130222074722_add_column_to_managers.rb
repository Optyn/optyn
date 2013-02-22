class AddColumnToManagers < ActiveRecord::Migration
  def up
    add_column :managers,:name,:string
  end
end
