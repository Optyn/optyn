class CreateTemplateUrls < ActiveRecord::Migration
  def change
    create_table :template_urls do |t|
      t.text :orginal_url
      t.text :optyn_url
      t.timestamps
    end
  end
end
