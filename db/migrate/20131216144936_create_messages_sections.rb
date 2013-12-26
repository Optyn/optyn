class CreateMessagesSections < ActiveRecord::Migration
  def change
    create_table :messages_sections do |t|
      t.references :message
      t.references :section
      t.integer :position
      t.text :content

      t.timestamps
    end

    add_index(:messages_sections, [:message_id, :section_id])
  end
end
