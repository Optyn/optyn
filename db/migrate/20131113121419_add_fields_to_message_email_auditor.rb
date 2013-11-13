class AddFieldsToMessageEmailAuditor < ActiveRecord::Migration
  def change
    add_column :message_email_auditors, :email_to, :string
    add_column :message_email_auditors, :message_id, :integer
    add_index :message_email_auditors, :message_id
  end
end
