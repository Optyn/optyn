class AddColumnToUsers < ActiveRecord::Migration
  
  def up
    add_column :users, :office_zip_code, :string
    add_column :users, :home_zip_code, :string
  end

  def down
  end

end
