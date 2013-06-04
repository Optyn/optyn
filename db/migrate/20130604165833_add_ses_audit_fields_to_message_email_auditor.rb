class AddSesAuditFieldsToMessageEmailAuditor < ActiveRecord::Migration
  def change
    add_column(:message_email_auditors, :ses_message_id, :string)
    add_column(:message_email_auditors, :bounced, :boolean)
    add_column(:message_email_auditors, :complaint, :boolean)
    add_column(:message_email_auditors, :body, :text)

    add_index(:message_email_auditors, :ses_message_id, unique: true)
  end
end
