class AddLabelToFileImports < ActiveRecord::Migration
  def change
    add_column(:file_imports, :label, :string, default: 'Import')
  end
end
