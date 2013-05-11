class CreateMessageFolders < ActiveRecord::Migration
  def change
    create_table :message_folders do |t|
      t.string   :name

      t.timestamps
    end
  end
end
