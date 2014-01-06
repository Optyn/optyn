class AddSendOnAndSubjectToMessageChangeNotifiers < ActiveRecord::Migration
  def change
    add_column(:message_change_notifiers, :subject, :string)
    add_column(:message_change_notifiers, :send_on, :datetime)
  end
end
