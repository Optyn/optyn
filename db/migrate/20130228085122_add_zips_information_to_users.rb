class AddZipsInformationToUsers < ActiveRecord::Migration
  
  def up
    add_column :users, :office_zip_code, :string
    add_column :users, :home_zip_code, :string
    add_column :users, :zip_prompted, :boolean
  end

  def down
  	remove_column :users, :office_zip_code
    remove_column :users, :home_zip_code
    remmove_column :users, :zip_prompted
  end

end
