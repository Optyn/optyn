class CreateMessageImages < ActiveRecord::Migration
  def change
    create_table :message_images do |t|		
      t.references  "message"
	  t.string   "title"
	  t.string "image"
      t.timestamps
    end
  end
end
