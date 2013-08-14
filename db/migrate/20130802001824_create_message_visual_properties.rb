class CreateMessageVisualProperties < ActiveRecord::Migration
  def change
    create_table :message_visual_properties do |t|
      t.references :message
      t.references :message_visual_section
      t.string :property_key
      t.text :property_value

      t.timestamps
    end

    add_index(:message_visual_properties, [:message_id, :message_visual_section_id], name: "join_table_index")
  end
end
