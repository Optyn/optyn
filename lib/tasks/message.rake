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
  task :make_bounced_or_complaint_connections_inactive do
    message_email_auditors = MessageEmailAuditor.bounced_or_complains
    message_email_auditors.each do |audit_entry|
      Connection.mark_inactive_bounce_or_complaint(audit_entry)
    end
  end
end