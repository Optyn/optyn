class CreateFileImports < ActiveRecord::Migration
  def change
    create_table :file_imports do |t|
    	t.string :csv_file
    	t.references :manager

      t.timestamps
    end
  end
end
