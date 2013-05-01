class CreateImportUsers < ActiveRecord::Migration
  def change
    create_table :import_users do |t|
    	t.string :csv_file
    	t.references :manager

      t.timestamps
    end
  end
end
