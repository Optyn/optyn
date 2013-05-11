class CreateMessageLabels < ActiveRecord::Migration
  def change
    create_table :message_labels do |t|
      t.references :label
      t.references :message

      t.timestamps
    end
  end
end
