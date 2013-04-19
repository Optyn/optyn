class CreateMessageEmailAuditors < ActiveRecord::Migration
  def change
    create_table :message_email_auditors do |t|
      t.references :message_user
      t.boolean :delivered

      t.timestamps
    end
  end
end
