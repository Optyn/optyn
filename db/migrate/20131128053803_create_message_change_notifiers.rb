class CreateMessageChangeNotifiers < ActiveRecord::Migration
  def change
    create_table :message_change_notifiers do |t|
      t.references :message, :index => true
      t.string :uuid
      t.text :content
      t.text :rejection_comment

      t.timestamps
    end
  end
end