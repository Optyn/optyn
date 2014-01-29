class SelfEmailSender
  include Sidekiq::Worker
  sidekiq_options :queue => :general_queue, :backtrace => true

  def perform(message_id)
    message = Message.find(message_id)
    manager = Manager.find(message.manager_id)
    if message.instance_of?(TemplateMessage)
      MessageMailer.send_template(message, manager).deliver
    else
      MessageMailer.send_announcement(message, manager).deliver
    end
  end

end