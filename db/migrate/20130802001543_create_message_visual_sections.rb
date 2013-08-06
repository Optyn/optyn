class CreateMessageVisualSections < ActiveRecord::Migration
  def change
    create_table :message_visual_sections do |t|
      t.string :name

      t.timestamps
    end
  end
end
