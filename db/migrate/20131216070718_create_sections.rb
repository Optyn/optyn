class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :section_type
      t.text :content
      t.boolean :addable, default: true

      t.timestamps
    end
  end
end
