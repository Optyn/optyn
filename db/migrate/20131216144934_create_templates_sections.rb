class CreateTemplatesSections < ActiveRecord::Migration
  def change
    create_table :templates_sections do |t|
      t.references :template
      t.references :section
      t.integer :position

      t.timestamps
    end

    add_index(:templates_sections, [:template_id, :section_id])
  end
end
