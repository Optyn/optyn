class CreateStylesheets < ActiveRecord::Migration
  def change
    create_table :stylesheets do |t|
      t.references :template
      t.string :name
      t.string :location, limit: 1000

      t.timestamps
    end
  end
end
