class CreateMessageMailHolders < ActiveRecord::Migration
  def change
    create_table :message_mail_holders do |t|
      t.references :message_email_auditor
      t.string :to
      t.string :from
      t.string :reply_to
      t.string :subject, limit: 1000
      t.string :content_type
      t.text :body

      t.timestamps
    end
  end
end