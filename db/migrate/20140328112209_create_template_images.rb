class CreateTemplateImages < ActiveRecord::Migration
  def change
    create_table :template_images do |t|
      t.string :image
      t.string :title
      t.integer :template_id

      t.timestamps
    end
  end
end
