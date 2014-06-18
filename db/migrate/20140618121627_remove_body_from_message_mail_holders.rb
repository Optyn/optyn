class RemoveBodyFromMessageMailHolders < ActiveRecord::Migration
  def up
    remove_column(:message_mail_holders, :body)
  end

  def down
    add_column(:message_mail_holders, :body, :text)
  end
end
