class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.references :shop
      t.string :name
      t.boolean :system_generated, default: false

      t.timestamps
    end
  end
end
