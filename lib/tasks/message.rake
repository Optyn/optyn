namespace :message do
  desc "Add the header message section"
  task :header_message_visual_section => :environment do
    MessageVisualSection.find_or_create_by_name('Header')
  end

  desc "Add the header message section"
  task :footer_message_visual_section => :environment do
    MessageVisualSection.find_or_create_by_name('Footer')
  end

  desc "Mark the connections whose emails were marked as bounced or complaint as inactive"
  task :make_bounced_or_complaint_connections_inactive => :environment do
    message_email_auditors = MessageEmailAuditor.bounced_or_complains
    message_email_auditors.each do |audit_entry|
      Connection.mark_inactive_bounce_or_complaint(audit_entry)
    end
  end

  desc "Populate missing message_id for existing MessageEmailAuditor records"
  task :populate_message_id_to_message_email_auditors => :environment do
    MessageEmailAuditor.all.each do |message_email_audit|
      if message_email_audit.message_id.nil? and message_email_audit.message_user
        message_email_audit.message_id = message_email_audit.message_user.message.id
        message_email_audit.save
      end
    end
  end

  desc "Task to invoke the batch send of messages"
  task :batch_send => :environment do
    Message.batch_send
  end

  desc "Task to update the 'from' field of messages email@optyn.com -> email@optynmail.com"
  task :update_from_to_optyn_mail => :environment do
    messages = Message.with_state([:queued, :draft])
    messages.each do |message|
      if message.partner.optyn?
        message.from = message.send(:canned_from)
        message.save(validate: false)
      end
    end
  end

  desc "Task to populate the new greeting field for all sent/queued messages"
  task :populate_greetings => :environment do
    messages = Message.where("state != ? and greeting is NULL", 'draft')
    messages.each do |message|
      message.update_attribute(:greeting, message.generate_greeting) 
    end
  end
end