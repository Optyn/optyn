class CreateTemplateUploads < ActiveRecord::Migration
  def change
    create_table :template_uploads do |t|
      t.text :template_html_file
      t.references :manager
      t.references :template
      t.timestamps
    end
  end
end
