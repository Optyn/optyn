class AddTextPartBodyAndHtmlPartBodyToMessageMailHolders < ActiveRecord::Migration
  def change
    add_column(:message_mail_holders, :text_part_body, :text)
    add_column(:message_mail_holders, :html_part_body, :text)
  end
end
