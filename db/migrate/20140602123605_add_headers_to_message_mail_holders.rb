class AddHeadersToMessageMailHolders < ActiveRecord::Migration
  def change
  	add_column :message_mail_holders, :headers, :text
  end
end
