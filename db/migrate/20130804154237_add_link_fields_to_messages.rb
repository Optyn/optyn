class AddLinkFieldsToMessages < ActiveRecord::Migration
  def change
  	add_column(:messages, :button_url, :string, :limit => "2303")
  	add_column(:messages, :button_text, :string, :limit => "1000")	
  end
end
