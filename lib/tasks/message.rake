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

  desc "Task to add Redemption Instructions to existing Coupon Messages"
  task :add_redemption_instructions => :environment do

    message_discount_type_text = Proc.new { |message| amount = message.sanitized_discount_amount
      message.percentage_off? ? (amount.to_s + "%") : number_to_currency(amount, precision: (amount.to_s.include?(".") ? 2 : 0)) }

    formatted_message_form_datetime = Proc.new { |message, attr| message.send(attr.to_s.to_sym).strftime('%m/%d/%Y %I:%M %p %Z') }

    old_instructions = Proc.new { |message| "Just bring or show this email to #{message.shop_name} "\
      "(print out or show it on your iPhone) and bamm, you got yourself an awesome "\
      "#{message_discount_type_text.call(message)} off at #{message.shop_name}.\n\n\n"\
      "How awesome is that? Go ahead and hurry"\
      "#{"before it expires on #{formatted_message_form_datetime.call(message, 'ending')}" if message.ending.present?}." }

    CouponMessage.all.each do |message|
      if message.redemption_instructions.blank?
        message.redemption_instructions = old_instructions.call(message)
        message.save(:validate => false)
      end
    end
  end
end