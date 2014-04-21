class AddErrorToFileImport < ActiveRecord::Migration
  def change
  	add_column :file_imports, :error, :string
  end
end
