class RenameColumnSesMessageIdForMessageEmailAuditors < ActiveRecord::Migration
  def up
    remove_index(:message_email_auditors, :ses_message_id)
    rename_column(:message_email_auditors, :ses_message_id, :message_smtp_id)
    add_index(:message_email_auditors, :message_smtp_id, unique: true)
  end

  def down
    remove_index(:message_email_auditors, :message_smtp_id)
    rename_column(:message_email_auditors, :message_smtp_id, :ses_message_id)
    add_index(:message_email_auditors, :ses_message_id, unique: true)
  end
end
