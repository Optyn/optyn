class AddStatsToFileImports < ActiveRecord::Migration
  def change
    add_column(:file_imports, :stats, :text)
  end
end
