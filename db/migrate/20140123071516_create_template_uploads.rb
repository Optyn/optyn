class CreateTemplateUploads < ActiveRecord::Migration
  def change
    create_table :template_uploads do |t|
      t.string :template_html_file
      t.references :manager
      t.references :template
      t.timestamps
    end
  end
end
