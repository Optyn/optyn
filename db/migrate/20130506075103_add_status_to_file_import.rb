class AddStatusToFileImport < ActiveRecord::Migration
  def change
    add_column(:file_imports, :status, :string)
  end
end
